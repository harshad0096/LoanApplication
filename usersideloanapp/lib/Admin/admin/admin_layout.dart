import 'package:flutter/material.dart';
import 'package:usersideloanapp/Admin/admin/AdminDashboard.dart';
import 'package:usersideloanapp/Admin/admin/AllApplicationsPage.dart';
import 'package:usersideloanapp/Admin/admin/AuditLogsPage.dart';
import 'package:usersideloanapp/Admin/admin/EmiTrackingPage.dart';
import 'package:usersideloanapp/Admin/admin/LoanPoliciesPage.dart';
import 'package:usersideloanapp/Admin/admin/ReportsPage.dart';
import 'package:usersideloanapp/Admin/admin/UsersRolesPage.dart';
import 'package:usersideloanapp/Admin/admin/admin_side_nav.dart';

class AdminLayout extends StatefulWidget {
  final String initialRoute;

  const AdminLayout({super.key, required this.initialRoute});

  @override
  State<AdminLayout> createState() => _AdminLayoutState();
}

class _AdminLayoutState extends State<AdminLayout> {
  late String currentRoute;

  @override
  void initState() {
    super.initState();
    currentRoute = widget.initialRoute;
  }

  Widget _getPage() {
    switch (currentRoute) {
      case '/admin/users':
        return const UsersRolesPage();
      case '/admin/AllApplicationsPage':
        return const AllApplicationsPage();
      case '/admin/policies':
        return const LoanPoliciesPage();
      case '/admin/emi':
        return const EmiTrackingPage();
      case '/admin/reports':
        return const ReportsPage();
      case '/admin/auditlogs':
        return const AuditLogsPage();
      case '/admin/dashboard':
      default:
        return const AdminDashboardPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool wide = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Panel"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: wide
            ? null
            : Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
      ),

      /// MOBILE DRAWER
      drawer: wide
          ? null
          : Drawer(
              child: AdminSideNav(
                selectedRoute: currentRoute,
                onNavigate: (route) {
                  setState(() => currentRoute = route);
                  Navigator.pop(context);
                },
              ),
            ),

      body: Row(
        children: [
          /// DESKTOP SIDEBAR
          if (wide)
            AdminSideNav(
              selectedRoute: currentRoute,
              onNavigate: (route) {
                setState(() => currentRoute = route);
              },
            ),

          Expanded(child: _getPage()),
        ],
      ),
    );
  }
}
