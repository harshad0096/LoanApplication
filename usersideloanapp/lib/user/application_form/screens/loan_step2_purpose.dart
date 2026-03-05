import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:usersideloanapp/user/layouts/loan_flow_shell.dart';
import '../providers/loan_provider.dart';

class LoanStep2Purpose extends StatefulWidget {
  const LoanStep2Purpose({super.key});

  @override
  State<LoanStep2Purpose> createState() => _LoanStep2PurposeState();
}

class _LoanStep2PurposeState extends State<LoanStep2Purpose> {
  final purposeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    purposeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LoanFlowShell(
      child: Scaffold(
        appBar: AppBar(title: const Text("Loan Purpose")),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: purposeController,
                  decoration: const InputDecoration(labelText: "Purpose"),
                  validator: (v) =>
                      v == null || v.isEmpty ? "Enter purpose" : null,
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      if (!_formKey.currentState!.validate()) return;

                      context
                          .read<LoanProvider>()
                          .setPurpose(purposeController.text.trim());

                      Navigator.pushNamed(context, '/loan-step3');
                    },
                    child: const Text("Continue"),
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
