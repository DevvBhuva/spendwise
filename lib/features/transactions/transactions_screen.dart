import 'package:flutter/material.dart';
import 'add_transaction_screen.dart';
import '../reports/reports_screen.dart';
import '../../utils/currency_formatter.dart';
import '../../utils/export_csv.dart';
import '../../utils/backup_service.dart';
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
  late DateTime _currentMonth;

  final TransactionRepository _repository = TransactionRepository();
  final BackupService _backupService = BackupService();

  List<TransactionModel> _transactions = [];

  final tabs = const ['Daily', 'Calendar', 'Monthly', 'Total', 'Note'];

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime.now();
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

  String _monthName(int m) {
    const months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    return months[m - 1];
  }

  /* ================= MORE MENU ================= */

  void _openMoreMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _MoreItem(
              icon: Icons.upload_file,
              label: 'Export to CSV',
              onTap: () async {
                Navigator.pop(context);
                await CsvExporter.exportTransactions(_transactions);
                _toast('CSV exported');
              },
            ),
            _MoreItem(
              icon: Icons.picture_as_pdf,
              label: 'Export to PDF',
              onTap: () {
                Navigator.pop(context);
                _toast('PDF export coming soon');
              },
            ),
            _MoreItem(
              icon: Icons.backup,
              label: 'Backup',
              onTap: () async {
                Navigator.pop(context);
                await _backupService.exportBackup();
                _toast('Backup created');
              },
            ),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final income = _transactions
        .where((t) =>
            t.type == 'income' &&
            t.date.month == _currentMonth.month &&
            t.date.year == _currentMonth.year)
        .fold(0.0, (s, t) => s + t.amount);

    final expense = _transactions
        .where((t) =>
            t.type != 'income' &&
            t.date.month == _currentMonth.month &&
            t.date.year == _currentMonth.year)
        .fold(0.0, (s, t) => s + t.amount);

    return Scaffold(
      appBar: AppBar(
        title: Text('${_monthName(_currentMonth.month)} ${_currentMonth.year}'),
        actions: [
          /// 📊 STATS
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

          /// ⋮ MORE
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
        backgroundColor: Colors.redAccent,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddTransactionScreen(),
            ),
          );
          if (result == true) _loadTransactions();
        },
        child: const Icon(Icons.add),
      ),

      body: Column(
        children: [
          _SummaryBar(
            income: income,
            expense: expense,
            total: income - expense,
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _DailyView(transactions: _transactions, onDelete: _delete),
                _CalendarView(
                  currentMonth: _currentMonth,
                  transactions: _transactions,
                ),
                const _EmptyState(),
                _TotalView(transactions: _transactions),
                const _EmptyState(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/* ================= MORE ITEM ================= */

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

/* ================= DAILY ================= */

class _DailyView extends StatelessWidget {
  final List<TransactionModel> transactions;
  final Function(TransactionModel) onDelete;

  const _DailyView({
    required this.transactions,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();

    final todayTx = transactions.where((t) =>
        t.date.year == today.year &&
        t.date.month == today.month &&
        t.date.day == today.day).toList();

    if (todayTx.isEmpty) return const _EmptyState();

    return ListView(
      children: todayTx.map((t) {
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
            subtitle: Text(
              (t.note == null || t.note!.isEmpty) ? '—' : t.note!,
            ),
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

/* ================= CALENDAR ================= */

class _CalendarView extends StatelessWidget {
  final DateTime currentMonth;
  final List<TransactionModel> transactions;

  const _CalendarView({
    required this.currentMonth,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    return const _EmptyState();
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
      if (t.type == 'income') {
        income += t.amount;
      } else {
        expense += t.amount;
      }
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

class _SummaryBar extends StatelessWidget {
  final double income, expense, total;

  const _SummaryBar({
    required this.income,
    required this.expense,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _SummaryItem('Income', income, Colors.blue),
        _SummaryItem('Expense', expense, Colors.red),
        _SummaryItem('Total', total, Colors.white),
      ],
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _SummaryItem(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          CurrencyFormatter.format(value),
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('No data available'));
}
