import 'user.dart';

class Expense {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final String category;
  final User? payer;
  final List<ExpenseSplit>? splits;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    this.payer,
    this.splits,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'],
      title: json['title'],
      amount: double.tryParse(json['amount'].toString()) ?? 0.0,
      date: DateTime.parse(json['date']),
      category: json['category'] ?? 'other',
      payer: json['payer'] != null ? User.fromJson(json['payer']) : null,
      splits: json['splits'] != null 
          ? (json['splits'] as List).map((s) => ExpenseSplit.fromJson(s)).toList() 
          : null,
    );
  }
}

class ExpenseSplit {
  final String id;
  final User? user;
  final double amount;

  ExpenseSplit({required this.id, this.user, required this.amount});

  factory ExpenseSplit.fromJson(Map<String, dynamic> json) {
    return ExpenseSplit(
      id: json['id'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      amount: double.tryParse(json['amount'].toString()) ?? 0.0,
    );
  }
}
