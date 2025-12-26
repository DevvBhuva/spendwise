import 'package:flutter/material.dart';
import '../../core/dummy/dummy_data.dart';
import '../transactions/transactions_screen.dart';
import '../transactions/add_transaction_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final totalBalance =
        accounts.fold<double>(0, (sum, a) => sum + a.balance);

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddTransactionScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text('Total Balance'),
                    const SizedBox(height: 8),
                    Text(
                      '₹${totalBalance.toStringAsFixed(0)}',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: transactions.map((t) {
                  return ListTile(
                    title: Text(t.title),
                    subtitle: Text(
                      '${t.date.day}/${t.date.month}/${t.date.year}',
                    ),
                    trailing: Text(
                      '₹${t.amount.abs()}',
                      style: TextStyle(
                        color:
                            t.isIncome ? Colors.green : Colors.red,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const TransactionsScreen(),
                  ),
                );
              },
              child: const Text('View all transactions'),
            ),
          ],
        ),
      ),
    );
  }
}
