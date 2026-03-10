import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';

class UploadLoanDocumentPage extends StatefulWidget {
  final String loanId;

  const UploadLoanDocumentPage({super.key, required this.loanId});

  @override
  State<UploadLoanDocumentPage> createState() => _UploadLoanDocumentPageState();
}

class _UploadLoanDocumentPageState extends State<UploadLoanDocumentPage> {
  Uint8List? fileBytes;
  String? fileName;
  bool isUploading = false;

  final String userId = FirebaseAuth.instance.currentUser!.uid;

  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      withData: true,
    );

    if (result != null) {
      setState(() {
        fileBytes = result.files.first.bytes;
        fileName = result.files.first.name;
      });
    }
  }

  Future<void> uploadDocument() async {
    if (fileBytes == null) return;

    setState(() => isUploading = true);

    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child("loan_documents")
          .child(widget.loanId)
          .child(fileName!);

      await storageRef.putData(fileBytes!);

      final downloadUrl = await storageRef.getDownloadURL();

      await FirebaseFirestore.instance.collection("loan_documents").add({
        "loanId": widget.loanId,
        "userId": userId,
        "fileUrl": downloadUrl,
        "fileName": fileName,
        "uploadedAt": FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Document Uploaded Successfully")),
      );

      setState(() {
        fileBytes = null;
        fileName = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }

    setState(() => isUploading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff4f6ff),
      appBar: AppBar(
        title: const Text("Upload Loan Document"),
      ),
      body: Center(
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                  color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.upload_file, size: 60, color: Colors.deepPurple),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: pickFile,
                child: const Text("Pick Document"),
              ),
              const SizedBox(height: 20),
              if (fileName != null) ...[
                const Text(
                  "Preview",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.insert_drive_file,
                          size: 40, color: Colors.blue),
                      const SizedBox(height: 5),
                      Text(fileName!),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 30),
              isUploading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      onPressed: fileBytes == null ? null : uploadDocument,
                      child: const Text("Submit Document"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
