class TransactionModel {
  final int? id;
  final double amount;
  final String type; // income / expense
  final String category;
  final String paymentWay;
  final String? note;
  final DateTime date;

  TransactionModel({
    this.id,
    required this.amount,
    required this.type,
    required this.category,
    required this.paymentWay,
    this.note,
    required this.date,
  });

  /* ================= MAP → MODEL ================= */

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as int?,
      amount: (map['amount'] as num).toDouble(),
      type: map['type'],
      category: map['category'],
      paymentWay: map['payment_way'],
      note: map['note'],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
    );
  }

  /* ================= MODEL → MAP ================= */
  /// ✅ THIS FIXES YOUR ERROR
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'type': type,
      'category': category,
      'payment_way': paymentWay,
      'note': note,
      'date': date.millisecondsSinceEpoch,
    };
  }
}
