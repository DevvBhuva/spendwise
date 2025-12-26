import 'package:flutter/widgets.dart';

import 'package:spendwise/data/models/account_model.dart';
import 'package:spendwise/data/models/category_model.dart';
import 'package:spendwise/data/models/transaction_model.dart';

import 'package:spendwise/data/repositories/account_repository.dart';
import 'package:spendwise/data/repositories/category_repository.dart';
import 'package:spendwise/data/repositories/transaction_repository.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final accountRepo = AccountRepository();
  final categoryRepo = CategoryRepository();
  final transactionRepo = TransactionRepository();

  print('--- DB TEST START ---');

  final accountId = await accountRepo.create(
    AccountModel(name: 'Cash Wallet', type: 'cash', balance: 5000),
  );
  print('Account created with id: $accountId');

  final categories = await categoryRepo.getByType('expense');
  print('Expense categories: ${categories.map((c) => c.name).toList()}');

  await transactionRepo.create(
    TransactionModel(
      amount: 250,
      type: 'expense',
      categoryId: categories.first.id,
      accountId: accountId,
      note: 'Lunch',
      date: DateTime.now().millisecondsSinceEpoch,
    ),
  );
  print('Transaction added');

  final income = await transactionRepo.totalIncome();
  final expense = await transactionRepo.totalExpense();
  final balance = await accountRepo.getTotalBalance();

  print('Total Income: $income');
  print('Total Expense: $expense');
  print('Total Balance: $balance');

  print('--- DB TEST END ---');
}
