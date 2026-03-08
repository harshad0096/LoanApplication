import 'package:flutter/material.dart';

class GradientSection extends StatefulWidget {
  const GradientSection({super.key});

  @override
  State<GradientSection> createState() => _GradientSectionState();
}

class _GradientSectionState extends State<GradientSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> floatingAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    floatingAnimation = Tween<double>(begin: -12, end: 12).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 900;

    return Container(
      clipBehavior: Clip.hardEdge,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 60,
        vertical: isMobile ? 40 : 60,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xff7F00FF), Color(0xffE100FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(60),
          bottomRight: Radius.circular(60),
        ),
      ),
      child: isMobile ? _mobileLayout() : _webLayout(),
    );
  }

  /// ================= WEB LAYOUT =================
  Widget _webLayout() {
    return Row(
      children: [
        Expanded(
          flex: 5,
          child: _textSection(),
        ),
        Expanded(
          flex: 5,
          child: _imageSection(),
        ),
      ],
    );
  }

  /// ================= MOBILE LAYOUT =================
  Widget _mobileLayout() {
    return Column(
      children: [
        _imageSection(),
        const SizedBox(height: 30),
        _textSection(),
      ],
    );
  }

  /// ================= TEXT =================
  Widget _textSection() {
    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: 900),
      tween: Tween<double>(begin: 40, end: 0),
      curve: Curves.easeOut,
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset(0, value),
          child: Opacity(
            opacity: value == 0 ? 1 : 0.9,
            child: child,
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xff7B61FF), Color(0xffA855F7)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.currency_rupee,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(height: 30),
          const Text(
            "QuickLoan",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 30),
          const Text(
            "Smart Loans\nfor Smart People",
            style: TextStyle(
              color: Colors.white,
              fontSize: 42,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Get instant personal, home, car and business loans with minimal documentation.",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  /// ================= FLOATING IMAGE =================
  Widget _imageSection() {
    return AnimatedBuilder(
      animation: floatingAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, floatingAnimation.value),
          child: child,
        );
      },
      child: Image.asset(
        "assets/images/loan_signup.png",
        height: 320,
        fit: BoxFit.contain,
      ),
    );
  }
}
