import 'dart:convert';
import '../models/expense.dart';
import '../core/network/api_client.dart';

class ExpenseService {
  Future<List<Expense>> getExpenses() async {
    final response = await apiClient.get('/expenses');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Expense.fromJson(json)).toList();
    } else {
      throw Exception('Erreur lors de la récupération des dépenses');
    }
  }

  Future<Expense> createExpense(String title, double amount, DateTime date, String category) async {
    final response = await apiClient.post(
      '/expenses',
      body: {
        'title': title,
        'amount': amount,
        'date': date.toIso8601String(),
        'category': category,
      },
    );

    if (response.statusCode == 201) {
      return Expense.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Erreur lors de la création de la dépense');
    }
  }
}
