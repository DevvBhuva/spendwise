import 'package:flutter/material.dart';

class _InputRow extends StatelessWidget {
  final String label;
  final String? value;

  const _InputRow({required this.label, this.value});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      trailing: value != null
          ? Text(value!, style: const TextStyle(color: Colors.grey))
          : const Icon(Icons.chevron_right),
      onTap: () {},
    );
  }
}
