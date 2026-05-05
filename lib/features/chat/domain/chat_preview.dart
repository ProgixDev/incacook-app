class ChatPreview {
  const ChatPreview({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.avatarPath,
    required this.lastMessageAt,
    this.isTyping = false,
    this.unreadCount = 0,
  });

  final String id;
  final String name;
  final String lastMessage;
  final String avatarPath;
  final DateTime lastMessageAt;
  final bool isTyping;
  final int unreadCount;
}
