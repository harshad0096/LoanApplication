import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:usersideloanapp/Login/Login.dart';

class SideNavbar extends StatelessWidget {
  final String selectedRoute;
  final Function(String route) onNavigate;

  const SideNavbar({
    super.key,
    required this.selectedRoute,
    required this.onNavigate,
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
    final user = FirebaseAuth.instance.currentUser;

    return Container(
      width: 260,
      color: const Color(0xFF1F2A36),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// LOGO
          Row(
            children: const [
              Icon(Icons.account_balance, color: Colors.white),
              SizedBox(width: 10),
              Text(
                "LoanFlow Officer",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),

          /// NAVIGATION
          _navItem(
            icon: Icons.dashboard,
            title: "Dashboard",
            route: "/loan_officer/dashboard",
          ),
          _navItem(
            icon: Icons.description,
            title: "Applications",
            route: "/loan_officer/applications",
          ),
          _navItem(
            icon: Icons.verified,
            title: "Verifications",
            route: "/loan_officer/verifications",
          ),

          const Spacer(),
          const Divider(color: Colors.white24),

          /// USER INFO + LOGOUT (Same as Admin)
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.teal,
                child: Text(
                  user?.email != null ? user!.email![0].toUpperCase() : "L",
                ),
              ),
              const SizedBox(width: 10),

              /// USER NAME + EMAIL
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.displayName ?? "Loan Officer",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      user?.email ?? "",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              /// LOGOUT BUTTON
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white70),
                onPressed: () => _logout(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _navItem({
    required IconData icon,
    required String title,
    required String route,
  }) {
    final bool isActive = selectedRoute == route;

    return InkWell(
      onTap: () => onNavigate(route),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: isActive ? Colors.teal.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isActive
              ? const Border(left: BorderSide(color: Colors.teal, width: 4))
              : null,
        ),
        child: Row(
          children: [
            Icon(icon, color: isActive ? Colors.white : Colors.white70),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.white70,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
