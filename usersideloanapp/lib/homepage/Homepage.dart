import 'package:flutter/material.dart';
import 'package:usersideloanapp/Login/Login.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 900;

    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFF),
      appBar: _buildNavBar(context, isMobile),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            _HeroSection(context: context, isMobile: isMobile),
            _StatsSection(isMobile: isMobile),
            _AboutSection(isMobile: isMobile),
            _ProcessSection(isMobile: isMobile),
            _LoanProductsSection(isMobile: isMobile),
            _TestimonialSection(isMobile: isMobile),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildNavBar(BuildContext context, bool isMobile) {
    return AppBar(
      backgroundColor: Colors.white.withOpacity(0.9),
      elevation: 0,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: const Color(0xFF9333EA),
                borderRadius: BorderRadius.circular(8)),
            child:
                const Icon(Icons.currency_rupee, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          const Text("QuickLoan",
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
        ],
      ),
      actions: isMobile
          ? null
          : [
              _navLink("About"),
              _navLink("Process"),
              _navLink("Loans"),
              _navLink("Help"),
              _navLink("Contact"),
              const SizedBox(width: 20),
              TextButton(
                  onPressed: () {},
                  child: const Text("Sign In",
                      style: TextStyle(color: Color(0xFF1E293B)))),
              const SizedBox(width: 10),
              _gradientButton(context, "Get Started", true),
              const SizedBox(width: 20),
            ],
    );
  }

  Widget _navLink(String title) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Text(title,
            style: const TextStyle(color: Colors.grey, fontSize: 14)),
      );
}

// --- HERO SECTION ---
class _HeroSection extends StatelessWidget {
  final BuildContext context;
  final bool isMobile;
  const _HeroSection({required this.context, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          EdgeInsets.symmetric(horizontal: isMobile ? 20 : 80, vertical: 60),
      decoration: BoxDecoration(
        gradient: RadialGradient(
            center: const Alignment(0.8, -0.5),
            radius: 1.2,
            colors: [const Color(0xFFF3E8FF), const Color(0xFFFDFDFF)]),
      ),
      child: isMobile
          ? Column(
              children: [_content(), const SizedBox(height: 40), _heroImage()])
          : Row(children: [
              Expanded(child: _content()),
              Expanded(child: _heroImage())
            ]),
    );
  }

  Widget _content() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _badge("RBI REGISTERED NBFC", Icons.shield_outlined),
          const SizedBox(height: 20),
          RichText(
              text: const TextSpan(
                  style: TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F172A),
                      height: 1.1),
                  children: [
                TextSpan(text: "Instant\nLoans, "),
                TextSpan(
                    text: "Zero\nHassle",
                    style: TextStyle(color: Color(0xFF9333EA))),
              ])),
          const SizedBox(height: 20),
          const Text(
              "Get loans up to ₹25 Lakhs with minimal documentation.\nAI-powered approvals in under 24 hours.",
              style: TextStyle(fontSize: 18, color: Colors.grey, height: 1.5)),
          const SizedBox(height: 40),
          Row(children: [
            _gradientButton(context, "Apply Now — It's Free", false),
            const SizedBox(width: 15),
            _outlineButton("How It Works", Icons.play_circle_outline),
          ]),
        ],
      );

  Widget _heroImage() =>
      Image.network('https://i.imgur.com/your_mockup_placeholder.png',
          errorBuilder: (c, e, s) => _mockDashboard());

  Widget _mockDashboard() => Container(
        height: 400,
        decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(30)),
        padding: const EdgeInsets.all(30),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Icon(Icons.credit_card, color: Colors.purpleAccent),
            Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(8)),
                child: const Text("CIBIL: 782",
                    style: TextStyle(color: Colors.white, fontSize: 12))),
          ]),
          const Spacer(),
          const Text("AVAILABLE CREDIT",
              style: TextStyle(color: Colors.grey, fontSize: 12)),
          const Text("₹25,00,000",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          LinearProgressIndicator(
              value: 0.3,
              backgroundColor: Colors.white10,
              color: Colors.tealAccent),
          const SizedBox(height: 10),
          const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Used: ₹7,50,000",
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
                Text("Limit: ₹25L",
                    style: TextStyle(color: Colors.grey, fontSize: 12))
              ]),
        ]),
      );
}

// --- STATS SECTION ---
class _StatsSection extends StatelessWidget {
  final bool isMobile;
  const _StatsSection({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
      child: Wrap(
          spacing: 20,
          runSpacing: 20,
          alignment: WrapAlignment.center,
          children: [
            _statCard("1M+", "Happy Customers", Icons.people_outline),
            _statCard("₹5000Cr+", "Loans Disbursed", Icons.currency_rupee),
            _statCard("4.8★", "App Rating", Icons.star_border),
            _statCard("24hrs", "Avg. Approval", Icons.timer_outlined),
          ]),
    );
  }

  Widget _statCard(String val, String label, IconData icon) => Container(
        width: 240,
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20)
            ]),
        child: Column(children: [
          Icon(icon, color: Colors.indigo, size: 30),
          const SizedBox(height: 15),
          Text(val,
              style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF9333EA))),
          Text(label, style: const TextStyle(color: Colors.grey)),
        ]),
      );
}

// --- PROCESS SECTION (4 STEPS) ---
class _ProcessSection extends StatelessWidget {
  final bool isMobile;
  const _ProcessSection({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 20),
      child: Column(children: [
        _badge("HOW IT WORKS", Icons.bolt),
        const SizedBox(height: 20),
        _sectionHeader("Get Your Loan in ", "4 Simple Steps"),
        const SizedBox(height: 60),
        Wrap(
            spacing: 30,
            runSpacing: 40,
            alignment: WrapAlignment.center,
            children: [
              _stepCard(
                  "01",
                  "Apply Online",
                  "Fill a simple application form with basic details.",
                  Icons.edit_document,
                  Colors.indigo),
              _stepCard(
                  "02",
                  "Instant Verification",
                  "AI-powered KYC and CIBIL check completes in 2 mins.",
                  Icons.verified_user_outlined,
                  Colors.teal),
              _stepCard(
                  "03",
                  "Get Approved",
                  "Receive approval with best-in-class rates within 24 hours.",
                  Icons.account_balance_wallet_outlined,
                  Colors.orange),
              _stepCard(
                  "04",
                  "Money Disbursed",
                  "Funds transferred directly to your bank account same day.",
                  Icons.payments_outlined,
                  Colors.pink),
            ]),
      ]),
    );
  }

  Widget _stepCard(
          String num, String title, String desc, IconData icon, Color col) =>
      Container(
        width: 260,
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.grey.shade100)),
        child: Stack(children: [
          Positioned(
              right: 0,
              top: 0,
              child: Text(num,
                  style: TextStyle(
                      fontSize: 60,
                      fontWeight: FontWeight.w900,
                      color: Colors.grey.shade50))),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: col.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: col)),
            const SizedBox(height: 25),
            Text(title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(desc,
                style: TextStyle(color: Colors.grey.shade500, height: 1.5)),
          ]),
        ]),
      );
}

// --- LOAN PRODUCTS SECTION ---
class _LoanProductsSection extends StatelessWidget {
  final bool isMobile;
  const _LoanProductsSection({required this.isMobile});
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      _badge("OUR PRODUCTS", Icons.credit_card),
      const SizedBox(height: 20),
      _sectionHeader("Loans Tailored ", "For You"),
      const SizedBox(height: 50),
      Wrap(
          spacing: 20,
          runSpacing: 20,
          alignment: WrapAlignment.center,
          children: [
            _loanCard(
                "Personal Loan",
                "For your personal needs, travel, or emergencies",
                "10.5% p.a.",
                "₹25 Lakh",
                Icons.person_outline,
                Colors.indigo),
            _loanCard("Home Loan", "Make your dream home a reality",
                "8.5% p.a.", "₹5 Crore", Icons.home_outlined, Colors.teal),
            _loanCard(
                "Business Loan",
                "Grow your business with flexible funding",
                "12% p.a.",
                "₹50 Lakh",
                Icons.trending_up,
                Colors.orange),
            _loanCard("Car Loan", "Drive your dream car today", "9.2% p.a.",
                "₹20 Lakh", Icons.electric_bolt, Colors.cyan),
          ]),
    ]);
  }

  Widget _loanCard(String title, String desc, String rate, String limit,
          IconData icon, Color col) =>
      Container(
        width: 280,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20)
            ]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: col.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: col)),
          const SizedBox(height: 20),
          Text(title,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text(desc,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
          const SizedBox(height: 20),
          const Divider(),
          _rowInfo("Starting Rate", rate, true),
          _rowInfo("Up to", limit, false),
          const SizedBox(height: 20),
          Center(
              child: TextButton(
                  onPressed: () {},
                  child: const Text("Apply Now →",
                      style: TextStyle(
                          color: Colors.indigo, fontWeight: FontWeight.bold)))),
        ]),
      );
}

// --- TESTIMONIAL SECTION ---
class _TestimonialSection extends StatelessWidget {
  final bool isMobile;
  const _TestimonialSection({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80),
      child: Column(children: [
        _badge("TESTIMONIALS", Icons.star_outline),
        const SizedBox(height: 20),
        _sectionHeader("Loved by ", "Thousands"),
        const SizedBox(height: 50),
        Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: [
              _testiCard(
                  "Got my business loan approved in just 6 hours. The process was incredibly smooth!",
                  "Priya Sharma",
                  "PS"),
              _testiCard(
                  "Best interest rates I found anywhere. Highly recommended!",
                  "Amit Patel",
                  "AP"),
              _testiCard(
                  "Minimal documentation and instant check. Perfect for professionals.",
                  "Sneha Reddy",
                  "SR"),
            ]),
      ]),
    );
  }

  Widget _testiCard(String text, String name, String init) => Container(
        width: 320,
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20)
            ]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
              children: List.generate(
                  5,
                  (i) =>
                      const Icon(Icons.star, color: Colors.orange, size: 16))),
          const SizedBox(height: 20),
          Text("\"$text\"",
              style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF475569),
                  fontStyle: FontStyle.italic)),
          const SizedBox(height: 20),
          Row(children: [
            CircleAvatar(
                backgroundColor: Colors.purpleAccent,
                child: Text(init, style: const TextStyle(color: Colors.white))),
            const SizedBox(width: 12),
            Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
          ]),
        ]),
      );
}

// --- SHARED UI COMPONENTS ---
Widget _badge(String label, IconData icon) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
          color: const Color(0xFFF5F3FF),
          borderRadius: BorderRadius.circular(20)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: const Color(0xFF7C3AED)),
        const SizedBox(width: 8),
        Text(label,
            style: const TextStyle(
                color: Color(0xFF7C3AED),
                fontWeight: FontWeight.bold,
                fontSize: 11,
                letterSpacing: 1.1)),
      ]),
    );

Widget _sectionHeader(String light, String bold) => RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
          style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A)),
          children: [
            TextSpan(text: light),
            TextSpan(
                text: bold, style: const TextStyle(color: Color(0xFF9333EA))),
          ]),
    );

Widget _gradientButton(BuildContext context, String text, bool small) =>
    Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xFF7C3AED), Color(0xFFDB2777)]),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFFDB2777).withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 5))
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context, '/login');
        },
        style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: EdgeInsets.symmetric(
                horizontal: small ? 20 : 30, vertical: small ? 15 : 22)),
        child: Text(text,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );

Widget _outlineButton(String text, IconData icon) => OutlinedButton.icon(
      onPressed: () {},
      icon: Icon(icon, color: Colors.black),
      label: Text(text,
          style: const TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold)),
      style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 22),
          side: BorderSide(color: Colors.grey.shade200),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
    );

Widget _rowInfo(String label, String val, bool isGreen) => Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        Text(val,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isGreen ? Colors.green : Colors.black)),
      ]),
    );

// --- ABOUT SECTION (Mockup) ---
class _AboutSection extends StatelessWidget {
  final bool isMobile;
  const _AboutSection({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          EdgeInsets.symmetric(horizontal: isMobile ? 20 : 80, vertical: 80),
      child: isMobile
          ? Column(children: [
              _aboutText(),
              const SizedBox(height: 40),
              _aboutGrid()
            ])
          : Row(children: [
              Expanded(child: _aboutText()),
              Expanded(child: _aboutGrid())
            ]),
    );
  }

  Widget _aboutText() =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _badge("ABOUT US", Icons.info_outline),
        const SizedBox(height: 20),
        const Text("India's Most Trusted Digital Lending Platform",
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        const Text(
            "QuickLoan leverages cutting-edge AI to make lending fast, transparent, and accessible.",
            style: TextStyle(color: Colors.grey, height: 1.6)),
        const SizedBox(height: 20),
        ...[
          "AI-powered assessment",
          "Bank-grade security",
          "Zero hidden charges"
        ].map((e) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 18),
              const SizedBox(width: 10),
              Text(e)
            ]))),
      ]);

  Widget _aboutGrid() => GridView.count(
        shrinkWrap: true,
        crossAxisCount: 2,
        mainAxisSpacing: 15,
        crossAxisSpacing: 15,
        childAspectRatio: 1.2,
        children: [
          _miniCard(Icons.groups, "1M+ Customers"),
          _miniCard(Icons.shield, "RBI Registered"),
          _miniCard(Icons.bolt, "AI Powered"),
          _miniCard(Icons.star, "4.8 Rated"),
        ],
      );

  Widget _miniCard(IconData i, String t) => Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade100)),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(i, color: Colors.indigo),
          const SizedBox(height: 10),
          Text(t, style: const TextStyle(fontWeight: FontWeight.bold))
        ]),
      );
}
