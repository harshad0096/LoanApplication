import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final user = FirebaseAuth.instance.currentUser;
  final usersRef = FirebaseFirestore.instance.collection('users');

  bool isEditing = false;
  bool isLoading = true;

  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();

  bool biometricEnabled = true;
  bool panVerified = false;
  bool aadhaarVerified = false;
  bool bankVerified = false;

  File? profileImage;
  String photoUrl = "";

  bool get isMobile => MediaQuery.of(context).size.width < 900;

  // ================= INIT =================

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  // ================= LOAD =================

  Future<void> _loadProfile() async {
    if (user == null) return;

    final doc = await usersRef.doc(user!.uid).get();

    if (doc.exists) {
      final data = doc.data()!;

      nameCtrl.text = data['name'] ?? "";
      emailCtrl.text = data['email'] ?? "";
      phoneCtrl.text = data['phone'] ?? "";
      photoUrl = data['photoUrl'] ?? "";

      biometricEnabled = data['biometricEnabled'] ?? true;
      panVerified = data['panVerified'] ?? false;
      aadhaarVerified = data['aadhaarVerified'] ?? false;
      bankVerified = data['bankVerified'] ?? false;
    }

    setState(() => isLoading = false);
  }

  // ================= SAVE =================

  Future<void> _saveProfile() async {
    if (user == null) return;

    await usersRef.doc(user!.uid).set({
      'name': nameCtrl.text.trim(),
      'email': emailCtrl.text.trim(),
      'phone': phoneCtrl.text.trim(),
      'photoUrl': photoUrl,
      'biometricEnabled': biometricEnabled,
      'panVerified': panVerified,
      'aadhaarVerified': aadhaarVerified,
      'bankVerified': bankVerified,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    setState(() => isEditing = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Profile updated successfully"),
        backgroundColor: Color(0xff6366F1),
      ),
    );
  }

  // ================= IMAGE PICK =================

  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() => profileImage = File(picked.path));

      // ⚠️ TODO: Upload to Firebase Storage
      // After upload → set photoUrl
    }
  }

  // ================= LOGOUT =================

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
  }

  // ================= MAIN =================

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _profileCard(),
          const SizedBox(height: 20),
          _kycCard(),
          const SizedBox(height: 20),
          _securityCard(),
          const SizedBox(height: 20),
          _logoutCard(),
        ],
      ),
    );
  }

  // ================= PROFILE =================

  Widget _profileCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _glass(),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 48,
                backgroundImage: profileImage != null
                    ? FileImage(profileImage!)
                    : (photoUrl.isNotEmpty
                        ? NetworkImage(photoUrl) as ImageProvider
                        : null),
                child: profileImage == null && photoUrl.isEmpty
                    ? const Icon(Icons.person, size: 40)
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: InkWell(
                  onTap: pickImage,
                  child: const CircleAvatar(
                    radius: 16,
                    child: Icon(Icons.camera_alt, size: 16),
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 18),
          _field("Full Name", nameCtrl),
          _field("Email", emailCtrl),
          _field("Phone", phoneCtrl),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() => isEditing = !isEditing),
                  child: Text(isEditing ? "Cancel" : "Edit"),
                ),
              ),
              const SizedBox(width: 12),
              if (isEditing)
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff6366F1),
                    ),
                    child: const Text("Save"),
                  ),
                ),
            ],
          )
        ],
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl) {
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: TextField(
        controller: ctrl,
        enabled: isEditing,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Theme.of(context).cardColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  // ================= KYC =================

  Widget _kycCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: _glass(),
      child: Column(
        children: [
          _kycTile("PAN Card", panVerified),
          _kycTile("Aadhaar", aadhaarVerified),
          _kycTile("Bank Account", bankVerified),
        ],
      ),
    );
  }

  Widget _kycTile(String title, bool verified) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        verified ? Icons.verified : Icons.pending,
        color: verified ? Colors.green : Colors.orange,
      ),
      title: Text(title),
      trailing: Text(
        verified ? "Verified" : "Pending",
        style: TextStyle(
          color: verified ? Colors.green : Colors.orange,
        ),
      ),
    );
  }

  // ================= SECURITY =================

  Widget _securityCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: _glass(),
      child: SwitchListTile(
        value: biometricEnabled,
        title: const Text("Biometric Login"),
        onChanged: (v) => setState(() => biometricEnabled = v),
      ),
    );
  }

  // ================= LOGOUT =================

  Widget _logoutCard() {
    return Container(
      decoration: _glass(),
      child: ListTile(
        leading: const Icon(Icons.logout, color: Colors.red),
        title: const Text("Logout"),
        onTap: logout,
      ),
    );
  }

  // ================= GLASS =================

  BoxDecoration _glass() {
    return BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(.05),
          blurRadius: 18,
        )
      ],
    );
  }
}
