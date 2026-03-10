import 'dart:math';
import 'package:flutter/material.dart';

class DownloadApp extends StatefulWidget {
  const DownloadApp({super.key});

  @override
  State<DownloadApp> createState() => _DownloadAppState();
}

class _DownloadAppState extends State<DownloadApp>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 3))
          ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget storeButton(String image, bool isMobile) {
    return _HoverButton(
      child: Container(
        width: isMobile ? 140 : 190,
        height: isMobile ? 50 : 65,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
        ),
        clipBehavior: Clip.hardEdge,
        child: Image.asset(
          image,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    bool isMobile = width < 700;

    Widget logo = AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, sin(_controller.value * pi * 2) * 10),
          child: child,
        );
      },
      child: Image.asset(
        "assets/images/logoloanapp.png",
        height: isMobile ? 100 : 150,
      ),
    );

    Widget textSection = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment:
          isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(
          "Download QuickLoan App",
          textAlign: isMobile ? TextAlign.center : TextAlign.left,
          style: TextStyle(
            color: Colors.white,
            fontSize: isMobile ? 26 : 34,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 15),
        Text(
          "Apply for loans, track approvals, upload documents and manage your finances anytime with the QuickLoan mobile app.",
          textAlign: isMobile ? TextAlign.center : TextAlign.left,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 16,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 30),

        /// Buttons
        Wrap(
          spacing: 20,
          runSpacing: 15,
          alignment: isMobile ? WrapAlignment.center : WrapAlignment.start,
          children: [
            storeButton("assets/images/playstore.png", isMobile),
            storeButton("assets/images/appstore.png", isMobile),
          ],
        ),
      ],
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 50 : 70,
        horizontal: isMobile ? 20 : 40,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xff111827),
            Color(0xff1F2937),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: isMobile
              ? Column(
                  children: [
                    logo,
                    const SizedBox(height: 30),
                    textSection,
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    logo,
                    const SizedBox(width: 60),
                    Expanded(child: textSection),
                  ],
                ),
        ),
      ),
    );
  }
}

class _HoverButton extends StatefulWidget {
  final Widget child;

  const _HoverButton({required this.child});

  @override
  State<_HoverButton> createState() => _HoverButtonState();
}

class _HoverButtonState extends State<_HoverButton> {
  bool hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => hover = true),
      onExit: (_) => setState(() => hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()..scale(hover ? 1.08 : 1),
        child: widget.child,
      ),
    );
  }
}
