import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:usersideloanapp/Admin/admin/admin_layout.dart';
import 'package:usersideloanapp/Admin/ManagerHome.dart';
import 'package:usersideloanapp/Admin/loan_officer/LoanOfficerLayout.dart';
import 'package:usersideloanapp/Admin/manager/manager_layout.dart';
import 'package:usersideloanapp/homepage/Homepage.dart';
import 'package:usersideloanapp/user/UserDashboard/user_layout.dart';

class RoleBasedHome extends StatelessWidget {
  const RoleBasedHome({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text("User not logged in")));
    }

    return FutureBuilder<DocumentSnapshot>(
      future:
          FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Scaffold(
            body: Center(child: Text("User data not found")),
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;

        final role = data['role']
                ?.toString()
                .toLowerCase()
                .replaceAll("_", "")
                .replaceAll(" ", "") ??
            "applicant";

        print("USER ROLE = $role");

        switch (role) {
          case "admin":
            return const AdminLayout(initialRoute: '/admin/dashboard');

          case "applicant":
            return const UserLayout();

          case "manager":
            return const ManagerLayout();

          case "loanofficer":
            return const LoanOfficerLayout(
              initialRoute: "/loan_officer/dashboard",
            );

          default:
            return const HomePage();
        }
        ;
      },
    );
  }
}
