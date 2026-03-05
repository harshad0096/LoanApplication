import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:usersideloanapp/homepage/Homepage.dart';

import 'package:usersideloanapp/Login/Login.dart';
import 'package:usersideloanapp/Login/services/RoleBasedHome.dart';
import 'package:usersideloanapp/splash_Screen/splashscreen.dart';

import 'package:usersideloanapp/user/application_form/providers/loan_provider.dart';
import 'package:usersideloanapp/user/application_form/screens/loan_step1_details.dart';
import 'package:usersideloanapp/user/application_form/screens/loan_step2_purpose.dart';
import 'package:usersideloanapp/user/application_form/screens/loan_step3_employment.dart';
import 'package:usersideloanapp/user/application_form/screens/loan_step4_bank.dart';
import 'package:usersideloanapp/user/application_form/screens/loan_success_page.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Firebase init error: $e");
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoanProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _initialized = false;
  bool _handlingLink = false;

  @override
  void initState() {
    super.initState();
    _bootstrapApp();
  }

  // =========================================================
  // 🚀 APP BOOTSTRAP
  // =========================================================
  Future<void> _bootstrapApp() async {
    try {
      if (kIsWeb) {
        _handlingLink = true;
        await _handleEmailLink();
        _handlingLink = false;
      }

      await _createUserIfNotExists();
    } catch (e) {
      debugPrint("Bootstrap error: $e");
    }

    if (mounted) {
      setState(() => _initialized = true);
    }
  }

  // =========================================================
  // ✅ EMAIL LINK HANDLER
  // =========================================================
  Future<void> _handleEmailLink() async {
    try {
      final isEmailLink = _auth.isSignInWithEmailLink(Uri.base.toString());

      if (!isEmailLink) return;

      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('emailForSignIn');

      if (email == null) return;

      await _auth.signInWithEmailLink(
        email: email,
        emailLink: Uri.base.toString(),
      );

      await prefs.remove('emailForSignIn');
    } catch (e) {
      debugPrint("Email link error: $e");
    }
  }

  // =========================================================
  // ✅ ENSURE USER PROFILE EXISTS
  // =========================================================
  Future<void> _createUserIfNotExists() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final ref = FirebaseFirestore.instance.collection("users").doc(user.uid);

      final doc = await ref.get();

      if (!doc.exists) {
        await ref.set({
          "uid": user.uid,
          "email": user.email,
          "role": "APPLICANT",
          "isEmailVerified": true,
          "profileCompleted": false,
          "createdAt": FieldValue.serverTimestamp(),
          "updatedAt": FieldValue.serverTimestamp(),
          "lastLoginAt": FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        await ref.collection("notifications").doc("_init").set({
          "createdAt": FieldValue.serverTimestamp(),
        });
      } else {
        await ref.update({
          "lastLoginAt": FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      debugPrint("Create user error: $e");
    }
  }

  // =========================================================
  // 🚀 ROOT ROUTER
  // =========================================================
  Widget _buildRoot() {
    if (!_initialized || _handlingLink) {
      return const SplashScreen();
    }

    return StreamBuilder<User?>(
      stream: _auth.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }

        final user = snapshot.data;

        if (user == null) {
          return const HomePage();
          // return LoginPage(initialRoute: '');
        }

        return const RoleBasedHome();
      },
    );
  }

  // =========================================================
  // 🎨 APP UI
  // =========================================================
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Fintech Pro",
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xffF5F7FB),
        colorSchemeSeed: const Color(0xff6D5DF6),
      ),

      // ✅ ROOT
      home: _buildRoot(),

      // ✅ ROUTES
      routes: {
        '/login': (_) => const LoginPage(initialRoute: ''),
        '/home': (_) => const RoleBasedHome(),

        // 🚀 LOAN FLOW
        '/loan-step1': (_) => const LoanStep1Details(
              loanName: '',
            ),
        '/loan-step2': (_) => const LoanStep2Purpose(),
        '/loan-step3': (_) => const LoanStep3Employment(),
        '/loan-step4': (_) => const LoanStep4Bank(),
        '/loan-success': (context) => const LoanSuccessPage(
              applicationId: '',
            ),
      },
    );
  }
}
