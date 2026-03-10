import 'package:flutter/material.dart';
import 'package:usersideloanapp/Admin/loan_officer/LoanOfficerProfilePage.dart';
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

  /// PAGE SWITCH
  Widget _getPage() {
    switch (currentRoute) {
      case '/loan_officer/applications':
        return const LoanOfficerApplicationsPage();
      case '/loan_officer/verifications':
        return const LoanOfficerVerificationsPage();
      case '/loan_officer/profile':
        return const LoanOfficerProfilePage();
      case '/loan_officer/dashboard':
      default:
        return const LoanOfficerDashboardPage();
    }
  }

  /// MOBILE NAV INDEX
  int _getBottomIndex() {
    switch (currentRoute) {
      case '/loan_officer/dashboard':
        return 0;
      case '/loan_officer/applications':
        return 1;
      case '/loan_officer/verifications':
        return 2;
      case '/loan_officer/profile':
        return 3;
      default:
        return 0;
    }
  }

  /// MOBILE NAVIGATION
  void _onBottomTap(int index) {
    switch (index) {
      case 0:
        currentRoute = '/loan_officer/dashboard';
        break;
      case 1:
        currentRoute = '/loan_officer/applications';
        break;
      case 2:
        currentRoute = '/loan_officer/verifications';

        break;
      case 3:
        currentRoute = '/loan_officer/profile';
        break;
    }

    setState(() {});
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
      ),

      /// =========================
      /// BODY
      /// =========================
      body: wide
          ? Row(
              children: [
                /// DESKTOP SIDEBAR
                SideNavbar(
                  selectedRoute: currentRoute,
                  onNavigate: (route) {
                    setState(() => currentRoute = route);
                  },
                ),

                Expanded(child: _getPage()),
              ],
            )

          /// MOBILE VIEW
          : _getPage(),

      /// =========================
      /// MOBILE BOTTOM NAVBAR
      /// =========================
      bottomNavigationBar: wide
          ? null
          : BottomNavigationBar(
              currentIndex: _getBottomIndex(),
              onTap: _onBottomTap,
              type: BottomNavigationBarType.fixed,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard),
                  label: "Dashboard",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.description),
                  label: "Applications",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.verified),
                  label: "Verify",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: "Profile",
                ),
              ],
            ),
    );
  }
}
