import 'package:flutter/material.dart';

class _TestimonialSection extends StatelessWidget {
  final bool isMobile;

  const _TestimonialSection({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 80,
        horizontal: isMobile ? 20 : 80,
      ),
      color: const Color(0xFFF8FAFC),
      child: Column(
        children: [
          _badge("TESTIMONIALS", Icons.star_outline),
          const SizedBox(height: 20),
          _sectionHeader("Loved by ", "Thousands of Customers"),
          const SizedBox(height: 50),
          Wrap(
            spacing: 25,
            runSpacing: 25,
            alignment: WrapAlignment.center,
            children: [
              _testimonialCard(
                "Got my business loan approved in just 6 hours. The process was incredibly smooth and transparent.",
                "Priya Sharma",
                "PS",
              ),
              _testimonialCard(
                "Best interest rates I found anywhere. The application process was extremely easy.",
                "Amit Patel",
                "AP",
              ),
              _testimonialCard(
                "Minimal documentation and very fast approval. Perfect platform for professionals.",
                "Sneha Reddy",
                "SR",
              ),
            ],
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

  Widget _testimonialCard(String text, String name, String initials) {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// STARS
          Row(
            children: List.generate(
              5,
              (index) => const Icon(Icons.star, color: Colors.orange, size: 18),
            ),
          ),

          const SizedBox(height: 20),

          /// REVIEW TEXT
          Text(
            "\"$text\"",
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              color: Color(0xFF475569),
              fontStyle: FontStyle.italic,
            ),
          ),

          const SizedBox(height: 25),

          /// USER INFO
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFF9333EA),
                child: Text(
                  initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
