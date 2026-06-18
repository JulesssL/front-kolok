import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';

class AuthService {
  final String baseUrl = dotenv.env['API_URL'] ?? 'http://localhost:3000';
  
  final storage = const FlutterSecureStorage();

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/auth/register');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Erreur lors de l\'inscription');
    }
    
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/auth/login');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = jsonDecode(response.body);
      
      final token = data['access_token']; 

      if (token != null) {
        await storage.write(key: 'jwt_token', value: token);
      } else {
        throw Exception('Token manquant dans la réponse de l\'API');
      }
    } else {
      throw Exception('Email ou mot de passe incorrect');
    }
  }

  Future<String?> getToken() async {
    return await storage.read(key: 'jwt_token');
  }

  Future<User> getMe() async {
    final token = await storage.read(key: 'jwt_token');
    final url = Uri.parse('$baseUrl/users/me');
    final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});
    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Impossible de récupérer l\'utilisateur');
    }
  }

  Future<void> logout() async {
    await storage.delete(key: 'jwt_token');
  }
}