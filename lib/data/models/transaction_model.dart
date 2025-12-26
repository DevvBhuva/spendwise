class TransactionModel {
  final int? id;
  final double amount;

  /// 'income' | 'expense' | 'transfer'
  final String type;

  /// Used for income / expense
  final int? categoryId;

  /// Used for income / expense
  final int? accountId;

  /// Used for transfer
  final int? fromAccountId;
  final int? toAccountId;

  final String? note;
  final int date;

  TransactionModel({
    this.id,
    required this.amount,
    required this.type,
    this.categoryId,
    this.accountId,
    this.fromAccountId,
    this.toAccountId,
    this.note,
    required this.date,
  });

  // ================================
  // TO MAP
  // ================================
  Map<String, dynamic> toMap() => {
        'id': id,
        'amount': amount,
        'type': type,
        'category_id': categoryId,
        'account_id': accountId,
        'from_account_id': fromAccountId,
        'to_account_id': toAccountId,
        'note': note,
        'date': date,
      };

  // ================================
  // FROM MAP
  // ================================
  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as int?,
      amount: (map['amount'] as num).toDouble(),
      type: map['type'] as String,
      categoryId: map['category_id'] as int?,
      accountId: map['account_id'] as int?,
      fromAccountId: map['from_account_id'] as int?,
      toAccountId: map['to_account_id'] as int?,
      note: map['note'] as String?,
      date: map['date'] as int,
    );
  }
}
