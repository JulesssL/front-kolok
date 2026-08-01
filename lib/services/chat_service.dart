import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../models/chat_message.dart';
import '../core/network/api_client.dart';

class ChatService {
  IO.Socket? _socket;
  String? _currentToken;

  Future<List<ChatMessage>> getMessages({int limit = 20, int offset = 0}) async {
    final response = await apiClient.get('/chat?limit=$limit&offset=$offset');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => ChatMessage.fromJson(json)).toList();
    } else {
      throw Exception('Erreur lors de la récupération des messages');
    }
  }

  void connect(String token, Function(ChatMessage) onMessageReceived, Function(ChatMessage) onPollUpdated) {
    if (_socket != null && _socket!.connected) {
      if (_currentToken == token) {
        return;
      } else {
        disconnect();
      }
    }
    
    _currentToken = token;

    final baseUrl = apiClient.baseUrl;
    _socket = IO.io(baseUrl, IO.OptionBuilder()
      .disableAutoConnect()
      .enableForceNew()
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

    _socket?.on('pollUpdated', (data) {
      if (data != null) {
        onPollUpdated(ChatMessage.fromJson(data));
      }
    });

    _socket?.onDisconnect((_) {
      debugPrint('Disconnected from Chat WebSocket');
    });
  }

  void disconnect() {
    _socket?.disconnect();
    _socket = null;
    _currentToken = null;
  }

  void sendMessage(String content, {String type = 'text', List<String>? pollOptions}) {
    if (_socket != null && _socket!.connected) {
      final data = <String, dynamic>{
        'content': content,
        'type': type,
      };
      if (type == 'poll' && pollOptions != null) {
        data['pollOptions'] = pollOptions;
      }
      _socket?.emit('sendMessage', data);
    } else {
      throw Exception('Erreur: non connecté au serveur de chat');
    }
  }

  Future<void> votePoll(String pollId, String optionId) async {
    final response = await apiClient.post(
      '/chat/polls/$pollId/vote',
      body: {'optionId': optionId},
    );
    
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Erreur lors du vote');
    }
  }
}
