import 'package:flutter/material.dart';
import 'package:usersideloanapp/Login/services/OTPService.dart';

class OTPVerificationPage extends StatefulWidget {
  final String phone;

  const OTPVerificationPage({super.key, required this.phone});

  @override
  State<OTPVerificationPage> createState() => _OTPVerificationPageState();
}

class _OTPVerificationPageState extends State<OTPVerificationPage> {
  final OTPService _otpService = OTPService();

  final otpController = TextEditingController();

  String verificationId = "";

  bool loading = false;

  @override
  void initState() {
    super.initState();
    sendOTP();
  }

  void sendOTP() async {
    await _otpService.sendOTP(
      phone: widget.phone,
      codeSent: (id) {
        setState(() {
          verificationId = id;
        });
      },
      error: (msg) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(msg)));
      },
    );
  }

  Future<void> verifyOTP() async {
    setState(() => loading = true);

    final result = await _otpService.verifyOTP(
      verificationId: verificationId,
      otp: otpController.text.trim(),
    );

    setState(() => loading = false);

    if (result == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Phone Verified")));

      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(result)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Phone Verification")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Enter OTP",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text("OTP sent to ${widget.phone}"),
            const SizedBox(height: 20),
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "6 Digit OTP",
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: verifyOTP,
                child: const Text("Verify OTP"),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: sendOTP,
              child: const Text("Resend OTP"),
            ),
            if (loading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
