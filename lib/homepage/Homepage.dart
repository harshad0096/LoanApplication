import 'package:flutter/material.dart';
import 'package:usersideloanapp/homepage/DashboardPreview.dart';
import 'package:usersideloanapp/homepage/DownloadApp.dart';
import 'package:usersideloanapp/homepage/EligibilityChecker.dart';
import 'package:usersideloanapp/homepage/EmiCalculator.dart';
import 'package:usersideloanapp/homepage/FooterSection.dart';
import 'package:usersideloanapp/homepage/HeroFintechSection.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();

  int currentIndex = 0;

  /// SECTION KEYS
  final heroKey = GlobalKey();
  final emiKey = GlobalKey();
  final eligibilityKey = GlobalKey();
  final dashboardKey = GlobalKey();
  final downloadKey = GlobalKey();
  final footerKey = GlobalKey();

  /// SCROLL FUNCTION
  void scrollTo(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOut,
      );
    }
  }

  /// MOBILE NAVIGATION
  void onBottomTap(int index) {
    setState(() {
      currentIndex = index;
    });

    switch (index) {
      case 0:
        scrollTo(heroKey);
        break;
      case 1:
        scrollTo(emiKey);
        break;
      case 2:
        scrollTo(eligibilityKey);
        break;
      case 3:
        scrollTo(dashboardKey);
        break;
      case 4:
        scrollTo(downloadKey);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 900;

    return Scaffold(
      backgroundColor: const Color(0xffF5F7FB),

      /// APPBAR
      appBar: isMobile ? mobileAppBar() : glassNavbar(context),

      /// MOBILE BOTTOM NAV
      bottomNavigationBar: isMobile ? mobileBottomNav() : null,

      /// APPLY BUTTON
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xff7C3AED),
        icon: const Icon(Icons.flash_on),
        label: const Text("Apply Loan"),
        onPressed: () {
          Navigator.pushNamed(context, "/login");
        },
      ),

      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            /// HERO
            Container(
              key: heroKey,
              child: HeroFintechSection(isMobile: isMobile),
            ),

            const SizedBox(height: 80),

            /// EMI
            Container(
              key: emiKey,
              child: const EmiCalculator(),
            ),

            const SizedBox(height: 80),

            /// ELIGIBILITY
            Container(
              key: eligibilityKey,
              child: const EligibilityChecker(),
            ),

            const SizedBox(height: 80),

            /// DASHBOARD
            Container(
              key: dashboardKey,
              child: const DashboardPreview(),
            ),

            const SizedBox(height: 80),

            /// DOWNLOAD
            Container(
              key: downloadKey,
              child: const DownloadApp(),
            ),

            const SizedBox(height: 40),

            /// FOOTER
            Container(
              key: footerKey,
              child: const FooterSection(),
            ),
          ],
        ),
      ),
    );
  }

  /// DESKTOP NAVBAR
  PreferredSizeWidget glassNavbar(BuildContext context) {
    return AppBar(
      toolbarHeight: 80,
      elevation: 0,
      backgroundColor: Colors.white,
      titleSpacing: 40,

      /// LOGO
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xff7C3AED),
                  Color(0xffDB2777),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.currency_rupee, color: Colors.white),
          ),
          const SizedBox(width: 12),
          const Text(
            "QuickLoan",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ],
      ),

      actions: [
        navItem("Home", () => scrollTo(heroKey)),
        navItem("EMI", () => scrollTo(emiKey)),
        navItem("Eligibility", () => scrollTo(eligibilityKey)),
        navItem("Dashboard", () => scrollTo(dashboardKey)),
        navItem("Download", () => scrollTo(downloadKey)),
        navItem("Contact", () => scrollTo(footerKey)),
        const SizedBox(width: 20),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xff7C3AED),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          onPressed: () {
            Navigator.pushNamed(context, "/login");
          },
          child: const Text("Get Started"),
        ),
        const SizedBox(width: 20),
      ],
    );
  }

  Widget navItem(String title, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: TextButton(
        onPressed: onTap,
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  /// MOBILE APPBAR
  PreferredSizeWidget mobileAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      titleSpacing: 16,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xff7C3AED), Color(0xffDB2777)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child:
                const Icon(Icons.currency_rupee, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          const Text(
            "QuickLoan",
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff7C3AED),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            ),
            onPressed: () {
              Navigator.pushNamed(context, "/login");
            },
            child: const Text("Get Started", style: TextStyle(fontSize: 12)),
          ),
        )
      ],
    );
  }

  /// MOBILE BOTTOM NAVBAR
  Widget mobileBottomNav() {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onBottomTap,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xff7C3AED),
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: "Home",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calculate),
          label: "EMI",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.verified),
          label: "Eligibility",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: "Dashboard",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.download),
          label: "App",
        ),
      ],
    );
  }
}
