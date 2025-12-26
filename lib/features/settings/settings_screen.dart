import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: GridView.count(
        crossAxisCount: 3,
        padding: const EdgeInsets.all(24),
        children: const [
          _SettingItem(icon: Icons.settings, label: 'Configuration'),
          _SettingItem(icon: Icons.lock, label: 'Passcode'),
          _SettingItem(icon: Icons.calculate, label: 'CalcBox'),
          _SettingItem(icon: Icons.backup, label: 'Backup'),
          _SettingItem(icon: Icons.help_outline, label: 'Help'),
          _SettingItem(icon: Icons.thumb_up, label: 'Recommend'),
        ],
      ),
    );
  }
}

class _SettingItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SettingItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 32),
        const SizedBox(height: 8),
        Text(label, textAlign: TextAlign.center),
      ],
    );
  }
}
