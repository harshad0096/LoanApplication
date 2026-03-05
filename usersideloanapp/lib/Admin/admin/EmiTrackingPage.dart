import 'package:flutter/material.dart';

class EmiTrackingPage extends StatelessWidget {
  const EmiTrackingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('EMI Tracking')),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: Text('EMI Tracking page - implement tracking widgets here')),
      ),
    );
  }
}