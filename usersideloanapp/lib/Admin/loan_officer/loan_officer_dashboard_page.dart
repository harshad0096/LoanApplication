import 'dart:math' as Math;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'loan_officer_widgets.dart';

class LoanOfficerDashboardPage extends StatefulWidget {
  const LoanOfficerDashboardPage({Key? key}) : super(key: key);

  @override
  State<LoanOfficerDashboardPage> createState() =>
      _LoanOfficerDashboardPageState();
}

class _LoanOfficerDashboardPageState extends State<LoanOfficerDashboardPage> {
  final TextEditingController searchCtrl = TextEditingController();
  final TextEditingController remarkCtrl = TextEditingController();

  LoanApplication? selectedApp;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    searchCtrl.dispose();
    remarkCtrl.dispose();
    super.dispose();
  }

  /// =========================
  /// FIREBASE STREAM
  /// =========================

  Stream<List<LoanApplication>> getApplications() {
    return _firestore
        .collection('loan_applications')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              Timestamp? ts = data['createdAt'];

              return LoanApplication(
                id: doc.id,
                name: data['userName'] ?? '',
                loanType: data['loanType'] ?? '',
                status: data['status'] ?? 'PENDING',
                credit: data['credit'] ?? 0,
                amount: "₹${data['amount'] ?? 0}",
                date: ts != null ? ts.toDate() : DateTime.now(),
                tenureMonths: data['tenure'] ?? 12,
                interestRate: (data['interestRate'] ?? 10).toDouble(),
                documents: [],
              );
            }).toList());
  }

  /// =========================
  /// UPDATE STATUS + REMARK
  /// =========================

  Future<void> _changeStatus(String newStatus) async {
    if (selectedApp == null) return;

    await _firestore
        .collection('loan_applications')
        .doc(selectedApp!.id)
        .update({
      "status": newStatus,
      "loanOfficerRemark": remarkCtrl.text,
      "reviewedBy": "LoanOfficer",
      "reviewedAt": FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Application moved to $newStatus")),
    );

    remarkCtrl.clear();
  }

  /// =========================
  /// UI
  /// =========================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<List<LoanApplication>>(
          stream: getApplications(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final queue = snapshot.data!;

            final filtered = queue
                .where((a) =>
                    a.name
                        .toLowerCase()
                        .contains(searchCtrl.text.toLowerCase()) ||
                    a.id.toLowerCase().contains(searchCtrl.text.toLowerCase()))
                .toList();

            return Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// HEADER
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Application Review',
                              style: TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              width: 300,
                              child: TextField(
                                controller: searchCtrl,
                                onChanged: (_) => setState(() {}),
                                decoration: const InputDecoration(
                                  hintText: 'Search',
                                  prefixIcon: Icon(Icons.search),
                                ),
                              ),
                            )
                          ],
                        ),

                        const SizedBox(height: 20),

                        Expanded(
                          child: Row(
                            children: [
                              /// LEFT LIST
                              Container(
                                width: 350,
                                child: Card(
                                  child: ListView.builder(
                                    itemCount: filtered.length,
                                    itemBuilder: (context, index) {
                                      final app = filtered[index];

                                      return ListTile(
                                        title: Text(app.name),
                                        subtitle: Text(app.loanType),
                                        trailing: Text(app.status),
                                        selected: selectedApp?.id == app.id,
                                        onTap: () {
                                          setState(() {
                                            selectedApp = app;
                                          });
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ),

                              const SizedBox(width: 20),

                              /// RIGHT PANEL
                              Expanded(
                                child: Card(
                                  child: selectedApp == null
                                      ? const Center(
                                          child: Text("Select application"))
                                      : Padding(
                                          padding: const EdgeInsets.all(20),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              /// NAME
                                              Text(
                                                selectedApp!.name,
                                                style: const TextStyle(
                                                    fontSize: 22,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),

                                              const SizedBox(height: 10),

                                              Text(
                                                  "Loan Type: ${selectedApp!.loanType}"),
                                              Text(
                                                  "Amount: ${selectedApp!.amount}"),
                                              Text(
                                                  "Tenure: ${selectedApp!.tenureMonths} months"),
                                              Text(
                                                  "Interest: ${selectedApp!.interestRate}%"),

                                              const SizedBox(height: 20),

                                              /// EMI
                                              Text(
                                                "EMI: ₹${_calculateEmi(selectedApp!).toStringAsFixed(0)}",
                                                style: const TextStyle(
                                                    fontSize: 20,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),

                                              const SizedBox(height: 20),

                                              /// REMARK BOX
                                              TextField(
                                                controller: remarkCtrl,
                                                maxLines: 3,
                                                decoration: InputDecoration(
                                                  hintText:
                                                      "Loan officer remark...",
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                ),
                                              ),

                                              const SizedBox(height: 20),

                                              /// ACTION BUTTONS
                                              Row(
                                                children: [
                                                  ElevatedButton(
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor:
                                                          Colors.green,
                                                    ),
                                                    onPressed: () =>
                                                        _changeStatus(
                                                            "APPROVED"),
                                                    child:
                                                        const Text("Approve"),
                                                  ),

                                                  const SizedBox(width: 10),

                                                  ElevatedButton(
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor:
                                                          Colors.orange,
                                                    ),
                                                    onPressed: () =>
                                                        _changeStatus(
                                                            "ON HOLD"),
                                                    child: const Text("Hold"),
                                                  ),

                                                  const SizedBox(width: 10),

                                                  ElevatedButton(
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor:
                                                          Colors.red,
                                                    ),
                                                    onPressed: () =>
                                                        _changeStatus(
                                                            "REJECTED"),
                                                    child: const Text("Reject"),
                                                  ),

                                                  const SizedBox(width: 10),

                                                  /// NEW BUTTON
                                                  ElevatedButton.icon(
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor:
                                                          Colors.blue,
                                                    ),
                                                    onPressed: () =>
                                                        _changeStatus(
                                                            "MANAGER_APPROVAL"),
                                                    icon: const Icon(
                                                        Icons.forward),
                                                    label: const Text(
                                                        "Transfer to Manager"),
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }

  /// =========================
  /// EMI CALCULATION
  /// =========================

  double _calculateEmi(LoanApplication app) {
    final p = _parseAmount(app.amount);
    final annual = app.interestRate / 100;
    final monthly = annual / 12;
    final n = app.tenureMonths;

    final factor = Math.pow((1 + monthly), n);

    return p * monthly * factor / (factor - 1);
  }

  double _parseAmount(String amount) {
    final digits = amount.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(digits) ?? 0.0;
  }
}
