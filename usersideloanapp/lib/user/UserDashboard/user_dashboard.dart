import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard>
    with SingleTickerProviderStateMixin {
  final user = FirebaseAuth.instance.currentUser;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  // ================= SAFE DOUBLE CONVERTER =================
  double toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  // ================= EMI CALC =================
  double calculateEmi(double p, double r, int n) {
    if (p == 0 || r == 0 || n == 0) return 0;
    r = r / 12 / 100;
    return (p * r * math.pow(1 + r, n)) / (math.pow(1 + r, n) - 1);
  }

  // ================= MAIN =================
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('loan_applications')
          .where('userId', isEqualTo: user?.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final loans = snapshot.data!.docs;
        final totalApplications = loans.length; // Total loan applications

        if (loans.isEmpty) {
          return const Center(child: Text("No Loan Data Available"));
        }

        double totalLoan = 0;
        double totalEmi = 0;
        double totalPaid = 0;
        Map<int, double> monthlyData = {};

        for (var doc in loans) {
          final data = doc.data() as Map<String, dynamic>;
          double amount = toDouble(data['amount']);
          double emi = toDouble(data['emi']);
          double paid = toDouble(data['paidAmount']);
          String status = data['status']?.toString() ?? "PENDING";

          totalLoan += amount;
          totalPaid += paid;
          if (status == "APPROVED")
            totalEmi += emi; // Total EMI for approved loans

          if (data['createdAt'] != null && data['createdAt'] is Timestamp) {
            DateTime date = (data['createdAt'] as Timestamp).toDate();
            monthlyData[date.month] = (monthlyData[date.month] ?? 0) + amount;
          }
        }

        return FadeTransition(
          opacity: _fadeAnimation,
          child: LayoutBuilder(
            builder: (context, constraints) {
              bool isMobile = constraints.maxWidth < 800;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    headerCard(), // Dynamic user header
                    const SizedBox(height: 24),
                    statsSection(totalLoan, totalEmi, totalApplications),
                    const SizedBox(height: 30),
                    if (isMobile)
                      Column(
                        children: [
                          monthlyChart(monthlyData),
                          const SizedBox(height: 24),
                          progressCircle(totalPaid, totalLoan),
                        ],
                      )
                    else
                      Row(
                        children: [
                          Expanded(child: monthlyChart(monthlyData)),
                          const SizedBox(width: 24),
                          Expanded(child: progressCircle(totalPaid, totalLoan)),
                        ],
                      ),
                    const SizedBox(height: 30),
                    loansSection(loans),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  // ================= HEADER =================
  Widget headerCard() {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: glass(),
        child: Row(
          children: const [
            CircleAvatar(radius: 28, child: Icon(Icons.person)),
            SizedBox(width: 14),
            Text(
              "Welcome Back, Guest",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    return StreamBuilder<DocumentSnapshot>(
      stream:
          FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
      builder: (context, snapshot) {
        String name = "User";
        String? photoUrl;

        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          name = data["name"] ?? "User";
          photoUrl = data["photoUrl"];
        }

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: glass(),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundImage:
                    photoUrl != null ? NetworkImage(photoUrl) : null,
                child: photoUrl == null ? const Icon(Icons.person) : null,
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Welcome Back",
                    style: TextStyle(color: Colors.grey),
                  ),
                  Text(
                    name,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  // ================= STATS =================
  Widget statsSection(double total, double totalEmi, int totalApplications) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        statCard("₹${total.toStringAsFixed(0)}", "Total Loans"),
        statCard("₹${totalEmi.toStringAsFixed(0)}/mo", "Total EMI"), // Updated
        statCard(total > 0 ? "750" : "0", "Credit Score"),
        statCard(totalApplications.toString(), "Total Applications"),
      ],
    );
  }

  Widget statCard(String value, String label) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(20),
      decoration: glass(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value,
              style:
                  const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  // ================= MONTHLY CHART =================
  Widget monthlyChart(Map<int, double> monthlyData) {
    List<BarChartGroupData> bars = [];

    for (int i = 1; i <= 12; i++) {
      bars.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: monthlyData[i] ?? 0,
              width: 14,
              borderRadius: BorderRadius.circular(6),
              color: const Color(0xff6366F1),
            )
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: glass(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Monthly Loan Analytics",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          SizedBox(
            height: 260,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                titlesData: FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: bars,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= PROGRESS CIRCLE =================
  Widget progressCircle(double paid, double total) {
    double progress = total == 0 ? 0 : paid / total;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: glass(),
      child: Column(
        children: [
          const Text("Loan Progress",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            width: 180,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 14,
                  backgroundColor: Colors.grey.shade200,
                  color: const Color(0xff6366F1),
                ),
                Text("${(progress * 100).toStringAsFixed(0)}%",
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= LOANS LIST =================
  Widget loansSection(List<QueryDocumentSnapshot> loans) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Your Loans",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 14),
        ...loans.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          double emi = toDouble(data['emi']); // individual EMI
          String loanId = doc.id;

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: GestureDetector(
              onTap: () => showLoanDetailsDialog(context, loanId),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: glass(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data['loanType']?.toString() ?? "Loan",
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text("₹${toDouble(data['amount']).toStringAsFixed(0)}",
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff6366F1))),
                    const SizedBox(height: 6),
                    Text("EMI: ₹${emi.toStringAsFixed(0)} / month"),
                    const SizedBox(height: 6),
                    Text("Status: ${data['status'] ?? "PENDING"}"),
                  ],
                ),
              ),
            ),
          );
        }).toList()
      ],
    );
  }

// ================= DIALOG FOR LOAN DETAILS =================
  void showLoanDetailsDialog(BuildContext context, String loanId) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('loan_applications')
                .doc(loanId)
                .snapshots(),
            builder: (context, loanSnapshot) {
              if (!loanSnapshot.hasData) {
                return SizedBox(
                    height: 200,
                    child: Center(child: CircularProgressIndicator()));
              }

              final loanData =
                  loanSnapshot.data!.data() as Map<String, dynamic>;

              return StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(userId)
                    .snapshots(),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) {
                    return SizedBox(
                        height: 200,
                        child: Center(child: CircularProgressIndicator()));
                  }

                  final userData =
                      userSnapshot.data!.data() as Map<String, dynamic>?;

                  double emi = toDouble(loanData['emi']);
                  double amount = toDouble(loanData['amount']);
                  String status = loanData['status'] ?? "PENDING";
                  String loanType = loanData['loanType'] ?? "Loan";

                  // ================= POLICY SNAPSHOT =================
                  Map<String, dynamic> policy = loanData['policySnapshot'] !=
                          null
                      ? Map<String, dynamic>.from(loanData['policySnapshot'])
                      : {};

                  double interest = toDouble(policy['interest']);
                  double maxAmount = toDouble(policy['maxAmount']);
                  double minAmount = toDouble(policy['minAmount']);
                  int maxTenure = (policy['maxTenure'] ?? 0).toInt();
                  int minTenure = (policy['minTenure'] ?? 0).toInt();
                  double processingFee = toDouble(policy['processingFee']);

                  String userName = userData?['name'] ?? "User";
                  String userEmail = userData?['email'] ?? "No email";

                  return Padding(
                    padding: const EdgeInsets.all(20),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Loan Details",
                              style: const TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold)),
                          const Divider(height: 20, thickness: 1),
                          Text("Loan Type: $loanType"),
                          const SizedBox(height: 6),
                          Text("Amount: ₹${amount.toStringAsFixed(0)}"),
                          const SizedBox(height: 6),
                          Text("EMI: ₹${emi.toStringAsFixed(0)} / month"),
                          const SizedBox(height: 6),
                          Text("Status: $status"),
                          const SizedBox(height: 10),

                          // ================= POLICY INFO =================
                          const Text("Loan Policy",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          const Divider(height: 20, thickness: 1),
                          Text(
                              "Interest Rate: ${interest.toStringAsFixed(2)}%"),
                          const SizedBox(height: 6),
                          Text("Min Amount: ₹${minAmount.toStringAsFixed(0)}"),
                          const SizedBox(height: 6),
                          Text("Max Amount: ₹${maxAmount.toStringAsFixed(0)}"),
                          const SizedBox(height: 6),
                          Text("Min Tenure: $minTenure months"),
                          const SizedBox(height: 6),
                          Text("Max Tenure: $maxTenure months"),
                          const SizedBox(height: 6),
                          Text(
                              "Processing Fee: ${processingFee.toStringAsFixed(2)}%"),

                          const SizedBox(height: 20),
                          const Text("User Info",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          const Divider(height: 20, thickness: 1),
                          Text("Name: $userName"),
                          const SizedBox(height: 6),
                          Text("Email: $userEmail"),
                          const SizedBox(height: 20),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("Close")),
                          )
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  // ================= GLASS =================
  BoxDecoration glass() {
    return BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 15)
      ],
    );
  }
}
