import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/user.dart';
import '../../providers/chat_provider.dart';
import '../../providers/auth_provider.dart';
import '../settings/settings_screen.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 100) {
        context.read<ChatProvider>().loadMoreMessages();
      }
    });
    Future.microtask(() {
      if (mounted) {
        context.read<ChatProvider>().fetchMessages();
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: Image.asset(
          'assets/images/logo_text_blue.png',
          width: 90,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
                );
              },
              child: Consumer<AuthProvider>(
                builder: (context, authProv, child) {
                  final avatarUrl = authProv.currentUser?.avatarUrl;
                  if (avatarUrl != null) {
                    return CircleAvatar(
                      backgroundImage: NetworkImage(avatarUrl),
                      backgroundColor: Theme.of(context).colorScheme.surface,
                    );
                  }
                  return CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    child: Icon(Icons.person_outline, color: Colors.grey.shade700),
                  );
                },
              ),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          Consumer2<ChatProvider, AuthProvider>(
            builder: (context, chatProv, authProv, child) {
              final activeUsersMap = <String, User>{};
              for (var msg in chatProv.messages.reversed) {
                if (msg.sender != null && msg.sender!.id != authProv.currentUser?.id) {
                  activeUsersMap[msg.sender!.id] = msg.sender!;
                }
              }
              
              if (activeUsersMap.isEmpty) {
                return const SizedBox(height: 16);
              }
              
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Row(
                  children: activeUsersMap.values.take(4).map((user) {
                    return _buildOverlappingAvatar(user, Theme.of(context).colorScheme.primary);
                  }).toList(),
                ),
              );
            }
          ),
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
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: chatProv.messages.length,
                  itemBuilder: (context, index) {
                    final msg = chatProv.messages[chatProv.messages.length - 1 - index];
                    final isMe = msg.sender?.id == authProv.currentUser?.id;
                    
                    return _buildMessageBubble(
                      msg.sender, 
                      msg.content, 
                      msg.createdAt, 
                      isMe, 
                    );
                  },
                );
              },
            ),
          ),
          Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: TextField(
                      controller: _messageController,
                      onSubmitted: (value) {
                        if (value.isNotEmpty) {
                          context.read<ChatProvider>().sendMessage(value);
                          _messageController.clear();
                        }
                      },
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
                  backgroundColor: Theme.of(context).colorScheme.primary,
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
        ],
      ),
    );
  }

  Widget _buildAvatar(User user, Color color) {
    final initial = user.name.isNotEmpty ? user.name[0].toUpperCase() : '?';
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 2),
      ),
      child: CircleAvatar(
        radius: 16,
        backgroundColor: color,
        backgroundImage: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
            ? CachedNetworkImageProvider(user.avatarUrl!)
            : null,
        child: user.avatarUrl == null || user.avatarUrl!.isEmpty
            ? Text(initial, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))
            : null,
      ),
    );
  }

  Widget _buildOverlappingAvatar(User user, Color color) {
    return Align(
      widthFactor: 0.7,
      child: _buildAvatar(user, color),
    );
  }

  Widget _buildMessageBubble(User? sender, String text, DateTime time, bool isMe) {
    final senderName = sender?.name ?? 'Inconnu';
    final initial = senderName.isNotEmpty ? senderName[0].toUpperCase() : '?';
    final formattedTime = DateFormat('dd/MM HH:mm').format(time);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 14,
              backgroundColor: Theme.of(context).colorScheme.primary,
              backgroundImage: sender?.avatarUrl != null && sender!.avatarUrl!.isNotEmpty
                  ? CachedNetworkImageProvider(sender.avatarUrl!)
                  : null,
              child: sender?.avatarUrl == null || sender!.avatarUrl!.isEmpty
                  ? Text(initial, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))
                  : null,
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
                    child: Text(senderName, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isMe ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surface,
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
                      color: isMe ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
                      fontSize: 14,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4, right: 4),
                  child: Text(formattedTime, style: TextStyle(fontSize: 10, color: Colors.grey.shade400)),
                ),
              ],
            ),
          ),
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
