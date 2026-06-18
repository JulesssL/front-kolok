import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../models/chat_message.dart';
import '../core/network/api_client.dart';

class ChatService {
  IO.Socket? _socket;

  Future<List<ChatMessage>> getMessages() async {
    final response = await apiClient.get('/chat');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => ChatMessage.fromJson(json)).toList();
    } else {
      throw Exception('Erreur lors de la récupération des messages');
    }
  }

  void connect(String token, Function(ChatMessage) onMessageReceived) {
    if (_socket != null && _socket!.connected) return;

    final baseUrl = apiClient.baseUrl;
    _socket = IO.io(baseUrl, IO.OptionBuilder()
      .disableAutoConnect()
      .setTransports(['websocket'])
      .setAuth({'token': 'Bearer $token'})
      .build()
    );

    _socket?.connect();

    _socket?.onConnect((_) {
      debugPrint('Connected to Chat WebSocket');
    });

    _socket?.on('newMessage', (data) {
      if (data != null) {
        onMessageReceived(ChatMessage.fromJson(data));
      }
    });

    _socket?.onDisconnect((_) {
      debugPrint('Disconnected from Chat WebSocket');
    });
  }

  void disconnect() {
    _socket?.disconnect();
    _socket = null;
  }

  void sendMessage(String content) {
    if (_socket != null && _socket!.connected) {
      _socket?.emit('sendMessage', {'content': content});
    } else {
      throw Exception('Erreur: non connecté au serveur de chat');
    }
  }
}
