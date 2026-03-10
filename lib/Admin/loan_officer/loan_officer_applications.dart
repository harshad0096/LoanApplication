import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoanOfficerApplicationsPage extends StatefulWidget {
  const LoanOfficerApplicationsPage({super.key});

  @override
  State<LoanOfficerApplicationsPage> createState() =>
      _LoanOfficerApplicationsPageState();
}

class _LoanOfficerApplicationsPageState
    extends State<LoanOfficerApplicationsPage>
    with SingleTickerProviderStateMixin {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  late TabController _tabController;

  final TextEditingController searchCtrl = TextEditingController();
  final TextEditingController remarkCtrl = TextEditingController();

  Map<String, dynamic>? selectedApplication;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  /// =========================
  /// FIREBASE STREAM
  /// =========================

  Stream<List<Map<String, dynamic>>> getApplications() {
    return firestore
        .collection("loan_applications")
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();

        data["id"] = doc.id;

        return data;
      }).toList();
    });
  }

  /// =========================
  /// UPDATE STATUS
  /// =========================

  Future<void> updateStatus(String status) async {
    if (selectedApplication == null) return;

    await firestore
        .collection("loan_applications")
        .doc(selectedApplication!["id"])
        .update({
      "status": status,
      "loanOfficerRemark": remarkCtrl.text,
      "reviewedBy": "LoanOfficer",
      "reviewedAt": FieldValue.serverTimestamp()
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Status updated to $status")));
  }

  /// =========================
  /// UI
  /// =========================

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 900;

    return Scaffold(
      backgroundColor: const Color(0xfff5f7fb),
      appBar: AppBar(
        title: const Text("Loan Applications"),
        elevation: 0,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: getApplications(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final apps = snapshot.data!;

          final filtered = apps.where((app) {
            final q = searchCtrl.text.toLowerCase();
            return (app["userName"] ?? "").toLowerCase().contains(q) ||
                (app["id"] ?? "").toLowerCase().contains(q);
          }).toList();

          if (selectedApplication == null && filtered.isNotEmpty) {
            selectedApplication = filtered.first;
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                /// SEARCH

                TextField(
                  controller: searchCtrl,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: "Search applications...",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                  ),
                ),

                const SizedBox(height: 16),

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

  /// =========================
  /// WEB LAYOUT
  /// =========================

  Widget _webLayout(List<Map<String, dynamic>> apps) {
    return Row(
      children: [
        /// LEFT LIST

        SizedBox(width: 360, child: _applicationList(apps)),

        const SizedBox(width: 16),

        /// RIGHT DETAILS

        Expanded(child: _applicationDetails())
      ],
    );
  }

  /// =========================
  /// MOBILE LAYOUT
  /// =========================

  Widget _mobileLayout(List<Map<String, dynamic>> apps) {
    return ListView.builder(
      itemCount: apps.length,
      itemBuilder: (context, index) {
        final app = apps[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text(app["userName"] ?? ""),
            subtitle: Text(app["loanType"] ?? ""),
            trailing: _statusChip(app["status"] ?? ""),
            onTap: () {
              setState(() {
                selectedApplication = app;
              });

              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (_) => SizedBox(
                  height: MediaQuery.of(context).size.height * .8,
                  child: _applicationDetails(),
                ),
              );
            },
          ),
        );
      },
    );
  }

  /// =========================
  /// APPLICATION LIST
  /// =========================

  Widget _applicationList(List<Map<String, dynamic>> apps) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListView.builder(
        itemCount: apps.length,
        itemBuilder: (context, index) {
          final app = apps[index];

          bool active = selectedApplication?["id"] == app["id"];

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedApplication = app;
              });
            },
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: active ? Colors.blue.shade50 : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: active ? Border.all(color: Colors.blue) : null,
              ),
              child: ListTile(
                title: Text(app["userName"] ?? ""),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(app["id"]),
                    Text("${app["loanType"]} • ₹${app["amount"] ?? 0}")
                  ],
                ),
                trailing: _statusChip(app["status"] ?? ""),
              ),
            ),
          );
        },
      ),
    );
  }

  /// =========================
  /// DETAILS PANEL
  /// =========================

  Widget _applicationDetails() {
    if (selectedApplication == null) {
      return const Center(child: Text("Select Application"));
    }

    final app = selectedApplication!;

    double emi = _calculateEmi(
        app["amount"] ?? 0, app["interestRate"] ?? 10, app["tenure"] ?? 12);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// HEADER

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(app["userName"] ?? "",
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(app["loanType"] ?? ""),
                  ],
                ),
                Row(
                  children: [
                    _actionButton("Approve", Icons.check, Colors.green,
                        () => updateStatus("APPROVED")),
                    const SizedBox(width: 8),
                    _actionButton("Hold", Icons.pause, Colors.orange,
                        () => updateStatus("ON HOLD")),
                    const SizedBox(width: 8),
                    _actionButton("Reject", Icons.close, Colors.red,
                        () => updateStatus("REJECTED")),
                  ],
                )
              ],
            ),

            const SizedBox(height: 20),

            /// TABS

            TabBar(
              controller: _tabController,
              labelColor: Colors.blue,
              tabs: const [
                Tab(text: "Loan Details"),
                Tab(text: "Applicant Info"),
                Tab(text: "Documents"),
                Tab(text: "Eligibility")
              ],
            ),

            const SizedBox(height: 20),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  /// LOAN DETAILS

                  ListView(
                    children: [
                      GridView.count(
                        crossAxisCount: 4,
                        shrinkWrap: true,
                        childAspectRatio: 2.5,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _infoCard("Amount", "₹${app["amount"] ?? 0}"),
                          _infoCard("Tenure", "${app["tenure"]} months"),
                          _infoCard("Interest", "${app["interestRate"]}%"),
                          _infoCard("Credit Score", "${app["credit"] ?? 0}")
                        ],
                      ),
                      const SizedBox(height: 20),
                      _infoCard("Monthly EMI", "₹${emi.toStringAsFixed(0)}")
                    ],
                  ),

                  const Center(child: Text("Applicant Info")),
                  const Center(child: Text("Documents")),
                  const Center(child: Text("Eligibility")),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  /// =========================
  /// STATUS CHIP
  /// =========================

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

  /// =========================
  /// EMI
  /// =========================

  double _calculateEmi(amount, rate, tenure) {
    double p = amount.toDouble();

    double r = rate / 12 / 100;

    double n = tenure.toDouble();

    double factor = math.pow((1 + r), n).toDouble();

    return p * r * factor / (factor - 1);
  }

  /// =========================
  /// UI HELPERS
  /// =========================

  Widget _actionButton(
      String label, IconData icon, Color color, VoidCallback onTap) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: color),
      label: Text(label, style: TextStyle(color: color)),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: color),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _infoCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(height: 6),
          Text(value,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
