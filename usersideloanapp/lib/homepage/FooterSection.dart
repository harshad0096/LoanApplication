import 'package:flutter/material.dart';

class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

  Widget footerTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget footerItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 14,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double width = constraints.maxWidth;

        bool isMobile = width < 600;
        bool isTablet = width >= 600 && width < 1000;

        double horizontalPadding = isMobile ? 20 : 60;

        return Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: 50,
          ),
          color: const Color(0xff0F172A),
          child: Column(
            children: [
              /// MAIN FOOTER
              Wrap(
                spacing: 60,
                runSpacing: 40,
                alignment: WrapAlignment.spaceBetween,
                children: [
                  /// COMPANY INFO
                  SizedBox(
                    width: isMobile ? double.infinity : 260,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "QuickLoan",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 15),

                        const Text(
                          "QuickLoan is a secure fintech platform that helps users apply for loans, track approvals and manage finances easily.",
                          style: TextStyle(
                            color: Colors.white70,
                            height: 1.6,
                          ),
                        ),

                        const SizedBox(height: 20),

                        /// SOCIAL ICONS
                        Row(
                          children: const [
                            Icon(Icons.facebook, color: Colors.white70),
                            SizedBox(width: 12),
                            Icon(Icons.language, color: Colors.white70),
                            SizedBox(width: 12),
                            Icon(Icons.linked_camera, color: Colors.white70),
                          ],
                        )
                      ],
                    ),
                  ),

                  /// QUICK LINKS
                  SizedBox(
                    width: isMobile ? double.infinity : 180,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        footerTitle("Quick Links"),
                        const SizedBox(height: 15),
                        footerItem("Home"),
                        footerItem("Apply Loan"),
                        footerItem("Loan Status"),
                        footerItem("Documents"),
                      ],
                    ),
                  ),

                  /// SUPPORT
                  SizedBox(
                    width: isMobile ? double.infinity : 180,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        footerTitle("Support"),
                        const SizedBox(height: 15),
                        footerItem("Help Center"),
                        footerItem("Privacy Policy"),
                        footerItem("Terms & Conditions"),
                        footerItem("Contact Us"),
                      ],
                    ),
                  ),

                  /// CONTACT
                  SizedBox(
                    width: isMobile ? double.infinity : 220,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        footerTitle("Contact"),
                        const SizedBox(height: 15),
                        footerItem("support@quickloan.com"),
                        footerItem("+91 98765 43210"),
                        footerItem("Pune, Maharashtra, India"),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              const Divider(color: Colors.white24),

              const SizedBox(height: 20),

              /// COPYRIGHT
              const Text(
                "© 2026 QuickLoan Finance Pvt Ltd • RBI Registered NBFC",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
