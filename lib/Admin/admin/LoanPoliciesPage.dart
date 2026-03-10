import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoanPoliciesPage extends StatefulWidget {
  const LoanPoliciesPage({super.key});

  @override
  State<LoanPoliciesPage> createState() => _LoanPoliciesPageState();
}

class _LoanPoliciesPageState extends State<LoanPoliciesPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final List<LoanPolicy> policies = [
    LoanPolicy(
      id: "personal_loan",
      title: "Personal Loan",
      icon: Icons.person_outline,
      color: Colors.blue,
      interest: 12.5,
      minAmount: 50000,
      maxAmount: 2000000,
      minTenure: 6,
      maxTenure: 60,
      processingFee: 2,
    ),
    LoanPolicy(
      id: "education_loan",
      title: "Education Loan",
      icon: Icons.school_outlined,
      color: Colors.teal,
      interest: 9.5,
      minAmount: 100000,
      maxAmount: 5000000,
      minTenure: 12,
      maxTenure: 120,
      processingFee: 1,
    ),
    LoanPolicy(
      id: "home_loan",
      title: "Home Loan",
      icon: Icons.home_outlined,
      color: Colors.green,
      interest: 8.5,
      minAmount: 500000,
      maxAmount: 50000000,
      minTenure: 60,
      maxTenure: 360,
      processingFee: 0.5,
    ),
    LoanPolicy(
      id: "vehicle_loan",
      title: "Vehicle Loan",
      icon: Icons.directions_car_outlined,
      color: Colors.orange,
      interest: 10.5,
      minAmount: 100000,
      maxAmount: 5000000,
      minTenure: 12,
      maxTenure: 84,
      processingFee: 1.5,
    ),
  ];

  /// ===============================
  /// SAVE POLICY TO FIREBASE
  /// ===============================
  Future<void> _savePolicyToFirebase(LoanPolicy policy) async {
    await _firestore.collection("loan_policies").doc(policy.id).set({
      "title": policy.title,
      "interest": policy.interest,
      "minAmount": policy.minAmount,
      "maxAmount": policy.maxAmount,
      "minTenure": policy.minTenure,
      "maxTenure": policy.maxTenure,
      "processingFee": policy.processingFee,
      "updatedAt": FieldValue.serverTimestamp(),
    });
  }

  //delete policy from firebase
  Future<void> _deletePolicy(LoanPolicy policy) async {
    await _firestore.collection("loan_policies").doc(policy.id).delete();

    setState(() {
      policies.removeWhere((p) => p.id == policy.id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Policy Deleted")),
    );
  }

  void _confirmDeletePolicy(LoanPolicy policy) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Delete Policy"),
          content: Text("Are you sure you want to delete ${policy.title}?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                Navigator.pop(context);
                await _deletePolicy(policy);
              },
              child: const Text("Delete"),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Loan Policies",
              style: GoogleFonts.inter(
                fontSize: 26,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Configure loan products and interest rates",
              style: GoogleFonts.inter(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text("New Policy"),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              ),
              onPressed: _openCreatePolicyDialog,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                itemCount: policies.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: 0.9,
                ),
                itemBuilder: (context, index) {
                  final policy = policies[index];
                  return _loanCard(policy);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openCreatePolicyDialog() {
    final titleController = TextEditingController();
    final minAmountController = TextEditingController();
    final maxAmountController = TextEditingController();
    final minTenureController = TextEditingController();
    final maxTenureController = TextEditingController();
    final processingController = TextEditingController();

    double interest = 10;

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModal) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: SizedBox(
                  width: 500,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Text(
                          "Create New Loan Policy",
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: titleController,
                          decoration: const InputDecoration(
                            labelText: "Loan Title",
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: minAmountController,
                          decoration: const InputDecoration(
                            labelText: "Minimum Amount",
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: maxAmountController,
                          decoration: const InputDecoration(
                            labelText: "Maximum Amount",
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: minTenureController,
                          decoration: const InputDecoration(
                            labelText: "Min Tenure (months)",
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: maxTenureController,
                          decoration: const InputDecoration(
                            labelText: "Max Tenure (months)",
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: processingController,
                          decoration: const InputDecoration(
                            labelText: "Processing Fee %",
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "Interest Rate : ${interest.toStringAsFixed(1)}%",
                        ),
                        Slider(
                          min: 5,
                          max: 20,
                          value: interest,
                          onChanged: (v) => setModal(() => interest = v),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () async {
                            String id = titleController.text
                                .toLowerCase()
                                .replaceAll(" ", "_");

                            LoanPolicy newPolicy = LoanPolicy(
                              id: id,
                              title: titleController.text,
                              icon: Icons.account_balance,
                              color: Colors.purple,
                              interest: interest,
                              minAmount: int.parse(minAmountController.text),
                              maxAmount: int.parse(maxAmountController.text),
                              minTenure: int.parse(minTenureController.text),
                              maxTenure: int.parse(maxTenureController.text),
                              processingFee:
                                  double.parse(processingController.text),
                            );

                            policies.add(newPolicy);

                            await _savePolicyToFirebase(newPolicy);

                            setState(() {});

                            Navigator.pop(context);

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("New Policy Created"),
                              ),
                            );
                          },
                          child: const Text("Create Policy"),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _loanCard(LoanPolicy p) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: p.color.withOpacity(0.15),
                  child: Icon(p.icon, color: p.color),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => _openEditDialog(p),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _confirmDeletePolicy(p),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              p.title,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _info("Interest Rate", "${p.interest}%"),
            _info("Max Amount", "₹${p.maxAmount}"),
            _info("Max Tenure", "${p.maxTenure} months"),
            _info("Processing Fee", "${p.processingFee}%"),
          ],
        ),
      ),
    );
  }

  Widget _info(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: GoogleFonts.inter(color: Colors.grey)),
          ),
          Text(value, style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  void _openEditDialog(LoanPolicy policy) {
    final interestController =
        TextEditingController(text: policy.interest.toString());
    final minAmountController =
        TextEditingController(text: policy.minAmount.toString());
    final maxAmountController =
        TextEditingController(text: policy.maxAmount.toString());
    final minTenureController =
        TextEditingController(text: policy.minTenure.toString());
    final maxTenureController =
        TextEditingController(text: policy.maxTenure.toString());
    final processingController =
        TextEditingController(text: policy.processingFee.toString());

    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: 480,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Edit ${policy.title}",
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// INTEREST
                    _editField("Interest Rate (%)", interestController),

                    /// MIN AMOUNT
                    _editField("Min Amount", minAmountController),

                    /// MAX AMOUNT
                    _editField("Max Amount", maxAmountController),

                    /// MIN TENURE
                    _editField("Min Tenure (Months)", minTenureController),

                    /// MAX TENURE
                    _editField("Max Tenure (Months)", maxTenureController),

                    /// PROCESSING FEE
                    _editField("Processing Fee (%)", processingController),

                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Cancel"),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () async {
                            policy.interest =
                                double.parse(interestController.text);
                            policy.minAmount =
                                int.parse(minAmountController.text);
                            policy.maxAmount =
                                int.parse(maxAmountController.text);
                            policy.minTenure =
                                int.parse(minTenureController.text);
                            policy.maxTenure =
                                int.parse(maxTenureController.text);
                            policy.processingFee =
                                double.parse(processingController.text);

                            await _savePolicyToFirebase(policy);

                            setState(() {});
                            Navigator.pop(context);

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Policy Updated Successfully"),
                              ),
                            );
                          },
                          child: const Text("Save Changes"),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _editField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}

/// MODEL
class LoanPolicy {
  String id;
  String title;
  IconData icon;
  Color color;
  double interest;
  int minAmount;
  int maxAmount;
  int minTenure;
  int maxTenure;
  double processingFee;

  LoanPolicy({
    required this.id,
    required this.title,
    required this.icon,
    required this.color,
    required this.interest,
    required this.minAmount,
    required this.maxAmount,
    required this.minTenure,
    required this.maxTenure,
    required this.processingFee,
  });
}
