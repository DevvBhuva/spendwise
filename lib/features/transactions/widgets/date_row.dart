import 'package:flutter/material.dart';

class _DateRow extends StatelessWidget {
  final DateTime date;
  final VoidCallback onTap;

  const _DateRow({required this.date, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: const Text('Date'),
      trailing: Text(
        '${date.day}/${date.month}/${date.year}',
        style: const TextStyle(color: Colors.grey),
      ),
      onTap: onTap,
    );
  }
}
