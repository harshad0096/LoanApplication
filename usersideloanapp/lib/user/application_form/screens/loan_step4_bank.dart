import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:usersideloanapp/user/layouts/loan_flow_shell.dart';

import '../providers/loan_provider.dart';
import '../models/loan_application_model.dart';
import '../services/loan_service.dart';

class LoanStep4Bank extends StatefulWidget {
  const LoanStep4Bank({super.key});

  @override
  State<LoanStep4Bank> createState() => _LoanStep4BankState();
}

class _LoanStep4BankState extends State<LoanStep4Bank>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final bankController = TextEditingController();
  final accountController = TextEditingController();
  final ifscController = TextEditingController();

  bool isLoading = false;

  late AnimationController _animController;
  late Animation<double> _fade;

  // =======================================================
  // INIT
  // =======================================================
  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fade = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );

    _animController.forward();

    // Prefill bank details from provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final loan = context.read<LoanProvider>();
      bankController.text = loan.bankName;
      accountController.text = loan.accountNumber;
      ifscController.text = loan.ifsc;
    });
  }

  @override
  void dispose() {
    bankController.dispose();
    accountController.dispose();
    ifscController.dispose();
    _animController.dispose();
    super.dispose();
  }

  // =======================================================
  // SUBMIT LOAN
  // =======================================================
  Future<void> submitLoanApplication() async {
    if (!_formKey.currentState!.validate()) return;
    if (isLoading) return;

    try {
      setState(() => isLoading = true);

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not logged in");

      final loan = context.read<LoanProvider>();

      if (loan.loanType.isEmpty) {
        throw Exception("Loan type missing");
      }

      // Save latest bank details
      loan.setBank(
        bankName: bankController.text.trim(),
        accountNumber: accountController.text.trim(),
        ifsc: ifscController.text.trim(),
        bank: '',
        acc: '',
        ifscCode: '',
      );

      final loanId =
          "LN${DateTime.now().millisecondsSinceEpoch}${user.uid.substring(0, 4)}";

      final model = LoanApplicationModel(
        loanId: loanId,
        userId: user.uid,
        userName: user.displayName ?? "User",
        phone: user.phoneNumber ?? "",
        amount: loan.amount,
        tenure: loan.tenure,
        purpose: loan.purpose,
        employerName: loan.employerName,
        employerAddress: loan.employerAddress,
        workExperience: loan.workExperience,
        bankName: loan.bankName,
        accountNumber: loan.accountNumber,
        ifsc: loan.ifsc,
        status: "PENDING",
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        loanType: loan.loanType, // ✅ IMPORTANT
      );

      await LoanService().createLoan(model);

      if (mounted) {
        Navigator.pushReplacementNamed(
          context,
          '/loan-success',
          arguments: loanId,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // =======================================================
  // FIELD
  // =======================================================
  Widget _field({
    required TextEditingController controller,
    required String label,
    TextInputType? type,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: TextFormField(
        controller: controller,
        keyboardType: type,
        validator: (v) => v == null || v.isEmpty ? "$label is required" : null,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: const Color(0xffF5F7FF),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xff6D5DF6)),
          ),
        ),
      ),
    );
  }

  // =======================================================
  // BUILD
  // =======================================================
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    return LoanFlowShell(
      child: Scaffold(
        backgroundColor: const Color(0xffF6F7FB),
        appBar: AppBar(
          elevation: 0,
          title: const Text("Bank Details"),
          centerTitle: true,
        ),
        body: FadeTransition(
          opacity: _fade,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(isMobile ? 16 : 28),
            child: Center(
              child: Container(
                width: isMobile ? double.infinity : 520,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                    )
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Bank Information",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _field(
                        controller: bankController,
                        label: "Bank Name",
                      ),
                      _field(
                        controller: accountController,
                        label: "Account Number",
                        type: TextInputType.number,
                      ),
                      _field(
                        controller: ifscController,
                        label: "IFSC Code",
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : submitLoanApplication,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff6D5DF6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                )
                              : const Text(
                                  "Submit Application →",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
