// Conversation/message domain types shared by every chat surface
// (buyer↔seller from product cards, buyer↔delivery from the order
// tracking pill, future SUPPORT threads). Mirrors the persisted
// backend tables exposed via `/v1/conversations` and
// `/v1/conversations/:id/messages`.

enum ConversationType {
  buyerSeller,
  buyerDelivery,
  support,
}

extension ConversationTypeWire on ConversationType {
  String get wire {
    switch (this) {
      case ConversationType.buyerSeller:
        return 'BUYER_SELLER';
      case ConversationType.buyerDelivery:
        return 'BUYER_DELIVERY';
      case ConversationType.support:
        return 'SUPPORT';
    }
  }
}

ConversationType conversationTypeFromWire(String s) {
  switch (s) {
    case 'BUYER_SELLER':
      return ConversationType.buyerSeller;
    case 'BUYER_DELIVERY':
      return ConversationType.buyerDelivery;
    case 'SUPPORT':
      return ConversationType.support;
    default:
      throw ArgumentError('Unknown ConversationType: $s');
  }
}

enum ParticipantRole {
  buyer,
  seller,
  delivery,
  support,
}

ParticipantRole participantRoleFromWire(String s) {
  switch (s) {
    case 'BUYER':
      return ParticipantRole.buyer;
    case 'SELLER':
      return ParticipantRole.seller;
    case 'DELIVERY':
      return ParticipantRole.delivery;
    case 'SUPPORT':
      return ParticipantRole.support;
    default:
      throw ArgumentError('Unknown ParticipantRole: $s');
  }
}

enum MessageType { text, image, system }

MessageType messageTypeFromWire(String s) {
  switch (s) {
    case 'TEXT':
      return MessageType.text;
    case 'IMAGE':
      return MessageType.image;
    case 'SYSTEM':
      return MessageType.system;
    default:
      return MessageType.text;
  }
}

/// One persisted message in a conversation. Received from
/// `POST /v1/conversations/:id/messages`, `GET .../messages` history,
/// and the realtime `message:new` event on the `/tracking` socket
/// (room `conv:<id>`). [senderRole] reflects the sender's role on
/// THIS conversation — drives bubble alignment by comparing to the
/// viewer's role (which the chat screen receives from its caller).
class Message {
  const Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderRole,
    required this.content,
    required this.messageType,
    required this.createdAt,
  });

  final String id;
  final String conversationId;
  final String senderId;
  final ParticipantRole senderRole;
  final String content;
  final MessageType messageType;
  final DateTime createdAt;

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      conversationId: json['conversationId'] as String,
      senderId: json['senderId'] as String,
      senderRole: participantRoleFromWire(json['senderRole'] as String),
      content: json['content'] as String,
      messageType: messageTypeFromWire(json['messageType'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

/// Peer-side view of a conversation in the caller's list. The backend
/// already resolved the "other party" (display name, avatar, role) so
/// the UI can render each row without a separate lookup.
class ConversationPeer {
  const ConversationPeer({
    required this.userId,
    required this.displayName,
    required this.role,
    this.avatarPath,
  });

  final String userId;
  final String displayName;
  final ParticipantRole role;
  final String? avatarPath;

  factory ConversationPeer.fromJson(Map<String, dynamic> json) {
    return ConversationPeer(
      userId: json['userId'] as String,
      displayName: json['displayName'] as String,
      role: participantRoleFromWire(json['role'] as String),
      avatarPath: json['avatarPath'] as String?,
    );
  }
}

/// One row in any conversation list screen (buyer's messages tab,
/// seller's messages tab). Same shape regardless of the conversation
/// type — the screen filters server-side via `?type=`.
class ConversationListItem {
  const ConversationListItem({
    required this.id,
    required this.type,
    required this.unreadCount,
    required this.myRole,
    required this.peer,
    this.orderId,
    this.storeId,
    this.lastMessage,
    this.lastMessageAt,
  });

  final String id;
  final ConversationType type;
  final String? orderId;
  final String? storeId;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final int unreadCount;
  final ParticipantRole myRole;
  final ConversationPeer peer;

  factory ConversationListItem.fromJson(Map<String, dynamic> json) {
    return ConversationListItem(
      id: json['id'] as String,
      type: conversationTypeFromWire(json['type'] as String),
      orderId: json['orderId'] as String?,
      storeId: json['storeId'] as String?,
      lastMessage: json['lastMessage'] as String?,
      lastMessageAt: (json['lastMessageAt'] as String?) != null
          ? DateTime.parse(json['lastMessageAt'] as String)
          : null,
      unreadCount: (json['unreadCount'] as num).toInt(),
      myRole: participantRoleFromWire(json['myRole'] as String),
      peer: ConversationPeer.fromJson(json['peer'] as Map<String, dynamic>),
    );
  }
}

/// Returned by `POST /v1/conversations` (find-or-create). Use the
/// [id] to push the chat screen + subscribe to the conv room.
class ConversationRef {
  const ConversationRef({required this.id, required this.type});

  final String id;
  final ConversationType type;

  factory ConversationRef.fromJson(Map<String, dynamic> json) {
    return ConversationRef(
      id: json['id'] as String,
      type: conversationTypeFromWire(json['type'] as String),
    );
  }
}