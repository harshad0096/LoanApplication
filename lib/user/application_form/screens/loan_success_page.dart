import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:usersideloanapp/user/layouts/loan_flow_shell.dart';

class LoanSuccessPage extends StatefulWidget {
  final String applicationId;

  const LoanSuccessPage({super.key, required this.applicationId});

  @override
  State<LoanSuccessPage> createState() => _LoanSuccessPageState();
}

class _LoanSuccessPageState extends State<LoanSuccessPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _fade;

  late Future<Map<String, dynamic>?> _futureApplication;

  @override
  void initState() {
    super.initState();
    _futureApplication = _fetchApplication();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _scale = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>?> _fetchApplication() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('loan_applications')
          .doc(widget.applicationId)
          .get();

      if (!doc.exists) return null;
      return doc.data();
    } catch (e) {
      throw Exception("Failed to load application");
    }
  }

  Widget _successIcon() {
    return ScaleTransition(
      scale: _scale,
      child: const CircleAvatar(
        radius: 54,
        backgroundColor: Color(0xff10B981),
        child: Icon(Icons.check, color: Colors.white, size: 56),
      ),
    );
  }

  Widget _reviewCard(Map<String, dynamic> data, double maxWidth) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xffF8FAFC),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Application Summary",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 14),
          _row("Name", data['userName']),
          _row("Phone", data['phone']),
          _row("Loan Amount", "₹${data['amount']}"),
          _row("Tenure", "${data['tenure']} months"),
          _row("Status", data['status'] ?? "Pending"),
        ],
      ),
    );
  }

  Widget _row(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54)),
          Flexible(
            child: Text(
              value?.toString() ?? "-",
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 700;
    final containerWidth = isMobile ? double.infinity : screenWidth * 0.5;

    return LoanFlowShell(
      child: Scaffold(
        backgroundColor: const Color(0xffF6F7FB),
        body: FadeTransition(
          opacity: _fade,
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 16 : 32,
                vertical: 24,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: containerWidth),
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    gradient: const LinearGradient(
                      colors: [Color(0xff6D5DF6), Color(0xffEC4899)],
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 32,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(26),
                    ),
                    child: FutureBuilder<Map<String, dynamic>?>(
                      future: _futureApplication,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        if (snapshot.hasError) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.error,
                                  color: Colors.red, size: 50),
                              const SizedBox(height: 16),
                              const Text(
                                "Failed to load application",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _futureApplication = _fetchApplication();
                                  });
                                },
                                child: const Text("Retry"),
                              )
                            ],
                          );
                        }

                        final data = snapshot.data;

                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _successIcon(),
                            const SizedBox(height: 28),
                            const Text(
                              "Application Submitted 🎉",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 26, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              "Your loan request has been submitted successfully. Our team will review your application shortly.",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.black54),
                            ),
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xffEEF2FF),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                "Application ID: ${widget.applicationId}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            if (data != null) _reviewCard(data, containerWidth),
                            const SizedBox(height: 30),
                            SizedBox(
                              width: double.infinity,
                              height: 52,
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
                                    '/upload-document',
                                    (route) => true,
                                    arguments: widget.applicationId,
                                  );
                                },
                                child: const Text(
                                  "Upload Documents",
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
      ),
    );
  }
}
