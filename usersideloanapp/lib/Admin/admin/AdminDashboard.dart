import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final firestore = FirebaseFirestore.instance;

    return Scaffold(
      backgroundColor: const Color(0xfff4f6fa),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestore.collection('loan_applications').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No Applications Found"));
          }

          final docs = snapshot.data!.docs;

          /// ===============================
          /// SAFE DATA PROCESSING
          /// ===============================

          int totalApplications = docs.length;
          int pending = 0;
          int approved = 0;
          int rejected = 0;
          double totalAmount = 0;

          for (var doc in docs) {
            final data = doc.data() as Map<String, dynamic>;

            final status =
                (data['status'] ?? 'PENDING').toString().toUpperCase();

            final amount =
                double.tryParse(data['amount']?.toString() ?? '0') ?? 0;

            totalAmount += amount;

            if (status == "APPROVED") {
              approved++;
            } else if (status == "REJECTED") {
              rejected++;
            } else {
              pending++;
            }
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// HEADER
                const Text(
                  "Admin Dashboard",
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),

                /// STAT CARDS
                Wrap(
                  spacing: 20,
                  runSpacing: 20,
                  children: [
                    _statCard(
                        "Total Applications",
                        totalApplications.toString(),
                        Icons.description,
                        Colors.indigo),
                    _statCard("Pending", pending.toString(), Icons.schedule,
                        Colors.orange),
                    _statCard("Approved", approved.toString(),
                        Icons.check_circle, Colors.green),
                    _statCard("Rejected", rejected.toString(), Icons.cancel,
                        Colors.red),
                    _statCard(
                        "Total Loan Amount",
                        "₹${totalAmount.toStringAsFixed(0)}",
                        Icons.currency_rupee,
                        Colors.blue),
                  ],
                ),

                const SizedBox(height: 40),

                /// CHART + RECENT TABLE
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth < 900) {
                      /// Mobile layout
                      return Column(
                        children: [
                          _chartSection(pending, approved, rejected),
                          const SizedBox(height: 24),
                          _recentApplications(docs),
                        ],
                      );
                    } else {
                      /// Desktop layout
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                              child:
                                  _chartSection(pending, approved, rejected)),
                          const SizedBox(width: 24),
                          Expanded(child: _recentApplications(docs)),
                        ],
                      );
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// ===============================
  /// STAT CARD
  /// ===============================
  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: color.withOpacity(.1),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(fontSize: 14, color: Colors.grey)),
              const SizedBox(height: 6),
              Text(value,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }

  /// ===============================
  /// PIE CHART SECTION
  /// ===============================
  Widget _chartSection(int pending, int approved, int rejected) {
    return Container(
      height: 400,
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Application Status Overview",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                      value: pending.toDouble(),
                      title: "Pending",
                      color: Colors.orange),
                  PieChartSectionData(
                      value: approved.toDouble(),
                      title: "Approved",
                      color: Colors.green),
                  PieChartSectionData(
                      value: rejected.toDouble(),
                      title: "Rejected",
                      color: Colors.red),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ===============================
  /// RECENT APPLICATIONS
  /// ===============================
  Widget _recentApplications(List<QueryDocumentSnapshot> docs) {
    final recentDocs = docs.take(5).toList();

    return Container(
      height: 400,
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Recent Applications",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: recentDocs.length,
              itemBuilder: (context, index) {
                final data = recentDocs[index].data() as Map<String, dynamic>;

                final name = data['applicant'] ?? "No Name";

                final amount = data['amount']?.toString() ?? "0";

                final status = (data['status'] ?? 'PENDING').toString();

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(name),
                  subtitle: Text("₹$amount"),
                  trailing: _statusChip(status),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  /// STATUS CHIP
  Widget _statusChip(String status) {
    Color color;

    switch (status.toUpperCase()) {
      case "APPROVED":
        color = Colors.green;
        break;
      case "REJECTED":
        color = Colors.red;
        break;
      default:
        color = Colors.orange;
    }

    return Chip(
      label: Text(status),
      backgroundColor: color.withOpacity(.1),
      labelStyle: TextStyle(color: color),
    );
  }

  /// CARD DECORATION
  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(.05),
          blurRadius: 8,
          offset: const Offset(0, 4),
        )
      ],
    );
  }
}
