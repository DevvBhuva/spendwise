import 'package:flutter/material.dart';

enum TxType { income, expense, transfer }

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  TxType _type = TxType.expense;
  DateTime _date = DateTime.now();

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _customCategoryController =
      TextEditingController();

  String? _selectedCategory;
  String? _selectedPaymentWay;

  @override
  void dispose() {
    _amountController.dispose();
    _customCategoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_type.name.toUpperCase()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                const Text('SAVE', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _TypeSelector(
              selected: _type,
              onChanged: (v) => setState(() => _type = v),
            ),

            _DateRow(
              date: _date,
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

            // Amount
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  border: UnderlineInputBorder(),
                ),
              ),
            ),

            _PickerRow(
              label: 'Category',
              value: _selectedCategory,
              onTap: _showCategorySheet,
            ),

            _PickerRow(
              label: 'Payment Way',
              value: _selectedPaymentWay,
              onTap: _showPaymentWaySheet,
            ),

            _PickerRow(label: 'Note', onTap: () {}),
          ],
        ),
      ),
    );
  }

  /* ================= CATEGORY ================= */

  void _showCategorySheet() {
    final categories = [
      '🍜 Food',
      '👨‍👩‍👧 Social Life',
      '🐶 Pets',
      '🚕 Transport',
      '🖼 Culture',
      '🪑 Household',
      '👕 Apparel',
      '💄 Beauty',
      '🧘 Health',
      '📘 Education',
      '🎁 Gift',
      '📦 Other',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return _GridSheet(
          title: 'Category',
          items: categories,
          onSelect: (v) {
            Navigator.pop(context);
            if (v.contains('Other')) {
              _showAddCategoryDialog();
            } else {
              setState(() => _selectedCategory = v);
            }
          },
        );
      },
    );
  }

  void _showAddCategoryDialog() {
    _customCategoryController.clear();

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Add Category'),
          content: TextField(
            controller: _customCategoryController,
            autofocus: true,
            decoration:
                const InputDecoration(hintText: 'Enter category name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              onPressed: () {
                final value = _customCategoryController.text.trim();
                if (value.isNotEmpty) {
                  setState(() => _selectedCategory = value);
                }
                Navigator.pop(context);
              },
              child: const Text('ADD'),
            ),
          ],
        );
      },
    );
  }

  /* ================= PAYMENT WAY ================= */

  void _showPaymentWaySheet() {
    final ways = ['💵 Cash', '🏦 Accounts', '💳 Card'];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return _GridSheet(
          title: 'Payment Way',
          items: ways,
          columns: 3,
          onSelect: (v) {
            setState(() => _selectedPaymentWay = v);
            Navigator.pop(context);
          },
        );
      },
    );
  }
}

/* ================= PICKER ROW ================= */

class _PickerRow extends StatelessWidget {
  final String label;
  final String? value;
  final VoidCallback onTap;

  const _PickerRow({
    required this.label,
    this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      trailing: value != null
          ? Text(value!, style: const TextStyle(color: Colors.grey))
          : const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

/* ================= GRID SHEET (UPDATED ONLY) ================= */

class _GridSheet extends StatelessWidget {
  final String title;
  final List<String> items;
  final int columns;
  final ValueChanged<String> onSelect;

  const _GridSheet({
    required this.title,
    required this.items,
    required this.onSelect,
    this.columns = 3,
  });

  @override
  Widget build(BuildContext context) {
    final sheetHeight = MediaQuery.of(context).size.height * 0.55;

    return SizedBox(
      height: sheetHeight,
      child: Column(
        children: [
          const SizedBox(height: 12),

          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade700,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          const SizedBox(height: 12),

          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 16),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                itemCount: items.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 2.6,
                ),
                itemBuilder: (_, i) {
                  return InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => onSelect(items[i]),
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade700),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        items[i],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  );
                },
              ),
            ),
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
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: TxType.values.map((type) {
          final active = selected == type;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(type),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  border: Border.all(
                      color: active ? Colors.redAccent : Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  type.name.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: active ? Colors.redAccent : Colors.grey),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/* ================= DATE ROW ================= */

class _DateRow extends StatelessWidget {
  final DateTime date;
  final VoidCallback onTap;

  const _DateRow({required this.date, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: const Text('Date'),
      trailing: Text(
        '${date.day}/${date.month}/${date.year}',
        style: const TextStyle(color: Colors.grey),
      ),
      onTap: onTap,
    );
  }
}
