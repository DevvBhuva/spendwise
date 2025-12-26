import 'package:flutter/material.dart';
import 'features/transactions/transactions_screen.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: TransactionsScreen(), // main entry screen
    );
  }
}
