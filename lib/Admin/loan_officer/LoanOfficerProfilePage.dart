import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoanOfficerProfilePage extends StatefulWidget {
  const LoanOfficerProfilePage({super.key});

  @override
  State<LoanOfficerProfilePage> createState() => _LoanOfficerProfilePageState();
}

class _LoanOfficerProfilePageState extends State<LoanOfficerProfilePage> {
  final user = FirebaseAuth.instance.currentUser;
  final officerRef = FirebaseFirestore.instance.collection("loan_officers");

  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();

  String employeeId = "";
  String branch = "";
  int loansProcessed = 0;
  int pendingLoans = 0;
  double approvalRate = 0;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    if (user == null) return;

    final doc = await officerRef.doc(user!.uid).get();

    if (doc.exists) {
      final data = doc.data()!;

      nameCtrl.text = data["name"] ?? "";
      emailCtrl.text = data["email"] ?? "";
      phoneCtrl.text = data["phone"] ?? "";

      employeeId = data["employeeId"] ?? "LO-001";
      branch = data["branch"] ?? "Pune Branch";
      loansProcessed = data["loansProcessed"] ?? 0;
      pendingLoans = data["pendingLoans"] ?? 0;
      approvalRate = data["approvalRate"] ?? 0;
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final width = MediaQuery.of(context).size.width;
    bool isDesktop = width > 900;

    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC),
      appBar: AppBar(
        title: const Text("Loan Officer Profile"),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 40 : 20,
          vertical: 20,
        ),
        child: Column(
          children: [
            /// PROFILE HEADER
            _header(),

            const SizedBox(height: 24),

            /// STATS
            _statsGrid(),

            const SizedBox(height: 24),

            isDesktop
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _personalInfo()),
                      const SizedBox(width: 24),
                      Expanded(child: _workInfo()),
                    ],
                  )
                : Column(
                    children: [
                      _personalInfo(),
                      const SizedBox(height: 24),
                      _workInfo(),
                    ],
                  )
          ],
        ),
      ),
    );
  }

  /// HEADER
  Widget _header() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xff6366F1),
            Color(0xff8B5CF6),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 35,
            child: Icon(Icons.person, size: 36),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nameCtrl.text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  emailCtrl.text,
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 6),
                Text(
                  "Employee ID: $employeeId",
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  /// STATS GRID
  Widget _statsGrid() {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 4,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 2.2,
      children: [
        _statCard(
          "Loans Processed",
          loansProcessed.toString(),
          Icons.assignment_turned_in,
          Colors.green,
        ),
        _statCard(
          "Pending Loans",
          pendingLoans.toString(),
          Icons.pending_actions,
          Colors.orange,
        ),
        _statCard(
          "Approval Rate",
          "${approvalRate.toStringAsFixed(1)}%",
          Icons.trending_up,
          Colors.blue,
        ),
        _statCard(
          "Branch",
          branch,
          Icons.location_on,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          )
        ],
      ),
    );
  }

  /// PERSONAL INFO
  Widget _personalInfo() {
    return _card("Personal Information", [
      _infoTile("Full Name", nameCtrl.text),
      _infoTile("Email", emailCtrl.text),
      _infoTile("Phone", phoneCtrl.text),
    ]);
  }

  /// WORK INFO
  Widget _workInfo() {
    return _card("Work Information", [
      _infoTile("Employee ID", employeeId),
      _infoTile("Branch", branch),
      _infoTile("Loans Processed", loansProcessed.toString()),
      _infoTile("Pending Applications", pendingLoans.toString()),
    ]);
  }

  Widget _card(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          ...children
        ],
      ),
    );
  }

  Widget _infoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          )
        ],
      ),
    );
  }
}
