import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/chat_message.dart';

class ChatService {
  final String baseUrl = dotenv.env['API_URL'] ?? 'http://localhost:3000';
  final storage = const FlutterSecureStorage();

  Future<List<ChatMessage>> getMessages() async {
    final token = await storage.read(key: 'jwt_token');
    if (token == null) throw Exception("Non autorisé");

    final url = Uri.parse('$baseUrl/chat');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => ChatMessage.fromJson(json)).toList();
    } else {
      throw Exception('Erreur lors de la récupération des messages');
    }
  }

  Future<ChatMessage> sendMessage(String content) async {
    final token = await storage.read(key: 'jwt_token');
    if (token == null) throw Exception("Non autorisé");

    final url = Uri.parse('$baseUrl/chat');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'content': content,
      }),
    );

    if (response.statusCode == 201) {
      return ChatMessage.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Erreur lors de l\'envoi du message');
    }
  }
}
