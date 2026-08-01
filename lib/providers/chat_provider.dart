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

  int _offset = 0;
  final int _limit = 20;
  bool _hasMore = true;
  bool get hasMore => _hasMore;

  Future<void> fetchMessages() async {
    _isLoading = true;
    _offset = 0;
    _hasMore = true;
    notifyListeners();
    try {
      _messages = await _chatService.getMessages(limit: _limit, offset: _offset);
      if (_messages.length < _limit) {
        _hasMore = false;
      }
      
      final token = await apiClient.storage.read(key: 'jwt_token');
      if (token != null) {
        _chatService.connect(token, _onMessageReceived, _onPollUpdated);
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreMessages() async {
    if (_isLoading || !_hasMore) return;
    
    _isLoading = true;
    notifyListeners();
    try {
      _offset += _limit;
      final newMessages = await _chatService.getMessages(limit: _limit, offset: _offset);
      
      if (newMessages.isEmpty || newMessages.length < _limit) {
        _hasMore = false;
      }
      // Insert new messages at the beginning because they are older.
      // Wait, getMessages returns chronological ASC in the API if we didn't change it. 
      // Actually we changed it to DESC then reversed, so getMessages returns oldest first in the chunk.
      // Let's just prepend them:
      _messages.insertAll(0, newMessages);
    } catch (e) {
      debugPrint(e.toString());
      _offset -= _limit;
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

  void _onPollUpdated(ChatMessage updatedMessage) {
    final index = _messages.indexWhere((m) => m.id == updatedMessage.id);
    if (index != -1) {
      _messages[index] = updatedMessage;
      notifyListeners();
    }
  }

  void sendMessage(String content, {String type = 'text', List<String>? pollOptions}) {
    try {
      _chatService.sendMessage(content, type: type, pollOptions: pollOptions);
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<void> votePoll(String pollId, String optionId) async {
    try {
      await _chatService.votePoll(pollId, optionId);
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
