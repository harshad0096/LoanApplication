import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:usersideloanapp/dashborad/AdminHom.dart';
import 'package:usersideloanapp/dashborad/Dashboard.dart';
import 'package:usersideloanapp/dashborad/LoanOfficerHome.dart';
import 'package:usersideloanapp/dashborad/ManagerHome.dart';

class RoleBasedHome extends StatelessWidget {
  const RoleBasedHome({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final role = snapshot.data!['role'] ?? "APPLICANT";

        switch (role) {
          case "LOAN_OFFICER":
            return const LoanOfficerHome();
          case "MANAGER":
            return const ManagerHome();
          case "ADMIN":
            return const AdminHome();
          default:
            return const HomePage();
        }
      },
    );
  }
}
