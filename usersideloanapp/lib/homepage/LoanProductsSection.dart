import 'package:flutter/material.dart';

class _LoanProductsSection extends StatelessWidget {
  final bool isMobile;

  const _LoanProductsSection({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 80,
        horizontal: isMobile ? 20 : 70,
      ),
      child: Column(
        children: [
          _badge("OUR PRODUCTS", Icons.credit_card),
          const SizedBox(height: 20),
          _sectionHeader("Loans Tailored ", "For You"),
          const SizedBox(height: 50),
          Wrap(
            spacing: 25,
            runSpacing: 25,
            alignment: WrapAlignment.center,
            children: [
              _loanCard(
                "Personal Loan",
                "For travel, medical emergencies, or personal needs.",
                "10.5% p.a.",
                "₹25 Lakh",
                Icons.person_outline,
                Colors.indigo,
              ),
              _loanCard(
                "Home Loan",
                "Finance your dream home with flexible EMI options.",
                "8.5% p.a.",
                "₹5 Crore",
                Icons.home_outlined,
                Colors.teal,
              ),
              _loanCard(
                "Business Loan",
                "Grow your startup or business with quick funding.",
                "12% p.a.",
                "₹50 Lakh",
                Icons.trending_up,
                Colors.orange,
              ),
              _loanCard(
                "Car Loan",
                "Drive your dream car with low interest rates.",
                "9.2% p.a.",
                "₹20 Lakh",
                Icons.directions_car_outlined,
                Colors.purple,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _loanCard(
    String title,
    String desc,
    String rate,
    String limit,
    IconData icon,
    Color color,
  ) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ICON
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 26),
          ),

          const SizedBox(height: 20),

          /// TITLE
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          /// DESCRIPTION
          Text(
            desc,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 13,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 20),
          const Divider(),

          /// RATE
          _infoRow("Interest Rate", rate, true),

          /// LIMIT
          _infoRow("Maximum Loan", limit, false),

          const SizedBox(height: 20),

          /// APPLY BUTTON
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                "Apply Now",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String lightText, String highlightText) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: const TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w900,
          color: Color(0xFF0F172A),
        ),
        children: [
          TextSpan(text: lightText),
          TextSpan(
            text: highlightText,
            style: const TextStyle(
              color: Color(0xFF9333EA),
            ),
          ),
        ],
      ),
    );
  }

  Widget _badge(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F3FF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF7C3AED)),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF7C3AED),
              fontWeight: FontWeight.bold,
              fontSize: 11,
              letterSpacing: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, bool highlight) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: highlight ? Colors.green : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
