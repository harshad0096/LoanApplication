import 'package:flutter/material.dart';

class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

  Widget footerTitle(String text, bool isMobile) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.white,
        fontSize: isMobile ? 16 : 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget footerItem(String text, bool isMobile) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white70,
          fontSize: isMobile ? 13 : 14,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double width = constraints.maxWidth;

        bool isMobile = width < 650;
        bool isTablet = width >= 650 && width < 1000;
        bool isDesktop = width >= 1000;

        double horizontalPadding = isMobile
            ? 20
            : isTablet
                ? 40
                : 80;

        return Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: isMobile ? 40 : 60,
          ),
          color: const Color(0xff0F172A),
          child: Column(
            children: [
              /// MAIN FOOTER CONTENT
              isMobile
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        companyInfo(isMobile),
                        const SizedBox(height: 30),
                        quickLinks(isMobile),
                        const SizedBox(height: 30),
                        supportLinks(isMobile),
                        const SizedBox(height: 30),
                        contactInfo(isMobile),
                      ],
                    )
                  : Wrap(
                      spacing: 60,
                      runSpacing: 40,
                      alignment: WrapAlignment.spaceBetween,
                      children: [
                        companyInfo(isMobile),
                        quickLinks(isMobile),
                        supportLinks(isMobile),
                        contactInfo(isMobile),
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

  /// COMPANY INFO
  Widget companyInfo(bool isMobile) {
    return SizedBox(
      width: isMobile ? double.infinity : 260,
      child: Column(
        crossAxisAlignment:
            isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
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
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              height: 1.6,
            ),
          ),

          const SizedBox(height: 20),

          /// SOCIAL ICONS
          Row(
            mainAxisAlignment:
                isMobile ? MainAxisAlignment.center : MainAxisAlignment.start,
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
    );
  }

  /// QUICK LINKS
  Widget quickLinks(bool isMobile) {
    return SizedBox(
      width: isMobile ? double.infinity : 180,
      child: Column(
        crossAxisAlignment:
            isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          footerTitle("Quick Links", isMobile),
          const SizedBox(height: 15),
          footerItem("Home", isMobile),
          footerItem("Apply Loan", isMobile),
          footerItem("Loan Status", isMobile),
          footerItem("Documents", isMobile),
        ],
      ),
    );
  }

  /// SUPPORT
  Widget supportLinks(bool isMobile) {
    return SizedBox(
      width: isMobile ? double.infinity : 180,
      child: Column(
        crossAxisAlignment:
            isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          footerTitle("Support", isMobile),
          const SizedBox(height: 15),
          footerItem("Help Center", isMobile),
          footerItem("Privacy Policy", isMobile),
          footerItem("Terms & Conditions", isMobile),
          footerItem("Contact Us", isMobile),
        ],
      ),
    );
  }

  /// CONTACT
  Widget contactInfo(bool isMobile) {
    return SizedBox(
      width: isMobile ? double.infinity : 220,
      child: Column(
        crossAxisAlignment:
            isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          footerTitle("Contact", isMobile),
          const SizedBox(height: 15),
          footerItem("support@quickloan.com", isMobile),
          footerItem("+91 98765 43210", isMobile),
          footerItem("Pune, Maharashtra, India", isMobile),
        ],
      ),
    );
  }
}
