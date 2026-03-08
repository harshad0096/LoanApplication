import 'package:flutter/material.dart';

class EligibilityChecker extends StatefulWidget {
  const EligibilityChecker({super.key});

  @override
  State<EligibilityChecker> createState() => _EligibilityCheckerState();
}

class _EligibilityCheckerState extends State<EligibilityChecker> {
  final incomeController = TextEditingController();
  final loanController = TextEditingController();

  String employmentType = "Salaried";
  String result = "";

  void checkEligibility() {
    double income = double.tryParse(incomeController.text) ?? 0;
    double loan = double.tryParse(loanController.text) ?? 0;

    if (income == 0 || loan == 0) {
      setState(() {
        result = "Please enter valid details.";
      });
      return;
    }

    double maxLoan = income * 20;

    if (loan <= maxLoan) {
      setState(() {
        result = "✅ Congratulations! You are eligible for this loan.";
      });
    } else {
      setState(() {
        result =
            "❌ Requested loan exceeds eligibility. Max allowed: ₹${maxLoan.toStringAsFixed(0)}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    bool isMobile = width < 700;
    bool isTablet = width >= 700 && width < 1100;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 60,
        vertical: 80,
      ),
      color: const Color(0xFFF8FAFC),
      child: Column(
        children: [
          _badge("LOAN ELIGIBILITY", Icons.verified_user),
          const SizedBox(height: 20),
          _sectionHeader("Check Your Loan ", "Eligibility"),
          const SizedBox(height: 50),
          Center(
            child: Container(
              width: isMobile
                  ? double.infinity
                  : isTablet
                      ? 600
                      : 750,
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.05),
                    blurRadius: 25,
                    spreadRadius: 5,
                  )
                ],
              ),
              child: Column(
                children: [
                  /// INCOME FIELD
                  _inputField(
                    controller: incomeController,
                    label: "Monthly Income (₹)",
                    icon: Icons.currency_rupee,
                  ),

                  const SizedBox(height: 20),

                  /// EMPLOYMENT
                  DropdownButtonFormField<String>(
                    value: employmentType,
                    decoration:
                        _inputDecoration("Employment Type", Icons.work_outline),
                    items: const [
                      DropdownMenuItem(
                          value: "Salaried", child: Text("Salaried")),
                      DropdownMenuItem(
                          value: "Self Employed", child: Text("Self Employed")),
                    ],
                    onChanged: (value) {
                      setState(() {
                        employmentType = value!;
                      });
                    },
                  ),

                  const SizedBox(height: 20),

                  /// LOAN FIELD
                  _inputField(
                    controller: loanController,
                    label: "Required Loan Amount (₹)",
                    icon: Icons.account_balance_wallet,
                  ),

                  const SizedBox(height: 30),

                  /// BUTTON
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: checkEligibility,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                        backgroundColor: Colors.transparent,
                      ),
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF7C3AED), Color(0xFF9333EA)],
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: const Text(
                            "Check Eligibility",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  /// RESULT BOX
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: result.contains("Congratulations")
                          ? Colors.green.withOpacity(.1)
                          : Colors.red.withOpacity(.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: result.isEmpty
                        ? const SizedBox()
                        : Text(
                            result,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  /// INPUT FIELD
  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: _inputDecoration(label, icon),
    );
  }

  /// INPUT DECORATION
  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
    );
  }
}

Widget _sectionHeader(String lightText, String highlightText) {
  return RichText(
    textAlign: TextAlign.center,
    text: TextSpan(
      style: const TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w900,
        color: Color(0xFF0F172A),
      ),
      children: [
        TextSpan(text: lightText),
        TextSpan(
          text: highlightText,
          style: const TextStyle(
            color: Color(0xFF9333EA),
          ),
        ),
      ],
    ),
  );
}

Widget _badge(String label, IconData icon) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    decoration: BoxDecoration(
      color: const Color(0xFFF5F3FF),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: const Color(0xFF7C3AED)),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF7C3AED),
            fontWeight: FontWeight.bold,
            fontSize: 11,
            letterSpacing: 1.1,
          ),
        ),
      ],
    ),
  );
}
