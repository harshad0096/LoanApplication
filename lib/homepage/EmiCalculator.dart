import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class EmiCalculator extends StatefulWidget {
  const EmiCalculator({super.key});

  @override
  State<EmiCalculator> createState() => _EmiCalculatorState();
}

class _EmiCalculatorState extends State<EmiCalculator> {
  String selectedLoan = "";

  double amount = 200000;
  double tenure = 24;

  double interest = 10;
  double processingFee = 1;

  double minAmount = 50000;
  double maxAmount = 2000000;

  double minTenure = 6;
  double maxTenure = 60;

  /// LOAN POLICIES
  final List<Map<String, dynamic>> policies = [
    {
      "id": "personal",
      "title": "Personal Loan",
      "interest": 12.5,
      "processingFee": 2,
      "minAmount": 50000,
      "maxAmount": 2000000,
      "minTenure": 6,
      "maxTenure": 60,
    },
    {
      "id": "home",
      "title": "Home Loan",
      "interest": 8.5,
      "processingFee": 0.5,
      "minAmount": 500000,
      "maxAmount": 50000000,
      "minTenure": 60,
      "maxTenure": 360,
    },
    {
      "id": "vehicle",
      "title": "Vehicle Loan",
      "interest": 10.5,
      "processingFee": 1.5,
      "minAmount": 100000,
      "maxAmount": 5000000,
      "minTenure": 12,
      "maxTenure": 84,
    },
    {
      "id": "education",
      "title": "Education Loan",
      "interest": 9.5,
      "processingFee": 1,
      "minAmount": 100000,
      "maxAmount": 5000000,
      "minTenure": 12,
      "maxTenure": 120,
    }
  ];

  /// EMI FORMULA
  double get emi {
    double r = interest / 12 / 100;
    double n = tenure;

    return (amount * r * pow((1 + r), n)) / (pow((1 + r), n) - 1);
  }

  double get totalPayment => emi * tenure;

  double get totalInterest => totalPayment - amount;

  /// LOAD POLICY
  void loadPolicy(Map policy) {
    setState(() {
      selectedLoan = policy["id"];

      interest = policy["interest"].toDouble();
      processingFee = policy["processingFee"].toDouble();

      minAmount = policy["minAmount"].toDouble();
      maxAmount = policy["maxAmount"].toDouble();

      minTenure = policy["minTenure"].toDouble();
      maxTenure = policy["maxTenure"].toDouble();

      amount = minAmount;
      tenure = minTenure;
    });
  }

  @override
  void initState() {
    super.initState();
    loadPolicy(policies.first);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    bool isMobile = width < 700;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 40),
        child: Container(
          padding: EdgeInsets.all(isMobile ? 20 : 30),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: Colors.white,
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 20)],
          ),
          child: isMobile
              ? Column(
                  children: [
                    _leftSection(),
                    const SizedBox(height: 30),
                    _rightSection(),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _leftSection()),
                    const SizedBox(width: 40),
                    Expanded(child: _rightSection()),
                  ],
                ),
        ).animate().fade().slideY(),
      ),
    );
  }

  /// LEFT SIDE
  Widget _leftSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Loan EMI Calculator",
          style: TextStyle(
            fontSize: MediaQuery.of(context).size.width < 600 ? 24 : 30,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 25),

        const Text(
          "Loan Category",
          style: TextStyle(fontWeight: FontWeight.w500),
        ),

        const SizedBox(height: 10),

        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: policies.map((p) {
            bool selected = selectedLoan == p["id"];

            return ChoiceChip(
              label: Text(
                p["title"],
                style: TextStyle(
                  color: selected ? Colors.white : Colors.black,
                ),
              ),
              selected: selected,
              selectedColor: const Color(0xff7C3AED),
              onSelected: (_) => loadPolicy(p),
            );
          }).toList(),
        ),

        const SizedBox(height: 30),

        /// LOAN AMOUNT
        _sliderCard(
          title: "Loan Amount",
          value: "₹${amount.toInt()}",
          child: Slider(
            min: minAmount,
            max: maxAmount,
            value: amount,
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
            onChanged: (v) => setState(() => tenure = v),
          ),
        ),

        const SizedBox(height: 20),

        Row(
          children: [
            Expanded(
              child: _infoCard(
                "Interest",
                "$interest%",
                Icons.trending_up,
              ),
            ),
            const SizedBox(width: 10),
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title),
              Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.bold),
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
        color: Colors.grey.shade100,
      ),
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title),
              Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          )
        ],
      ),
    );
  }

  /// RIGHT SIDE EMI CARD
  Widget _rightSection() {
    bool isMobile = MediaQuery.of(context).size.width < 600;

    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: const Color(0xff111827),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Monthly EMI",
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 10),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: emi),
            duration: const Duration(milliseconds: 800),
            builder: (context, value, _) {
              return Text(
                "₹${value.toStringAsFixed(0)}",
                style: TextStyle(
                  fontSize: isMobile ? 32 : 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              );
            },
          ),
          const SizedBox(height: 30),
          _summary("Principal", "₹${amount.toInt()}"),
          _summary("Interest", "₹${totalInterest.toInt()}"),
          _summary("Total Payment", "₹${totalPayment.toInt()}"),
        ],
      ),
    );
  }

  Widget _summary(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
          Text(value,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
