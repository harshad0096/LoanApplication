import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:usersideloanapp/Login/Login.dart';
import 'package:usersideloanapp/Login/services/RoleBasedHome.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _handleEmailLink();
    }
  }

  Future<void> _handleEmailLink() async {
    final bool isEmailLink = _auth.isSignInWithEmailLink(Uri.base.toString());

    if (isEmailLink) {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('emailForSignIn');

      if (email != null) {
        await _auth.signInWithEmailLink(
          email: email,
          emailLink: Uri.base.toString(),
        );
        await prefs.remove('emailForSignIn');

        await _createUserIfNotExists();
      }
    }
  }

  Future<void> _createUserIfNotExists() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .get();

    if (!doc.exists) {
      await FirebaseFirestore.instance.collection("users").doc(user.uid).set({
        "email": user.email,
        "role": "APPLICANT", // Default Role
        "createdAt": FieldValue.serverTimestamp(),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StreamBuilder<User?>(
        stream: _auth.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasData) {
            return const RoleBasedHome();
          }

          return const LoginPage();
        },
      ),
    );
  }
}
