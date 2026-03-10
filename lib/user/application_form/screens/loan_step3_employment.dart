import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:usersideloanapp/user/layouts/loan_flow_shell.dart';
import '../providers/loan_provider.dart';

class LoanStep3Employment extends StatefulWidget {
  const LoanStep3Employment({super.key});

  @override
  State<LoanStep3Employment> createState() => _LoanStep3EmploymentState();
}

class _LoanStep3EmploymentState extends State<LoanStep3Employment> {
  final _formKey = GlobalKey<FormState>();

  // Unified Controllers (Reused based on employment type)
  final entityNameController = TextEditingController();
  final roleController = TextEditingController();
  final registrationController = TextEditingController();
  final addressController = TextEditingController();

  String _employmentType = 'Salaried';
  double _monthlyIncome = 25000;
  bool _loading = false;

  Future<void> _continue() async {
    // 1. Form Validation
    if (!_formKey.currentState!.validate()) return;

    // 2. Start Loading State
    setState(() => _loading = true);

    try {
      // 3. Save ALL data to Provider
      context.read<LoanProvider>().setEmployment(
            employerName: entityNameController.text.trim(),
            employerAddress:
                addressController.text.trim(), // FIXED: Was addressCtrl
            workExperience: roleController.text.trim(),
            type: _employmentType, // FIXED: Was _type
            income: _monthlyIncome,
            regNo: registrationController.text.trim(),
          );

      // 4. Simulate Network/Database Delay
      await Future.delayed(const Duration(seconds: 1));

      // 5. Navigate to next step
      if (mounted) {
        Navigator.pushNamed(context, '/loan-step4');
      }
    } catch (e) {
      debugPrint("Error saving employment details: $e");
    } finally {
      // 6. Stop loading regardless of success/failure
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoanFlowShell(
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFF),
        appBar: AppBar(
          title: const Text("Employment & Income",
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        body: AnimationLimiter(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: AnimationConfiguration.toStaggeredList(
                  duration: const Duration(milliseconds: 500),
                  childAnimationBuilder: (w) => SlideAnimation(
                      verticalOffset: 30, child: FadeInAnimation(child: w)),
                  children: [
                    _buildEmploymentTypeToggle(),
                    const SizedBox(height: 20),

                    // DYNAMIC FIELDS BASED ON SELECTION
                    _buildDynamicSection(),

                    _buildSectionCard(
                        "Income & Location", Icons.account_balance_wallet, [
                      _buildIncomeSlider(),
                      _buildTextField("Office / Business Address",
                          addressController, Icons.location_on,
                          maxLines: 2),
                    ]),

                    _buildAnimatedButton(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDynamicSection() {
    return _buildSectionCard(
      _employmentType == 'Student'
          ? "Student Details"
          : _employmentType == 'Self-Employed'
              ? "Business Details"
              : "Professional Details",
      _employmentType == 'Student'
          ? Icons.school
          : _employmentType == 'Self-Employed'
              ? Icons.storefront
              : Icons.work,
      [
        if (_employmentType == 'Student') ...[
          _buildTextField(
              "College / University Name", entityNameController, Icons.school),
          _buildTextField(
              "Current Course / Year", roleController, Icons.menu_book),
        ] else if (_employmentType == 'Self-Employed') ...[
          _buildTextField(
              "Business Name", entityNameController, Icons.business),
          _buildTextField("Nature of Business", roleController, Icons.category),
          _buildTextField("GST / Registration Number", registrationController,
              Icons.receipt_long),
        ] else ...[
          _buildTextField("Employer Name", entityNameController, Icons.domain),
          _buildTextField("Job Title / Role", roleController, Icons.badge),
          _buildTextField(
              "Work Experience (Years)", registrationController, Icons.history,
              isNum: true),
        ]
      ],
    );
  }

  Widget _buildEmploymentTypeToggle() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: ['Salaried', 'Self-Employed', 'Student'].map((type) {
          bool isSelected = _employmentType == type;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _employmentType = type),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color:
                      isSelected ? const Color(0xFF1A237E) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(type,
                      style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 11)),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildIncomeSlider() {
    return Column(
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text("Monthly Income/Profit",
              style: TextStyle(fontWeight: FontWeight.w600)),
          Text("\$${_monthlyIncome.toInt()}",
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.blueAccent)),
        ]),
        Slider(
          value: _monthlyIncome,
          min: 5000,
          max: 200000,
          activeColor: const Color(0xFF1A237E),
          onChanged: (val) => setState(() => _monthlyIncome = val),
        ),
      ],
    );
  }

  Widget _buildSectionCard(String title, IconData icon, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ]),
      child: Column(children: [
        Row(children: [
          Icon(icon, color: Colors.blueAccent, size: 20),
          const SizedBox(width: 10),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold))
        ]),
        const Divider(height: 30),
        ...children
      ]),
    );
  }

  Widget _buildTextField(
      String label, TextEditingController ctrl, IconData icon,
      {bool isNum = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: ctrl,
        maxLines: maxLines,
        keyboardType: isNum ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon, size: 20),
            filled: true,
            fillColor: const Color(0xFFF8FAFF),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none)),
        validator: (v) => v!.isEmpty ? "Required" : null,
      ),
    );
  }

  Widget _buildAnimatedButton() {
    return InkWell(
      onTap: _loading ? null : _continue,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 60,
        width: double.infinity,
        decoration: BoxDecoration(
            color: const Color(0xFF1A237E),
            borderRadius: BorderRadius.circular(18)),
        child: Center(
          child: _loading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text("Next: Final Review",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
