import 'package:flutter/material.dart';
import '../../data/models/transaction_model.dart';
import '../../data/repositories/transaction_repository.dart';

enum TxType { income, expense }

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final TransactionRepository _repo = TransactionRepository();

  TxType _type = TxType.expense;
  DateTime _date = DateTime.now();

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _customCategoryController =
      TextEditingController();

  String? _selectedCategory;
  String _paymentWay = 'Cash';

  /// 🔴 EXPENSE CATEGORIES
  final List<String> _expenseCategories = [
    '🍜 Food',
    '🚕 Transport',
    '🛒 Shopping',
    '🏠 Rent',
    '💡 Bills',
    '🎓 Education',
    '🎁 Gift',
    '📦 Other',
  ];

  /// 🔵 INCOME CATEGORIES
  final List<String> _incomeCategories = [
    '💼 Salary',
    '💻 Freelance',
    '🏦 Interest',
    '🎁 Gift',
    '📈 Investment',
    '📦 Other',
  ];

  List<String> get _activeCategories =>
      _type == TxType.income ? _incomeCategories : _expenseCategories;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _customCategoryController.dispose();
    super.dispose();
  }

  /* ================= SAVE ================= */

  Future<void> _save() async {
    if (_amountController.text.trim().isEmpty ||
        _selectedCategory == null) {
      _showError('Amount and category are required');
      return;
    }

    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      _showError('Enter a valid amount');
      return;
    }

    final tx = TransactionModel(
      amount: amount,
      type: _type.name,
      category: _selectedCategory!,
      paymentWay: _paymentWay,
      note: _noteController.text.trim(),
      date: _date,
    );

    await _repo.insertTransaction(tx);
    Navigator.pop(context, true);
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  /* ================= CATEGORY ================= */

  void _showCategorySheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: _activeCategories.map((c) {
            return ListTile(
              title: Text(c),
              onTap: () {
                Navigator.pop(context);
                if (c.contains('Other')) {
                  _showAddCategoryDialog();
                } else {
                  setState(() => _selectedCategory = c);
                }
              },
            );
          }).toList(),
        );
      },
    );
  }

  void _showAddCategoryDialog() {
    _customCategoryController.clear();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
            'Add ${_type == TxType.income ? 'Income' : 'Expense'} Category'),
        content: TextField(
          controller: _customCategoryController,
          autofocus: true,
          decoration:
              const InputDecoration(hintText: 'Category name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              final value = _customCategoryController.text.trim();
              if (value.isNotEmpty) {
                setState(() {
                  _activeCategories.insert(
                      _activeCategories.length - 1, value);
                  _selectedCategory = value;
                });
              }
              Navigator.pop(context);
            },
            child: const Text('ADD'),
          ),
        ],
      ),
    );
  }

  /* ================= UI ================= */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_type.name.toUpperCase()),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text(
              'SAVE',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _TypeSelector(
            selected: _type,
            onChanged: (v) {
              setState(() {
                _type = v;
                _selectedCategory = null; // 🔥 reset on switch
              });
            },
          ),

          ListTile(
            title: const Text('Date'),
            trailing:
                Text('${_date.day}/${_date.month}/${_date.year}'),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _date,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (picked != null) setState(() => _date = picked);
            },
          ),

          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration:
                const InputDecoration(labelText: 'Amount'),
          ),

          const SizedBox(height: 12),

          ListTile(
            title: const Text('Category'),
            trailing: Text(
              _selectedCategory ?? 'Select',
              style: const TextStyle(color: Colors.grey),
            ),
            onTap: _showCategorySheet,
          ),

          TextField(
            controller: _noteController,
            decoration: const InputDecoration(labelText: 'Note'),
          ),
        ],
      ),
    );
  }
}

/* ================= TYPE SELECTOR ================= */

class _TypeSelector extends StatelessWidget {
  final TxType selected;
  final ValueChanged<TxType> onChanged;

  const _TypeSelector({
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: TxType.values.map((type) {
        final active = selected == type;
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(type),
            child: Container(
              margin: const EdgeInsets.all(6),
              padding:
                  const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(
                    color:
                        active ? Colors.redAccent : Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                type.name.toUpperCase(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color:
                      active ? Colors.redAccent : Colors.grey,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
