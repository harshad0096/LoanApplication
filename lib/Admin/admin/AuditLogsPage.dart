import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AuditLogsPage extends StatefulWidget {
  const AuditLogsPage({super.key});

  @override
  State<AuditLogsPage> createState() => _AuditLogsPageState();
}

class _AuditLogsPageState extends State<AuditLogsPage> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  String search = "";
  String filter = "All";

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 900;

    return Scaffold(
      backgroundColor: const Color(0xfff6f8fb),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: StreamBuilder<QuerySnapshot>(
          stream: firestore
              .collection("audit_logs")
              .orderBy("createdAt", descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final logs = snapshot.data!.docs;

            final filteredLogs = logs.where((log) {
              final data = log.data() as Map<String, dynamic>;

              bool searchMatch =
                  (data["userName"] ?? "").toLowerCase().contains(search);

              bool filterMatch =
                  filter == "All" ? true : data["action"] == filter;

              return searchMatch && filterMatch;
            }).toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// HEADER
                const Text(
                  "Audit Logs",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 5),

                const Text(
                  "Track system activity and admin actions",
                  style: TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 20),

                /// SUMMARY
                _summaryCards(logs),

                const SizedBox(height: 20),

                /// SEARCH + FILTER
                _searchFilter(),

                const SizedBox(height: 20),

                /// LOG TABLE / MOBILE LIST
                Expanded(
                  child: isMobile
                      ? _mobileList(filteredLogs)
                      : _logTable(filteredLogs),
                )
              ],
            );
          },
        ),
      ),
    );
  }

  /// SUMMARY CARDS

  Widget _summaryCards(List logs) {
    int total = logs.length;

    int approvals = logs.where((e) => e["action"] == "APPROVED_LOAN").length;

    int rejects = logs.where((e) => e["action"] == "REJECTED_LOAN").length;

    int login = logs.where((e) => e["action"] == "LOGIN").length;

    return Row(
      children: [
        _card("Total Logs", total.toString(), Icons.history, Colors.blue),
        _card("Loan Approvals", approvals.toString(), Icons.check_circle,
            Colors.green),
        _card("Loan Rejections", rejects.toString(), Icons.cancel, Colors.red),
        _card("User Logins", login.toString(), Icons.login, Colors.deepPurple),
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
                      fontSize: 20, fontWeight: FontWeight.bold),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  /// SEARCH + FILTER

  Widget _searchFilter() {
    List filters = ["All", "LOGIN", "APPROVED_LOAN", "REJECTED_LOAN"];

    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              hintText: "Search by user...",
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
              ),
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
            return ChoiceChip(
              label: Text(f),
              selected: filter == f,
              selectedColor: Colors.deepPurple,
              onSelected: (_) {
                setState(() {
                  filter = f;
                });
              },
            );
          }).toList(),
        )
      ],
    );
  }

  /// DESKTOP TABLE

  Widget _logTable(List logs) {
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
            DataColumn(label: Text("User")),
            DataColumn(label: Text("Action")),
            DataColumn(label: Text("Target")),
            DataColumn(label: Text("Description")),
            DataColumn(label: Text("Date")),
          ],
          rows: logs.map((log) {
            final data = log.data() as Map<String, dynamic>;

            final date = data["createdAt"] != null
                ? DateFormat("yyyy-MM-dd HH:mm")
                    .format(data["createdAt"].toDate())
                : "";

            return DataRow(cells: [
              DataCell(Text(data["userName"] ?? "")),
              DataCell(_actionChip(data["action"])),
              DataCell(Text(data["targetId"] ?? "")),
              DataCell(Text(data["description"] ?? "")),
              DataCell(Text(date)),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  /// MOBILE LIST

  Widget _mobileList(List logs) {
    return ListView.builder(
      itemCount: logs.length,
      itemBuilder: (context, index) {
        final data = logs[index].data() as Map<String, dynamic>;

        final date = data["createdAt"] != null
            ? DateFormat("yyyy-MM-dd HH:mm").format(data["createdAt"].toDate())
            : "";

        return Card(
          margin: const EdgeInsets.only(bottom: 15),
          child: ListTile(
            title: Text(data["userName"] ?? ""),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 5),
                _actionChip(data["action"]),
                Text("Target: ${data["targetId"] ?? ""}"),
                Text(data["description"] ?? ""),
                Text(
                  date,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// ACTION CHIP

  Widget _actionChip(String action) {
    Color color;

    switch (action) {
      case "LOGIN":
        color = Colors.blue;
        break;

      case "APPROVED_LOAN":
        color = Colors.green;
        break;

      case "REJECTED_LOAN":
        color = Colors.red;
        break;

      default:
        color = Colors.orange;
    }

    return Chip(
      label: Text(action),
      backgroundColor: color.withOpacity(.1),
      labelStyle: TextStyle(color: color),
    );
  }
}
