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
          SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          const _TopSummary(),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              children: const [
                _SectionHeader('Cash'),
                _SimpleAccountTile(title: 'Cash'),

                _SectionHeader('Accounts'),
                _SimpleAccountTile(title: 'Accounts'),

                _SectionHeader('Card'),
                _CardHeader(),
                _CardAccountTile(title: 'Card'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/* ================= TOP SUMMARY ================= */

class _TopSummary extends StatelessWidget {
  const _TopSummary();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      color: Colors.black26,
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _SummaryItem('Assets', '₹ 0.00', Colors.blue),
          _SummaryItem('Liabilities', '₹ 0.00', Colors.red),
          _SummaryItem('Total', '₹ 0.00', Colors.white),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryItem(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}

/* ================= SECTIONS ================= */

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.grey,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/* ================= SIMPLE ACCOUNT ================= */

class _SimpleAccountTile extends StatelessWidget {
  final String title;
  const _SimpleAccountTile({required this.title});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      trailing: const Text(
        '₹ 0.00',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}

/* ================= CARD ACCOUNT ================= */

class _CardHeader extends StatelessWidget {
  const _CardHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Text('Balance Payable', style: TextStyle(color: Colors.grey)),
          Text('Outst. Balance', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

class _CardAccountTile extends StatelessWidget {
  final String title;
  const _CardAccountTile({required this.title});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Text(
            '₹ 0.00',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(width: 32),
          Text(
            '₹ 0.00',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
