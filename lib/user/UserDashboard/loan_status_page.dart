import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

class UserLoansPage extends StatefulWidget {
  const UserLoansPage({super.key, required Map<String, dynamic> loanData});

  @override
  State<UserLoansPage> createState() => _UserLoansPageState();
}

class _UserLoansPageState extends State<UserLoansPage>
    with SingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  late final String userId;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      Future.microtask(() => Navigator.pop(context));
      return;
    }

    userId = currentUser.uid;

    _fadeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));

    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  // ================= SAFE DOUBLE =================

  double toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  // ================= EMI CALC =================

  double calculateEMI(double principal, double annualRate, int months) {
    if (principal <= 0 || months <= 0) return 0;

    double monthlyRate = annualRate / 12 / 100;

    if (monthlyRate == 0) return principal / months;

    return principal *
        monthlyRate *
        pow(1 + monthlyRate, months) /
        (pow(1 + monthlyRate, months) - 1);
  }

  // ================= DOCUMENT UPLOAD =================

  Future<void> uploadDocument(String loanId) async {
    Uint8List? fileBytes;
    String fileName = "";

    try {
      if (kIsWeb) {
        final result = await FilePicker.platform.pickFiles(withData: true);

        if (result != null && result.files.isNotEmpty) {
          fileBytes = result.files.first.bytes;
          fileName = result.files.first.name;
        }
      } else {
        final source = await showModalBottomSheet<ImageSource>(
          context: context,
          builder: (_) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Camera"),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text("Gallery"),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        );

        if (source != null) {
          final picked = await _picker.pickImage(source: source);

          if (picked != null) {
            fileBytes = await picked.readAsBytes();
            fileName = picked.name;
          }
        }
      }

      if (fileBytes == null) return;

      final ref = _storage
          .ref()
          .child("loan_documents")
          .child(userId)
          .child(loanId)
          .child(fileName);

      await ref.putData(fileBytes);

      final url = await ref.getDownloadURL();

      await _firestore.collection("loan_documents").add({
        "userId": userId,
        "loanId": loanId,
        "fileUrl": url,
        "fileName": fileName,
        "uploadedAt": FieldValue.serverTimestamp()
      });

      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Document Uploaded")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  // ================= LOAN CARD =================

  Widget loanCard(Map<String, dynamic> data, String loanId) {
    final loanType = data["loanType"] ?? "Loan";
    final amount = toDouble(data["loanAmount"] ?? data["amount"]);
    final tenure = (data["tenureMonths"] ?? data["tenure"] ?? 0).toInt();
    final paidAmount = toDouble(data["paidAmount"]);

    final status = data["status"] ?? "PENDING";

    final policy = Map<String, dynamic>.from(data["policySnapshot"] ?? {});
    final interest = toDouble(policy["interest"]);

    final emi = calculateEMI(amount, interest, tenure);

    double progress = 0;

    if (amount > 0) {
      progress = paidAmount / amount;
    }

    progress = progress.clamp(0.0, 1.0);

    Color statusColor = status == "APPROVED"
        ? Colors.green
        : status == "REJECTED"
            ? Colors.red
            : Colors.orange;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        showLoanDetails(data, loanId, emi, progress);
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: glass(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Loan ID: $loanId",
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 8),
            Text(
              loanType,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xff6366F1)),
            ),
            const SizedBox(height: 8),
            Text("Amount: ₹${amount.toStringAsFixed(0)}"),
            Text("Tenure: $tenure Months"),
            Text("EMI: ₹${emi.toStringAsFixed(0)} / month"),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.grey.shade300,
              color: const Color(0xff6366F1),
            ),
            const SizedBox(height: 6),
            Text(
              "Progress ${(progress * 100).toStringAsFixed(0)}%",
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  status,
                  style: TextStyle(
                      color: statusColor, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: () => uploadDocument(loanId),
                  icon: const Icon(Icons.upload_file),
                  label: const Text("Upload"),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  // ================= LOAN DETAILS =================

  void showLoanDetails(
      Map<String, dynamic> data, String loanId, double emi, double progress) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Loan Details",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            detail("Loan ID", loanId),
            detail("Loan Type", data["loanType"]),
            detail("Amount", "₹${data["amount"]}"),
            detail("Tenure", "${data["tenure"]} months"),
            detail("Status", data["status"]),
            detail("Monthly EMI", "₹${emi.toStringAsFixed(0)}"),
            const SizedBox(height: 20),
            LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              color: const Color(0xff6366F1),
            ),
            const SizedBox(height: 10),
            Text("Repayment ${(progress * 100).toStringAsFixed(0)}%"),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget detail(String title, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value?.toString() ?? "-"),
        ],
      ),
    );
  }

  // ================= BUILD =================

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("My Loan Applications"),
          backgroundColor: const Color(0xff6366F1),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: _firestore
              .collection('loan_applications')
              .where('userId', isEqualTo: userId)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.data!.docs.isEmpty) {
              return const Center(child: Text("No Loan Applications"));
            }

            final loans = snapshot.data!.docs;

            return ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: loans.length,
              itemBuilder: (context, index) {
                final doc = loans[index];
                final data = doc.data() as Map<String, dynamic>;

                // Pass the context here so the popup can show correctly
                return buildLoanStatusCard(context, data, doc.id);
              },
            );
          },
        ),
      ),
    );
  }

  //appli time line status pop up
  void showLoanDetailsPopup(BuildContext context, Map<String, dynamic> data) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows full control over height
      backgroundColor:
          Colors.transparent, // Necessary for custom rounded corners
      builder: (context) {
        return Container(
          height:
              MediaQuery.of(context).size.height * 0.85, // 85% of screen height
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const Text("Application Timeline",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),

              // Timeline Widget
              Expanded(
                child: ListView(
                  children: [
                    _buildTimelineTile(
                      title: "Application Submitted",
                      subtitle:
                          "Your loan application has been received and logged",
                      date: "Jan 15, 2024 • 10:30 AM",
                      isCompleted: true,
                      isLast: false,
                    ),
                    _buildTimelineTile(
                      title: "Under Verification",
                      subtitle: "Documents are being reviewed by our team",
                      date: "Jan 16, 2024 • 2:15 PM",
                      isCompleted: false, // Active
                      isLast: false,
                      isActive: true,
                    ),
                    _buildTimelineTile(
                      title: "Approval",
                      subtitle: "Waiting for credit team approval",
                      date: "",
                      isCompleted: false,
                      isLast: false,
                    ),
                    _buildTimelineTile(
                      title: "Disbursement",
                      subtitle:
                          "Loan amount will be transferred to your account",
                      date: "",
                      isCompleted: false,
                      isLast: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildLoanStatusCard(
      BuildContext context, Map<String, dynamic> data, String docId) {
    return InkWell(
      onTap: () {
        // This triggers the timeline popup when the card is clicked
        showLoanDetailsPopup(context, data);
      },
      borderRadius: BorderRadius.circular(20), // Keeps ripple effect rounded
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xff6366F1), Color(0xffEC4899)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Application ID",
                style: TextStyle(color: Colors.white70, fontSize: 12)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(docId,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                const Icon(Icons.copy, color: Colors.white70, size: 16),
              ],
            ),
            const SizedBox(height: 10),
            Text(
                "${data['loanType']} • ₹${data['amount']} • Applied ${data['appliedDate'] ?? 'N/A'}",
                style: const TextStyle(color: Colors.white, fontSize: 13)),
            const Divider(color: Colors.white24, height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Est. Approval",
                        style: TextStyle(color: Colors.white70, fontSize: 12)),
                    Text("24-48 hrs",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text("Current Stage",
                        style: TextStyle(color: Colors.white70, fontSize: 12)),
                    Text(data['status'] ?? "Verification",
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    const Text("Step 2 of 4",
                        style: TextStyle(color: Colors.white70, fontSize: 10)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

// Reusable Timeline Tile Widget
  Widget _buildTimelineTile({
    required String title,
    required String subtitle,
    required String date,
    required bool isCompleted,
    required bool isLast,
    bool isActive = false,
  }) {
    return IntrinsicHeight(
      child: Row(
        children: [
          Column(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted
                      ? Colors.teal
                      : (isActive
                          ? Colors.indigo.shade100
                          : Colors.grey.shade200),
                ),
                child: Icon(
                    isCompleted
                        ? Icons.check
                        : (isActive ? Icons.access_time : Icons.circle),
                    size: 16,
                    color: isCompleted
                        ? Colors.white
                        : (isActive ? Colors.indigo : Colors.grey)),
              ),
              if (!isLast)
                Expanded(
                    child: Container(width: 2, color: Colors.grey.shade300)),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isActive ? Colors.indigo.shade50 : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: isActive
                      ? Border.all(color: Colors.indigo.shade100)
                      : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isActive ? Colors.indigo : Colors.black)),
                    Text(subtitle,
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey)),
                    if (date.isNotEmpty)
                      Text(date,
                          style: const TextStyle(
                              fontSize: 10, color: Colors.teal)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildFeaturesRow(BoxConstraints constraints) {
    final bool isMobile = constraints.maxWidth < 600;

    final features = [
      {
        "icon": Icons.access_time,
        "title": "Quick Approval",
        "sub": "Get approved within 24 hours"
      },
      {
        "icon": Icons.shield_outlined,
        "title": "100% Secure",
        "sub": "Bank-grade encryption"
      },
      {
        "icon": Icons.show_chart,
        "title": "Flexible EMI",
        "sub": "Choose your repayment plan"
      },
      {
        "icon": Icons.check_circle_outline,
        "title": "No Hidden Fees",
        "sub": "Transparent processing"
      },
    ];

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      alignment: WrapAlignment.center,
      children: features
          .map((f) => Container(
                width: isMobile ? constraints.maxWidth : 250,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: const Color(0xff6366F1).withOpacity(0.1),
                      child: Icon(f["icon"] as IconData,
                          color: const Color(0xff6366F1), size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(f["title"] as String,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          Text(f["sub"] as String,
                              style: TextStyle(
                                  fontSize: 11, color: Colors.grey.shade600)),
                        ],
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }

  // ================= GLASS UI =================

  BoxDecoration glass() {
    return BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 15)
      ],
    );
  }
  //mu
}
