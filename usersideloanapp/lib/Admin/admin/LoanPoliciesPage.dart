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
                  width: 480,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Edit ${policy.title}",
                        style: GoogleFonts.inter(
                            fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 20),
                      Slider(
                        min: 5,
                        max: 20,
                        value: policy.interest,
                        onChanged: (v) => setModal(() => policy.interest = v),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async {
                          await _savePolicyToFirebase(policy);
                          setState(() {});
                          Navigator.pop(context);

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Policy Saved to Firebase"),
                            ),
                          );
                        },
                        child: const Text("Save Changes"),
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
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
