import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/loan_provider.dart';

class EligibilityMeter extends StatelessWidget {
  const EligibilityMeter({super.key});

  @override
  Widget build(BuildContext context) {
    final score = context.watch<LoanProvider>().eligibilityScore;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Approval Chance",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: score),
          duration: const Duration(milliseconds: 800),
          builder: (_, value, __) => ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 12,
              backgroundColor: Colors.grey.shade200,
            ),
          ),
        ),
      ],
    );
  }
}
