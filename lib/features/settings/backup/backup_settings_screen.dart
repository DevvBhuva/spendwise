import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  void initState() {
    super.initState();
    _loadFrequency();
  }

  Future<void> _loadFrequency() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString('backup_frequency');
    if (value != null) {
      setState(() {
        _frequency =
            BackupFrequency.values.firstWhere((e) => e.name == value);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Backup Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Backup Frequency',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            ...BackupFrequency.values.map(
              (f) => RadioListTile(
                value: f,
                groupValue: _frequency,
                title: Text(_label(f)),
                onChanged: (v) async {
                  setState(() => _frequency = v!);
                  final prefs =
                      await SharedPreferences.getInstance();
                  await prefs.setString('backup_frequency', v!.name);

                },
              ),
            ),

            const SizedBox(height: 16),
            const Text(
              'Google Account',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            ListTile(
              title: Text(_email ?? 'Choose Google account'),
              trailing: _loading
                  ? const CircularProgressIndicator()
                  : const Icon(Icons.chevron_right),
              onTap: _loading ? null : _selectAccount,
            ),

            const SizedBox(height: 24),
            const Divider(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.backup),
                label: const Text('Backup Now'),
                onPressed: _loading ? null : _backupNow,
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.restore),
                label: const Text('Restore Backup'),
                onPressed: _loading ? null : _restoreBackup,
              ),
            ),
          ],
        ),
      ),
    );
  }

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

  Future<void> _selectAccount() async {
    setState(() => _loading = true);
    try {
      final email = await BackupService.signIn();
      if (email == null) return;

      await BackupService.getOrCreateFolder();
      setState(() => _email = email);

      _toast('Google Drive connected');
    } catch (e) {
      _toast('Error: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _backupNow() async {
    if (_email == null) {
      _toast('Please select Google account first');
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

      _toast('Backup uploaded successfully');
    } catch (e) {
      _toast('Backup failed: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _restoreBackup() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mmbak'],
    );
    if (result == null) return;

    setState(() => _loading = true);
    try {
      final file = File(result.files.single.path!);
      final count =
          await BackupService.restoreFromBackup(file);
      _toast('Restored $count transactions');
    } catch (e) {
      _toast('Restore failed: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }
}
