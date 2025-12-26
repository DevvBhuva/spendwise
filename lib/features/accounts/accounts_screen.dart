import 'package:flutter/material.dart';

class AccountsScreen extends StatelessWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accounts'),
        actions: const [
          Icon(Icons.bar_chart),
          SizedBox(width: 12),
          Icon(Icons.more_vert),
          SizedBox(width: 12),
        ],
      ),
      body: ListView(
        children: const [
          _AccountSummary(),
          _AccountTile(title: 'Cash', amount: '₹ 0.00'),
          _AccountTile(title: 'Accounts', amount: '₹ 0.00'),
          _AccountTile(title: 'Card', amount: '₹ 0.00'),
        ],
      ),
    );
  }
}

class _AccountSummary extends StatelessWidget {
  const _AccountSummary();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.black26,
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _Summary(label: 'Assets', value: '0.00', color: Colors.blue),
          _Summary(label: 'Liabilities', value: '0.00', color: Colors.red),
          _Summary(label: 'Total', value: '0.00', color: Colors.white),
        ],
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _Summary({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color, fontSize: 16)),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}

class _AccountTile extends StatelessWidget {
  final String title;
  final String amount;

  const _AccountTile({required this.title, required this.amount});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      trailing: Text(amount),
    );
  }
}
