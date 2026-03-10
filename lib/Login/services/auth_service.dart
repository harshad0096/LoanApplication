import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // =========================================================
  // 🧠 HELPERS
  // =========================================================

  bool isStrongPassword(String password) {
    final regex =
        RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&]).{8,}$');
    return regex.hasMatch(password);
  }

  bool isAdult(DateTime dob) {
    final today = DateTime.now();
    int age = today.year - dob.year;
    if (today.month < dob.month ||
        (today.month == dob.month && today.day < dob.day)) {
      age--;
    }
    return age >= 18;
  }

  bool isValidPhone(String phone) {
    return RegExp(r'^[6-9]\d{9}$').hasMatch(phone);
  }

  // =========================================================
  // 🔍 CHECK PHONE EXISTS (FINTECH MUST)
  // =========================================================
  Future<bool> _phoneExists(String phone) async {
    final query = await _firestore
        .collection("users")
        .where("phone", isEqualTo: phone)
        .limit(1)
        .get();

    return query.docs.isNotEmpty;
  }

  // =========================================================
  // 🔐 DEVICE INFO (simple production safe)
  // =========================================================
  Map<String, dynamic> _sessionMeta() {
    return {
      "platform": "flutter",
      "loginAt": FieldValue.serverTimestamp(),
    };
  }

  // =========================================================
  // ✅ SIGN UP — BANK LEVEL
  // =========================================================
  Future<String?> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
    required DateTime dob,
    required String address,
    required String employmentType,
  }) async {
    try {
      email = email.trim().toLowerCase();
      phone = phone.trim();

      // 🔐 validations
      if (!isStrongPassword(password)) {
        return "Password must contain upper, lower, number & special character.";
      }

      if (!isAdult(dob)) {
        return "You must be at least 18 years old.";
      }

      if (!isValidPhone(phone)) {
        return "Enter valid 10-digit mobile number.";
      }

      // 🚫 phone duplicate check
      if (await _phoneExists(phone)) {
        return "Mobile number already registered.";
      }

      // 🔹 create auth user
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password.trim(),
      );

      final user = credential.user!;
      await user.sendEmailVerification();

      final userRef = _firestore.collection("users").doc(user.uid);

      // 🔹 transaction safe write
      await _firestore.runTransaction((tx) async {
        tx.set(
            userRef,
            {
              "uid": user.uid,
              "email": email,
              "name": name.trim(),
              "phone": phone,
              "dob": Timestamp.fromDate(dob),
              "address": address.trim(),
              "employmentType": employmentType,
              "role": "APPLICANT",
              "isEmailVerified": false,
              "profileCompleted": true,
              "createdAt": FieldValue.serverTimestamp(),
              "updatedAt": FieldValue.serverTimestamp(),
              "lastLoginAt": FieldValue.serverTimestamp(),
            },
            SetOptions(merge: true));
      });

      // 🔔 create notification root (important for badge)
      await userRef.collection("notifications").doc("_init").set({
        "createdAt": FieldValue.serverTimestamp(),
      });

      return null;
    } on FirebaseAuthException catch (e) {
      return _handleAuthError(e);
    } on TimeoutException {
      return "Request timeout. Check your internet.";
    } catch (e) {
      return "Signup failed. Please try again.";
    }
  }

  // =========================================================
  // ✅ EMAIL VERIFIED CHECK
  // =========================================================
  Future<bool> checkEmailVerified() async {
    await _auth.currentUser?.reload();
    return _auth.currentUser?.emailVerified ?? false;
  }

  // =========================================================
  // ✅ LOGIN — FINTECH SMART
  // =========================================================
  Future<Map<String, dynamic>?> login({
    required String email,
    required String password,
  }) async {
    try {
      email = email.trim().toLowerCase();

      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password.trim(),
      );

      final user = credential.user!;

      // 🚫 block unverified users
      if (!user.emailVerified) {
        await _auth.signOut();
        return {"error": "Please verify your email before login."};
      }

      final docRef = _firestore.collection("users").doc(user.uid);
      final doc = await docRef.get();

      if (!doc.exists) {
        return {"error": "User profile missing."};
      }

      final data = doc.data()!;
      final role = data["role"] ?? "APPLICANT";

      // 🔄 update login metadata
      await docRef.update({
        "isEmailVerified": true,
        "lastLoginAt": FieldValue.serverTimestamp(),
        "lastSession": _sessionMeta(),
      });

      return {
        "uid": user.uid,
        "role": role,
      };
    } on FirebaseAuthException catch (e) {
      return {"error": _handleAuthError(e)};
    } catch (e) {
      return {"error": "Login failed. Try again."};
    }
  }

  // =========================================================
  // 🔁 RESEND VERIFICATION
  // =========================================================
  Future<String?> resendVerificationEmail() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return "User not logged in.";

      await user.sendEmailVerification();
      return null;
    } catch (e) {
      return "Failed to resend email.";
    }
  }

  // =========================================================
  // 🔑 RESET PASSWORD
  // =========================================================
  Future<String?> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return null;
    } on FirebaseAuthException catch (e) {
      return _handleAuthError(e);
    } catch (e) {
      return "Failed to send reset email.";
    }
  }

  // =========================================================
  // 👤 PROFILE STREAM (VERY IMPORTANT FOR FINTECH)
  // =========================================================
  Stream<DocumentSnapshot<Map<String, dynamic>>> userProfileStream() {
    final uid = _auth.currentUser?.uid;
    return _firestore.collection("users").doc(uid).snapshots();
  }

  // =========================================================
  Future<void> logout() async {
    await _auth.signOut();
  }

  // =========================================================
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // =========================================================
  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return "No user found with this email.";
      case 'wrong-password':
        return "Incorrect password.";
      case 'email-already-in-use':
        return "Email already registered.";
      case 'weak-password':
        return "Password is too weak.";
      case 'invalid-email':
        return "Invalid email address.";
      case 'too-many-requests':
        return "Too many attempts. Try later.";
      case 'network-request-failed':
        return "Network error. Check connection.";
      default:
        return e.message ?? "Authentication error.";
    }
  }

  // Save login credentials to SharedPreferences
  Future<void> saveSession(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('uid', data['uid']);
    await prefs.setString('role', data['role']);
    await prefs.setString('email', data['email'] ?? '');
    await prefs.setInt('loginAt', DateTime.now().millisecondsSinceEpoch);
  }

  // Clear session on logout
  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // Get saved session
  Future<Map<String, dynamic>?> getSavedSession() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getString('uid');
    final role = prefs.getString('role');
    final email = prefs.getString('email');

    if (uid != null && role != null) {
      return {'uid': uid, 'role': role, 'email': email};
    }
    return null;
  }
}
