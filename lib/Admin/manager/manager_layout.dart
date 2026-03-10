import 'package:flutter/material.dart';
import 'package:usersideloanapp/Admin/manager/dashboard/ManagerReportsPage.dart';
import 'package:usersideloanapp/Admin/manager/dashboard/ManagerUsersPage.dart';
import 'package:usersideloanapp/Admin/manager/dashboard/manager_dashboard_page/ManagerLoanApprovalsPage.dart';
import 'package:usersideloanapp/Admin/manager/dashboard/manager_dashboard_page/manager_dashboard_page.dart';
import 'package:usersideloanapp/Admin/manager/ManagerSidebar.dart';
import 'package:usersideloanapp/Appbar/quickloan_appbar.dart';

class ManagerLayout extends StatefulWidget {
  const ManagerLayout({super.key});

  @override
  State<ManagerLayout> createState() => _ManagerLayoutState();
}

class _ManagerLayoutState extends State<ManagerLayout> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  int selectedIndex = 0;

  final pages = [
    const ManagerDashboardPage(),
    const ManagerLoanApprovalsPage(),
    const ManagerUsersPage(),
    const ManagerReportsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final bool wide = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      key: scaffoldKey,

      /// QUICK LOAN APP BAR
      appBar: QuickLoanAppBar(
        isMobile: !wide,
      ),

      body: Row(
        children: [
          /// DESKTOP SIDEBAR
          if (wide)
            ManagerSidebar(
              selectedIndex: selectedIndex,
              onItemSelected: (i) {
                setState(() {
                  selectedIndex = i;
                });
              },
            ),

          /// PAGE CONTENT
          Expanded(
            child: pages[selectedIndex],
          ),
        ],
      ),

      /// MOBILE DRAWER
      drawer: wide
          ? null
          : Drawer(
              child: ManagerSidebar(
                selectedIndex: selectedIndex,
                onItemSelected: (i) {
                  setState(() {
                    selectedIndex = i;
                  });
                  Navigator.pop(context);
                },
              ),
            ),
    );
  }
}
