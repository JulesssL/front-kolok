import 'dart:convert';
import '../models/shopping_item.dart';
import '../core/network/api_client.dart';

class ShoppingService {
  Future<List<ShoppingItem>> getItems() async {
    final response = await apiClient.get('/shopping-list');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => ShoppingItem.fromJson(json)).toList();
    } else {
      throw Exception('Erreur lors de la récupération de la liste de courses');
    }
  }

  Future<ShoppingItem> createItem(String name, String? quantity) async {
    final response = await apiClient.post(
      '/shopping-list',
      body: {
        'name': name,
        if (quantity != null) 'quantity': quantity,
      },
    );

    if (response.statusCode == 201) {
      return ShoppingItem.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Erreur lors de l\'ajout de l\'article');
    }
  }

  Future<void> toggleItem(String id, bool isBought) async {
    final response = await apiClient.patch(
      '/shopping-list/$id',
      body: {'is_bought': isBought},
    );

    if (response.statusCode != 200) {
      throw Exception('Erreur lors de la mise à jour de l\'article');
    }
  }
}
