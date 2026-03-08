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

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 900;

    return Scaffold(
      backgroundColor: const Color(0xffF5F7FB),

      /// NAVBAR
      appBar: glassNavbar(context),

      /// MOBILE DRAWER
      drawer: isMobile ? mobileDrawer() : null,

      /// APPLY BUTTON
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xff7C3AED),
        icon: const Icon(Icons.flash_on),
        label: const Text("Apply Loan"),
        onPressed: () {
          Navigator.pushNamed(context, "/login");
        },
      ),

      /// PAGE
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

  /// NAVBAR
  PreferredSizeWidget glassNavbar(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    bool isMobile = width < 900;

    return AppBar(
      toolbarHeight: 80,
      elevation: 0,
      backgroundColor: Colors.white.withOpacity(.9),
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
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),

      /// MENU
      actions: [
        if (!isMobile) ...[
          navItem("Home", () => scrollTo(heroKey)),
          navItem("EMI", () => scrollTo(emiKey)),
          navItem("Eligibility", () => scrollTo(eligibilityKey)),
          navItem("Dashboard", () => scrollTo(dashboardKey)),
          navItem("Download", () => scrollTo(downloadKey)),
          navItem("Contact", () => scrollTo(footerKey)),
          const SizedBox(width: 30),
        ],

        /// SIGN IN
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, "/login");
          },
          child: const Text(
            "Sign In",
            style: TextStyle(color: Colors.black87),
          ),
        ),

        const SizedBox(width: 10),

        /// GET STARTED
        Container(
          margin: const EdgeInsets.only(right: 20),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 6,
              backgroundColor: const Color(0xff7C3AED),
            ),
            onPressed: () {
              Navigator.pushNamed(context, "/login");
            },
            child: const Row(
              children: [
                Text("Get Started"),
                SizedBox(width: 6),
                Icon(Icons.arrow_forward, size: 18)
              ],
            ),
          ),
        ),

        /// MOBILE MENU
        if (isMobile)
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
          )
      ],
    );
  }

  /// NAV ITEM
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

  /// MOBILE DRAWER
  Drawer mobileDrawer() {
    return Drawer(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 40),
          drawerItem("Home", heroKey),
          drawerItem("EMI Calculator", emiKey),
          drawerItem("Eligibility", eligibilityKey),
          drawerItem("Dashboard", dashboardKey),
          drawerItem("Download App", downloadKey),
          drawerItem("Contact", footerKey),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.login),
            title: const Text("Login"),
            onTap: () {
              Navigator.pushNamed(context, "/login");
            },
          )
        ],
      ),
    );
  }

  Widget drawerItem(String title, GlobalKey key) {
    return ListTile(
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        scrollTo(key);
      },
    );
  }
}
