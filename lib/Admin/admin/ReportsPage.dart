import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 700;

    return Scaffold(
      backgroundColor: const Color(0xfff6f8fb),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: StreamBuilder<QuerySnapshot>(
            stream: firestore.collection("loan_applications").snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text("No Reports Available"));
              }

              final loans = snapshot.data!.docs;

              int totalLoans = loans.length;

              int approved =
                  loans.where((e) => (e["status"] ?? "") == "APPROVED").length;

              int rejected =
                  loans.where((e) => (e["status"] ?? "") == "REJECTED").length;

              int pending =
                  loans.where((e) => (e["status"] ?? "") == "PENDING").length;

              double totalAmount = 0;

              for (var l in loans) {
                totalAmount += (l["amount"] ?? 0).toDouble();
              }

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// HEADER
                    const Text(
                      "Reports & Analytics",
                      style:
                          TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 6),

                    const Text(
                      "View financial analytics and export reports",
                      style: TextStyle(color: Colors.grey),
                    ),

                    const SizedBox(height: 25),

                    /// SUMMARY CARDS
                    _summaryCards(
                        totalLoans, approved, pending, rejected, totalAmount),

                    const SizedBox(height: 25),

                    /// CHART SECTION
                    isMobile
                        ? Column(
                            children: [
                              _loanStatusChart(approved, pending, rejected),
                              const SizedBox(height: 20),
                              _collectionChart(),
                            ],
                          )
                        : Row(
                            children: [
                              Expanded(
                                child: _loanStatusChart(
                                    approved, pending, rejected),
                              ),
                              const SizedBox(width: 20),
                              Expanded(child: _collectionChart()),
                            ],
                          ),

                    const SizedBox(height: 25),

                    /// EXPORT SECTION
                    _exportSection(isMobile)
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// SUMMARY CARDS

  Widget _summaryCards(
      int total, int approved, int pending, int rejected, double amount) {
    return LayoutBuilder(builder: (context, constraints) {
      int crossAxis = constraints.maxWidth < 800 ? 2 : 5;

      return GridView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxis,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          childAspectRatio: 3,
        ),
        children: [
          _card("Total Loans", total.toString(), Icons.account_balance_wallet,
              Colors.blue),
          _card("Approved", approved.toString(), Icons.check_circle,
              Colors.green),
          _card("Pending", pending.toString(), Icons.schedule, Colors.orange),
          _card("Rejected", rejected.toString(), Icons.cancel, Colors.red),
          _card("Total Amount", "₹${(amount / 100000).toStringAsFixed(2)}L",
              Icons.currency_rupee, Colors.deepPurple),
        ],
      );
    });
  }

  Widget _card(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(.1),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(title, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 4),
              Text(
                value,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              )
            ],
          )
        ],
      ),
    );
  }

  /// PIE CHART

  Widget _loanStatusChart(int approved, int pending, int rejected) {
    return Container(
      padding: const EdgeInsets.all(20),
      height: 320,
      decoration: _box(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Loan Status Distribution",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Expanded(
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                      value: approved.toDouble(),
                      color: Colors.green,
                      title: "Approved"),
                  PieChartSectionData(
                      value: pending.toDouble(),
                      color: Colors.orange,
                      title: "Pending"),
                  PieChartSectionData(
                      value: rejected.toDouble(),
                      color: Colors.red,
                      title: "Rejected"),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  /// BAR CHART

  Widget _collectionChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      height: 320,
      decoration: _box(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Monthly Loan Distribution",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Expanded(
            child: BarChart(
              BarChartData(
                barGroups: List.generate(
                  6,
                  (i) => BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: 20 + i * 5,
                        color: Colors.deepPurple,
                        width: 14,
                        borderRadius: BorderRadius.circular(6),
                      )
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  /// EXPORT SECTION

  Widget _exportSection(bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _box(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Export Reports",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          isMobile
              ? Column(
                  children: [
                    _exportBtn("Export CSV", Icons.table_chart),
                    const SizedBox(height: 10),
                    _exportBtn("Export PDF", Icons.picture_as_pdf),
                  ],
                )
              : Row(
                  children: [
                    _exportBtn("Export CSV", Icons.table_chart),
                    const SizedBox(width: 20),
                    _exportBtn("Export PDF", Icons.picture_as_pdf),
                  ],
                )
        ],
      ),
    );
  }

  Widget _exportBtn(String title, IconData icon) {
    return ElevatedButton.icon(
      onPressed: () {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("$title started")));
      },
      icon: Icon(icon),
      label: Text(title),
    );
  }

  /// COMMON BOX DECORATION

  BoxDecoration _box() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
    );
  }
}
