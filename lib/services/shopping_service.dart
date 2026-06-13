import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/shopping_item.dart';

class ShoppingService {
  final String baseUrl = dotenv.env['API_URL'] ?? 'http://localhost:3000';
  final storage = const FlutterSecureStorage();

  Future<List<ShoppingItem>> getItems() async {
    final token = await storage.read(key: 'jwt_token');
    if (token == null) throw Exception("Non autorisé");

    final url = Uri.parse('$baseUrl/shopping-list');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => ShoppingItem.fromJson(json)).toList();
    } else {
      throw Exception('Erreur lors de la récupération de la liste de courses');
    }
  }

  Future<ShoppingItem> createItem(String name, String? quantity) async {
    final token = await storage.read(key: 'jwt_token');
    if (token == null) throw Exception("Non autorisé");

    final url = Uri.parse('$baseUrl/shopping-list');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'name': name,
        if (quantity != null) 'quantity': quantity,
      }),
    );

    if (response.statusCode == 201) {
      return ShoppingItem.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Erreur lors de l\'ajout de l\'article');
    }
  }

  Future<void> toggleItem(String id, bool isBought) async {
    final token = await storage.read(key: 'jwt_token');
    if (token == null) throw Exception("Non autorisé");

    final url = Uri.parse('$baseUrl/shopping-list/$id');
    final response = await http.patch(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'is_bought': isBought}),
    );

    if (response.statusCode != 200) {
      throw Exception('Erreur lors de la mise à jour de l\'article');
    }
  }
}
