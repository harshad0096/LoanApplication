import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:usersideloanapp/Appbar/quickloan_appbar.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final dobController = TextEditingController();
  final addressController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final AuthService _authService = AuthService();

  bool loading = false;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  String employmentType = "Salaried";

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    dobController.dispose();
    addressController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  // ======================================================
  // 🚀 SIGNUP (PRODUCTION)
  // ======================================================
  Future<void> signUp() async {
    if (!_formKey.currentState!.validate()) return;

    // ✅ convert DOB safely
    try {
      final parts = dobController.text.split("/");
      final dobDate = DateTime(
        int.parse(parts[2]),
        int.parse(parts[1]),
        int.parse(parts[0]),
      );

      setState(() => loading = true);

      final result = await _authService.signUp(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        name: nameController.text.trim(),
        phone: phoneController.text.trim(),
        dob: dobDate,
        address: addressController.text.trim(),
        employmentType: employmentType,
      );

      if (!mounted) return;
      setState(() => loading = false);

      if (result == null) {
        await _showVerifyDialog();
      } else {
        _showSnack(result);
      }
    } catch (e) {
      setState(() => loading = false);
      _showSnack("Invalid date of birth.");
    }
  }

  // ======================================================
  Future<void> _showVerifyDialog() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Verify Your Email"),
        content: const Text(
          "Verification link sent to your email.\n\n"
          "After verifying, click VERIFY.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              bool verified = await _authService.checkEmailVerified();

              if (!mounted) return;

              if (verified) {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, "/role");
              } else {
                _showSnack("Email not verified yet");
              }
            },
            child: const Text("VERIFY"),
          ),
        ],
      ),
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // ======================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: QuickLoanAppBar(
          isMobile: MediaQuery.of(context).size.width < 900,
        ),
      ),
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
  Widget _webView() {
    return Row(
      children: [
        Expanded(flex: 2, child: _gradientSection()),
        Expanded(
          flex: 3,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: _signupCard(width: 520, isWeb: true),
            ),
          ),
        ),
      ],
    );
  }

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
              child: _signupCard(width: double.infinity, isWeb: false),
            ),
          ],
        ),
      ),
    );
  }

  // ======================================================
  Widget _gradientSection({bool isMobile = false}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 60 : 80,
        horizontal: isMobile ? 20 : 60,
      ),
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
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 30),
          Text(
            "Create Your\nAccount",
            style: TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ======================================================
  Widget _signupCard({required double width, required bool isWeb}) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 600),
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
              "Create Account",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            isWeb
                ? Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: _formFields(isWeb),
                  )
                : Column(children: _formFields(isWeb)),
            const SizedBox(height: 24),
            loading
                ? const CircularProgressIndicator()
                : SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: signUp,
                      child: const Text("Sign Up"),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  // ======================================================
  List<Widget> _formFields(bool isWeb) {
    double fieldWidth = isWeb ? 260 : double.infinity;

    return [
      SizedBox(
        width: fieldWidth,
        child: _input(nameController, "Full Name", Icons.person),
      ),
      SizedBox(
        width: fieldWidth,
        child: _input(emailController, "Email", Icons.email_outlined),
      ),
      SizedBox(
        width: fieldWidth,
        child: _input(phoneController, "Phone Number", Icons.phone),
      ),

      // ✅ DOB picker
      SizedBox(
        width: fieldWidth,
        child: TextFormField(
          controller: dobController,
          readOnly: true,
          decoration: InputDecoration(
            labelText: "Date of Birth",
            prefixIcon: const Icon(Icons.calendar_today),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          validator: (v) =>
              v == null || v.isEmpty ? "Date of Birth is required" : null,
          onTap: () async {
            DateTime? picked = await showDatePicker(
              context: context,
              initialDate: DateTime(2000),
              firstDate: DateTime(1950),
              lastDate: DateTime.now(),
            );
            if (picked != null) {
              dobController.text =
                  "${picked.day}/${picked.month}/${picked.year}";
            }
          },
        ),
      ),

      SizedBox(
        width: fieldWidth,
        child: _input(addressController, "Address", Icons.home),
      ),

      SizedBox(
        width: fieldWidth,
        child: DropdownButtonFormField<String>(
          value: employmentType,
          decoration: InputDecoration(
            labelText: "Employment Type",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          items: const [
            DropdownMenuItem(value: "Salaried", child: Text("Salaried")),
            DropdownMenuItem(
              value: "Self Employed",
              child: Text("Self Employed"),
            ),
          ],
          onChanged: (v) => setState(() => employmentType = v!),
        ),
      ),

      SizedBox(
        width: fieldWidth,
        child: _passwordField(
          controller: passwordController,
          label: "Password",
          obscure: obscurePassword,
          toggle: () => setState(() => obscurePassword = !obscurePassword),
        ),
      ),

      SizedBox(
        width: fieldWidth,
        child: _passwordField(
          controller: confirmPasswordController,
          label: "Confirm Password",
          obscure: obscureConfirmPassword,
          toggle: () =>
              setState(() => obscureConfirmPassword = !obscureConfirmPassword),
          validator: (v) =>
              v != passwordController.text ? "Passwords do not match" : null,
        ),
      ),
    ];
  }

  // ======================================================
  Widget _input(TextEditingController controller, String label, IconData icon) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (v) {
        if (v == null || v.trim().isEmpty) {
          return "$label is required";
        }

        if (label == "Email" &&
            !RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) {
          return "Enter valid email";
        }

        if (label == "Phone Number" && !RegExp(r'^[6-9]\d{9}$').hasMatch(v)) {
          return "Enter valid 10-digit mobile number";
        }

        return null;
      },
    );
  }

  // ======================================================
  Widget _passwordField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required VoidCallback toggle,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator ??
          (v) => v == null || v.length < 8
              ? "Minimum 8 characters required"
              : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
          onPressed: toggle,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
