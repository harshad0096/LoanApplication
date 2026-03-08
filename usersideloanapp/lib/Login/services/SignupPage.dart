import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:usersideloanapp/Appbar/quickloan_appbar.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPage();
}

class _SignupPage extends State<SignupPage> {
  final AuthService _authService = AuthService();
  final PageController _pageController = PageController();

  String? selectedGender;
  int currentStep = 0;
  bool loading = false;

  // STEP 1
  final firstNameController = TextEditingController();
  final middleNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final dobController = TextEditingController();
  final addressController = TextEditingController();

  // STEP 2
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  // STEP 3
  String employmentType = "Salaried";
  final incomeController = TextEditingController();

  // STEP 4
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  double get progress => (currentStep + 1) / 4;

  // =========================================================
  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  // =========================================================
  bool validateCurrentStep() {
    switch (currentStep) {
      case 0:
        if (firstNameController.text.trim().isEmpty) {
          showError("First Name required");
          return false;
        }

        if (lastNameController.text.trim().isEmpty) {
          showError("Last Name required");
          return false;
        }

        if (dobController.text.isEmpty) {
          showError("Date of Birth required");
          return false;
        }

        if (addressController.text.trim().isEmpty) {
          showError("Address required");
          return false;
        }

        return true;

      case 1:
        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
            .hasMatch(emailController.text.trim())) {
          showError("Enter valid email");
          return false;
        }

        if (!RegExp(r'^[0-9]{10}$').hasMatch(phoneController.text.trim())) {
          showError("Enter valid 10 digit phone number");
          return false;
        }

        return true;

      case 2:
        if (employmentType.isEmpty) {
          showError("Select employment type");
          return false;
        }

        if (incomeController.text.isEmpty) {
          showError("Enter yearly income");
          return false;
        }

        return true;

      case 3:
        if (passwordController.text.length < 8) {
          showError("Password must be minimum 8 characters");
          return false;
        }

        if (passwordController.text != confirmPasswordController.text) {
          showError("Passwords do not match");
          return false;
        }

        return true;
    }

    return false;
  }

  // =========================================================
  Future<void> signUp() async {
    if (loading) return;

    if (!validateCurrentStep()) return;

    final parts = dobController.text.split("/");

    final dobDate = DateTime(
      int.parse(parts[2]),
      int.parse(parts[1]),
      int.parse(parts[0]),
    );

    setState(() => loading = true);

    final fullName = [
      firstNameController.text.trim(),
      middleNameController.text.trim(),
      lastNameController.text.trim(),
    ].where((name) => name.isNotEmpty).join(" ");

    final result = await _authService.signUp(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
      name: fullName,
      phone: phoneController.text.trim(),
      dob: dobDate,
      address: addressController.text.trim(),
      employmentType: employmentType,
    );

    setState(() => loading = false);

    if (result == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Signup Success")));

      Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);
    } else {
      showError(result);
    }
  }

  // =========================================================
  void nextStep() {
    if (!validateCurrentStep()) return;

    if (currentStep < 3) {
      setState(() => currentStep++);

      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      signUp();
    }
  }

  void previousStep() {
    if (currentStep == 0) return;

    setState(() => currentStep--);

    _pageController.previousPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  // =========================================================
  @override
  void dispose() {
    firstNameController.dispose();
    middleNameController.dispose();
    lastNameController.dispose();
    dobController.dispose();
    addressController.dispose();
    emailController.dispose();
    phoneController.dispose();
    incomeController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  // =========================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: QuickLoanAppBar(
          isMobile: MediaQuery.of(context).size.width < 900,
        ),
      ),
      resizeToAvoidBottomInset: true,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return constraints.maxWidth < 900 ? _mobileView() : _webView();
        },
      ),
    );
  }

  // =========================================================
  Widget _webView() {
    return Row(
      children: [
        Expanded(flex: 2, child: _gradientSection()),
        Expanded(
          flex: 3,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: _signupCard(width: 520),
            ),
          ),
        ),
      ],
    );
  }

  Widget _mobileView() {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            _gradientSection(isMobile: true),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _signupCard(width: double.infinity),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
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

  // =========================================================
  Widget _signupCard({required double width}) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.grey.shade300, blurRadius: 24),
        ],
      ),
      child: Column(
        children: [
          const Text(
            "Create Account",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: Colors.grey.shade300,
            valueColor: const AlwaysStoppedAnimation(Color(0xff7F00FF)),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 260,
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                step1(),
                step2(),
                step3(),
                step4(),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (currentStep > 0)
                TextButton(
                  onPressed: previousStep,
                  child: const Text("Back"),
                ),
              ElevatedButton(
                onPressed: nextStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff7F00FF),
                ),
                child: Text(currentStep == 3 ? "Sign Up" : "Next"),
              ),
            ],
          ),
          if (loading)
            const Padding(
              padding: EdgeInsets.only(top: 20),
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }

  // =========================================================
  Widget step1() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
                child: _field(firstNameController, "First Name", Icons.person)),
            const SizedBox(width: 10),
            Expanded(
                child: _field(lastNameController, "Last Name", Icons.person)),
          ],
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: selectedGender,
          decoration: InputDecoration(
            labelText: "Gender",
            prefixIcon: const Icon(Icons.wc),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          items: ["Male", "Female", "Other"]
              .map((g) => DropdownMenuItem(value: g, child: Text(g)))
              .toList(),
          onChanged: (v) => setState(() => selectedGender = v),
        ),
        const SizedBox(height: 12),
        _dobField(),
        const SizedBox(height: 12),
        _field(addressController, "Address", Icons.home),
      ],
    );
  }

  Widget step2() {
    return Column(
      children: [
        _field(emailController, "Email", Icons.email),
        const SizedBox(height: 12),
        TextFormField(
          controller: phoneController,
          keyboardType: TextInputType.phone,
          maxLength: 10,
          decoration: InputDecoration(
            labelText: "Phone",
            prefixIcon: const Icon(Icons.phone),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  Widget step3() {
    return Column(
      children: [
        DropdownButtonFormField<String>(
          value: employmentType,
          decoration: InputDecoration(
            labelText: "Employment Type",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          items: const [
            DropdownMenuItem(value: "Salaried", child: Text("Salaried")),
            DropdownMenuItem(
                value: "Self Employed", child: Text("Self Employed")),
          ],
          onChanged: (v) => setState(() => employmentType = v!),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: incomeController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: "Income Per Year (₹)",
            prefixIcon: const Icon(Icons.currency_rupee),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget step4() {
    return Column(
      children: [
        _passwordField(passwordController, "Password", obscurePassword, () {
          setState(() => obscurePassword = !obscurePassword);
        }),
        const SizedBox(height: 12),
        _passwordField(confirmPasswordController, "Confirm Password",
            obscureConfirmPassword, () {
          setState(() => obscureConfirmPassword = !obscureConfirmPassword);
        }),
      ],
    );
  }

  // =========================================================
  Widget _field(TextEditingController controller, String label, IconData icon) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _dobField() {
    return TextFormField(
      controller: dobController,
      readOnly: true,
      decoration: InputDecoration(
        labelText: "Date of Birth",
        prefixIcon: const Icon(Icons.calendar_today),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onTap: () async {
        DateTime? picked = await showDatePicker(
          context: context,
          initialDate: DateTime(2000),
          firstDate: DateTime(1950),
          lastDate: DateTime.now(),
        );

        if (picked != null) {
          dobController.text = "${picked.day}/${picked.month}/${picked.year}";
        }
      },
    );
  }

  Widget _passwordField(
    TextEditingController controller,
    String label,
    bool obscure,
    VoidCallback toggle,
  ) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
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
