import 'package:flutter/material.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dec 2025'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Chip(label: Text('Monthly')),
          ),
        ],
      ),
      body: const Center(
        child: Text(
          'No data available.',
          style: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}
