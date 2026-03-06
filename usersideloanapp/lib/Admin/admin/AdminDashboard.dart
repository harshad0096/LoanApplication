import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  /// UPDATE STATUS + REMARKS
  Future<void> _updateApplication(
      String docId, String action, String remarks) async {
    await FirebaseFirestore.instance
        .collection('loan_applications')
        .doc(docId)
        .update({
      "status": action,
      "officerAction": action,
      "officerRemarks": remarks,
      "updatedAt": FieldValue.serverTimestamp(),
    });
  }

  /// REMARK DIALOG
  void _showActionDialog(String docId, String action) {
    final TextEditingController remarkController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("$action Application"),
          content: TextField(
            controller: remarkController,
            decoration: const InputDecoration(
              labelText: "Officer Remarks",
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: const Text("Submit"),
              onPressed: () {
                _updateApplication(docId, action, remarkController.text);

                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff4f6fa),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('loan_applications')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          int pending = 0;
          int approved = 0;
          int rejected = 0;
          double totalAmount = 0;

          for (var doc in docs) {
            final data = doc.data() as Map<String, dynamic>;

            final status =
                (data['status'] ?? "PENDING").toString().toUpperCase();

            final amount =
                double.tryParse(data['amount']?.toString() ?? '0') ?? 0;

            totalAmount += amount;

            if (status == "APPROVED") approved++;
            if (status == "REJECTED") rejected++;
            if (status == "PENDING") pending++;
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

                /// KPI CARDS
                Wrap(
                  spacing: 20,
                  runSpacing: 20,
                  children: [
                    _card("Pending", pending.toString(), Icons.schedule,
                        Colors.orange),
                    _card("Approved", approved.toString(), Icons.check_circle,
                        Colors.green),
                    _card("Rejected", rejected.toString(), Icons.cancel,
                        Colors.red),
                    _card("Total Loan", "₹${totalAmount.toStringAsFixed(0)}",
                        Icons.currency_rupee, Colors.blue),
                  ],
                ),

                const SizedBox(height: 30),

                /// PIE CHART
                Container(
                  height: 350,
                  padding: const EdgeInsets.all(20),
                  decoration: _box(),
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

                const SizedBox(height: 30),

                /// APPLICATION TABLE
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: _box(),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text("User")),
                        DataColumn(label: Text("Amount")),
                        DataColumn(label: Text("Status")),
                        DataColumn(label: Text("Officer Remarks")),
                        DataColumn(label: Text("Actions")),
                      ],
                      rows: docs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;

                        final name = data['userName'] ?? "No Name";
                        final amount = data['amount'] ?? "0";
                        final status = data['status'] ?? "PENDING";
                        final remarks = data['officerRemarks'] ?? "-";

                        return DataRow(
                          cells: [
                            DataCell(Text(name)),
                            DataCell(Text("₹$amount")),
                            DataCell(_statusChip(status)),
                            DataCell(Text(remarks)),
                            DataCell(
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.check_circle,
                                        color: Colors.green),
                                    onPressed: () {
                                      _showActionDialog(doc.id, "APPROVED");
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.cancel,
                                        color: Colors.red),
                                    onPressed: () {
                                      _showActionDialog(doc.id, "REJECTED");
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.grey),
                                    onPressed: () {
                                      FirebaseFirestore.instance
                                          .collection('loan_applications')
                                          .doc(doc.id)
                                          .delete();
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _card(String title, String value, IconData icon, Color color) {
    return Container(
      width: 230,
      padding: const EdgeInsets.all(20),
      decoration: _box(),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(.1),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 4),
              Text(value,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }

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

  BoxDecoration _box() {
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
