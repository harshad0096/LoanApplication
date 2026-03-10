import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ManagerHome extends StatelessWidget {
  const ManagerHome({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Manager Dashboard"),
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
              icon: Icons.approval,
              title: "Final Loan Approval",
              subtitle: "Approve verified applications",
            ),
            _buildCard(
              icon: Icons.assignment_turned_in,
              title: "Approved Loans",
              subtitle: "Loans approved by manager",
            ),
            _buildCard(
              icon: Icons.analytics,
              title: "Reports & Analytics",
              subtitle: "Loan statistics overview",
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
        leading: Icon(icon, size: 35, color: Colors.green),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {},
      ),
    );
  }
}
