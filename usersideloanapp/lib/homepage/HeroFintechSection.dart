import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class HeroFintechSection extends StatefulWidget {
  final bool isMobile;

  const HeroFintechSection({super.key, required this.isMobile});

  @override
  State<HeroFintechSection> createState() => _HeroFintechSectionState();
}

class _HeroFintechSectionState extends State<HeroFintechSection> {
  int cibilScore = 782;

  bool showResult = false;
  bool isLoading = false;
  // Dummy API simulation
  Future<void> fetchCibilScore(String pan) async {
    setState(() {
      isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    final random = Random();
    int score = 600 + random.nextInt(250);

    setState(() {
      cibilScore = score;
      isLoading = false;
      showResult = true;
    });
  }

  void openPanDialog() {
    TextEditingController panController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "",
      barrierColor: Colors.black.withOpacity(0.85),
      transitionDuration: const Duration(milliseconds: 450),

      pageBuilder: (context, anim1, anim2) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 420,
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xff111827),
                    Color(0xff020617),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black54,
                    blurRadius: 40,
                    spreadRadius: 4,
                  )
                ],
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Title
                    Row(
                      children: const [
                        Icon(Icons.credit_score, color: Colors.greenAccent),
                        SizedBox(width: 10),
                        Text(
                          "Check Your CIBIL Score",
                          style: TextStyle(
                            fontSize: 22,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    /// Info text
                    const Text(
                      "Enter your PAN to instantly check your credit score.\n"
                      "This helps us determine your loan eligibility.",
                      style: TextStyle(
                        color: Colors.white70,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 25),

                    /// PAN Field
                    TextFormField(
                      controller: panController,
                      textCapitalization: TextCapitalization.characters,
                      maxLength: 10,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "ABCDE1234F",
                        hintStyle: const TextStyle(color: Colors.white38),
                        labelText: "PAN Card Number",
                        labelStyle: const TextStyle(color: Colors.white70),
                        counterText: "",
                        filled: true,
                        fillColor: const Color(0xff1E293B),
                        prefixIcon: const Icon(
                          Icons.badge,
                          color: Colors.white70,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "PAN number is required";
                        }

                        if (value.length != 10) {
                          return "PAN must be 10 characters";
                        }

                        final panRegex = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$');

                        if (!panRegex.hasMatch(value)) {
                          return "Invalid PAN format";
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 25),

                    /// Security Info
                    Row(
                      children: const [
                        Icon(Icons.lock, size: 18, color: Colors.greenAccent),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Your data is encrypted & secure. We never store your PAN.",
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: 12,
                            ),
                          ),
                        )
                      ],
                    ),

                    const SizedBox(height: 30),

                    /// Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: const BorderSide(color: Colors.white24),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text(
                              "Cancel",
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: isLoading
                              ? const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.greenAccent,
                                  ),
                                )
                              : ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xff7C3AED),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  onPressed: () async {
                                    if (!formKey.currentState!.validate())
                                      return;

                                    Navigator.pop(context);

                                    await fetchCibilScore(
                                        panController.text.toUpperCase());
                                  },
                                  child: const Text(
                                    "Check Score",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },

      /// Animation
      transitionBuilder: (context, anim1, anim2, child) {
        return Transform.scale(
          scale: Curves.easeOutBack.transform(anim1.value),
          child: Opacity(
            opacity: anim1.value,
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const BackgroundGrid(),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: widget.isMobile ? 20 : 80,
            vertical: 80,
          ),
          child: widget.isMobile
              ? Column(
                  children: [
                    _content(context),
                    const SizedBox(height: 50),
                    _dashboardPreview()
                  ],
                )
              : Row(
                  children: [
                    Expanded(child: _content(context)),
                    Expanded(child: _dashboardPreview()),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _content(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            badge("RBI REGISTERED NBFC", Colors.green),
            const SizedBox(width: 10),
            badge("AWARD WINNING", Colors.deepPurple),
          ],
        ).animate().fade().slideX(),
        const SizedBox(height: 20),
        Text(
          "Instant Loans,",
          style: GoogleFonts.poppins(
            fontSize: widget.isMobile ? 34 : 52,
            fontWeight: FontWeight.bold,
          ),
        ).animate().fade().slideY(),
        const SizedBox(height: 10),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xff7C3AED), Color(0xffEC4899)],
          ).createShader(bounds),
          child: Text(
            "Zero Hassle",
            style: GoogleFonts.poppins(
              fontSize: widget.isMobile ? 38 : 56,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ).animate().fade().slideY(delay: 200.ms),
        const SizedBox(height: 20),
        Text(
          "Get loans up to ₹25 Lakhs with minimal documentation.\nAI-powered approvals in under 24 hours.",
          style: GoogleFonts.poppins(
            fontSize: 18,
            color: Colors.grey[700],
          ),
        ).animate().fade(delay: 300.ms),
        const SizedBox(height: 40),
        Wrap(
          spacing: 16,
          runSpacing: 10,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 18),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
                backgroundColor: const Color(0xff7C3AED),
              ),
              onPressed: () {
                Navigator.pushNamed(context, "/login");
              },
              child: const Text("Apply Now — It's Free"),
            ),
            const SizedBox(width: 20),
            OutlinedButton(
              onPressed: openPanDialog,
              child: const Text("Check CIBIL Score"),
            ),
          ],
        ).animate().fade(delay: 400.ms).slideY(),
      ],
    );
  }

  Widget badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: color.withOpacity(.1),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _dashboardPreview() {
    return Stack(
      children: [
        Container(
          height: widget.isMobile ? 340 : 420,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xff1E293B), Color(0xff0F172A)],
            ),
            borderRadius: BorderRadius.circular(28),
          ),
          padding: const EdgeInsets.all(30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "YOUR CIBIL SCORE",
                style: TextStyle(color: Colors.white60),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SfRadialGauge(
                  axes: [
                    RadialAxis(
                      minimum: 300,
                      maximum: 900,
                      showTicks: false,
                      ranges: [
                        GaugeRange(
                            startValue: 300, endValue: 550, color: Colors.red),
                        GaugeRange(
                            startValue: 550,
                            endValue: 700,
                            color: Colors.orange),
                        GaugeRange(
                            startValue: 700,
                            endValue: 900,
                            color: Colors.green),
                      ],
                      pointers: [
                        NeedlePointer(
                          value: cibilScore.toDouble(),
                          needleColor: Colors.white,
                          knobStyle: const KnobStyle(color: Colors.white),
                          enableAnimation: true,
                          animationDuration: 1500,
                        )
                      ],
                      annotations: [
                        GaugeAnnotation(
                          widget: Text(
                            "$cibilScore",
                            style: const TextStyle(
                              fontSize: 32,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          angle: 90,
                          positionFactor: 0.5,
                        )
                      ],
                    )
                  ],
                ).animate().scale().fade(),
              ),
              const SizedBox(height: 10),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 600),
                child: showResult
                    ? Text(
                        "Your CIBIL Score is $cibilScore",
                        key: ValueKey(cibilScore),
                        style: const TextStyle(
                          color: Colors.greenAccent,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ).animate().fade().slideY()
                    : const Text(
                        "Click 'Check CIBIL Score'",
                        style: TextStyle(color: Colors.white70),
                      ),
              )
            ],
          ),
        ).animate().scale(),
        Positioned(
          top: -20,
          right: -10,
          child: floatingCard("LOAN APPROVAL", "98%"),
        ).animate().fade().slideX(),
        Positioned(
          bottom: -20,
          right: 40,
          child: floatingCard("APPROVED IN", "4 hrs"),
        ).animate().fade().slideY(),
      ],
    );
  }

  Widget floatingCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 20)],
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(color: Colors.grey)),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          )
        ],
      ),
    );
  }
}

class BackgroundGrid extends StatelessWidget {
  const BackgroundGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      width: double.infinity,
      child: CustomPaint(
        painter: GridPainter(),
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(.15)
      ..strokeWidth = 1;

    const spacing = 40;

    for (double i = 0; i < size.width; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }

    for (double i = 0; i < size.height; i += spacing) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
