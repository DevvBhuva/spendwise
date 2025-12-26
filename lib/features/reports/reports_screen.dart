import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../data/repositories/transaction_repository.dart';
import '../../data/models/transaction_model.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen>
    with SingleTickerProviderStateMixin {
  final TransactionRepository _repository = TransactionRepository();
  List<TransactionModel> _transactions = [];

  late TabController _tabController;
  DateTime _selectedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    final data = await _repository.getAllTransactions();
    setState(() => _transactions = data);
  }

  /* ================= MONTH PICKER ================= */

  Future<void> _pickMonth() async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 5),
      helpText: 'Select Month',
      fieldLabelText: 'Month',
    );

    if (picked != null) {
      setState(() {
        _selectedMonth = DateTime(picked.year, picked.month);
      });
    }
  }

  String _monthLabel(DateTime d) {
    const months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    return '${months[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final monthTx = _transactions.where((t) =>
        t.date.year == _selectedMonth.year &&
        t.date.month == _selectedMonth.month);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Expense'),
            Tab(text: 'Income'),
          ],
        ),
      ),
      body: Column(
        children: [
          /* ===== MONTH SELECTOR ===== */
          InkWell(
            onTap: _pickMonth,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _monthLabel(_selectedMonth),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.keyboard_arrow_down),
                ],
              ),
            ),
          ),

          const Divider(height: 1),

          /* ===== REPORTS ===== */
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _ReportView(
                  transactions:
                      monthTx.where((t) => t.type != 'income').toList(),
                  title: 'Expense by Category',
                ),
                _ReportView(
                  transactions:
                      monthTx.where((t) => t.type == 'income').toList(),
                  title: 'Income by Category',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/* ================= REPORT VIEW ================= */

class _ReportView extends StatelessWidget {
  final List<TransactionModel> transactions;
  final String title;

  const _ReportView({
    required this.transactions,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return const _EmptyState();
    }

    final Map<String, double> categoryTotals = {};
    for (final t in transactions) {
      categoryTotals[t.category] =
          (categoryTotals[t.category] ?? 0) + t.amount;
    }

    final sections = categoryTotals.entries.map((e) {
      final color =
          Colors.primaries[e.key.hashCode % Colors.primaries.length];

      return PieChartSectionData(
        value: e.value,
        title: e.key,
        color: color,
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 260,
            child: PieChart(
              PieChartData(
                sections: sections,
                sectionsSpace: 2,
                centerSpaceRadius: 40,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              children: categoryTotals.entries.map((e) {
                return ListTile(
                  title: Text(e.key),
                  trailing: Text(
                    e.value.toStringAsFixed(2),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

/* ================= EMPTY ================= */

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'No report data available',
        style: TextStyle(color: Colors.grey),
      ),
    );
  }
}
