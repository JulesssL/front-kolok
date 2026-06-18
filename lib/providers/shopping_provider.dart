import 'package:flutter/material.dart';
import '../models/shopping_item.dart';
import '../services/shopping_service.dart';

class ShoppingProvider with ChangeNotifier {
  final ShoppingService _shoppingService = ShoppingService();
  
  List<ShoppingItem> _items = [];
  List<ShoppingItem> get items => _items;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchItems() async {
    _isLoading = true;
    notifyListeners();
    try {
      _items = await _shoppingService.getItems();
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createItem(String name, String? quantity) async {
    try {
      final newItem = await _shoppingService.createItem(name, quantity);
      _items.add(newItem);
      notifyListeners();
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<void> toggleItem(String id, bool isBought) async {
    try {
      await _shoppingService.toggleItem(id, isBought);
      final index = _items.indexWhere((i) => i.id == id);
      if (index != -1) {
        final i = _items[index];
        _items[index] = ShoppingItem(
          id: i.id,
          name: i.name,
          quantity: i.quantity,
          isBought: isBought,
          createdBy: i.createdBy,
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<void> clearBoughtItems() async {
    try {
      await _shoppingService.clearBoughtItems();
      _items.removeWhere((item) => item.isBought);
      notifyListeners();
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }
}
