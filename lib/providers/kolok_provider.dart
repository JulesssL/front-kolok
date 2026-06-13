import 'package:flutter/material.dart';
import '../services/kolok_service.dart';

class KolokProvider with ChangeNotifier {
  final KolokService _kolokService = KolokService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Map<String, dynamic>? _currentKolok;
  Map<String, dynamic>? get currentKolok => _currentKolok;

  Future<void> createKolok(String name, {String? address}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final kolok = await _kolokService.createKolok(name: name, address: address);
      _currentKolok = kolok;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> joinKolok(String joinCode) async {
    _isLoading = true;
    notifyListeners();

    try {
      final kolok = await _kolokService.joinKolok(joinCode);
      _currentKolok = kolok;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  void clearKolok() {
    _currentKolok = null;
    notifyListeners();
  }
}
