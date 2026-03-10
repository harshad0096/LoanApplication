import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:usersideloanapp/user/application_form/providers/loan_provider.dart';
import 'package:usersideloanapp/user/application_form/screens/loan_step1_details.dart';

class LoansPage extends StatefulWidget {
  const LoansPage({super.key});

  @override
  State<LoansPage> createState() => _LoansPageState();
}

class _LoansPageState extends State<LoansPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  String? hoveredCard;
  bool _isNavigating = false; // 🛡 prevent double tap

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fadeAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, .08),
      end: Offset.zero,
    ).animate(_fadeAnimation);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // =========================================================
  // APPLY LOAN — PRODUCTION SAFE
  // =========================================================
  Future<void> _applyLoan(BuildContext context, String loanName) async {
    if (_isNavigating) return;
    _isNavigating = true;

    try {
      final provider = context.read<LoanProvider>();

      provider.reset();
      provider.setLoanType(loanName); // ✅ AUTO SET TYPE

      await Navigator.pushNamed(
        context,
        '/loan-step1',
        arguments: loanName,
      );
    } catch (e) {
      debugPrint("Navigation error: $e");
    } finally {
      _isNavigating = false;
    }
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    int crossAxisCount = 1;
    if (width > 1300) {
      crossAxisCount = 3;
    } else if (width > 750) {
      crossAxisCount = 2;
    }

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xfff6f8ff), Color(0xffeef2ff)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(width < 700 ? 16 : 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _premiumHeader(),
                const SizedBox(height: 28),
                _glassBanner(context, width < 900),
                const SizedBox(height: 40),
                const Text(
                  "All Loan Products",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildFeatureCard(
                  icon: Icons.verified,
                  title: "Pre-Approved Offers",
                  subtitle: "Exclusive deals based on your profile",
                  width: width < 700 ? double.infinity : 300,
                ),
                const SizedBox(height: 20),
                GridView.count(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 22,
                  mainAxisSpacing: 22,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.15,
                  children: [
                    _loanCard(
                      context: context,
                      id: "personal_loan",
                      title: "Personal Loan",
                      rate: "10.5%",
                      amount: "₹25 Lakhs",
                      tenure: "Up to 5 years",
                      color: const Color(0xff6D5DF6),
                    ),
                    _loanCard(
                      context: context,
                      id: "home",
                      title: "Home Loan",
                      rate: "8.5%",
                      amount: "₹5 Crore",
                      tenure: "Up to 30 years",
                      color: const Color(0xff00A8A8),
                    ),
                    _loanCard(
                      context: context,
                      id: "car",
                      title: "Car Loan",
                      rate: "9.0%",
                      amount: "₹50 Lakhs",
                      tenure: "Up to 7 years",
                      color: const Color(0xffFF8A00),
                    ),
                    _loanCard(
                      context: context,
                      id: "education",
                      title: "Education Loan",
                      rate: "9.5%",
                      amount: "₹75 Lakhs",
                      tenure: "Up to 15 years",
                      color: const Color(0xff00C853),
                    ),
                    _loanCard(
                      context: context,
                      id: "business",
                      title: "Business Loan",
                      rate: "12.0%",
                      amount: "₹2 Crore",
                      tenure: "Up to 10 years",
                      color: const Color(0xffFF4D4F),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =========================================================
  // HEADER
  // =========================================================

  Widget _premiumHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Loan Marketplace",
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: 6),
        Text(
          "Choose smart financing tailored for you",
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  // =========================================================
  // GLASS BANNER
  // =========================================================

  Widget _glassBanner(BuildContext context, bool isMobile) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xff6D5DF6), Color(0xffEC4899)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff6D5DF6).withOpacity(.25),
            blurRadius: 40,
            offset: const Offset(0, 20),
          )
        ],
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _bannerContent(),
                const SizedBox(height: 22),
                _gradientButton(context, "Pre-Approved Personal Loan"),
              ],
            )
          : Row(
              children: [
                Expanded(child: _bannerContent()),
                _gradientButton(context, "Pre-Approved Personal Loan"),
              ],
            ),
    );
  }

  Widget _bannerContent() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Recommended for You", style: TextStyle(color: Colors.white70)),
        SizedBox(height: 10),
        Text(
          "Pre-Approved Personal Loan",
          style: TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        Text(
          "Instant approval up to ₹25 Lakhs with minimal documentation.",
          style: TextStyle(color: Colors.white70),
        ),
      ],
    );
  }

// Helper method to keep code clean
  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required double width,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50), // Fully rounded ends
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.indigo.shade50,
            child: Icon(icon, color: Colors.indigo.shade400, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(subtitle,
                    style:
                        TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _gradientButton(BuildContext context, String loanName) {
    return InkWell(
      onTap: () => _applyLoan(context, loanName),
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Text(
          "Apply Now →",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xff6D5DF6),
          ),
        ),
      ),
    );
  }

  // =========================================================
  // LOAN CARD
  // =========================================================

  Widget _loanCard({
    required BuildContext context,
    required String id,
    required String title,
    required String rate,
    required String amount,
    required String tenure,
    required Color color,
  }) {
    final isHover = hoveredCard == id;

    return MouseRegion(
      onEnter: (_) => setState(() => hoveredCard = id),
      onExit: (_) => setState(() => hoveredCard = null),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        transform: isHover
            ? (Matrix4.identity()..translate(0, -6))
            : Matrix4.identity(),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isHover ? 0.12 : 0.05),
              blurRadius: isHover ? 25 : 12,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(.12),
              child: Icon(Icons.account_balance, color: color),
            ),
            const SizedBox(height: 16),
            Text(title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 14),
            _infoRow("Interest", rate),
            _infoRow("Max Amount", amount),
            _infoRow("Tenure", tenure),
            const Spacer(),
            InkWell(
              onTap: () {
                context.read<LoanProvider>().setLoanType(id);

                Navigator.pushNamed(
                  context,
                  '/loan-step1',
                  arguments: id,
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: color.withOpacity(.08),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Apply Now",
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String t, String v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text("$t: $v", style: const TextStyle(color: Colors.black87)),
    );
  }
}
