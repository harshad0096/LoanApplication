import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:usersideloanapp/user/UserDashboard/UploadLoanDocument/DocumentService.dart';

class DocumentsPage extends StatefulWidget {
  const DocumentsPage({super.key});

  @override
  State<DocumentsPage> createState() => _DocumentsPageState();
}

class _DocumentsPageState extends State<DocumentsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  final double progress = 0.25; // 25%

  @override
  void initState() {
    super.initState();

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _progressAnimation = Tween<double>(
      begin: 0,
      end: progress,
    ).animate(_progressController);

    _progressController.forward();
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  void _openUploadDialog() {
    showDialog(
        context: context,
        builder: (context) => const UploadDialog(
              documentType: '',
            ));
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 900;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: isMobile
              ? Column(
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 20),
                    _buildStats(),
                    const SizedBox(height: 20),
                    _buildDocuments(),
                    const SizedBox(height: 20),
                    _buildRightPanel(),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        children: [
                          _buildHeader(),
                          const SizedBox(height: 20),
                          _buildStats(),
                          const SizedBox(height: 20),
                          _buildDocuments(),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(flex: 1, child: _buildRightPanel()),
                  ],
                ),
        );
      },
    );
  }

  // ================= HEADER =================

  Widget _buildHeader() {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "KYC Documents",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 6),
              Text(
                "Upload and manage your verification documents",
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(30),
          ),
          child: const Row(
            children: [
              Icon(Icons.shield, color: Colors.green, size: 18),
              SizedBox(width: 6),
              Text("256-bit Encrypted"),
            ],
          ),
        ),
      ],
    );
  }

  // ================= STATS =================

  Widget _buildStats() {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 4,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isMobile ? 2 : 4,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        mainAxisExtent: isMobile ? 90 : 80, // ✅ KEY FIX
      ),
      itemBuilder: (context, index) {
        const data = [
          ("1", "Verified", Colors.green, Icons.check_circle),
          ("1", "Under Review", Colors.orange, Icons.access_time),
          ("1", "Pending", Colors.grey, Icons.info_outline),
          ("1", "Rejected", Colors.red, Icons.close),
        ];

        return StatusCard(
          data[index].$1,
          data[index].$2,
          data[index].$3,
          data[index].$4,
        );
      },
    );
  }

  // ================= DOCUMENTS =================

  Widget _buildDocuments() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection("documents")
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Column(
            children: [
              DocumentCard(
                title: "Aadhaar Card",
                subtitle: "Front and back of your Aadhaar card",
                fileName: "",
                status: "Pending",
                statusColor: Colors.grey,
                onUpload: _openUploadDialog,
              ),
              const SizedBox(height: 16),
              DocumentCard(
                title: "PAN Card",
                subtitle: "Clear image of your PAN card",
                fileName: "",
                status: "Pending",
                statusColor: Colors.grey,
                onUpload: _openUploadDialog,
              ),
              const SizedBox(height: 16),
              DocumentCard(
                title: "Salary Slip / Bank Statement",
                subtitle: "Last 3 months salary slip or bank statement",
                fileName: "",
                status: "Pending",
                statusColor: Colors.grey,
                onUpload: _openUploadDialog,
              ),
              const SizedBox(height: 16),
              DocumentCard(
                title: "Photo & Signature",
                subtitle: "Passport size photo and signature",
                fileName: "",
                status: "Pending",
                statusColor: Colors.grey,
                onUpload: _openUploadDialog,
              ),
            ],
          );
        }

        var docs = snapshot.data!.docs;

        return Column(
          children: docs.map((doc) {
            var data = doc.data();

            Color statusColor = Colors.grey;

            if (data['status'] == "verified") {
              statusColor = Colors.green;
            } else if (data['status'] == "pending") {
              statusColor = Colors.orange;
            } else if (data['status'] == "rejected") {
              statusColor = Colors.red;
            } else if (data['status'] == "hold") {
              statusColor = Colors.blue;
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: DocumentCard(
                title: data['type'] ?? "",
                subtitle: "Uploaded Document",
                fileName: data['fileName'] ?? "",
                status: data['status'] ?? "pending",
                statusColor: statusColor,
                onUpload: () {
                  showDialog(
                    context: context,
                    builder: (_) => UploadDialog(
                      documentType: data['type'] ?? "",
                    ),
                  );
                },
              ),
            );
          }).toList(),
        );
      },
    );
  }
  // ================= RIGHT PANEL =================

  Widget _buildRightPanel() {
    return Column(
      children: [
        // Progress Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: _cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Verification Progress",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 16),
              AnimatedBuilder(
                animation: _progressAnimation,
                builder: (context, child) {
                  return LinearProgressIndicator(
                    value: _progressAnimation.value,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(20),
                  );
                },
              ),
              const SizedBox(height: 10),
              const Text("1 of 4 verified (25%)"),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Tips Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: _cardDecoration(),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Upload Tips",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              SizedBox(height: 12),
              TipItem("Ensure documents are clearly legible"),
              TipItem("All four corners must be visible"),
              TipItem("File size should not exceed 5MB"),
              TipItem("Supported formats: JPG, PNG, PDF"),
            ],
          ),
        ),
      ],
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: const [
        BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
      ],
    );
  }
}

//////////////////////////////////////////////////////////////
/// STATUS CARD
//////////////////////////////////////////////////////////////

class StatusCard extends StatelessWidget {
  final String count;
  final String label;
  final Color color;
  final IconData icon;

  const StatusCard(this.count, this.label, this.color, this.icon, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                count,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(label),
            ],
          ),
        ],
      ),
    );
  }
}

//////////////////////////////////////////////////////////////
/// DOCUMENT CARD
//////////////////////////////////////////////////////////////

class DocumentCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String fileName;
  final String status;
  final Color statusColor;
  final VoidCallback onUpload;

  const DocumentCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.fileName,
    required this.status,
    required this.statusColor,
    required this.onUpload,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: Colors.grey)),
                if (fileName.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(fileName),
                ],
                const SizedBox(height: 8),
                Chip(
                  label: Text(status),
                  backgroundColor: statusColor.withOpacity(.1),
                  labelStyle: TextStyle(color: statusColor),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => UploadDialog(
                  documentType: title,
                ),
              );
            },
            icon: const Icon(Icons.upload_rounded),
          )
        ],
      ),
    );
  }
}

//////////////////////////////////////////////////////////////
/// TIP ITEM
//////////////////////////////////////////////////////////////

class TipItem extends StatelessWidget {
  final String text;
  const TipItem(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

//////////////////////////////////////////////////////////////
/// UPLOAD DIALOG (MOBILE FIXED ✅)
//////////////////////////////////////////////////////////////

class UploadDialog extends StatefulWidget {
  final String documentType;

  const UploadDialog({super.key, required this.documentType});

  @override
  State<UploadDialog> createState() => _UploadDialogState();
}

class _UploadDialogState extends State<UploadDialog> {
  bool uploading = false;

  Future pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'png', 'pdf'],
        withData: true,
      );

      if (result == null) return;

      PlatformFile file = result.files.first;

      if (file.bytes == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("File data not found")),
        );
        return;
      }

      Uint8List bytes = file.bytes!;

      setState(() {
        uploading = true;
      });

      await DocumentService().uploadDocument(
        documentType: widget.documentType,
        fileName: file.name,
        fileBytes: bytes,
      );

      setState(() {
        uploading = false;
      });

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Document uploaded successfully")),
      );
    } catch (e) {
      setState(() {
        uploading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Upload failed: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Upload ${widget.documentType}",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            InkWell(
              onTap: pickFile,
              child: Container(
                height: 160,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey),
                ),
                child: Center(
                  child: uploading
                      ? const CircularProgressIndicator()
                      : const Text(
                          "Click to Upload\nJPG, PNG, PDF",
                          textAlign: TextAlign.center,
                        ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: pickFile,
              child: const Text("Select File"),
            )
          ],
        ),
      ),
    );
  }
}
