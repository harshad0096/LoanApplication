import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DocumentService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future uploadDocument({
    required String documentType,
    required String fileName,
    required Uint8List fileBytes,
  }) async {
    final uid = _auth.currentUser!.uid;

    // ensure user document exists
    await _firestore.collection("users").doc(uid).set(
        {"uid": uid, "createdAt": FieldValue.serverTimestamp()},
        SetOptions(merge: true));

    // upload file
    final ref = _storage
        .ref()
        .child("user_documents")
        .child(uid)
        .child("$documentType-$fileName");

    TaskSnapshot snapshot = await ref.putData(fileBytes);

    String downloadUrl = await snapshot.ref.getDownloadURL();

    // save document info
    await _firestore.collection("users").doc(uid).collection("documents").add({
      "type": documentType,
      "fileName": fileName,
      "fileUrl": downloadUrl,
      "status": "pending",
      "uploadedAt": FieldValue.serverTimestamp(),
    });
  }
}
