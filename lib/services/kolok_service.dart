import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class KolokService {
  final String baseUrl = dotenv.env['API_URL'] ?? 'http://localhost:3000';
  final storage = const FlutterSecureStorage();

  Future<Map<String, dynamic>> createKolok({
    required String name,
    String? address,
  }) async {
    final token = await storage.read(key: 'jwt_token');
    if (token == null) throw Exception("Non autorisé. Veuillez vous reconnecter.");

    final url = Uri.parse('$baseUrl/koloks');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', 
      },
      body: jsonEncode({
        'name': name,
        if (address != null && address.isNotEmpty) 'address': address,
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return jsonDecode(response.body); 
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Erreur lors de la création de la colocation');
    }
  }

  Future<Map<String, dynamic>> joinKolok(String joinCode) async {
    final token = await storage.read(key: 'jwt_token');
    if (token == null) throw Exception("Non autorisé. Veuillez vous reconnecter.");

    final url = Uri.parse('$baseUrl/koloks/join');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'joinCode': joinCode}),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Erreur lors de la tentative de rejoindre');
    }
  }
}