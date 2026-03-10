import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:usersideloanapp/user/application_form/models/bank_model.dart';
import 'package:usersideloanapp/user/application_form/screens/loan_success_page.dart';
import 'package:usersideloanapp/user/application_form/services/BankService.dart';
import 'package:usersideloanapp/user/application_form/services/IfscService.dart';
import 'package:usersideloanapp/user/layouts/loan_flow_shell.dart';
import '../providers/loan_provider.dart';

class LoanStep4Bank extends StatefulWidget {
  const LoanStep4Bank({super.key});

  @override
  State<LoanStep4Bank> createState() => _LoanStep4BankState();
}

class _LoanStep4BankState extends State<LoanStep4Bank>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final bankController = TextEditingController();
  final accountHolderController = TextEditingController();
  final accountController = TextEditingController();
  final confirmAccountController = TextEditingController();
  final ifscController = TextEditingController();

  bool isLoading = false;
  bool isVerified = false;

  String branch = "";
  String city = "";
  String state = "";

  final RegExp ifscRegex = RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$');

  /// REALTIME IFSC VERIFICATION
  Future<void> _verifyIfsc(String value) async {
    value = value.toUpperCase();

    if (!ifscRegex.hasMatch(value)) {
      setState(() => isVerified = false);
      return;
    }

    setState(() {
      isLoading = true;
      isVerified = false;
      // CRITICAL: Clear bank when IFSC changes,
      // or set it if your service allows
      bankController.clear();
    });

    final data = await IfscService.fetchDetails(value);

    if (data != null) {
      setState(() {
        // Set the bank name and trigger a rebuild
        bankController.text = data["BANK"] ?? "";
        branch = data["BRANCH"] ?? "";
        city = data["CITY"] ?? "";
        state = data["STATE"] ?? "";
        isVerified = true;
      });
    }

    setState(() => isLoading = false);
  }

  /// SUBMIT APPLICATION
  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    if (!isVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please verify the IFSC code first")),
      );
      return;
    }

    final loan = context.read<LoanProvider>();
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not logged in")),
      );
      return;
    }

    try {
      setState(() => isLoading = true);

      loan.setBank(
        bankName: bankController.text.trim(),
        accountNumber: accountController.text.trim(),
        ifsc: ifscController.text.trim().toUpperCase(),
      );

      final loanId = await loan.submitLoanApplication(
        userId: user.uid,
        userName: user.displayName ?? "User",
        phone: user.phoneNumber ?? "",
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => LoanSuccessPage(applicationId: loanId),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Submission Failed: $e")),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoanFlowShell(
      child: Scaffold(
        backgroundColor: const Color(0xffF6F7FB),
        appBar: AppBar(
          title: const Text("Bank Verification"),
          centerTitle: true,
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  /// animation
                  Lottie.network(
                    'https://assets9.lottiefiles.com/packages/lf20_q5mv0d0i.json',
                    height: 130,
                    // Add this block to prevent the red crash screen
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.account_balance,
                          size: 90, color: Colors.grey);
                    },
                  ),

                  const SizedBox(height: 20),

                  /// main card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(.05),
                          blurRadius: 20,
                        )
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          /// IFSC
                          _textField(
                            controller: ifscController,
                            label: "IFSC Code",
                            icon: Icons.qr_code_scanner,
                            isUpper: true,
                            onChanged: _verifyIfsc,
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return "Enter IFSC Code";
                              }
                              if (!ifscRegex.hasMatch(v)) {
                                return "Invalid IFSC format";
                              }
                              return null;
                            },
                          ),

                          if (isLoading)
                            const Padding(
                              padding: EdgeInsets.only(bottom: 15),
                              child: LinearProgressIndicator(),
                            ),

                          /// Animated IFSC Result
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 400),
                            child:
                                isVerified ? _verifiedCard() : const SizedBox(),
                          ),

                          /// BANK SEARCH
                          _bankSearchField(),

                          /// ACCOUNT HOLDER
                          _textField(
                            controller: accountHolderController,
                            label: "Account Holder Name",
                            icon: Icons.person_outline,
                            validator: (v) =>
                                v!.isEmpty ? "Enter account holder name" : null,
                          ),

                          /// ACCOUNT NUMBER
                          _textField(
                            controller: accountController,
                            label: "Account Number",
                            icon: Icons.account_balance_wallet,
                            isNumber: true,
                            validator: (v) {
                              if (v!.isEmpty) return "Enter account number";
                              if (v.length < 8) return "Invalid account number";
                              return null;
                            },
                          ),

                          /// CONFIRM ACCOUNT
                          _textField(
                            controller: confirmAccountController,
                            label: "Confirm Account Number",
                            icon: Icons.verified_user,
                            isNumber: true,
                            validator: (v) {
                              if (v != accountController.text) {
                                return "Account numbers do not match";
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 25),

                          /// SUBMIT BUTTON
                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              onPressed: _submit,
                              child: const Text("Verify & Submit"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// VERIFIED CARD
  Widget _verifiedCard() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xffEEF2FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.verified, color: Colors.green),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "$branch • $city • $state",
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  /// BANK SEARCH FIELD
  Widget _bankSearchField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: TypeAheadField<BankModel>(
        builder: (context, controller, focusNode) {
          return TextFormField(
            controller: bankController,
            focusNode: focusNode,
            decoration: InputDecoration(
              labelText: "Search Bank",
              prefixIcon: const Icon(Icons.account_balance),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (v) =>
                v == null || v.isEmpty ? "Select your bank" : null,
          );
        },
        suggestionsCallback: (pattern) async {
          return await BankService.searchBanks(pattern);
        },
        itemBuilder: (context, BankModel bank) {
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.white,
              child: SvgPicture.network(
                bank.logo,
                width: 24,
                height: 24,
                placeholderBuilder: (context) => Icon(Icons.account_balance),
              ),
            ),
            title: Text(
              bank.name,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          );
        },
        onSelected: (BankModel bank) {
          bankController.text = bank.name;
        },
      ),
    );
  }

  /// COMMON TEXT FIELD
  Widget _textField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isNumber = false,
    bool isUpper = false,
    Function(String)? onChanged,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        onChanged: onChanged,
        validator: validator ?? (v) => v!.isEmpty ? "Required" : null,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        textCapitalization:
            isUpper ? TextCapitalization.characters : TextCapitalization.none,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
        ),
      ),
    );
  }
}
