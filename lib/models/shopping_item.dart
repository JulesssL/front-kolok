import 'user.dart';

class ShoppingItem {
  final String id;
  final String name;
  final String? quantity;
  final bool isBought;
  final User? createdBy;

  ShoppingItem({
    required this.id,
    required this.name,
    this.quantity,
    required this.isBought,
    this.createdBy,
  });

  factory ShoppingItem.fromJson(Map<String, dynamic> json) {
    return ShoppingItem(
      id: json['id'],
      name: json['name'],
      quantity: json['quantity'],
      isBought: json['is_bought'] ?? false,
      createdBy: json['createdBy'] != null ? User.fromJson(json['createdBy']) : null,
    );
  }
}
