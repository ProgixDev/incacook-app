import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:incacook/core/services/realtime/chat_message.dart';
import 'package:incacook/features/chat/data/conversations_repository.dart';
import 'package:incacook/features/chat/presentation/screens/chat.dart';

/// One-stop helper for opening ChatScreen from any entry point.
/// Wraps the find-or-create call so every callsite is the same:
///   `ChatNavigator.openBuyerSeller(context: ..., peerUserId: ...)`.
/// Surfaces failures via a SnackBar instead of bubbling up — chat
/// entry points are always secondary actions (next to a primary
/// "Acheter"/"Suivre" CTA), so a hard error would be jarring.
class ChatNavigator {
  ChatNavigator._();

  /// BUYER_SELLER thread. [orderId] is optional — pass it from
  /// order-scoped surfaces (tracking, seller order requests) to scope
  /// the conversation to that order; omit for product-card chat.
  static Future<void> openBuyerSeller({
    required BuildContext context,
    required String peerUserId,
    required String peerName,
    required ParticipantRole myRole,
    String? orderId,
  }) =>
      _open(
        context: context,
        type: ConversationType.buyerSeller,
        peerUserId: peerUserId,
        peerName: peerName,
        myRole: myRole,
        orderId: orderId,
      );

  /// BUYER_DELIVERY thread — buyer ↔ assigned driver. The backend
  /// requires [orderId] and derives the counterpart from it, so the
  /// caller doesn't pass a peer id: the buyer doesn't know the driver's
  /// user id, and the server rejects the call until a driver is
  /// assigned (surfaced here as a SnackBar).
  static Future<void> openBuyerDelivery({
    required BuildContext context,
    required String peerName,
    required String orderId,
    required ParticipantRole myRole,
  }) =>
      _open(
        context: context,
        type: ConversationType.buyerDelivery,
        peerName: peerName,
        myRole: myRole,
        orderId: orderId,
      );

  static Future<void> _open({
    required BuildContext context,
    required ConversationType type,
    required String peerName,
    required ParticipantRole myRole,
    String? peerUserId,
    String? orderId,
  }) async {
    try {
      final ref = await ConversationsRepository.instance.findOrCreate(
        type: type,
        peerUserId: peerUserId,
        orderId: orderId,
      );
      if (!context.mounted) return;
      await Get.to<void>(
        () => ChatScreen(
          conversationId: ref.id,
          myRole: myRole,
          title: peerName,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Impossible d\'ouvrir la conversation: $e')),
      );
    }
  }
}