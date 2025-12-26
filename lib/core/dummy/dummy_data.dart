import '../models/ui_models.dart';

final accounts = [
  UiAccount('Cash', 5200),
  UiAccount('Bank', 18500),
];

final categories = [
  UiCategory('Food', false),
  UiCategory('Travel', false),
  UiCategory('Salary', true),
];

final transactions = [
  UiTransaction(
    title: 'Groceries',
    amount: -450,
    date: DateTime.now(),
    isIncome: false,
  ),
  UiTransaction(
    title: 'Salary',
    amount: 25000,
    date: DateTime.now(),
    isIncome: true,
  ),
];
