import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../services/chat_service.dart';
import '../core/network/api_client.dart';

class ChatProvider with ChangeNotifier {
  final ChatService _chatService = ChatService();
  
  List<ChatMessage> _messages = [];
  List<ChatMessage> get messages => _messages;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchMessages() async {
    _isLoading = true;
    notifyListeners();
    try {
      _messages = await _chatService.getMessages();
      
      final token = await apiClient.storage.read(key: 'jwt_token');
      if (token != null) {
        _chatService.connect(token, _onMessageReceived);
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _onMessageReceived(ChatMessage message) {
    if (!_messages.any((m) => m.id == message.id)) {
      _messages.add(message);
      notifyListeners();
    }
  }

  void sendMessage(String content) {
    try {
      _chatService.sendMessage(content);
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  @override
  void dispose() {
    _chatService.disconnect();
    super.dispose();
  }
}
