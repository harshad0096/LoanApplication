import 'dart:io';
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
  const UserLoansPage({super.key});

  @override
  State<UserLoansPage> createState() => _UserLoansPageState();
}

class _UserLoansPageState extends State<UserLoansPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final String userId = FirebaseAuth.instance.currentUser!.uid;
  final ImagePicker _picker = ImagePicker();

  // ================= SAFE DOUBLE CONVERTER =================
  double toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  // ================= EMI CALC =================
  double calculateEMI(double principal, double annualRate, int months) {
    double monthlyRate = annualRate / 12 / 100;
    if (monthlyRate == 0 || months == 0)
      return principal / (months == 0 ? 1 : months);

    return principal *
        monthlyRate *
        (pow(1 + monthlyRate, months)) /
        (pow(1 + monthlyRate, months) - 1);
  }

  // ================= UPLOAD DOCUMENT =================
  Future<void> uploadDocument(String loanId) async {
    Uint8List? fileBytes;
    String fileName = "";

    try {
      // WEB
      if (kIsWeb) {
        FilePickerResult? result =
            await FilePicker.platform.pickFiles(withData: true);
        if (result != null) {
          fileBytes = result.files.first.bytes;
          fileName = result.files.first.name;
        }
      } else {
        // MOBILE (Camera + Gallery)
        final source = await showModalBottomSheet<ImageSource>(
          context: context,
          builder: (_) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text("Camera"),
                  onTap: () => Navigator.pop(context, ImageSource.camera)),
              ListTile(
                  leading: const Icon(Icons.photo),
                  title: const Text("Gallery"),
                  onTap: () => Navigator.pop(context, ImageSource.gallery)),
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

      // ================= PREVIEW BEFORE SUBMIT =================
      final confirm = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Preview Document"),
          content: Image.memory(fileBytes!, height: 200),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel")),
            ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Upload")),
          ],
        ),
      );

      if (confirm != true) return;

      // ================= UPLOAD TO STORAGE =================
      final ref = _storage
          .ref()
          .child("loan_documents")
          .child(userId)
          .child(loanId)
          .child(fileName);

      await ref.putData(fileBytes);

      final downloadUrl = await ref.getDownloadURL();

      // ================= SAVE TO FIRESTORE =================
      await _firestore.collection("loan_documents").add({
        "userId": userId,
        "loanId": loanId,
        "fileName": fileName,
        "fileUrl": downloadUrl,
        "uploadedAt": FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Document Uploaded Successfully")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error uploading document: $e")),
        );
      }
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    /// USER NOT LOGGED IN
    if (currentUser == null) {
      return const Scaffold(
        body: Center(
          child: Text("User not logged in"),
        ),
      );
    }

    final String userId = currentUser.uid;

    return Scaffold(
      backgroundColor: const Color(0xfff4f6ff),
      appBar: AppBar(
        title: const Text("My Loan Applications"),
        centerTitle: true,
        backgroundColor: const Color(0xff6366F1),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('loan_applications')
            .where('userId', isEqualTo: userId)
            .orderBy('createdAt', descending: true)
            .limit(50)
            .snapshots(),
        builder: (context, snapshot) {
          /// ================= LOADING =================
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          /// ================= ERROR =================
          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error loading loans\n${snapshot.error}",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          /// ================= EMPTY =================
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No loan applications found",
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;

              final loanType = data["loanType"] ?? "Loan";
              final amount = toDouble(data["loanAmount"]);
              final tenure = (data["tenureMonths"] ?? 0).toInt();
              final status = data["status"] ?? "SUBMITTED";

              /// POLICY SNAPSHOT
              Map<String, dynamic> policy = {};
              if (data["policySnapshot"] != null) {
                policy = Map<String, dynamic>.from(data["policySnapshot"]);
              }

              final interest = toDouble(policy["interest"]);
              final emi = calculateEMI(amount, interest, tenure);

              return _loanCard(
                loanId: doc.id,
                loanType: loanType,
                amount: amount,
                tenure: tenure,
                status: status,
                emi: emi,
                policy: policy,
              );
            },
          );
        },
      ),
    );
  }

  Widget _loanCard({
    required String loanId,
    required String loanType,
    required double amount,
    required int tenure,
    required String status,
    required double emi,
    required Map<String, dynamic> policy,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xff6D5DF6), Color(0xffEC4899)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Loan ID: $loanId",
              style: const TextStyle(color: Colors.white, fontSize: 12)),
          const SizedBox(height: 8),
          Text("Type: $loanType",
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
          Text("Amount: ₹${amount.toStringAsFixed(0)}",
              style: const TextStyle(color: Colors.white, fontSize: 14)),
          Text("Tenure: $tenure Months",
              style: const TextStyle(color: Colors.white, fontSize: 14)),
          Text("EMI: ₹${emi.toStringAsFixed(0)} / month",
              style: const TextStyle(color: Colors.white, fontSize: 14)),
          Text("Status: $status",
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),

          // Policy Info
          if (policy.isNotEmpty) ...[
            const Divider(color: Colors.white70),
            const Text("Loan Policy",
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            Text(
                "Interest: ${toDouble(policy['interest']).toStringAsFixed(2)}%",
                style: const TextStyle(color: Colors.white, fontSize: 12)),
            Text(
                "Min Amount: ₹${toDouble(policy['minAmount']).toStringAsFixed(0)}",
                style: const TextStyle(color: Colors.white, fontSize: 12)),
            Text(
                "Max Amount: ₹${toDouble(policy['maxAmount']).toStringAsFixed(0)}",
                style: const TextStyle(color: Colors.white, fontSize: 12)),
            Text("Min Tenure: ${policy['minTenure']} Months",
                style: const TextStyle(color: Colors.white, fontSize: 12)),
            Text("Max Tenure: ${policy['maxTenure']} Months",
                style: const TextStyle(color: Colors.white, fontSize: 12)),
            Text(
                "Processing Fee: ${toDouble(policy['processingFee']).toStringAsFixed(2)}%",
                style: const TextStyle(color: Colors.white, fontSize: 12)),
            const SizedBox(height: 10),
          ],

          // Upload Button
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white, foregroundColor: Colors.black),
              onPressed: () => uploadDocument(loanId),
              icon: const Icon(Icons.upload_file),
              label: const Text("Upload Document"),
            ),
          )
        ],
      ),
    );
  }
}
