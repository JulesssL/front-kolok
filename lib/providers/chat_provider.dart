import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../services/chat_service.dart';

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
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendMessage(String content) async {
    try {
      final newMsg = await _chatService.sendMessage(content);
      _messages.add(newMsg);
      notifyListeners();
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }
}
