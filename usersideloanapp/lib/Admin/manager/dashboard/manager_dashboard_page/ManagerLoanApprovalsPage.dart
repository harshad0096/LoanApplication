import 'dart:math' as Math;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:usersideloanapp/Admin/loan_officer/loan_officer_widgets.dart';

class ManagerLoanApprovalsPage extends StatefulWidget {
  const ManagerLoanApprovalsPage({Key? key}) : super(key: key);

  @override
  State<ManagerLoanApprovalsPage> createState() =>
      _ManagerLoanApprovalsPageState();
}

class _ManagerLoanApprovalsPageState extends State<ManagerLoanApprovalsPage> {
  final TextEditingController searchCtrl = TextEditingController();
  final TextEditingController managerRemarkCtrl = TextEditingController();

  LoanApplication? selectedApp;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    searchCtrl.dispose();
    managerRemarkCtrl.dispose();
    super.dispose();
  }

  /// =========================
  /// FIRESTORE STREAM
  /// =========================

  Stream<List<LoanApplication>> getApplications() {
    return _firestore
        .collection('loan_applications')
        .where('status', isEqualTo: 'MANAGER_APPROVAL')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              Timestamp? ts = data['createdAt'];

              return LoanApplication(
                id: doc.id,
                name: data['userName'] ?? "Unknown",
                loanType: data['loanType'] ?? "Loan",
                status: data['status'] ?? "",
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
  /// UPDATE STATUS
  /// =========================

  Future<void> _updateStatus(String status) async {
    if (selectedApp == null) return;

    try {
      await _firestore
          .collection('loan_applications')
          .doc(selectedApp!.id)
          .update({
        "status": status,
        "managerRemark": managerRemarkCtrl.text,
        "approvedBy": "Manager",
        "approvedAt": FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Application $status")),
      );

      managerRemarkCtrl.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating application")),
      );
    }
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
            /// 🔄 LOADING
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            /// ❌ ERROR
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  "Error loading applications",
                  style: TextStyle(color: Colors.red, fontSize: 18),
                ),
              );
            }

            /// 📭 NO DATA
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text(
                  "No applications waiting for manager approval",
                  style: TextStyle(fontSize: 18),
                ),
              );
            }

            final queue = snapshot.data!;

            final filtered = queue.where((a) {
              final search = searchCtrl.text.toLowerCase();
              return a.name.toLowerCase().contains(search) ||
                  a.id.toLowerCase().contains(search);
            }).toList();

            /// 🔍 NO SEARCH RESULTS
            if (filtered.isEmpty) {
              return const Center(
                child: Text(
                  "No matching applications found",
                  style: TextStyle(fontSize: 18),
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// HEADER
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Manager Loan Approvals",
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        width: 300,
                        child: TextField(
                          controller: searchCtrl,
                          onChanged: (_) => setState(() {}),
                          decoration: const InputDecoration(
                            hintText: "Search Application",
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
                                    child: Text("Select application"),
                                  )
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
                                              fontWeight: FontWeight.bold),
                                        ),

                                        const SizedBox(height: 10),

                                        Text(
                                            "Loan Type: ${selectedApp!.loanType}"),
                                        Text("Amount: ${selectedApp!.amount}"),
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
                                              fontWeight: FontWeight.bold),
                                        ),

                                        const SizedBox(height: 20),

                                        /// REMARK
                                        TextField(
                                          controller: managerRemarkCtrl,
                                          maxLines: 3,
                                          decoration: InputDecoration(
                                            hintText: "Manager remark...",
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                        ),

                                        const SizedBox(height: 20),

                                        /// ACTION BUTTONS
                                        Row(
                                          children: [
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.green),
                                              onPressed: () =>
                                                  _updateStatus("APPROVED"),
                                              child: const Text("Approve Loan"),
                                            ),
                                            const SizedBox(width: 10),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.red),
                                              onPressed: () =>
                                                  _updateStatus("REJECTED"),
                                              child: const Text("Reject"),
                                            ),
                                            const SizedBox(width: 10),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.orange),
                                              onPressed: () => _updateStatus(
                                                  "LOAN_OFFICER_REVIEW"),
                                              child: const Text("Send Back"),
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
