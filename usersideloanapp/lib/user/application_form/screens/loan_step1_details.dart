import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:usersideloanapp/user/layouts/loan_flow_shell.dart';
import '../providers/loan_provider.dart';
import '../widgets/emi_preview_card.dart';
import '../widgets/eligibility_meter.dart' hide EmiPreviewCard;

class LoanStep1Details extends StatefulWidget {
  final String loanName;

  const LoanStep1Details({
    super.key,
    required this.loanName,
  });

  @override
  State<LoanStep1Details> createState() => _LoanStep1DetailsState();
}

class _LoanStep1DetailsState extends State<LoanStep1Details>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final amountController = TextEditingController();

  int tenure = 24;
  bool _loading = false;

  late AnimationController _animController;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    loadPolicy();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fade = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );

    _animController.forward();

    // ✅ SAFE PROVIDER PREFILL
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final loan = context.read<LoanProvider>();

      if (widget.loanName.isNotEmpty) {
        loan.setLoanType(widget.loanName);
      }

      amountController.text = loan.amount.toStringAsFixed(0);
      tenure = loan.tenure;
      setState(() {});
    });
  }

  @override
  void dispose() {
    amountController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> loadPolicy() async {
    final provider = context.read<LoanProvider>();

    final policies = await provider.fetchPolicy();

    if (policies.isNotEmpty) {
      final policy = policies[0]; // pick the first policy
      print('Interest: ${policy['interest']}');
      print('Max Amount: ${policy['maxAmount']}');
    } else {
      print('No policies found');
    }
  }

  // =========================================================
  // ✅ CONTINUE
  // =========================================================
  Future<void> _continue() async {
    if (!_formKey.currentState!.validate()) return;
    if (_loading) return;

    setState(() => _loading = true);

    context.read<LoanProvider>().setBasicDetails(
          amount: double.parse(amountController.text),
          tenure: tenure,
        );

    await Future.delayed(const Duration(milliseconds: 200));

    if (mounted) {
      Navigator.pushNamed(context, '/loan-step2');
    }

    setState(() => _loading = false);
  }

  // =========================================================
  // BUILD
  // =========================================================
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 900;

    return LoanFlowShell(
      child: Scaffold(
        backgroundColor: const Color(0xffF6F7FB),
        appBar: AppBar(
          elevation: 0,
          title: Text(
            widget.loanName.isNotEmpty
                ? "Apply for ${widget.loanName}"
                : "Loan Details",
          ),
          centerTitle: true,
        ),
        body: FadeTransition(
          opacity: _fade,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(isMobile ? 16 : 28),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: isMobile ? _buildMobileLayout() : _buildDesktopLayout(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // =========================================================
  // 📱 MOBILE LAYOUT
  // =========================================================
  Widget _buildMobileLayout() {
    return Column(
      children: [
        _loanFormCard(),
        const SizedBox(height: 20),
        const EmiPreviewCard(),
        const SizedBox(height: 16),
        const EligibilityMeter(),
      ],
    );
  }

  // =========================================================
  // 🖥️ DESKTOP LAYOUT
  // =========================================================
  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 2, child: _loanFormCard()),
        const SizedBox(width: 24),
        const Expanded(
          child: Column(
            children: [
              EmiPreviewCard(),
              SizedBox(height: 16),
              EligibilityMeter(),
            ],
          ),
        ),
      ],
    );
  }

  // =========================================================
  // 🧾 FORM CARD (MAIN UI)
  // =========================================================
  Widget _loanFormCard() {
    return Container(
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
                "Loan Amount",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 18),

              // ✅ AMOUNT FIELD
              TextFormField(
                controller: amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: InputDecoration(
                  labelText: "Loan Amount",
                  prefixText: "₹ ",
                  filled: true,
                  fillColor: const Color(0xffF5F7FF),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return "Enter loan amount";
                  }
                  final parsed = double.tryParse(v);
                  if (parsed == null) return "Invalid amount";
                  if (parsed < 10000) return "Minimum ₹10,000";
                  return null;
                },
                onChanged: (v) {
                  final parsed = double.tryParse(v);
                  if (parsed != null) {
                    context.read<LoanProvider>().setAmount(parsed);
                  }
                },
              ),

              const SizedBox(height: 20),

              // ✅ TENURE
              DropdownButtonFormField<int>(
                value: tenure,
                decoration: InputDecoration(
                  labelText: "Tenure",
                  filled: true,
                  fillColor: const Color(0xffF5F7FF),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: 6, child: Text("6 Months")),
                  DropdownMenuItem(value: 12, child: Text("12 Months")),
                  DropdownMenuItem(value: 24, child: Text("24 Months")),
                  DropdownMenuItem(value: 36, child: Text("36 Months")),
                  DropdownMenuItem(value: 60, child: Text("60 Months")),
                ],
                onChanged: (v) {
                  if (v == null) return;
                  setState(() => tenure = v);
                  context.read<LoanProvider>().setTenure(v);
                },
              ),

              const SizedBox(height: 32),

              // ✅ CONTINUE BUTTON
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
    );
  }
}
