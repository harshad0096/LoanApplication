import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:usersideloanapp/Login/Login.dart';
import 'package:usersideloanapp/Login/services/RoleBasedHome.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);

    _controller.forward();

    _navigate();
  }

  // ✅ PRODUCTION SAFE NAVIGATION
  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, __, ___) => const RoleBasedHome(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // 🎨 UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xff7F00FF),
              Color(0xffE100FF),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 🔥 LOGO CARD
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 25,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Image.asset(
                    "assets/images/logoloanapp.png",
                    width: 110,
                    height: 110,
                    fit: BoxFit.contain,
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  "QuickLoan",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  "Fast • Secure • Trusted",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 40),

                const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
