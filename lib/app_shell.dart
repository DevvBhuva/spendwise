import 'package:flutter/material.dart';

import 'utils/backup_service.dart';
import 'features/transactions/transactions_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  @override
  void initState() {
    super.initState();
    _checkAutoBackup();
  }

  Future<void> _checkAutoBackup() async {
    await BackupService.autoBackupIfNeeded();
  }

  @override
  Widget build(BuildContext context) {
    return const TransactionsScreen();
  }
}
