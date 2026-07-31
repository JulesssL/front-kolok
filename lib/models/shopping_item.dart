import 'user.dart';

class ShoppingItem {
  final String id;
  final String name;
  final String? quantity;
  final bool isBought;
  final User? createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ShoppingItem({
    required this.id,
    required this.name,
    this.quantity,
    required this.isBought,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  factory ShoppingItem.fromJson(Map<String, dynamic> json) {
    return ShoppingItem(
      id: json['id'],
      name: json['name'],
      quantity: json['quantity'],
      isBought: json['is_bought'] ?? false,
      createdBy: json['createdBy'] != null ? User.fromJson(json['createdBy']) : null,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : (json['created_at'] != null ? DateTime.parse(json['created_at']) : null),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : (json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null),
    );
  }
}
