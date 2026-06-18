import 'dart:convert';
import '../models/chat_message.dart';
import '../core/network/api_client.dart';

class ChatService {
  Future<List<ChatMessage>> getMessages() async {
    final response = await apiClient.get('/chat');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => ChatMessage.fromJson(json)).toList();
    } else {
      throw Exception('Erreur lors de la récupération des messages');
    }
  }

  Future<ChatMessage> sendMessage(String content) async {
    final response = await apiClient.post(
      '/chat',
      body: {'content': content},
    );

    if (response.statusCode == 201) {
      return ChatMessage.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Erreur lors de l\'envoi du message');
    }
  }
}
