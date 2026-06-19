import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/kolok_service.dart';
import '../models/user.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final KolokService _kolokService = KolokService();
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isCheckingAuth = true;
  bool get isCheckingAuth => _isCheckingAuth;

  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;

  User? _currentUser;
  User? get currentUser => _currentUser;

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.login(email: email, password: password);
      _currentUser = await _authService.getMe();
      _isAuthenticated = true;
    } catch (e) {
      _isAuthenticated = false;
      _currentUser = null;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(String name, String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.register(name: name, email: email, password: password);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _isAuthenticated = false;
    _currentUser = null;
    notifyListeners();
  }

  Future<void> uploadAvatar(String filePath) async {
    _isLoading = true;
    notifyListeners();
    try {
      _currentUser = await _authService.uploadAvatar(filePath);
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> checkAuthStatus() async {
    final token = await _authService.getToken();
    if (token != null) {
      try {
        await _authService.refreshToken();
        _currentUser = await _authService.getMe();
        _isAuthenticated = true;
      } catch (e) {
        _isAuthenticated = false;
        _currentUser = null;
      }
    } else {
      _isAuthenticated = false;
      _currentUser = null;
    }
    _isCheckingAuth = false;
    notifyListeners();
  }

  Future<void> updateKolokInfo(String kolokId, String name, String address) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _kolokService.updateKolok(kolokId, name: name, address: address);
      _currentUser = await _authService.getMe();
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
