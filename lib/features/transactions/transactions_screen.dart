import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import 'add_transaction_screen.dart';
import '../reports/reports_screen.dart';
import '../settings/backup/backup_settings_screen.dart';

import '../../utils/currency_formatter.dart';
import '../../utils/export_csv.dart';
import '../../utils/export_pdf.dart';
import '../../data/repositories/transaction_repository.dart';
import '../../data/models/transaction_model.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final TransactionRepository _repository = TransactionRepository();
  List<TransactionModel> _transactions = [];

  DateTime _selectedDate = DateTime.now();
  DateTime _selectedMonth = DateTime.now();

  final tabs = const ['Daily', 'Calendar', 'Monthly', 'Total', 'Note'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this);
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    final data = await _repository.getAllTransactions();
    setState(() => _transactions = data);
  }

  Future<void> _delete(TransactionModel t) async {
    await _repository.deleteTransaction(t.id!);
    _loadTransactions();
  }

  /* ================= MORE MENU ================= */

  void _openMoreMenu() {
    showModalBottomSheet(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _MoreItem(
            icon: Icons.upload_file,
            label: 'Export to CSV',
            onTap: () async {
              Navigator.pop(context);
              await CsvExporter.exportTransactions(_transactions);
            },
          ),
          _MoreItem(
            icon: Icons.picture_as_pdf,
            label: 'Export to PDF',
            onTap: () async {
              Navigator.pop(context);
              final file =
                  await PdfExporter.exportTransactions(_transactions);
              await Share.shareXFiles([XFile(file.path)]);
            },
          ),
          _MoreItem(
            icon: Icons.backup,
            label: 'Backup',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const BackupSettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /* ================= FILTER HELPERS ================= */

  List<TransactionModel> _byDate(DateTime d) {
    return _transactions.where((t) =>
        t.date.year == d.year &&
        t.date.month == d.month &&
        t.date.day == d.day).toList();
  }

  List<TransactionModel> _byMonth(DateTime m) {
    return _transactions.where((t) =>
        t.date.year == m.year &&
        t.date.month == m.month).toList();
  }

  /* ================= UI ================= */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SpendWise'),
        actions: [
          IconButton(
            icon: const Icon(Icons.pie_chart_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ReportsScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: _openMoreMenu,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: tabs.map((t) => Tab(text: t)).toList(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final res = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddTransactionScreen(),
            ),
          );
          if (res == true) _loadTransactions();
        },
        child: const Icon(Icons.add),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _TransactionList(
            list: _byDate(DateTime.now()),
            onDelete: _delete,
          ),

          // 📅 CALENDAR
          Column(
            children: [
              ListTile(
                title: Text(
                  '${_selectedDate.day}-${_selectedDate.month}-${_selectedDate.year}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                    initialDate: _selectedDate,
                  );
                  if (picked != null) {
                    setState(() => _selectedDate = picked);
                  }
                },
              ),
              Expanded(
                child: _TransactionList(
                  list: _byDate(_selectedDate),
                  onDelete: _delete,
                ),
              ),
            ],
          ),

          // 📆 MONTHLY
          Column(
            children: [
              ListTile(
                title: Text(
                  '${_selectedMonth.month}-${_selectedMonth.year}',
                ),
                trailing: const Icon(Icons.date_range),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                    initialDate: _selectedMonth,
                  );
                  if (picked != null) {
                    setState(() =>
                        _selectedMonth = DateTime(picked.year, picked.month));
                  }
                },
              ),
              Expanded(
                child: _TransactionList(
                  list: _byMonth(_selectedMonth),
                  onDelete: _delete,
                ),
              ),
            ],
          ),

          _TotalView(transactions: _transactions),
          const _EmptyState(),
        ],
      ),
    );
  }
}

/* ================= SHARED LIST ================= */

class _TransactionList extends StatelessWidget {
  final List<TransactionModel> list;
  final Function(TransactionModel) onDelete;

  const _TransactionList({
    required this.list,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (list.isEmpty) return const _EmptyState();

    return ListView(
      children: list.map((t) {
        final isIncome = t.type == 'income';
        return Dismissible(
          key: ValueKey(t.id),
          direction: DismissDirection.endToStart,
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (_) => onDelete(t),
          child: ListTile(
            title: Text(t.category),
            subtitle: Text(t.note?.isEmpty ?? true ? '—' : t.note!),
            trailing: Text(
              '${isIncome ? '+' : '-'}${CurrencyFormatter.format(t.amount)}',
              style: TextStyle(
                color: isIncome ? Colors.blue : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

/* ================= TOTAL ================= */

class _TotalView extends StatelessWidget {
  final List<TransactionModel> transactions;

  const _TotalView({required this.transactions});

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) return const _EmptyState();

    double income = 0;
    double expense = 0;

    for (final t in transactions) {
      t.type == 'income'
          ? income += t.amount
          : expense += t.amount;
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _TotalCard('All-time Income', income, Colors.blue),
          const SizedBox(height: 12),
          _TotalCard('All-time Expense', expense, Colors.red),
          const SizedBox(height: 12),
          _TotalCard('Net Balance', income - expense, Colors.green),
        ],
      ),
    );
  }
}

/* ================= UI HELPERS ================= */

class _TotalCard extends StatelessWidget {
  final String title;
  final double value;
  final Color color;

  const _TotalCard(this.title, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 8),
          Text(
            CurrencyFormatter.format(value),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _MoreItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MoreItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      onTap: onTap,
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('No data available'));
}
