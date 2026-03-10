import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:usersideloanapp/user/layouts/loan_flow_shell.dart';
import '../providers/loan_provider.dart';

class LoanStep3Employment extends StatefulWidget {
  const LoanStep3Employment({super.key});

  @override
  State<LoanStep3Employment> createState() => _LoanStep3EmploymentState();
}

class _LoanStep3EmploymentState extends State<LoanStep3Employment>
    with SingleTickerProviderStateMixin {
  final employerController = TextEditingController();
  final addressController = TextEditingController();
  final expController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _loading = false;

  late AnimationController _animController;
  late Animation<double> _fade;

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

    // ✅ Prefill from provider (important UX)
    final loan = context.read<LoanProvider>();
    employerController.text = loan.employerName;
    addressController.text = loan.employerAddress;
    expController.text = loan.workExperience;
  }

  @override
  void dispose() {
    employerController.dispose();
    addressController.dispose();
    expController.dispose();
    _animController.dispose();
    super.dispose();
  }

  // =========================================================
  // CONTINUE — BANK SAFE
  // =========================================================
  Future<void> _continue() async {
    if (!_formKey.currentState!.validate()) return;
    if (_loading) return;

    setState(() => _loading = true);

    // ✅ FIXED — correct parameters only
    context.read<LoanProvider>().setEmployment(
          employerName: employerController.text.trim(),
          employerAddress: addressController.text.trim(),
          workExperience: expController.text.trim(),
        );

    await Future.delayed(const Duration(milliseconds: 250));

    if (mounted) {
      Navigator.pushNamed(context, '/loan-step4');
    }

    setState(() => _loading = false);
  }

  // =========================================================
  // BUILD
  // =========================================================
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    return LoanFlowShell(
      child: Scaffold(
        backgroundColor: const Color(0xffF6F7FB),
        appBar: AppBar(
          elevation: 0,
          title: const Text("Employment Details"),
          centerTitle: true,
        ),
        body: FadeTransition(
          opacity: _fade,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Container(
                width: isMobile ? double.infinity : 520,
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: const LinearGradient(
                    colors: [Color(0xff6D5DF6), Color(0xffEC4899)],
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Employment Information",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // ================= EMPLOYER =================
                        TextFormField(
                          controller: employerController,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.organizationName],
                          decoration: _inputDecoration("Employer Name"),
                          validator: (v) => v == null || v.isEmpty
                              ? "Enter employer name"
                              : null,
                        ),

                        const SizedBox(height: 16),

                        // ================= ADDRESS =================
                        TextFormField(
                          controller: addressController,
                          textInputAction: TextInputAction.next,
                          maxLines: 2,
                          decoration: _inputDecoration("Employer Address"),
                          validator: (v) => v == null || v.isEmpty
                              ? "Enter employer address"
                              : null,
                        ),

                        const SizedBox(height: 16),

                        // ================= EXPERIENCE =================
                        TextFormField(
                          controller: expController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9.]')),
                          ],
                          decoration:
                              _inputDecoration("Work Experience (years)"),
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return "Enter experience";
                            }
                            final exp = double.tryParse(v);
                            if (exp == null) return "Invalid value";
                            if (exp < 0) return "Invalid experience";
                            return null;
                          },
                        ),

                        const SizedBox(height: 32),

                        // ================= CONTINUE =================
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _loading ? null : _continue,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xff6D5DF6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: _loading
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    "Continue →",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
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
      ),
    );
  }

  // =========================================================
  // INPUT DECORATION (PREMIUM)
  // =========================================================
  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: const Color(0xffF5F7FF),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }
}
