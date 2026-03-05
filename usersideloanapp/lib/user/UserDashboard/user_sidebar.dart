import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:usersideloanapp/Login/Login.dart';

class UserSidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const UserSidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    required bool isCollapsed,
    required Null Function() onToggle,
  });
  Future<void> _logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context, false),
          ),
          ElevatedButton(
            child: const Text("Logout"),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseAuth.instance.signOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage(initialRoute: '')),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          navItem(Icons.dashboard, "Dashboard", 0),
          navItem(Icons.account_balance_wallet, "Loans", 1),
          navItem(Icons.trending_up, "Loan Status", 2),
          navItem(Icons.description, "Documents", 3),
          navItem(Icons.notifications, "Notifications", 4),
          navItem(Icons.person, "Profile", 5),

          const Spacer(),

          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.teal,
                child: Text(
                  "user", //   user?.email != null ? user!.email![0].toUpperCase() : "A",
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "user", //   user?.displayName ?? "Admin User",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      //  user?.email ??
                      "",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.logout,
                  color: Color.fromARGB(179, 23, 4, 4),
                ),
                onPressed: () => _logout(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget navItem(IconData icon, String title, int index) {
    final bool isSelected = selectedIndex == index;

    return ListTile(
      leading: Icon(icon, color: isSelected ? Colors.deepPurple : Colors.grey),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? Colors.deepPurple : Colors.black,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onTap: () => onItemSelected(index),
    );
  }
}
