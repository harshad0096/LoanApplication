import 'package:flutter/material.dart';
import 'package:usersideloanapp/Admin/admin/AdminDashboard.dart';
import 'package:usersideloanapp/Admin/admin/AllApplicationsPage.dart';
import 'package:usersideloanapp/Admin/admin/AuditLogsPage.dart';
import 'package:usersideloanapp/Admin/admin/EmiTrackingPage.dart';
import 'package:usersideloanapp/Admin/admin/LoanPoliciesPage.dart';
import 'package:usersideloanapp/Admin/admin/ReportsPage.dart';
import 'package:usersideloanapp/Admin/admin/UsersRolesPage.dart';
import 'package:usersideloanapp/Admin/admin/admin_side_nav.dart';
import 'package:usersideloanapp/Appbar/quickloan_appbar.dart';

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

  /// PAGE SWITCHER
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

  /// MOBILE BOTTOM NAVIGATION INDEX
  int _getBottomIndex() {
    switch (currentRoute) {
      case '/admin/dashboard':
        return 0;
      case '/admin/AllApplicationsPage':
        return 1;
      case '/admin/users':
        return 2;
      case '/admin/policies':
        return 3;
      default:
        return 0;
    }
  }

  /// HANDLE MOBILE NAVIGATION
  void _onBottomTap(int index) {
    switch (index) {
      case 0:
        currentRoute = '/admin/dashboard';
        break;
      case 1:
        currentRoute = '/admin/AllApplicationsPage';
        break;
      case 2:
        currentRoute = '/admin/users';
        break;
      case 3:
        currentRoute = '/admin/policies';
        break;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final bool wide = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      appBar: QuickLoanAppBar(
        isMobile: !wide,
      ),

      /// =====================
      /// BODY
      /// =====================
      body: wide
          ? Row(
              children: [
                /// DESKTOP SIDEBAR
                AdminSideNav(
                  selectedRoute: currentRoute,
                  onNavigate: (route) {
                    setState(() => currentRoute = route);
                  },
                ),

                /// PAGE
                Expanded(child: _getPage()),
              ],
            )

          /// MOBILE VIEW
          : _getPage(),

      /// =====================
      /// MOBILE BOTTOM NAV
      /// =====================
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
                  icon: Icon(Icons.group),
                  label: "Users",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings),
                  label: "Policies",
                ),
              ],
            ),
    );
  }
}
