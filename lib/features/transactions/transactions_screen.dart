import 'package:flutter/material.dart';
import 'add_transaction_screen.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late DateTime _currentMonth;

  final tabs = const ['Daily', 'Calendar', 'Monthly', 'Total', 'Note'];

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime.now();
    _tabController = TabController(length: tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _monthName(int m) {
    const months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    return months[m - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${_monthName(_currentMonth.month)} ${_currentMonth.year}',
        ),
        actions: const [
          Icon(Icons.star_border),
          SizedBox(width: 12),
          Icon(Icons.search),
          SizedBox(width: 12),
          Icon(Icons.tune),
          SizedBox(width: 12),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.redAccent,
          labelColor: Colors.redAccent,
          unselectedLabelColor: Colors.grey,
          tabs: tabs.map((t) => Tab(text: t)).toList(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.redAccent,
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
      body: Column(
        children: [
          _SummaryBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                const _DailyView(),
                _CalendarView(currentMonth: _currentMonth),
                _MonthlyView(currentMonth: _currentMonth),
                const _TotalView(),
                const _NotesView(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/* ================= SUMMARY BAR ================= */

class _SummaryBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      color: Colors.black26,
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _SummaryItem(label: 'Income', value: '25,000', color: Colors.blue),
          _SummaryItem(label: 'Expense', value: '3,000', color: Colors.red),
          _SummaryItem(label: 'Total', value: '22,000', color: Colors.white),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                color: color, fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}

/* ================= DAILY ================= */

class _DailyView extends StatelessWidget {
  const _DailyView();

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        _DayHeader('Today'),
        _TransactionTile('Food', 'Lunch', '-120', false),
        _TransactionTile('Transport', 'Bus', '-40', false),
        _DayHeader('Yesterday'),
        _TransactionTile('Salary', 'Monthly salary', '+25,000', true),
      ],
    );
  }
}

class _DayHeader extends StatelessWidget {
  final String text;
  const _DayHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(text,
          style: const TextStyle(
              color: Colors.grey, fontWeight: FontWeight.bold)),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String amount;
  final bool income;

  const _TransactionTile(this.title, this.subtitle, this.amount, this.income);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: income ? Colors.blue : Colors.red,
        child: Icon(
          income ? Icons.arrow_downward : Icons.arrow_upward,
          color: Colors.white,
          size: 18,
        ),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Text(
        amount,
        style: TextStyle(
          color: income ? Colors.blue : Colors.red,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/* ================= CALENDAR ================= */

class _CalendarView extends StatefulWidget {
  final DateTime currentMonth;
  const _CalendarView({required this.currentMonth});

  @override
  State<_CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<_CalendarView> {
  int selectedDay = DateTime.now().day;

  String _monthName(int m) {
    const months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    return months[m - 1];
  }

  @override
  Widget build(BuildContext context) {
    final days = DateUtils.getDaysInMonth(
        widget.currentMonth.year, widget.currentMonth.month);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            '${_monthName(widget.currentMonth.month)} ${widget.currentMonth.year}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        const _WeekRow(),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: days,
          gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7),
          itemBuilder: (_, i) {
            final day = i + 1;
            return GestureDetector(
              onTap: () => setState(() => selectedDay = day),
              child: Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: selectedDay == day ? Colors.redAccent : null,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade700),
                ),
                child: Center(
                  child: Text(
                    '$day',
                    style: TextStyle(
                      color: selectedDay == day
                          ? Colors.white
                          : Colors.white70,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        const Divider(),
        const Expanded(child: _EmptyState()),
      ],
    );
  }
}

class _WeekRow extends StatelessWidget {
  const _WeekRow();

  @override
  Widget build(BuildContext context) {
    const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return Row(
      children: days
          .map((d) => Expanded(
                child: Center(
                    child:
                        Text(d, style: const TextStyle(color: Colors.grey))),
              ))
          .toList(),
    );
  }
}

/* ================= MONTHLY ================= */

class _MonthlyView extends StatelessWidget {
  final DateTime currentMonth;
  const _MonthlyView({required this.currentMonth});

  String _monthName(int m) {
    const months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    return months[m - 1];
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Center(
          child: Text(
            '${_monthName(currentMonth.month)} ${currentMonth.year}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 16),
        _MonthlyCards(),
        const SizedBox(height: 24),
        _CategoryRow('Food', '1,200', '40%', Colors.red),
        _CategoryRow('Transport', '600', '20%', Colors.orange),
        _CategoryRow('Shopping', '1,200', '40%', Colors.purple),
      ],
    );
  }
}

class _MonthlyCards extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _MonthlyCard('Income', '25,000', Colors.blue)),
        const SizedBox(width: 12),
        Expanded(child: _MonthlyCard('Expense', '3,000', Colors.red)),
      ],
    );
  }
}

class _MonthlyCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _MonthlyCard(this.title, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Text(value,
              style: TextStyle(
                  color: color,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final String name;
  final String amount;
  final String percent;
  final Color color;

  const _CategoryRow(this.name, this.amount, this.percent, this.color);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(radius: 6, backgroundColor: color),
      title: Text(name),
      subtitle: Text('$percent of total'),
      trailing:
          Text(amount, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}

/* ================= TOTAL / NOTES / EMPTY ================= */

class _TotalView extends StatelessWidget {
  const _TotalView();

  @override
  Widget build(BuildContext context) {
    return const _EmptyState();
  }
}

class _NotesView extends StatelessWidget {
  const _NotesView();

  @override
  Widget build(BuildContext context) {
    return const _EmptyState();
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('No data available',
          style: TextStyle(color: Colors.grey)),
    );
  }
}
