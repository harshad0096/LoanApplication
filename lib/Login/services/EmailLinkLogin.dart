import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EmailLinkLogin extends StatefulWidget {
  const EmailLinkLogin({super.key});

  @override
  State<EmailLinkLogin> createState() => _EmailLinkLoginState();
}

class _EmailLinkLoginState extends State<EmailLinkLogin> {
  final emailController = TextEditingController();

  Future<void> sendEmailLink() async {
    final ActionCodeSettings actionCodeSettings = ActionCodeSettings(
      url: 'https://usersideloanapp.page.link/login',
      handleCodeInApp: true,
      androidPackageName: 'com.example.usersideloanapp',
      androidInstallApp: true,
      androidMinimumVersion: '12',
    );

    await FirebaseAuth.instance.sendSignInLinkToEmail(
      email: emailController.text.trim(),
      actionCodeSettings: actionCodeSettings,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Email link sent")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Email Link Login")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: sendEmailLink,
              child: const Text("Send Login Link"),
            ),
          ],
        ),
      ),
    );
  }
}