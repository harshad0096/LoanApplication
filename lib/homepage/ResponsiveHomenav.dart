import 'package:flutter/material.dart';

class ResponsiveHome extends StatefulWidget {
  const ResponsiveHome({super.key});

  @override
  State<ResponsiveHome> createState() => _ResponsiveHomeState();
}

class _ResponsiveHomeState extends State<ResponsiveHome> {
  int selectedIndex = 0;

  final List<String> navItems = [
    "Home",
    "Loans",
    "EMI Calculator",
    "About",
    "Contact"
  ];

  final List<Widget> pages = const [
    Center(child: Text("Home Page")),
    Center(child: Text("Loans Page")),
    Center(child: Text("EMI Calculator Page")),
    Center(child: Text("About Page")),
    Center(child: Text("Contact Page")),
  ];

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 800;

    return Scaffold(
      /// WEB NAVBAR
      appBar: isMobile
          ? AppBar(title: const Text("Loan App"))
          : PreferredSize(
              preferredSize: const Size.fromHeight(70),
              child: webNavBar(),
            ),

      /// MOBILE BOTTOM NAV
      bottomNavigationBar: isMobile ? mobileBottomNav() : null,

      body: pages[selectedIndex],
    );
  }

  /// WEB NAVBAR
  Widget webNavBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      color: Colors.white,
      child: Row(
        children: [
          const Text(
            "LoanApp",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          ...List.generate(navItems.length, (index) {
            return navItem(navItems[index], () {
              setState(() {
                selectedIndex = index;
              });
            });
          })
        ],
      ),
    );
  }

  /// WEB NAV ITEM
  Widget navItem(String title, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: TextButton(
        onPressed: onTap,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  /// MOBILE BOTTOM NAV
  Widget mobileBottomNav() {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      selectedItemColor: Colors.deepPurple,
      unselectedItemColor: Colors.grey,
      onTap: (index) {
        setState(() {
          selectedIndex = index;
        });
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: "Home",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_balance),
          label: "Loans",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calculate),
          label: "EMI",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.info),
          label: "About",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.contact_mail),
          label: "Contact",
        ),
      ],
    );
  }
}
