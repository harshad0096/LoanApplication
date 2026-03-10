import 'package:flutter/material.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: Text('Reports page - analytics and exports here')),
      ),
    );
  }
}
