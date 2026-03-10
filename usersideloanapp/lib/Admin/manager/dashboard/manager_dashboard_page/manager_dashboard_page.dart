import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManagerDashboardPage extends StatelessWidget {
  const ManagerDashboardPage({super.key});

  Stream<Map<String, dynamic>> dashboardStream() {
    return FirebaseFirestore.instance
        .collection('loan_applications')
        .snapshots()
        .map((snapshot) {
      int pending = 0;
      int approved = 0;
      int rejected = 0;
      double totalAmount = 0;

      List<Map<String, dynamic>> recent = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();

        String status = data['status'] ?? "";
        double amount = (data['amount'] ?? 0).toDouble();

        totalAmount += amount;

        if (status == "MANAGER_APPROVAL") pending++;
        if (status == "APPROVED") approved++;
        if (status == "REJECTED") rejected++;

        recent.add({
          "name": data["userName"] ?? "",
          "loan": data["loanType"] ?? "",
          "amount": amount,
          "status": status
        });
      }

      recent = recent.take(6).toList();

      return {
        "pending": pending,
        "approved": approved,
        "rejected": rejected,
        "totalAmount": totalAmount,
        "recent": recent
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff4f6fa),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: StreamBuilder<Map<String, dynamic>>(
          stream: dashboardStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return const Center(child: Text("Error loading dashboard"));
            }

            if (!snapshot.hasData) {
              return const Center(child: Text("No data found"));
            }

            final data = snapshot.data!;

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// HEADER
                  const Text(
                    "Manager Dashboard",
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 30),

                  /// KPI CARDS
                  Wrap(
                    spacing: 20,
                    runSpacing: 20,
                    children: [
                      _kpiCard(
                        "Pending Approvals",
                        data["pending"].toString(),
                        Icons.pending_actions,
                        Colors.orange,
                      ),
                      _kpiCard(
                        "Approved Loans",
                        data["approved"].toString(),
                        Icons.check_circle,
                        Colors.green,
                      ),
                      _kpiCard(
                        "Rejected Loans",
                        data["rejected"].toString(),
                        Icons.cancel,
                        Colors.red,
                      ),
                      _kpiCard(
                        "Total Loan Value",
                        "₹${data["totalAmount"].toStringAsFixed(0)}",
                        Icons.currency_rupee,
                        Colors.blue,
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  /// RECENT APPLICATIONS TABLE
                  const Text(
                    "Recent Loan Applications",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 15),

                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 10,
                          color: Colors.black.withOpacity(.05),
                        )
                      ],
                    ),
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text("Applicant")),
                        DataColumn(label: Text("Loan Type")),
                        DataColumn(label: Text("Amount")),
                        DataColumn(label: Text("Status")),
                      ],
                      rows: (data["recent"] as List)
                          .map<DataRow>((item) => DataRow(cells: [
                                DataCell(Text(item["name"])),
                                DataCell(Text(item["loan"])),
                                DataCell(Text("₹${item["amount"]}")),
                                DataCell(_statusChip(item["status"]))
                              ]))
                          .toList(),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// KPI CARD
  Widget _kpiCard(title, value, icon, color) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            blurRadius: 8,
            color: Colors.black.withOpacity(.05),
          )
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: color.withOpacity(.1),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 5),
              Text(
                value,
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              )
            ],
          )
        ],
      ),
    );
  }

  /// STATUS CHIP
  Widget _statusChip(String status) {
    Color color = Colors.grey;

    if (status == "APPROVED") color = Colors.green;
    if (status == "REJECTED") color = Colors.red;
    if (status == "MANAGER_APPROVAL") color = Colors.orange;

    return Chip(
      label: Text(status),
      backgroundColor: color.withOpacity(.15),
      labelStyle: TextStyle(color: color),
    );
  }
}
