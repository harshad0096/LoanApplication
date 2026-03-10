import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:usersideloanapp/user/layouts/loan_flow_shell.dart';

class LoanSuccessPage extends StatefulWidget {
  final String applicationId;

  const LoanSuccessPage({
    super.key,
    required this.applicationId,
  });

  @override
  State<LoanSuccessPage> createState() => _LoanSuccessPageState();
}

class _LoanSuccessPageState extends State<LoanSuccessPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _scale = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _fade = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // =========================================================
  // 🔥 FETCH APPLICATION
  // =========================================================
  Future<Map<String, dynamic>?> _fetchApplication() async {
    final doc = await FirebaseFirestore.instance
        .collection('loan_applications')
        .doc(widget.applicationId)
        .get();

    return doc.data();
  }

  // =========================================================
  // BUILD
  // =========================================================
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    return LoanFlowShell(
      child: Scaffold(
        backgroundColor: const Color(0xffF6F7FB),
        body: FadeTransition(
          opacity: _fade,
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(isMobile ? 16 : 28),
              child: Container(
                width: isMobile ? double.infinity : 520,
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: const LinearGradient(
                    colors: [Color(0xff6D5DF6), Color(0xffEC4899)],
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 40,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(26),
                  ),

                  // ✅ ✅ FUTURE BUILDER ADDED HERE
                  child: FutureBuilder<Map<String, dynamic>?>(
                    future: _fetchApplication(),
                    builder: (context, snapshot) {
                      final data = snapshot.data;

                      if (!snapshot.hasData || snapshot.data == null) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ScaleTransition(
                              scale: _scale,
                              child: const CircleAvatar(
                                radius: 52,
                                backgroundColor: Color(0xff10B981),
                                child: Icon(Icons.check,
                                    color: Colors.white, size: 54),
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              "Application submitted successfully",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 12),
                            Text("Application ID: ${widget.applicationId}"),
                          ],
                        );
                      }

                      if (snapshot.hasError) {
                        return const Center(
                          child: Text(
                            "Failed to load application details",
                            style: TextStyle(color: Colors.red),
                          ),
                        );
                      }

                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // ✅ Animated success icon
                          ScaleTransition(
                            scale: _scale,
                            child: const CircleAvatar(
                              radius: 52,
                              backgroundColor: Color(0xff10B981),
                              child: Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 54,
                              ),
                            ),
                          ),

                          const SizedBox(height: 28),

                          const Text(
                            "Application Submitted 🎉",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 12),

                          const Text(
                            "Your loan request has been successfully submitted.",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.black54),
                          ),

                          const SizedBox(height: 18),

                          // ✅ USER DATA
                          if (data != null) ...[
                            Text(
                              "Name: ${data['userName'] ?? ''}",
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Phone: ${data['phone'] ?? ''}",
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 16),
                          ],

                          // ✅ APPLICATION ID
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xffF1F5F9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              "Application ID: ${widget.applicationId}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          const SizedBox(height: 30),

                          // ✅ Go to dashboard button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xff6D5DF6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              onPressed: () {
                                Navigator.of(context, rootNavigator: true)
                                    .pushNamedAndRemoveUntil(
                                  '/dashboard',
                                  (route) => false,
                                );
                              },
                              child: const Text(
                                "Go to Dashboard",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
