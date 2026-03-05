import 'package:flutter/material.dart';
import 'package:usersideloanapp/Admin/loan_officer/loan_officer_applications.dart';
import 'package:usersideloanapp/Admin/loan_officer/loan_officer_dashboard_page.dart';
import 'package:usersideloanapp/Admin/loan_officer/loan_officer_verifications.dart';
import 'package:usersideloanapp/Admin/loan_officer/side_navbar.dart';

class LoanOfficerLayout extends StatefulWidget {
  final String initialRoute;

  const LoanOfficerLayout({super.key, required this.initialRoute});

  @override
  State<LoanOfficerLayout> createState() => _LoanOfficerLayoutState();
}

class _LoanOfficerLayoutState extends State<LoanOfficerLayout> {
  late String currentRoute;

  @override
  void initState() {
    super.initState();
    currentRoute = widget.initialRoute;
  }

  Widget _getPage() {
    switch (currentRoute) {
      case '/loan_officer/applications':
        return const LoanOfficerApplicationsPage();
      case '/loan_officer/verifications':
        return const LoanOfficerVerificationsPage();
      case '/loan_officer/dashboard':
      default:
        return const LoanOfficerDashboardPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool wide = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Loan Officer Panel"),
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
              child: SideNavbar(
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
            SideNavbar(
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
