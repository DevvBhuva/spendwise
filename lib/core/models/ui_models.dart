class UiAccount {
  final String name;
  final double balance;
  UiAccount(this.name, this.balance);
}

class UiCategory {
  final String name;
  final bool isIncome;
  UiCategory(this.name, this.isIncome);
}

class UiTransaction {
  final String title;
  final double amount;
  final DateTime date;
  final bool isIncome;

  UiTransaction({
    required this.title,
    required this.amount,
    required this.date,
    required this.isIncome,
  });
}
