import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_animate/flutter_animate.dart';

class EmiCalculator extends StatefulWidget {
  const EmiCalculator({super.key});

  @override
  State<EmiCalculator> createState() => _EmiCalculatorState();
}

class _EmiCalculatorState extends State<EmiCalculator> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  String selectedLoan = "";
  double amount = 200000;
  double tenure = 24;

  double interest = 10;
  double processingFee = 1;

  double minAmount = 50000;
  double maxAmount = 2000000;

  double minTenure = 6;
  double maxTenure = 60;

  /// EMI FORMULA
  double get emi {
    double r = interest / 12 / 100;
    double n = tenure;

    double emi = (amount * r * (pow((1 + r), n))) / (pow((1 + r), n) - 1);

    return emi;
  }

  double get totalPayment => emi * tenure;

  double get totalInterest => totalPayment - amount;

  /// FETCH POLICY DATA
  void loadPolicy(DocumentSnapshot doc) {
    setState(() {
      selectedLoan = doc.id;

      interest = doc['interest'].toDouble();
      processingFee = doc['processingFee'].toDouble();

      minAmount = doc['minAmount'].toDouble();
      maxAmount = doc['maxAmount'].toDouble();

      minTenure = doc['minTenure'].toDouble();
      maxTenure = doc['maxTenure'].toDouble();

      amount = minAmount;
      tenure = minTenure;
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    bool isMobile = width < 800;

    return Padding(
      padding: const EdgeInsets.all(40),
      child: StreamBuilder<QuerySnapshot>(
        stream: firestore.collection("loan_policies").snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final policies = snapshot.data!.docs;

          return Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: Colors.white,
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 20)
              ],
            ),
            child: isMobile
                ? Column(
                    children: [
                      _leftSection(policies),
                      const SizedBox(height: 30),
                      _rightSection()
                    ],
                  )
                : Row(
                    children: [
                      Expanded(child: _leftSection(policies)),
                      const SizedBox(width: 40),
                      Expanded(child: _rightSection())
                    ],
                  ),
          ).animate().fade().slideY();
        },
      ),
    );
  }

  /// LEFT SIDE
  Widget _leftSection(List policies) {
    final width = MediaQuery.of(context).size.width;
    bool isMobile = width < 700;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// TITLE
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xff7C3AED), Color(0xffEC4899)],
          ).createShader(bounds),
          child: const Text(
            "Loan EMI Calculator",
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),

        const SizedBox(height: 25),

        /// LOAN CATEGORY
        Text(
          "Loan Category",
          style: TextStyle(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 10),

        Wrap(
          spacing: 12,
          runSpacing: 10,
          children: policies.map((p) {
            bool selected = selectedLoan == p.id;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              child: ChoiceChip(
                label: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Text(
                    p['title'],
                    style: TextStyle(
                      color: selected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                selected: selected,
                selectedColor: const Color(0xff7C3AED),
                backgroundColor: Colors.grey.shade200,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                onSelected: (_) => loadPolicy(p),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 35),

        /// LOAN AMOUNT
        _sliderCard(
          title: "Loan Amount",
          value: "₹${amount.toInt()}",
          child: Slider(
            min: minAmount,
            max: maxAmount,
            value: amount,
            activeColor: const Color(0xff7C3AED),
            onChanged: (v) => setState(() => amount = v),
          ),
        ),

        const SizedBox(height: 20),

        /// TENURE
        _sliderCard(
          title: "Tenure",
          value: "${tenure.toInt()} months",
          child: Slider(
            min: minTenure,
            max: maxTenure,
            value: tenure,
            activeColor: const Color(0xff7C3AED),
            onChanged: (v) => setState(() => tenure = v),
          ),
        ),

        const SizedBox(height: 25),

        /// POLICY INFO CARDS
        Row(
          children: [
            Expanded(
              child: _infoCard(
                "Interest",
                "$interest%",
                Icons.trending_up,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: _infoCard(
                "Processing Fee",
                "$processingFee%",
                Icons.account_balance_wallet,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _sliderCard({
    required String title,
    required String value,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.grey.shade100,
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: const Color(0xff7C3AED).withOpacity(.1),
                ),
                child: Text(
                  value,
                  style: const TextStyle(
                    color: Color(0xff7C3AED),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            ],
          ),
          child
        ],
      ),
    );
  }

  Widget _infoCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [
            Color(0xffF8FAFC),
            Color(0xffF1F5F9),
          ],
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xff7C3AED)),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.black54)),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  /// RIGHT SIDE
  Widget _rightSection() {
    final width = MediaQuery.of(context).size.width;
    bool isMobile = width < 700;

    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: 900),
      tween: Tween<double>(begin: 0.85, end: 1),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) {
        return Transform.scale(scale: scale, child: child);
      },
      child: Container(
        padding: EdgeInsets.all(isMobile ? 22 : 30),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),

          /// FINTECH GRADIENT
          gradient: const LinearGradient(
            colors: [
              Color(0xff0F172A),
              Color(0xff1E293B),
              Color(0xff020617),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),

          /// PREMIUM SHADOW
          boxShadow: [
            BoxShadow(
              color: const Color(0xff7C3AED).withOpacity(.45),
              blurRadius: 60,
              spreadRadius: 2,
              offset: const Offset(0, 20),
            )
          ],

          /// GLASS BORDER
          border: Border.all(
            color: Colors.white.withOpacity(.08),
          ),
        ),
        child: Stack(
          children: [
            /// GRID BACKGROUND
            Positioned.fill(
              child: CustomPaint(
                painter: _CardGridPainter(),
              ),
            ),

            /// GLOW CIRCLE
            Positioned(
              right: -40,
              top: -40,
              child: Container(
                height: 120,
                width: 120,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Color(0xff7C3AED),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// HEADER
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      "Monthly EMI",
                      style: TextStyle(
                        color: Colors.white60,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Icon(Icons.auto_graph, color: Colors.white38)
                  ],
                ),

                const SizedBox(height: 12),

                /// EMI VALUE ANIMATION
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: emi),
                  duration: const Duration(milliseconds: 1200),
                  builder: (context, value, _) {
                    return Text(
                      "₹${value.toStringAsFixed(0)}",
                      style: TextStyle(
                        fontSize: isMobile ? 34 : 42,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.1,
                      ),
                    );
                  },
                ),

                const SizedBox(height: 30),

                /// SUMMARY
                _summaryCard("Principal", "₹${amount.toInt()}"),
                _summaryCard("Interest", "₹${totalInterest.toInt()}"),
                _summaryCard("Total Payment", "₹${totalPayment.toInt()}"),

                const SizedBox(height: 30),

                /// APPLY BUTTON
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      backgroundColor: Colors.transparent,
                    ),
                    onPressed: () {},
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xff7C3AED),
                            Color(0xff4F46E5),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xff7C3AED).withOpacity(.6),
                            blurRadius: 20,
                          )
                        ],
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.flash_on, color: Colors.white),
                            SizedBox(width: 10),
                            Text(
                              "Apply Loan",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Widget _summaryCard(String title, String value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white70),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _summary(String label, String value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Row(
      children: [
        Expanded(
            child: Text(label, style: const TextStyle(color: Colors.white70))),
        Text(value,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold))
      ],
    ),
  );
}

class _CardGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1;

    const double spacing = 35;

    /// Vertical Lines
    for (double x = 0; x <= size.width; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    /// Horizontal Lines
    for (double y = 0; y <= size.height; y += spacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }

    /// Highlight center cross line (Fintech style)
    final highlight = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..strokeWidth = 1.4;

    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      highlight,
    );

    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      highlight,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
