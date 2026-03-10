import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'loan_officer_widgets.dart';

class LoanOfficerDashboardPage extends StatefulWidget {
  const LoanOfficerDashboardPage({super.key});

  @override
  State<LoanOfficerDashboardPage> createState() =>
      _LoanOfficerDashboardPageState();
}

class _LoanOfficerDashboardPageState extends State<LoanOfficerDashboardPage> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final TextEditingController searchCtrl = TextEditingController();
  final TextEditingController remarkCtrl = TextEditingController();

  LoanApplication? selectedApp;

  int notificationCount = 0;

  /// ===============================
  /// FIREBASE STREAM
  /// ===============================

  Stream<List<LoanApplication>> getApplications() {
    return firestore
        .collection("loan_applications")
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map((snapshot) {
      notificationCount = snapshot.docs.length;

      return snapshot.docs.map((doc) {
        final data = doc.data();

        Timestamp? ts = data["createdAt"];

        return LoanApplication(
          id: doc.id,
          name: data["userName"] ?? "",
          loanType: data["loanType"] ?? "",
          status: data["status"] ?? "PENDING",
          credit: data["credit"] ?? 0,
          amount: "₹${data["amount"] ?? 0}",
          date: ts != null ? ts.toDate() : DateTime.now(),
          tenureMonths: data["tenure"] ?? 12,
          interestRate: (data["interestRate"] ?? 10).toDouble(),
          // documents: List<String>.from(data["documents"] ?? []),
        );
      }).toList();
    });
  }

  /// ===============================
  /// UPDATE STATUS
  /// ===============================

  Future<void> updateStatus(String status) async {
    if (selectedApp == null) return;

    try {
      await firestore
          .collection("loan_applications")
          .doc(selectedApp!.id)
          .update({
        "status": status,
        "loanOfficerRemark": remarkCtrl.text,
        "reviewedBy": "LoanOfficer",
        "reviewedAt": FieldValue.serverTimestamp(),
      });

      /// CREATE NOTIFICATION

      await firestore.collection("notifications").add({
        "title": "Loan Status Updated",
        "message": "Application ${selectedApp!.name} moved to $status",
        "loanId": selectedApp!.id,
        "createdAt": FieldValue.serverTimestamp()
      });

      remarkCtrl.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Application moved to $status")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  /// ===============================
  /// UI
  /// ===============================

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 900;

    return Scaffold(
      backgroundColor: const Color(0xfff5f7fb),
      appBar: AppBar(
        title: const Text("Loan Officer Dashboard"),
        elevation: 0,
        actions: [
          /// NOTIFICATION ICON

          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () {},
              ),
              if (notificationCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(
                        color: Colors.red, shape: BoxShape.circle),
                    child: Text(
                      notificationCount.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                )
            ],
          )
        ],
      ),
      body: StreamBuilder<List<LoanApplication>>(
        stream: getApplications(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Error loading applications"));
          }

          final apps = snapshot.data ?? [];

          final filtered = apps.where((app) {
            final q = searchCtrl.text.toLowerCase();

            return app.name.toLowerCase().contains(q) ||
                app.id.toLowerCase().contains(q);
          }).toList();

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                /// SEARCH BAR

                TextField(
                  controller: searchCtrl,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: "Search application...",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                  ),
                ),

                const SizedBox(height: 20),

                Expanded(
                  child:
                      isMobile ? _mobileLayout(filtered) : _webLayout(filtered),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  /// ===============================
  /// WEB LAYOUT
  /// ===============================

  Widget _webLayout(List<LoanApplication> apps) {
    return Row(
      children: [
        /// APPLICATION LIST

        Container(
          width: 340,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: ListView.builder(
            itemCount: apps.length,
            itemBuilder: (context, index) {
              final app = apps[index];

              return ListTile(
                selected: selectedApp?.id == app.id,
                title: Text(app.name),
                subtitle: Text(app.loanType),
                trailing: _statusChip(app.status),
                onTap: () {
                  setState(() {
                    selectedApp = app;
                  });
                },
              );
            },
          ),
        ),

        const SizedBox(width: 20),

        Expanded(child: _detailsPanel())
      ],
    );
  }

  /// ===============================
  /// MOBILE LAYOUT
  /// ===============================

  Widget _mobileLayout(List<LoanApplication> apps) {
    return ListView.builder(
      itemCount: apps.length,
      itemBuilder: (context, index) {
        final app = apps[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 14),
          child: ListTile(
            title: Text(app.name),
            subtitle: Text(app.loanType),
            trailing: _statusChip(app.status),
            onTap: () {
              setState(() {
                selectedApp = app;
              });

              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (_) => Padding(
                  padding: const EdgeInsets.all(20),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: _detailsPanel(),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  /// ===============================
  /// DETAILS PANEL
  /// ===============================

  Widget _detailsPanel() {
    if (selectedApp == null) {
      return const Center(child: Text("Select an application"));
    }

    final app = selectedApp!;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(app.name,
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text("Loan Type: ${app.loanType}"),
            Text("Amount: ${app.amount}"),
            Text("Tenure: ${app.tenureMonths} months"),
            Text("Interest: ${app.interestRate}%"),
            const SizedBox(height: 20),
            Text(
              "EMI ₹${_calculateEmi(app).toStringAsFixed(0)}",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: remarkCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Officer Remark",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                ElevatedButton(
                    onPressed: () => updateStatus("APPROVED"),
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text("Approve")),
                ElevatedButton(
                    onPressed: () => updateStatus("ON HOLD"),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange),
                    child: const Text("Hold")),
                ElevatedButton(
                    onPressed: () => updateStatus("REJECTED"),
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text("Reject")),
                ElevatedButton.icon(
                    onPressed: () => updateStatus("MANAGER_APPROVAL"),
                    icon: const Icon(Icons.forward),
                    label: const Text("Send to Manager"))
              ],
            )
          ],
        ),
      ),
    );
  }

  /// STATUS CHIP

  Widget _statusChip(String status) {
    Color color = Colors.grey;

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
    }

    return Chip(
      label: Text(status),
      backgroundColor: color.withOpacity(.15),
      labelStyle: TextStyle(color: color),
    );
  }

  /// EMI

  double _calculateEmi(LoanApplication app) {
    final p = _parseAmount(app.amount);

    final r = app.interestRate / 12 / 100;

    final n = app.tenureMonths;

    final factor = math.pow((1 + r), n);

    return p * r * factor / (factor - 1);
  }

  double _parseAmount(String amount) {
    final digits = amount.replaceAll(RegExp(r'[^0-9.]'), '');

    return double.tryParse(digits) ?? 0;
  }
}
