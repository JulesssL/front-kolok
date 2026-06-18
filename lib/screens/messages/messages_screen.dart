import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/auth_provider.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<ChatProvider>().fetchMessages();
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 0,
        title: const Text(
          "KOLOK",
          style: TextStyle(
            color: Color(0xFF2E3192),
            fontWeight: FontWeight.w800,
            fontSize: 24,
            fontFamily: 'Gilroy',
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person_outline, color: Colors.grey.shade700),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Chat Coloc",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  "4 colocataires",
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              children: [
                _buildOverlappingAvatar("S", const Color(0xFF2E3192)),
                _buildOverlappingAvatar("M", const Color(0xFF2E3192)),
                _buildOverlappingAvatar("L", const Color(0xFF2E3192)),
                _buildOverlappingAvatar("E", const Color(0xFF2E3192)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Consumer2<ChatProvider, AuthProvider>(
              builder: (context, chatProv, authProv, child) {
                if (chatProv.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (chatProv.messages.isEmpty) {
                  return const Center(child: Text("Aucun message"));
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  itemCount: chatProv.messages.length,
                  itemBuilder: (context, index) {
                    final msg = chatProv.messages[index];
                    final isMe = msg.sender?.id == authProv.user?.id;
                    final senderName = msg.sender?.name ?? 'Inconnu';
                    final initial = senderName.isNotEmpty ? senderName[0].toUpperCase() : '?';
                    
                    return _buildMessageBubble(
                      senderName, 
                      msg.content, 
                      "Aujourd'hui", // format date properly later
                      isMe, 
                      initial
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: Row(
          children: [
            Icon(Icons.attach_file, color: Colors.grey.shade400),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: "Écrire un message...",
                    hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            CircleAvatar(
              backgroundColor: const Color(0xFF2E3192),
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white, size: 18),
                onPressed: () {
                  if (_messageController.text.isNotEmpty) {
                    context.read<ChatProvider>().sendMessage(_messageController.text);
                    _messageController.clear();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(String initial, Color color) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: CircleAvatar(
        radius: 16,
        backgroundColor: color,
        child: Text(initial, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildOverlappingAvatar(String initial, Color color) {
    return Align(
      widthFactor: 0.7,
      child: _buildAvatar(initial, color),
    );
  }

  Widget _buildMessageBubble(String sender, String text, String time, bool isMe, String initial) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 14,
              backgroundColor: const Color(0xFF2E3192),
              child: Text(initial, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (!isMe)
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 4),
                    child: Text(sender, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isMe ? const Color(0xFF2E3192) : Colors.white,
                    borderRadius: BorderRadius.circular(20).copyWith(
                      bottomLeft: isMe ? const Radius.circular(20) : const Radius.circular(0),
                      bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(20),
                    ),
                    boxShadow: isMe ? [] : [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.05),
                        blurRadius: 5,
                        spreadRadius: 1,
                      )
                    ],
                  ),
                  child: Text(
                    text,
                    style: TextStyle(
                      color: isMe ? Colors.white : Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4, right: 4),
                  child: Text(time, style: TextStyle(fontSize: 10, color: Colors.grey.shade400)),
                ),
              ],
            ),
          ),
          if (isMe) const SizedBox(width: 22), 
        ],
      ),
    );
  }

  Widget _buildPollWidget() {
    return Padding(
      padding: const EdgeInsets.only(left: 36, bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20).copyWith(bottomLeft: const Radius.circular(0)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 5,
              spreadRadius: 1,
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPollOption("Pizza", 3, true),
            _buildPollOption("Pâtes", 1, false),
            _buildPollOption("Sushi", 2, false),
            const SizedBox(height: 8),
            Text("6 votants", style: TextStyle(fontSize: 10, color: Colors.grey.shade400)),
          ],
        ),
      ),
    );
  }

  Widget _buildPollOption(String title, int votes, bool isLeading) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      height: 36,
      decoration: BoxDecoration(
        color: isLeading ? const Color(0xFF2E3192).withOpacity(0.1) : const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Text(title, style: TextStyle(fontWeight: isLeading ? FontWeight.bold : FontWeight.normal, fontSize: 13)),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Text("$votes", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
