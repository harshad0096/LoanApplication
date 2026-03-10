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

class _UserProfilePageState extends State<UserProfilePage>
    with TickerProviderStateMixin {
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

  late AnimationController _animController;

  // ================= INIT =================

  @override
  void initState() {
    super.initState();
    _loadProfile();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  // ================= LOAD PROFILE =================

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

  // ================= SAVE PROFILE =================

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
    }
  }

  // ================= LOGOUT =================

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();

    Navigator.of(context).pushNamedAndRemoveUntil(
      "/login",
      (route) => false,
    );
  }

  // ================= BUILD =================

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return FadeTransition(
      opacity: _animController,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _profileHeader(),
            const SizedBox(height: 20),
            _profileCard(),
            const SizedBox(height: 20),
            const SizedBox(height: 20),
            _accountOverview(),
            const SizedBox(height: 20),
            _kycItem("PAN Card", panVerified),
            _kycItem("Aadhaar Card", aadhaarVerified),
            const SizedBox(height: 20),
            _kycSection(),
            const SizedBox(height: 20),
            _securitySection(),
            const SizedBox(height: 20),
            _logoutButton(),
          ],
        ),
      ),
    );
  }

  // ================= PROFILE HEADER =================

  Widget _profileHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xff6366F1), Color(0xff8B5CF6)],
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage:
                photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
            child: photoUrl.isEmpty
                ? const Icon(Icons.person, size: 35, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nameCtrl.text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  emailCtrl.text,
                  style: const TextStyle(
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: _profileCompletion(),
                  backgroundColor: Colors.white24,
                  color: Colors.white,
                ),
                const SizedBox(height: 4),
                Text(
                  "Profile ${(_profileCompletion() * 100).toInt()}% Complete",
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  double _profileCompletion() {
    int total = 6;
    int completed = 0;

    if (nameCtrl.text.isNotEmpty) completed++;
    if (emailCtrl.text.isNotEmpty) completed++;
    if (phoneCtrl.text.isNotEmpty) completed++;
    if (panVerified) completed++;
    if (aadhaarVerified) completed++;
    if (bankVerified) completed++;

    return completed / total;
  }
  // ================= PROFILE CARD =================

  Widget _profileCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: _card(),
      child: Column(
        children: [
          _field("Full Name", nameCtrl),
          _field("Email", emailCtrl),
          _field("Phone", phoneCtrl),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() => isEditing = !isEditing),
                  child: Text(isEditing ? "Cancel" : "Edit Profile"),
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

  Widget _accountOverview() {
    return Row(
      children: [
        Expanded(
          child: _statCard(
            "Credit Score",
            "742",
            Icons.trending_up,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard(
            "Active Loans",
            "2",
            Icons.account_balance,
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 12,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: const TextStyle(color: Colors.grey),
          )
        ],
      ),
    );
  }

  Widget _kycItem(String title, bool verified) {
    return ListTile(
      leading: Icon(
        verified ? Icons.verified : Icons.pending,
        color: verified ? Colors.green : Colors.orange,
      ),
      title: Text(title),
      trailing: Chip(
        label: Text(verified ? "Verified" : "Pending"),
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
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  // ================= KYC SECTION =================

  Widget _kycSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "KYC Verification",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 10),
          _kycTile("PAN Card", panVerified),
          _kycTile("Aadhaar Card", aadhaarVerified),
          _kycTile("Bank Account", bankVerified),
        ],
      ),
    );
  }

  Widget _kycTile(String title, bool verified) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        verified ? Icons.verified : Icons.pending_actions,
        color: verified ? Colors.green : Colors.orange,
      ),
      title: Text(title),
      trailing: Text(
        verified ? "Verified" : "Pending",
        style: TextStyle(
          color: verified ? Colors.green : Colors.orange,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ================= SECURITY =================

  Widget _securitySection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _card(),
      child: SwitchListTile(
        value: biometricEnabled,
        title: const Text("Enable Biometric Login"),
        activeColor: const Color(0xff6366F1),
        onChanged: (v) => setState(() => biometricEnabled = v),
      ),
    );
  }

  // ================= LOGOUT =================

  Widget _logoutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.logout),
        label: const Text("Logout"),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: logout,
      ),
    );
  }

  // ================= CARD =================

  BoxDecoration _card() {
    return BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(18),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(.05),
          blurRadius: 14,
        )
      ],
    );
  }
}
