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
  bool panVerified = true;
  bool aadhaarVerified = true;
  bool bankVerified = true;

  String photoUrl = "";

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    if (user == null) return;
    final doc = await usersRef.doc(user!.uid).get();
    if (doc.exists) {
      final data = doc.data()!;
      nameCtrl.text = data['name'] ?? "Rahul Kumar";
      emailCtrl.text = data['email'] ?? "rahul.kumar@email.com";
      phoneCtrl.text = data['phone'] ?? "+91 98765 43210";
    }
    setState(() => isLoading = false);
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushNamedAndRemoveUntil("/login", (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF9FAFB),
      appBar: AppBar(
          title: const Text("My Profile"), centerTitle: true, elevation: 0),
      body: LayoutBuilder(builder: (context, constraints) {
        bool isDesktop = constraints.maxWidth > 900;

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 48 : 24, vertical: 24),
          child: Column(
            children: [
              _profileHeader(),
              const SizedBox(height: 24),
              // Grid with dynamic aspect ratio to prevent overflow
              _statGrid(isDesktop ? 4 : 2),
              const SizedBox(height: 24),
              isDesktop
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 2, child: _leftColumn()),
                        const SizedBox(width: 24),
                        Expanded(child: _rightColumn()),
                      ],
                    )
                  : Column(children: [
                      _leftColumn(),
                      const SizedBox(height: 24),
                      _rightColumn()
                    ]),
            ],
          ),
        );
      }),
    );
  }

  Widget _statGrid(int crossAxisCount) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      // Increased ratio ensures cards don't overflow on small screens
      childAspectRatio: 2.2,
      children: [
        _statCard(
            "Active Loans", "1", Icons.account_balance_wallet, Colors.blue),
        _statCard("CIBIL Score", "742", Icons.trending_up, Colors.green),
        _statCard("Total Borrowed", "₹7.5L", Icons.money, Colors.orange),
        _statCard("Reward Points", "2,450", Icons.star_border, Colors.purple),
      ],
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(value,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _profileHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xff6366F1), Color(0xff8B5CF6)]),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          const CircleAvatar(radius: 35, child: Icon(Icons.person, size: 40)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nameCtrl.text,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                Text(emailCtrl.text,
                    style: const TextStyle(color: Colors.white70)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _infoCard(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _leftColumn() {
    return Column(
      children: [
        _infoCard("Personal Information", [
          _profileField("FULL NAME", nameCtrl.text, Icons.person_outline),
          _profileField("EMAIL ADDRESS", emailCtrl.text, Icons.email_outlined),
          _profileField("PHONE NUMBER", phoneCtrl.text, Icons.phone_outlined),
        ]),
        const SizedBox(height: 24),
        _infoCard("KYC & Verification", [
          _kycTile("Aadhaar Number", "•••• •••• 4532", aadhaarVerified),
          _kycTile("PAN Card", "ABCDE1234F", panVerified),
          _kycTile("Bank Account", "HDFC Bank ••••4532", bankVerified),
        ]),
      ],
    );
  }

  Widget _rightColumn() {
    return Column(
      children: [
        _infoCard("Account", [
          _actionTile("Linked Bank Account", "HDFC Bank ••••4532",
              Icons.account_balance),
          _actionTile("KYC Status", "Fully Verified", Icons.verified_user),
          _actionTile("Employment Details", "Salaried • TechCorp Ltd",
              Icons.work_outline),
        ]),
        const SizedBox(height: 24),
        _securitySection(),
        const SizedBox(height: 24),
        _logoutButton(),
      ],
    );
  }

  Widget _profileField(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade400),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label,
                style: const TextStyle(fontSize: 10, color: Colors.grey)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
          ]),
        ],
      ),
    );
  }

  Widget _kycTile(String label, String value, bool isVerified) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
              child:
                  Text(label, style: TextStyle(color: Colors.grey.shade600))),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Icon(isVerified ? Icons.verified : Icons.error,
              color: isVerified ? Colors.green : Colors.orange, size: 16),
        ],
      ),
    );
  }

  Widget _actionTile(String title, String subtitle, IconData icon) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: const Color(0xff6366F1)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: const Icon(Icons.chevron_right, size: 20),
    );
  }

  Widget _securitySection() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.shade200)),
      child: SwitchListTile(
        value: biometricEnabled,
        title: const Text("Enable Biometric Login"),
        onChanged: (v) => setState(() => biometricEnabled = v),
      ),
    );
  }

  Widget _logoutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.logout),
        label: const Text("Logout"),
        style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.all(20),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16))),
        onPressed: logout,
      ),
    );
  }
}
