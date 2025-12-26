import 'package:flutter/material.dart';
import '../../data/repositories/transaction_repository.dart';
import '../../utils/export_csv.dart';
import '../../utils/backup_service.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TransactionRepository repo = TransactionRepository();
    final BackupService backupService = BackupService();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: GridView.count(
        crossAxisCount: 3,
        padding: const EdgeInsets.all(24),
        children: [
          _SettingItem(
            icon: Icons.settings,
            label: 'Configuration',
            onTap: () {},
          ),
          _SettingItem(
            icon: Icons.lock,
            label: 'Passcode',
            onTap: () {},
          ),
          _SettingItem(
            icon: Icons.calculate,
            label: 'CalcBox',
            onTap: () {},
          ),

          /// 📤 EXPORT CSV
          _SettingItem(
            icon: Icons.upload_file,
            label: 'Export CSV',
            onTap: () async {
              final data = await repo.getAllTransactions();
              await CsvExporter.exportTransactions(data);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('CSV exported successfully'),
                ),
              );
            },
          ),

          /// 💾 BACKUP JSON
          _SettingItem(
            icon: Icons.backup,
            label: 'Backup',
            onTap: () async {
              final File? file = await backupService.exportBackup();

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    file == null
                        ? 'Backup completed'
                        : 'Backup saved:\n${file.path}',
                  ),
                ),
              );
            },
          ),

          /// ♻ RESTORE JSON
          _SettingItem(
            icon: Icons.restore,
            label: 'Restore',
            onTap: () async {
              final result = await FilePicker.platform.pickFiles(
                type: FileType.custom,
                allowedExtensions: ['json'],
              );

              if (result != null && result.files.single.path != null) {
                final file = File(result.files.single.path!);
                await backupService.importBackup(file);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Data restored successfully'),
                  ),
                );
              }
            },
          ),

          _SettingItem(
            icon: Icons.help_outline,
            label: 'Help',
            onTap: () {},
          ),
          _SettingItem(
            icon: Icons.thumb_up,
            label: 'Recommend',
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _SettingItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SettingItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32),
          const SizedBox(height: 8),
          Text(label, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
