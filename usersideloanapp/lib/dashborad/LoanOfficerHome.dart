import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoanOfficerHome extends StatelessWidget {
  const LoanOfficerHome({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Loan Officer Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            _buildCard(
              icon: Icons.description,
              title: "Verify Loan Applications",
              subtitle: "Review submitted documents",
            ),
            _buildCard(
              icon: Icons.pending_actions,
              title: "Pending Verifications",
              subtitle: "Applications awaiting review",
            ),
            _buildCard(
              icon: Icons.check_circle,
              title: "Approved by You",
              subtitle: "Loans verified successfully",
            ),
            const SizedBox(height: 30),
            Center(
              child: Text(
                "Logged in as: ${user?.email}",
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      child: ListTile(
        leading: Icon(icon, size: 35, color: Colors.blue),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {},
      ),
    );
  }
}
