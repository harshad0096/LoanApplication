import 'package:flutter/material.dart';
import 'package:usersideloanapp/Notification/NotificationPage.dart';
import 'package:usersideloanapp/user/UserDashboard/UserProfilePage.dart';
import 'package:usersideloanapp/user/UserDashboard/documents_page.dart';
import 'package:usersideloanapp/user/UserDashboard/loan_status_page.dart';
import 'package:usersideloanapp/user/UserDashboard/loans_page.dart';
import 'package:usersideloanapp/user/UserDashboard/payemis.dart';
import 'package:usersideloanapp/user/UserDashboard/user_dashboard.dart';

import 'user_sidebar.dart';
import '../../Appbar/quickloan_appbar.dart';

class UserLayout extends StatefulWidget {
  const UserLayout({super.key});

  @override
  State<UserLayout> createState() => _UserLayoutState();
}

class _UserLayoutState extends State<UserLayout> {
  int selectedIndex = 0;
  bool isSidebarCollapsed = false;

  /// ALL PAGES
  final List<Widget> pages = const [
    UserDashboard(), // 0
    LoansPage(), // 1
    UserLoansPage(loanData: {}), // 2
    DocumentsPage(), // 3
    PayEmisPage(), // 4
    NotificationPage(), // 5
    UserProfilePage(), // 6
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        final bool isMobile = width < 700;
        final bool isTablet = width >= 700 && width < 1100;

        return Scaffold(
          backgroundColor: const Color(0xffF5F7FB),

          /// APPBAR
          appBar: QuickLoanAppBar(
            isMobile: isMobile,
          ),

          /// BODY
          body: Row(
            children: [
              /// SIDEBAR (Tablet + Desktop)
              if (!isMobile)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: isTablet
                      ? (isSidebarCollapsed ? 80 : 220)
                      : (isSidebarCollapsed ? 90 : 260),
                  child: UserSidebar(
                    selectedIndex: selectedIndex,
                    isCollapsed: isSidebarCollapsed,
                    onToggle: () {
                      setState(() {
                        isSidebarCollapsed = !isSidebarCollapsed;
                      });
                    },
                    onItemSelected: (index) {
                      setState(() {
                        selectedIndex = index;
                      });
                    },
                  ),
                ),

              /// PAGE CONTENT
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  switchInCurve: Curves.easeIn,
                  switchOutCurve: Curves.easeOut,
                  child: Container(
                    key: ValueKey(selectedIndex),
                    child: pages[selectedIndex],
                  ),
                ),
              ),
            ],
          ),

          /// MOBILE NAVIGATION
          bottomNavigationBar: isMobile
              ? BottomNavigationBar(
                  currentIndex: selectedIndex,
                  type: BottomNavigationBarType.fixed,
                  selectedItemColor: const Color(0xff6366F1),
                  unselectedItemColor: Colors.grey,
                  onTap: (index) {
                    setState(() {
                      selectedIndex = index;
                    });
                  },
                  items: const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.dashboard),
                      label: "Dashboard",
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.account_balance),
                      label: "Loans",
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.assignment_turned_in),
                      label: "Status",
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.description),
                      label: "Docs",
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.payment),
                      label: "Pay EMI",
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.notifications),
                      label: "Alerts",
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.person),
                      label: "Profile",
                    ),
                  ],
                )
              : null,
        );
      },
    );
  }
}
