import 'package:flutter/material.dart';
import 'loan_officer_dashboard_page.dart';
import 'side_navbar.dart';

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
      case "/loan_officer/dashboard":
        return const LoanOfficerDashboardPage();

      case "/loan_officer/applications":
        return const LoanOfficerDashboardPage(); // replace later

      case "/loan_officer/verifications":
        return const LoanOfficerDashboardPage(); // replace later

      default:
        return const LoanOfficerDashboardPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool wide = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      body: Row(
        children: [
          if (wide)
            SideNavbar(
              selectedRoute: currentRoute,
              onNavigate: (route) {
                setState(() {
                  currentRoute = route;
                });
              },
            ),

          Expanded(child: _getPage()),
        ],
      ),

      drawer: wide
          ? null
          : Drawer(
              child: SideNavbar(
                selectedRoute: currentRoute,
                onNavigate: (route) {
                  setState(() {
                    currentRoute = route;
                  });
                  Navigator.pop(context);
                },
              ),
            ),

      appBar: wide ? null : AppBar(title: const Text("Loan Officer")),
    );
  }
}
