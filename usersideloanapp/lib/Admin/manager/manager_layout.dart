import 'package:flutter/material.dart';
import 'package:usersideloanapp/Admin/manager/dashboard/ManagerReportsPage.dart';
import 'package:usersideloanapp/Admin/manager/dashboard/ManagerUsersPage.dart';
import 'package:usersideloanapp/Admin/manager/dashboard/manager_dashboard_page/ManagerLoanApprovalsPage.dart';
import 'package:usersideloanapp/Admin/manager/dashboard/manager_dashboard_page/manager_dashboard_page.dart';
import 'package:usersideloanapp/Admin/manager/ManagerSidebar.dart';

class ManagerLayout extends StatefulWidget {
  const ManagerLayout({super.key});

  @override
  State<ManagerLayout> createState() => _ManagerLayoutState();
}

class _ManagerLayoutState extends State<ManagerLayout> {
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
      body: Row(
        children: [
          if (wide)
            ManagerSidebar(
              selectedIndex: selectedIndex,
              onItemSelected: (i) {
                setState(() {
                  selectedIndex = i;
                });
              },
            ),
          Expanded(child: pages[selectedIndex])
        ],
      ),
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
      appBar: wide ? null : AppBar(title: const Text("Manager Panel")),
    );
  }
}
