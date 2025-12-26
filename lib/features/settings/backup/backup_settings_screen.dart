import 'package:flutter/material.dart';
import '../../../utils/backup_service.dart';

enum BackupFrequency { daily, weekly, monthly, manual }

class BackupSettingsScreen extends StatefulWidget {
  const BackupSettingsScreen({super.key});

  @override
  State<BackupSettingsScreen> createState() => _BackupSettingsScreenState();
}

class _BackupSettingsScreenState extends State<BackupSettingsScreen> {
  BackupFrequency _frequency = BackupFrequency.manual;
  String? _email;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Backup Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─────────────────────────────
            // BACKUP FREQUENCY
            // ─────────────────────────────
            const Text(
              'Backup Frequency',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              'Choose how often your data should be backed up automatically.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<BackupFrequency>(
                  value: _frequency,
                  isExpanded: true,
                  items: BackupFrequency.values.map((f) {
                    return DropdownMenuItem(
                      value: f,
                      child: Text(_label(f)),
                    );
                  }).toList(),
                  onChanged: (v) {
                    setState(() => _frequency = v!);
                  },
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ─────────────────────────────
            // GOOGLE ACCOUNT
            // ─────────────────────────────
            const Text(
              'Google Drive Account',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              'Select the Google account where backups will be stored.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 12),

            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              child: ListTile(
                leading: const Icon(Icons.account_circle, size: 30),
                title: Text(_email ?? 'Choose Google account'),
                trailing: _loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.chevron_right),
                onTap: _loading ? null : _selectAccount,
              ),
            ),

            const SizedBox(height: 32),

            // ─────────────────────────────
            // BACKUP BUTTON
            // ─────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.cloud_upload),
                label: const Text(
                  'BACKUP NOW',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: _loading ? null : _backupNow,
              ),
            ),

            const SizedBox(height: 12),

            Center(
              child: Text(
                'Your backup will be saved securely in Google Drive',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────

  String _label(BackupFrequency f) {
    switch (f) {
      case BackupFrequency.daily:
        return 'Daily';
      case BackupFrequency.weekly:
        return 'Weekly';
      case BackupFrequency.monthly:
        return 'Monthly';
      case BackupFrequency.manual:
        return 'Only when I tap backup';
    }
  }

  // ─────────────────────────────────────
  // GOOGLE ACCOUNT
  // ─────────────────────────────────────

  Future<void> _selectAccount() async {
    setState(() => _loading = true);

    try {
      final email = await BackupService.signIn();
      if (email == null) return;

      await BackupService.getOrCreateFolder();
      setState(() => _email = email);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Google Drive connected')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  // ─────────────────────────────────────
  // BACKUP FLOW
  // ─────────────────────────────────────

  Future<void> _backupNow() async {
    if (_email == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a Google account first')),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final json = await BackupService.generateJsonBackup();
      final file =
          await BackupService.createCompressedBackup(jsonData: json);
      final folderId = await BackupService.getOrCreateFolder();

      await BackupService.uploadToDrive(
        file: file,
        folderId: folderId,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Backup uploaded successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Backup failed: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }
}
