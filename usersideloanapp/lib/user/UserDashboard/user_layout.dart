import 'package:flutter/material.dart';
import 'package:usersideloanapp/Notification/NotificationPage.dart';
import 'package:usersideloanapp/user/UserDashboard/UserProfilePage.dart';
import 'package:usersideloanapp/user/UserDashboard/documents_page.dart';
import 'package:usersideloanapp/user/UserDashboard/loan_status_page.dart';
import 'package:usersideloanapp/user/UserDashboard/loans_page.dart';
import 'user_sidebar.dart';
import 'user_dashboard.dart';
import '../../Appbar/quickloan_appbar.dart';

class UserLayout extends StatefulWidget {
  const UserLayout({super.key});

  @override
  State<UserLayout> createState() => _UserLayoutState();
}

class _UserLayoutState extends State<UserLayout>
    with SingleTickerProviderStateMixin {
  int selectedIndex = 0;
  bool isSidebarCollapsed = false;

  /// ✅ FIX: Scaffold key for mobile drawer
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Widget> pages = [
    const UserDashboard(),
    const LoansPage(),
    const UserLoansPage(),
    const DocumentsPage(),
    const NotificationPage(),
    const UserProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        final isMobile = width < 700;
        final isTablet = width >= 700 && width < 1100;

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: const Color(0xffF5F7FB),

          /// ✅ APP BAR (FIXED)
          appBar: QuickLoanAppBar(
            isMobile: isMobile,
            onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
          ),

          /// ✅ MOBILE DRAWER
          drawer: isMobile
              ? UserSidebar(
                  selectedIndex: selectedIndex,
                  onItemSelected: (index) {
                    setState(() => selectedIndex = index);
                    Navigator.pop(context);
                  },
                  isCollapsed: false,
                  onToggle: () {},
                )
              : null,

          /// optional: better swipe experience
          drawerEdgeDragWidth: isMobile ? 80 : 0,

          body: Row(
            children: [
              /// 💻 Sidebar for tablet + desktop
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
                      setState(() => selectedIndex = index);
                    },
                  ),
                ),

              /// 📄 PAGE CONTENT (animated)
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: pages[selectedIndex],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
