import 'package:flutter/material.dart';
import 'package:usersideloanapp/user/UserDashboard/user_sidebar.dart';

class LoanFlowShell extends StatefulWidget {
  final Widget child;
  final int selectedIndex;

  const LoanFlowShell({
    super.key,
    required this.child,
    this.selectedIndex = 1,
  });

  @override
  State<LoanFlowShell> createState() => _LoanFlowShellState();
}

class _LoanFlowShellState extends State<LoanFlowShell> {
  int currentIndex = 1;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.selectedIndex;
  }

  void _onSidebarTap(int index) {
    setState(() => currentIndex = index);

    // 👉 optional navigation
    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/home');
        break;
      case 1:
        // already in loans
        break;
      case 2:
        Navigator.pushNamed(context, '/loan-status');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    // 📱 MOBILE → normal screen
    if (!isDesktop) {
      return widget.child;
    }

    // 🖥️ DESKTOP → sidebar fixed
    return Scaffold(
      body: Row(
        children: [
          SizedBox(
            width: 260,
            child: UserSidebar(
              selectedIndex: currentIndex,
              onItemSelected: _onSidebarTap,
              isCollapsed: false,
              onToggle: () {},
            ),
          ),

          // RIGHT CONTENT
          Expanded(child: widget.child),
        ],
      ),
    );
  }
}
