import 'package:flutter/material.dart';
import 'package:usersideloanapp/Login/OTPVerificationPage.dart';
import 'package:usersideloanapp/Login/services/OTPService.dart';
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

  int currentStep = 0;
  bool loading = false;
  final OTPService _otpService = OTPService();

  String verificationId = "";
  final otpController = TextEditingController();

  bool otpSent = false;
  bool otpVerified = false;
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

  // STEP 4
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  double get progress => (currentStep + 1) / 5;

  // =========================================================
  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
  //otp

  // =========================================================
  bool validateCurrentStep() {
    switch (currentStep) {
      // STEP 1
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

        final parts = dobController.text.split("/");

        final dob = DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );

        final age = DateTime.now().year - dob.year;

        if (age < 18) {
          showError("You must be at least 18 years old");
          return false;
        }

        if (addressController.text.trim().isEmpty) {
          showError("Address required");
          return false;
        }

        return true;

      // STEP 2
      case 1:
        if (!RegExp(r'\S+@\S+\.\S+').hasMatch(emailController.text)) {
          showError("Enter valid email");
          return false;
        }

        if (!RegExp(r'^[0-9]{10}$').hasMatch(phoneController.text)) {
          showError("Enter valid 10 digit phone");
          return false;
        }

        return true;

      // STEP 3
      case 2:
        if (!otpVerified) {
          showError("Please verify phone number with OTP");
          return false;
        }

        return true;
      case 3:
        if (employmentType.isEmpty) {
          showError("Select employment type");
          return false;
        }

        return true;

      // STEP 4
      case 4:
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

//otp functiona
  Future<void> sendOTP() async {
    setState(() => loading = true);

    await _otpService.sendOTP(
      phone: "+91${phoneController.text}",
      codeSent: (id) {
        verificationId = id;

        setState(() {
          otpSent = true;
          loading = false;
        });
      },
      error: (msg) {
        showError(msg);
        setState(() => loading = false);
      },
    );
  }

  Future<void> verifyOTP() async {
    if (otpController.text.length != 6) {
      showError("Enter valid OTP");
      return;
    }

    setState(() => loading = true);

    final result = await _otpService.verifyOTP(
      verificationId: verificationId,
      otp: otpController.text.trim(),
    );

    setState(() => loading = false);

    if (result == null) {
      setState(() {
        otpVerified = true;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Phone Verified")));
    } else {
      showError(result);
    }
  }

  // =========================================================
  Future<void> signUp() async {
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
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 60 : 80,
        horizontal: isMobile ? 20 : 60,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xff7F00FF), Color(0xffE100FF)],
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
                color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 30),
          Text(
            "Create Your\nAccount",
            style: TextStyle(
                color: Colors.white, fontSize: 34, fontWeight: FontWeight.bold),
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

          // STEP INDICATOR
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(4, (index) {
              bool active = index <= currentStep;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 34,
                width: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      active ? const Color(0xff7F00FF) : Colors.grey.shade300,
                ),
                child: Center(
                  child: active
                      ? const Icon(Icons.check, color: Colors.white, size: 18)
                      : Text("${index + 1}"),
                ),
              );
            }),
          ),

          const SizedBox(height: 20),

          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.grey.shade300,
              valueColor: const AlwaysStoppedAnimation(Color(0xff7F00FF)),
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            height: 260,
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                // STEP 1
                Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _field(
                            firstNameController,
                            "First Name",
                            Icons.person_outline,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _field(
                            middleNameController,
                            "Middle Name",
                            Icons.person_outline,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _field(
                      lastNameController,
                      "Last Name",
                      Icons.person,
                    ),
                    const SizedBox(height: 12),
                    _dobField(),
                    const SizedBox(height: 12),
                    _field(
                      addressController,
                      "Address",
                      Icons.home,
                    ),
                  ],
                ),

                // STEP 2
                Column(
                  children: [
                    _field(emailController, "Email", Icons.email),
                    const SizedBox(height: 12),
                    _field(phoneController, "Phone", Icons.phone),
                  ],
                ),

                // STEP 3
                Column(
                  children: [
                    if (!otpSent)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: sendOTP,
                          child: const Text("Send OTP"),
                        ),
                      ),
                    if (otpSent) ...[
                      TextField(
                        controller: otpController,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        decoration: InputDecoration(
                          labelText: "Enter OTP",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: verifyOTP,
                          child: const Text("Verify OTP"),
                        ),
                      ),
                      TextButton(
                        onPressed: sendOTP,
                        child: const Text("Resend OTP"),
                      ),
                      if (otpVerified)
                        const Text(
                          "Phone Verified ✓",
                          style: TextStyle(color: Colors.green),
                        ),
                    ],
                  ],
                ),
                DropdownButtonFormField<String>(
                  value: employmentType,
                  decoration: InputDecoration(
                    labelText: "Employment Type",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  items: const [
                    DropdownMenuItem(
                        value: "Salaried", child: Text("Salaried")),
                    DropdownMenuItem(
                        value: "Self Employed", child: Text("Self Employed")),
                  ],
                  onChanged: (v) => setState(() => employmentType = v!),
                ),

                // STEP 4
                Column(
                  children: [
                    _passwordField(
                        passwordController, "Password", obscurePassword, () {
                      setState(() => obscurePassword = !obscurePassword);
                    }),
                    const SizedBox(height: 12),
                    _passwordField(confirmPasswordController,
                        "Confirm Password", obscureConfirmPassword, () {
                      setState(() =>
                          obscureConfirmPassword = !obscureConfirmPassword);
                    }),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (currentStep > 0)
                TextButton(
                  onPressed: () async {
                    if (!validateCurrentStep()) return;

                    // STEP 2 → PHONE OTP VERIFICATION
                    if (currentStep == 1) {
                      final verified = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => OTPVerificationPage(
                            phone: "+91${phoneController.text}",
                          ),
                        ),
                      );

                      // if OTP not verified stop here
                      if (verified != true) return;
                    }

                    if (currentStep < 3) {
                      setState(() => currentStep++);

                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      signUp();
                    }
                  },
                  child: const Text("Back"),
                ),
              ElevatedButton(
                onPressed: () {
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
                },
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

  // =========================================================
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

  // =========================================================
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
