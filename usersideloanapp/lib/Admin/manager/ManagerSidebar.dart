import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ManagerSidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const ManagerSidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  // Logout function
  void logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    // Navigate to Login Page
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login',
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 230,
      color: const Color(0xff0F172A),
      child: Column(
        children: [
          const SizedBox(height: 40),
          const Text(
            "Fintech Manager",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 30),
          _item(Icons.dashboard, "Dashboard", 0),
          _item(Icons.approval, "Loan Approvals", 1),
          _item(Icons.people, "Users", 2),
          _item(Icons.bar_chart, "Reports", 3),
          const Spacer(),
          const Divider(color: Colors.white24),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              "Logout",
              style: TextStyle(color: Colors.red),
            ),
            onTap: () => logout(context),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _item(icon, title, index) {
    bool active = selectedIndex == index;

    return ListTile(
      leading: Icon(
        icon,
        color: active ? Colors.blue : Colors.white,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: active ? Colors.blue : Colors.white,
        ),
      ),
      onTap: () => onItemSelected(index),
    );
  }
}
