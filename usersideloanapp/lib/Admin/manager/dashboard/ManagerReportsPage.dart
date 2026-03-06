import 'package:flutter/material.dart';

class ManagerReportsPage extends StatelessWidget {
  const ManagerReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Reports",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text("Loan Analytics Coming Soon")
          ],
        ),
      ),
    );
  }
}
