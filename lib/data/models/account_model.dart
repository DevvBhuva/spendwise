class AccountModel {
  final int? id;
  final String name;
  final String type;
  final double balance;

  AccountModel({
    this.id,
    required this.name,
    required this.type,
    required this.balance,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'type': type,
        'balance': balance,
      };

  factory AccountModel.fromMap(Map<String, dynamic> map) {
    return AccountModel(
      id: map['id'],
      name: map['name'],
      type: map['type'],
      balance: map['balance'],
    );
  }
}
