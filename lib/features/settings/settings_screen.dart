import 'package:flutter/material.dart';

import 'backup/backup_settings_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.backup),
            title: const Text('Backup & Restore'),
            subtitle: const Text('Google Drive backup'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const BackupSettingsScreen(),
                ),
              );
            },
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            subtitle: const Text('SpendWise'),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'SpendWise',
                applicationVersion: '1.0.0',
              );
            },
          ),
        ],
      ),
    );
  }
}
