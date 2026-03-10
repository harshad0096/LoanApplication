import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManagerReportsPage extends StatelessWidget {
  const ManagerReportsPage({super.key});

  /// FIREBASE STREAM
  Stream<Map<String, dynamic>> reportStream() {
    return FirebaseFirestore.instance
        .collection('loan_applications')
        .snapshots()
        .map((snapshot) {
      int totalLoans = snapshot.docs.length;
      int approved = 0;
      int rejected = 0;
      int pending = 0;
      double totalAmount = 0;

      List<Map<String, dynamic>> recent = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();

        String status = data["status"] ?? "";
        double amount = (data["amount"] ?? 0).toDouble();

        totalAmount += amount;

        if (status == "APPROVED") approved++;
        if (status == "REJECTED") rejected++;
        if (status == "MANAGER_APPROVAL") pending++;

        recent.add({
          "name": data["userName"] ?? "",
          "loan": data["loanType"] ?? "",
          "amount": amount,
          "status": status
        });
      }

      recent = recent.take(10).toList();

      return {
        "total": totalLoans,
        "approved": approved,
        "rejected": rejected,
        "pending": pending,
        "totalAmount": totalAmount,
        "recent": recent
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    bool isMobile = width < 700;

    int gridCount = isMobile ? 1 : 4;

    return Scaffold(
      backgroundColor: const Color(0xffF5F7FB),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: StreamBuilder<Map<String, dynamic>>(
          stream: reportStream(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final data = snapshot.data!;

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// HEADER
                  const Text(
                    "Manager Reports",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    "Loan analytics and performance insights",
                    style: TextStyle(color: Colors.grey),
                  ),

                  const SizedBox(height: 30),

                  /// REPORT CARDS
                  GridView.count(
                    crossAxisCount: gridCount,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    childAspectRatio: 2.8,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _reportCard(
                        "Total Loans",
                        data["total"].toString(),
                        Icons.account_balance,
                        Colors.blue,
                      ),
                      _reportCard(
                        "Approved Loans",
                        data["approved"].toString(),
                        Icons.check_circle,
                        Colors.green,
                      ),
                      _reportCard(
                        "Rejected Loans",
                        data["rejected"].toString(),
                        Icons.cancel,
                        Colors.red,
                      ),
                      _reportCard(
                        "Total Loan Value",
                        "₹${data["totalAmount"].toStringAsFixed(0)}",
                        Icons.currency_rupee,
                        Colors.orange,
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  /// RECENT LOANS TABLE
                  const Text(
                    "Recent Loan Report",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 10,
                          color: Colors.black.withOpacity(.05),
                        )
                      ],
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columnSpacing: 40,
                        columns: const [
                          DataColumn(label: Text("Applicant")),
                          DataColumn(label: Text("Loan Type")),
                          DataColumn(label: Text("Amount")),
                          DataColumn(label: Text("Status")),
                        ],
                        rows: (data["recent"] as List)
                            .map<DataRow>((item) => DataRow(
                                  cells: [
                                    DataCell(Text(item["name"])),
                                    DataCell(Text(item["loan"])),
                                    DataCell(Text("₹${item["amount"]}")),
                                    DataCell(_statusChip(item["status"]))
                                  ],
                                ))
                            .toList(),
                      ),
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

  /// REPORT CARD
  Widget _reportCard(title, value, icon, color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
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
            radius: 24,
            backgroundColor: color.withOpacity(.12),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
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
