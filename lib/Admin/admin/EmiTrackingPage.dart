import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class EmiManegmantPage extends StatefulWidget {
  const EmiManegmantPage({super.key});

  @override
  State<EmiManegmantPage> createState() => _EmiManegmantPageState();
}

class _EmiManegmantPageState extends State<EmiManegmantPage> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  String selectedFilter = "All";

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 900;

    return Scaffold(
      backgroundColor: const Color(0xfff6f8fb),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: StreamBuilder<QuerySnapshot>(
          stream: firestore.collection("payments").snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final payments = snapshot.data!.docs;

            final filtered = selectedFilter == "All"
                ? payments
                : payments.where((e) => e["status"] == selectedFilter).toList();

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// HEADER
                  const Text(
                    "EMI & Payments",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 5),

                  const Text(
                    "Monitor payments, track collections, and manage overdue accounts",
                    style: TextStyle(color: Colors.grey),
                  ),

                  const SizedBox(height: 20),

                  /// SUMMARY CARDS
                  _summaryCards(payments),

                  const SizedBox(height: 20),

                  /// CHART + OVERDUE
                  isMobile
                      ? Column(
                          children: [
                            _chartCard(),
                            const SizedBox(height: 20),
                            _overdueAccounts(),
                          ],
                        )
                      : Row(
                          children: [
                            Expanded(child: _chartCard()),
                            const SizedBox(width: 20),
                            Expanded(child: _overdueAccounts()),
                          ],
                        ),

                  const SizedBox(height: 20),

                  /// PAYMENT HISTORY
                  _paymentHistory(filtered)
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// SUMMARY CARDS

  Widget _summaryCards(List payments) {
    double total = 0;
    int success = 0;
    int failed = 0;

    for (var p in payments) {
      total += (p["amount"] ?? 0).toDouble();

      if (p["status"] == "SUCCESS") success++;
      if (p["status"] == "FAILED") failed++;
    }

    double rate = payments.isEmpty ? 0 : success / payments.length * 100;

    return Row(
      children: [
        _card("Total Collected", "₹${(total / 100000).toStringAsFixed(2)}Cr",
            Icons.currency_rupee, Colors.green),
        _card("Success Rate", "${rate.toStringAsFixed(1)}%", Icons.trending_up,
            Colors.deepPurple),
        _card("Total Overdue", "₹74200", Icons.warning, Colors.red),
      ],
    );
  }

  Widget _card(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 15),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
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
              children: [
                Text(title, style: const TextStyle(color: Colors.grey)),
                Text(
                  value,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  /// CHART

  Widget _chartCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      height: 300,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Monthly Collection vs Target (₹L)",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: BarChart(
              BarChartData(
                barGroups: List.generate(6, (i) {
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: 40 + i * 5,
                        color: Colors.green,
                        width: 12,
                      ),
                      BarChartRodData(
                        toY: 50 + i * 5,
                        color: Colors.grey.shade300,
                        width: 12,
                      ),
                    ],
                  );
                }),
              ),
            ),
          )
        ],
      ),
    );
  }

  /// OVERDUE ACCOUNTS

  Widget _overdueAccounts() {
    return StreamBuilder<QuerySnapshot>(
      stream: firestore
          .collection("loans")
          .where("overdueDays", isGreaterThan: 0)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final loans = snapshot.data!.docs;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Overdue Accounts",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ...loans.map((loan) {
                final data = loan.data() as Map<String, dynamic>;

                return Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data["userName"] ?? "",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text("Loan: ${loan.id}"),
                          const SizedBox(height: 5),
                          Text(
                            "₹${data["overdueAmount"]}",
                            style: const TextStyle(
                                color: Colors.red, fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                        ),
                        onPressed: () {},
                        child: const Text("Send Reminder"),
                      )
                    ],
                  ),
                );
              })
            ],
          ),
        );
      },
    );
  }

  /// PAYMENT HISTORY

  Widget _paymentHistory(List payments) {
    List filters = ["All", "SUCCESS", "FAILED", "OVERDUE"];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Payment History",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Wrap(
                spacing: 10,
                children: filters.map((f) {
                  return ChoiceChip(
                    label: Text(f),
                    selected: selectedFilter == f,
                    selectedColor: Colors.deepPurple,
                    onSelected: (_) {
                      setState(() {
                        selectedFilter = f;
                      });
                    },
                  );
                }).toList(),
              )
            ],
          ),
          const SizedBox(height: 20),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text("TXN ID")),
                DataColumn(label: Text("User")),
                DataColumn(label: Text("Loan ID")),
                DataColumn(label: Text("Amount")),
                DataColumn(label: Text("Method")),
                DataColumn(label: Text("Date")),
                DataColumn(label: Text("Status")),
              ],
              rows: payments.map((p) {
                final data = p.data() as Map<String, dynamic>;

                return DataRow(cells: [
                  DataCell(Text(p.id)),
                  DataCell(Text(data["userName"] ?? "")),
                  DataCell(Text(data["loanId"] ?? "")),
                  DataCell(Text("₹${data["amount"]}")),
                  DataCell(Text(data["method"] ?? "")),
                  DataCell(Text(data["date"] ?? "")),
                  DataCell(_statusChip(data["status"]))
                ]);
              }).toList(),
            ),
          )
        ],
      ),
    );
  }

  Widget _statusChip(String status) {
    Color color;

    switch (status) {
      case "SUCCESS":
        color = Colors.green;
        break;

      case "FAILED":
        color = Colors.red;
        break;

      case "OVERDUE":
        color = Colors.orange;
        break;

      default:
        color = Colors.blue;
    }

    return Chip(
      label: Text(status),
      backgroundColor: color.withOpacity(.1),
      labelStyle: TextStyle(color: color),
    );
  }
}
