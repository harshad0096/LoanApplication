import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:usersideloanapp/Appbar/quickloan_appbar.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final AuthService _authService = AuthService();

  bool loading = false;

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  // ======================================================
  // 🚀 RESET PASSWORD
  // ======================================================
  Future<void> resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    final result = await _authService.resetPassword(
      emailController.text.trim(),
    );

    if (!mounted) return;
    setState(() => loading = false);

    if (result == null) {
      _showSnack("Password reset email sent!");
      Navigator.pop(context);
    } else {
      _showSnack(result);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // ======================================================
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;

    return Scaffold(
      appBar: AppBar(title: QuickLoanAppBar(isMobile: isMobile)),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 900) {
            return _mobileView();
          } else {
            return _webView();
          }
        },
      ),
    );
  }

  // ======================================================
  // 🌐 WEB VIEW
  // ======================================================
  Widget _webView() {
    return Row(
      children: [
        Expanded(flex: 2, child: _gradientSection()),
        Expanded(
          flex: 3,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: _card(width: 480, isWeb: true),
            ),
          ),
        ),
      ],
    );
  }

  // ======================================================
  // 📱 MOBILE VIEW
  // ======================================================
  Widget _mobileView() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          children: [
            _gradientSection(isMobile: true),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _card(width: double.infinity, isWeb: false),
            ),
          ],
        ),
      ),
    );
  }

  // ======================================================
  // 🎨 GRADIENT HEADER (SAME AS SIGNUP)
  // ======================================================
  Widget _gradientSection({bool isMobile = false}) {
    return Container(
      clipBehavior: Clip.hardEdge,
      padding: const EdgeInsets.all(60),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xff7F00FF), Color(0xffE100FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(60),
          bottomRight: Radius.circular(60),
        ),
      ),
      child: Row(
        children: [
          /// LEFT TEXT SECTION WITH SLIDE ANIMATION
          Expanded(
            flex: 5,
            child: TweenAnimationBuilder(
              duration: const Duration(milliseconds: 900),
              tween: Tween<double>(begin: 60, end: 0),
              curve: Curves.easeOut,
              builder: (context, double value, child) {
                return Transform.translate(
                  offset: Offset(0, value),
                  child: Opacity(
                    opacity: value == 0 ? 1 : 0.9,
                    child: child,
                  ),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xff7B61FF), Color(0xffA855F7)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.currency_rupee,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    "QuickLoan",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    "Smart Loans\nfor Smart People",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Get instant personal, home, car and business loans with minimal documentation.",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// RIGHT IMAGE WITH FLOATING ANIMATION
          Expanded(
            flex: 5,
            child: TweenAnimationBuilder(
              tween: Tween<double>(begin: -12, end: 12),
              duration: const Duration(seconds: 3),
              curve: Curves.easeInOut,
              builder: (context, double value, child) {
                return Transform.translate(
                  offset: Offset(0, value),
                  child: child,
                );
              },
              child: Image.asset(
                "assets/images/loan_signup.png",
                height: 320,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ======================================================
  // 🧾 CARD
  // ======================================================
  Widget _card({required double width, required bool isWeb}) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 520),
      width: width,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            const Text(
              "Forgot Password",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            // ✅ EMAIL FIELD
            TextFormField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: "Enter Email",
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return "Email is required";
                }

                if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) {
                  return "Enter valid email";
                }

                return null;
              },
            ),

            const SizedBox(height: 24),

            // ✅ BUTTON
            loading
                ? const CircularProgressIndicator()
                : SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: resetPassword,
                      child: const Text("Send Reset Link"),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
