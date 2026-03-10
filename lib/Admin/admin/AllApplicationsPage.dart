import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoanManagementPage extends StatefulWidget {
  const LoanManagementPage({super.key});

  @override
  State<LoanManagementPage> createState() => _LoanManagementPageState();
}

class _LoanManagementPageState extends State<LoanManagementPage> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  String selectedStatus = "All";
  String search = "";

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 800;

    return Scaffold(
      backgroundColor: const Color(0xfff6f8fb),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: StreamBuilder<QuerySnapshot>(
          stream: firestore
              .collection("loan_applications")
              .orderBy("createdAt", descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final docs = snapshot.data!.docs;

            final filtered = docs.where((doc) {
              final data = doc.data() as Map<String, dynamic>;

              bool statusMatch = selectedStatus == "All"
                  ? true
                  : data["status"] == selectedStatus;

              bool searchMatch =
                  (data["userName"] ?? "").toLowerCase().contains(search);

              return statusMatch && searchMatch;
            }).toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Loan Management",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                const Text(
                  "View and manage all loan applications and active loans",
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 20),

                /// SUMMARY
                _summaryCards(docs),

                const SizedBox(height: 20),

                /// SEARCH + FILTER
                _searchFilter(),

                const SizedBox(height: 20),

                /// TABLE / LIST
                Expanded(
                  child:
                      isMobile ? _mobileList(filtered) : _dataTable(filtered),
                )
              ],
            );
          },
        ),
      ),
    );
  }

  /// SUMMARY CARDS
  Widget _summaryCards(List docs) {
    int total = docs.length;
    int active = docs.where((e) => e["status"] == "APPROVED").length;
    int pending = docs.where((e) => e["status"] == "PENDING").length;
    int rejected = docs.where((e) => e["status"] == "REJECTED").length;

    return Row(
      children: [
        _card("Total Loans", total, Icons.wallet, Colors.blue),
        _card("Active", active, Icons.check_circle, Colors.green),
        _card("Pending", pending, Icons.schedule, Colors.orange),
        _card("Rejected", rejected, Icons.cancel, Colors.red),
      ],
    );
  }

  Widget _card(String title, int value, IconData icon, Color color) {
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
                  value.toString(),
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

  /// SEARCH + FILTER
  Widget _searchFilter() {
    List<String> filters = [
      "All",
      "APPROVED",
      "PENDING",
      "REJECTED",
    ];

    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              hintText: "Search by user...",
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
            ),
            onChanged: (v) {
              setState(() {
                search = v.toLowerCase();
              });
            },
          ),
        ),
        const SizedBox(width: 20),
        Wrap(
          spacing: 10,
          children: filters.map((f) {
            bool active = selectedStatus == f;

            return ChoiceChip(
              label: Text(f),
              selected: active,
              selectedColor: Colors.deepPurple,
              onSelected: (_) {
                setState(() {
                  selectedStatus = f;
                });
              },
            );
          }).toList(),
        )
      ],
    );
  }

  /// DESKTOP TABLE
  Widget _dataTable(List docs) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text("Loan ID")),
            DataColumn(label: Text("Borrower")),
            DataColumn(label: Text("Type")),
            DataColumn(label: Text("Amount")),
            DataColumn(label: Text("Status")),
            DataColumn(label: Text("Actions")),
          ],
          rows: docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;

            return DataRow(cells: [
              DataCell(Text(doc.id)),
              DataCell(Text(data["userName"] ?? "")),
              DataCell(Text(data["loanType"] ?? "")),
              DataCell(Text("₹${data["amount"] ?? 0}")),
              DataCell(_statusChip(data["status"])),
              DataCell(Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.check, color: Colors.green),
                    onPressed: () => updateStatus(doc.id, "APPROVED"),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: () => updateStatus(doc.id, "REJECTED"),
                  )
                ],
              ))
            ]);
          }).toList(),
        ),
      ),
    );
  }

  /// MOBILE LIST
  Widget _mobileList(List docs) {
    return ListView.builder(
      itemCount: docs.length,
      itemBuilder: (context, index) {
        final data = docs[index].data() as Map<String, dynamic>;

        return Card(
          margin: const EdgeInsets.only(bottom: 15),
          child: ListTile(
            title: Text(data["userName"] ?? ""),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Loan: ${data["loanType"]}"),
                Text("Amount: ₹${data["amount"]}"),
                _statusChip(data["status"])
              ],
            ),
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(value: "APPROVED", child: Text("Approve")),
                const PopupMenuItem(value: "REJECTED", child: Text("Reject")),
              ],
              onSelected: (value) {
                updateStatus(docs[index].id, value);
              },
            ),
          ),
        );
      },
    );
  }

  /// STATUS CHIP
  Widget _statusChip(String status) {
    Color color;

    switch (status) {
      case "APPROVED":
        color = Colors.green;
        break;
      case "REJECTED":
        color = Colors.red;
        break;
      case "PENDING":
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

  /// UPDATE STATUS
  Future updateStatus(String id, String status) async {
    await firestore.collection("loan_applications").doc(id).update({
      "status": status,
      "updatedAt": FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Loan $status")));
  }
}
