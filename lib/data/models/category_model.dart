class CategoryModel {
  final int? id;
  final String name;
  final String type;
  final int? color;
  final int? icon;

  CategoryModel({
    this.id,
    required this.name,
    required this.type,
    this.color,
    this.icon,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'type': type,
        'color': color,
        'icon': icon,
      };

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'],
      name: map['name'],
      type: map['type'],
      color: map['color'],
      icon: map['icon'],
    );
  }
}
