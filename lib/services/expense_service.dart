import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/expense.dart';

class ExpenseService {
  final String baseUrl = dotenv.env['API_URL'] ?? 'http://localhost:3000';
  final storage = const FlutterSecureStorage();

  Future<List<Expense>> getExpenses() async {
    final token = await storage.read(key: 'jwt_token');
    if (token == null) throw Exception("Non autorisé");

    final url = Uri.parse('$baseUrl/expenses');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Expense.fromJson(json)).toList();
    } else {
      throw Exception('Erreur lors de la récupération des dépenses');
    }
  }

  Future<Expense> createExpense(String title, double amount, DateTime date, String category) async {
    final token = await storage.read(key: 'jwt_token');
    if (token == null) throw Exception("Non autorisé");

    final url = Uri.parse('$baseUrl/expenses');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'title': title,
        'amount': amount,
        'date': date.toIso8601String(),
        'category': category,
      }),
    );

    if (response.statusCode == 201) {
      return Expense.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Erreur lors de la création de la dépense');
    }
  }
}
