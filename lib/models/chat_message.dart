import 'user.dart';

class ChatMessage {
  final String id;
  final String content;
  final User? sender;
  final DateTime createdAt;

  ChatMessage({
    required this.id,
    required this.content,
    this.sender,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      content: json['content'],
      sender: json['sender'] != null ? User.fromJson(json['sender']) : null,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : (json['created_at'] != null 
              ? DateTime.parse(json['created_at']) 
              : DateTime.now()),
    );
  }
}
