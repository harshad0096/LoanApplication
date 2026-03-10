import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:usersideloanapp/Admin/admin/admin_layout.dart';
import 'package:usersideloanapp/Admin/ManagerHome.dart';
import 'package:usersideloanapp/Admin/loan_officer/LoanOfficerLayout.dart';
import 'package:usersideloanapp/homepage/Homepage.dart';
import 'package:usersideloanapp/user/UserDashboard/user_layout.dart';

class RoleBasedHome extends StatelessWidget {
  const RoleBasedHome({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        /// ⏳ Loading while firebase restores session
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        /// ❌ NOT LOGGED IN
        if (!authSnapshot.hasData) {
          return const HomePage();
        }

        final user = authSnapshot.data!;

        /// ✅ FETCH ROLE
        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get(),
          builder: (context, roleSnapshot) {
            /// ⏳ Loading role
            if (roleSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            /// ❌ Error loading user doc
            if (roleSnapshot.hasError) {
              return _errorScreen();
            }

            /// ❌ If user doc missing
            if (!roleSnapshot.hasData || !roleSnapshot.data!.exists) {
              return const UserLayout();
            }

            final data = roleSnapshot.data!.data() as Map<String, dynamic>;

            final role = data['role']?.toString().toLowerCase() ?? "applicant";

            debugPrint("🔥 USER ROLE = $role");

            switch (role) {
              case "admin":
                return const AdminLayout(
                  initialRoute: '/admin/dashboard',
                );

              case "manager":
                return const ManagerHome();

              case "loanofficer":
                return const LoanOfficerLayout(
                  initialRoute: "/loan_officer/dashboard",
                );

              case "applicant":
                return const UserLayout();

              default:
                return const HomePage();
            }
          },
        );
      },
    );
  }

  /// 🔴 ERROR SCREEN WITH REFRESH BUTTON
  Widget _errorScreen() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Something went wrong",
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
              },
              child: const Text("Refresh Page"),
            )
          ],
        ),
      ),
    );
  }
}
