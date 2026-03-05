import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:usersideloanapp/Login/Login.dart';

class AdminSideNav extends StatelessWidget {
  final String selectedRoute;
  final ValueChanged<String> onNavigate;

  const AdminSideNav({
    Key? key,
    required this.selectedRoute,
    required this.onNavigate,
  }) : super(key: key);

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
    final user = FirebaseAuth.instance.currentUser;

    return Container(
      width: 260,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🔷 TOP LOGO
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.deepPurple,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.account_balance, color: Colors.white),
              ),
              const SizedBox(width: 12),
              const Text(
                'LoanFlow Admin',
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),

          /// 🔷 NAV ITEMS
          _navItem(Icons.dashboard, 'Dashboard', '/admin/dashboard'),
          _navItem(
            Icons.description,
            'All Applications',
            '/admin/AllApplicationsPage',
          ),
          _navItem(Icons.group, 'Users & Roles', '/admin/users'),
          _navItem(Icons.settings, 'Loan Policies', '/admin/policies'),
          _navItem(Icons.money, 'EMI Tracking', '/admin/emi'),
          _navItem(Icons.bar_chart, 'Reports', '/admin/reports'),
          _navItem(Icons.history, 'Audit Logs', '/admin/auditlogs'),

          const Spacer(),
          const Divider(),

          /// 🔷 USER INFO
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.deepPurple,
                child: Text(
                  user?.email != null ? user!.email![0].toUpperCase() : "A",
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.displayName ?? "Admin User",
                      style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      user?.email ?? "",
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.black54),
                onPressed: () => _logout(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String title, String route) {
    final bool isActive = selectedRoute == route;

    return InkWell(
      onTap: () {
        if (!isActive) {
          onNavigate(route);
        }
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: isActive
              ? Colors.deepPurple.withOpacity(0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, color: isActive ? Colors.deepPurple : Colors.grey),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                color: isActive ? Colors.deepPurple : Colors.black87,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
