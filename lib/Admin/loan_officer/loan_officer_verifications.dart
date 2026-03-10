import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoanOfficerVerificationsPage extends StatefulWidget {
  const LoanOfficerVerificationsPage({super.key});

  @override
  State<LoanOfficerVerificationsPage> createState() =>
      _LoanOfficerVerificationsPageState();
}

class _LoanOfficerVerificationsPageState
    extends State<LoanOfficerVerificationsPage> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  int selectedIndex = 0;

  /// ============================
  /// FIREBASE STREAM
  /// ============================

  Stream<List<Map<String, dynamic>>> getApplications() {
    return firestore
        .collection("loan_verifications")
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => {...doc.data(), "id": doc.id}).toList());
  }

  /// ============================
  /// VERIFY DOCUMENT
  /// ============================

  Future<void> verifyDocument(String id, String docName) async {
    await firestore
        .collection("loan_verifications")
        .doc(id)
        .update({"documents.$docName": true});

    await firestore.collection("notifications").add({
      "title": "Document Verified",
      "message": "$docName verified",
      "time": FieldValue.serverTimestamp()
    });
  }

  /// ============================
  /// UI
  /// ============================

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: getApplications(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final apps = snapshot.data!;

        if (apps.isEmpty) {
          return const Center(child: Text("No verifications"));
        }

        final selected = apps[selectedIndex];

        return LayoutBuilder(
          builder: (context, constraints) {
            bool isMobile = constraints.maxWidth < 900;

            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _statsRow(apps, isMobile),
                  const SizedBox(height: 16),
                  Expanded(
                    child: isMobile
                        ? _applicationsList(apps, true)
                        : Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: _applicationsList(apps, false),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                flex: 3,
                                child: _documentPanel(selected),
                              )
                            ],
                          ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// ============================
  /// STATS
  /// ============================

  Widget _statsRow(List apps, bool isMobile) {
    int pending = apps.where((e) => e["status"] == "PENDING").length;
    int completed = apps.where((e) => e["status"] == "VERIFIED").length;
    int high = apps.where((e) => e["priority"] == "High").length;

    final stats = [
      _StatCard("Pending Verifications", "$pending", Colors.orange),
      _StatCard("Completed", "$completed", Colors.green),
      _StatCard("High Priority", "$high", Colors.red),
      _StatCard("Total Documents", "${apps.length * 4}", Colors.blue),
    ];

    return isMobile
        ? SizedBox(
            height: 110,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemBuilder: (_, i) => SizedBox(width: 220, child: stats[i]),
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemCount: stats.length,
            ),
          )
        : Row(children: stats);
  }

  /// ============================
  /// APPLICATION LIST
  /// ============================

  Widget _applicationsList(List apps, bool isMobile) {
    return ListView.builder(
      itemCount: apps.length,
      itemBuilder: (context, index) {
        final app = apps[index];

        return GestureDetector(
          onTap: () {
            setState(() => selectedIndex = index);

            if (isMobile) {
              _openMobileDetails(app);
            }
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: selectedIndex == index
                      ? Colors.blue
                      : Colors.transparent),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      app["name"] ?? "",
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                    const Spacer(),
                    _priorityChip(app["priority"] ?? "Low")
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  "${app["loanType"]} • ₹${app["amount"]}",
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: (app["progress"] ?? 0).toDouble(),
                  minHeight: 6,
                ),
                const SizedBox(height: 6),
                Text(
                  "SLA Deadline: ${app["sla"]}",
                  style: const TextStyle(fontSize: 12),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  /// ============================
  /// DOCUMENT PANEL
  /// ============================

  Widget _documentPanel(Map app) {
    Map docs = app["documents"] ?? {};

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Application ID: ${app["id"]}",
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text("Loan Type: ${app["loanType"]}"),
            Text("Amount: ₹${app["amount"]}"),
            const Divider(height: 30),
            _docTile(app["id"], "aadhaar", docs["aadhaar"] ?? false),
            _docTile(app["id"], "pan", docs["pan"] ?? false),
            _docTile(app["id"], "salarySlip", docs["salarySlip"] ?? false),
            _docTile(
                app["id"], "bankStatement", docs["bankStatement"] ?? false),
          ],
        ),
      ),
    );
  }

  /// ============================
  /// MOBILE BOTTOM SHEET
  /// ============================

  void _openMobileDetails(Map app) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: _documentPanel(app),
      ),
    );
  }

  /// ============================
  /// DOCUMENT TILE
  /// ============================

  Widget _docTile(String id, String docName, bool verified) {
    return ListTile(
      leading: const Icon(Icons.description_outlined),
      title: Text(docName),
      trailing: verified
          ? const Chip(label: Text("Verified"))
          : ElevatedButton(
              onPressed: () => verifyDocument(id, docName),
              child: const Text("Verify"),
            ),
    );
  }

  /// ============================
  /// PRIORITY CHIP
  /// ============================

  Widget _priorityChip(String priority) {
    Color color = Colors.grey;

    if (priority == "High") color = Colors.red;
    if (priority == "Medium") color = Colors.orange;

    return Chip(
      label: Text(priority),
      backgroundColor: color.withOpacity(.15),
      labelStyle: TextStyle(color: color),
    );
  }
}

/// ============================
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _StatCard(this.title, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            )
          ],
        ),
      ),
    );
  }
}
