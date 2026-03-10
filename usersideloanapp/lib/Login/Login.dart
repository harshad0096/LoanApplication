import 'package:flutter/material.dart';
import 'package:usersideloanapp/Login/services/RoleBasedHome.dart';
import 'package:usersideloanapp/Login/services/auth_service.dart';
import 'package:usersideloanapp/Login/services/SignupPage.dart';
import 'package:usersideloanapp/Login/services/ForgotPasswordPage.dart';
import 'package:usersideloanapp/Appbar/quickloan_appbar.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required String initialRoute});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool loading = false;
  bool obscurePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  //login function
  Future<void> login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    final result = await _authService.login(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );

    setState(() => loading = false);

    if (result == null || result.containsKey("error")) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result?["error"] ?? "Login failed"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // ✅ Save session for persistent login
    await _authService.saveSession({
      'uid': result['uid'],
      'role': result['role'],
      'email': emailController.text.trim(),
    });

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const RoleBasedHome()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: QuickLoanAppBar(isMobile: false)),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 900) {
            // ================= MOBILE / TABLET VIEW =================
            return mobileView();
          } else {
            // ================= WEB / DESKTOP VIEW =================
            return webView();
          }
        },
      ),
    );
  }

  // ================= WEB VIEW =================
  Widget webView() {
    return Row(
      children: [
        Expanded(flex: 2, child: gradientSection()),
        Expanded(
          flex: 2,
          child: Center(child: loginCard(width: 420, height: 500)),
        ),
      ],
    );
  }

  // ================= MOBILE VIEW =================
  Widget mobileView() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xff7F00FF), Color(0xffE100FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "QuickLoan",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 30),
                Text(
                  "Smart Loans\nfor Smart People",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: loginCard(width: double.infinity, height: 500),
          ),
        ],
      ),
    );
  }

  // ================= GRADIENT SECTION =================
  Widget gradientSection() {
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

//costom card for login page
  Widget buildInfoCards(BuildContext context) {
    Widget buildCard({
      required IconData icon,
      required String text,
      required Color bgColor,
      required Color borderColor,
      required Color iconColor,
    }) {
      return Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 5, // smaller horizontal
            vertical: 3 // smaller height like image
            ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(22), // smooth pill
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 10, color: iconColor), // smaller icon
            const SizedBox(
              width: 3,
            ), // smaller space
            Text(
              text,
              style: TextStyle(
                fontSize: 10, // exact medium size
                fontWeight: FontWeight.w500,
                color: iconColor,
              ),
            ),
          ],
        ),
      );
    }

    return Row(
      children: [
        Wrap(
          spacing: 5, // space between cards
          children: [
            buildCard(
              icon: Icons.shield_outlined,
              text: "RBI Registered",
              bgColor: const Color(0xFFE6F4EA),
              borderColor: const Color(0xFFB7E4C7),
              iconColor: const Color(0xFF1B8F5A),
            ),
            buildCard(
              icon: Icons.auto_awesome_outlined,
              text: "Instant Approval",
              bgColor: const Color(0xFFF1EDFF),
              borderColor: const Color(0xFFD6CCFF),
              iconColor: const Color(0xFF6C63FF),
            ),
            buildCard(
              icon: Icons.star,
              text: "4.8 Rating",
              bgColor: const Color(0xFFFFF4E5),
              borderColor: const Color(0xFFFFD8A8),
              iconColor: const Color(0xFFF59E0B),
            ),
          ],
        ),
      ],
    );
  }

  // ================= LOGIN CARD =================
  Widget loginCard({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(30),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Welcome back!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Sign in with your email to continue",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            //card for RBI registered, instant approval and 4.8 rating
            buildInfoCards(context),
            const SizedBox(height: 10),
            // Email
            TextFormField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: "Email",
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Email is required";
                }
                if (!value.contains("@")) {
                  return "Enter valid email";
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            // Password
            TextFormField(
              controller: passwordController,
              obscureText: obscurePassword,
              decoration: InputDecoration(
                labelText: "Password",
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    obscurePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      obscurePassword = !obscurePassword;
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Password is required";
                }
                if (value.length < 6) {
                  return "Minimum 6 characters required";
                }
                return null;
              },
            ),

            const SizedBox(height: 10),

            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ForgotPasswordPage(),
                    ),
                  );
                },
                child: const Text("Forgot Password?"),
              ),
            ),

            const SizedBox(height: 20),

            loading
                ? const Center(child: CircularProgressIndicator())
                : SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: login,
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xff7F00FF), Color(0xffE100FF)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text(
                            "Login",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),

            const SizedBox(height: 20),

            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SignupPage()),
                  );
                },
                child: const Text("Don't have an account? Sign Up"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
