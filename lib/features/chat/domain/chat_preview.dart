import 'package:flutter/painting.dart';

class ChatPreview {
  const ChatPreview({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.avatarPath,
    required this.avatarBackground,
    this.isTyping = false,
    this.unreadCount = 0,
  });

  final String id;
  final String name;
  final String lastMessage;
  final String avatarPath;
  final Color avatarBackground;
  final bool isTyping;
  final int unreadCount;
}
