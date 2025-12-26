import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../../data/repositories/transaction_repository.dart';
import '../../utils/export_csv.dart';
import '../../utils/export_pdf.dart';
import '../../utils/backup_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = TransactionRepository();
    final backupService = BackupService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('More'),
      ),
      body: GridView.count(
        crossAxisCount: 3,
        padding: const EdgeInsets.all(24),
        children: [
          /// 📤 EXPORT CSV
          _SettingItem(
            icon: Icons.table_chart,
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

          /// 📄 EXPORT PDF
          _SettingItem(
            icon: Icons.picture_as_pdf,
            label: 'Export PDF',
            onTap: () async {
              final data = await repo.getAllTransactions();
              final file = await PdfExporter.exportTransactions(data);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('PDF saved:\n${file.path}'),
                ),
              );
            },
          ),

          /// 💾 BACKUP (JSON)
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
        ],
      ),
    );
  }
}

/* ================= ITEM ================= */

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
          Icon(icon, size: 34, color: Colors.redAccent),
          const SizedBox(height: 10),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
