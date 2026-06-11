import 'package:get/get.dart';

import 'package:incacook/core/constants/api_constants.dart';
import 'package:incacook/core/network/api_client.dart';
import 'package:incacook/core/services/realtime/chat_message.dart';

/// Persisted-conversation REST surface — backs every chat list screen
/// (buyer & seller) and the find-or-create call that every chat
/// entry-point (seller card, order-tracking pill, etc.) makes before
/// pushing ChatScreen. One repo for all three conversation types
/// (BUYER_SELLER / BUYER_DELIVERY / SUPPORT); the caller picks the
/// type via the `type` arg.
class ConversationsRepository extends GetxService {
  ConversationsRepository({ApiClient? api}) : _api = api ?? Get.find<ApiClient>();

  static ConversationsRepository get instance => Get.find();

  final ApiClient _api;

  /// `POST /v1/conversations` — idempotent find-or-create. Returns
  /// the conversation id + type; push ChatScreen with [ConversationRef.id]
  /// next, the rest of the chat layer keys off conversationId.
  ///
  /// [peerUserId] is optional: omit it and pass [orderId] to let the
  /// server derive the counterpart from the order + caller's role on
  /// it. The buyer↔livreur chat relies on this — the buyer never knows
  /// the driver's user id, and the call fails until a driver is assigned.
  Future<ConversationRef> findOrCreate({
    required ConversationType type,
    String? peerUserId,
    String? orderId,
    String? storeId,
  }) async {
    final result = await _api.post<ConversationRef>(
      '${ApiConstants.apiPrefix}/conversations',
      body: {
        'type': type.wire,
        'peerUserId': ?peerUserId,
        'orderId': ?orderId,
        'storeId': ?storeId,
      },
      decoder: (json) => ConversationRef.fromJson(json! as Map<String, dynamic>),
    );
    return result.data;
  }

  /// `GET /v1/conversations` — every conversation the caller is in,
  /// optionally filtered by [type] (seller messages screen passes
  /// [ConversationType.buyerSeller] to hide delivery/support threads).
  Future<List<ConversationListItem>> list({ConversationType? type}) async {
    final result = await _api.get<List<ConversationListItem>>(
      '${ApiConstants.apiPrefix}/conversations',
      queryParameters: type == null ? null : {'type': type.wire},
      decoder: (json) => (json! as List<dynamic>)
          .map((e) => ConversationListItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
    return result.data;
  }

  /// `POST /v1/conversations/:id/read` — resets the caller's unread
  /// counter. Call when ChatScreen gains focus.
  Future<void> markRead(String conversationId) async {
    await _api.post<void>(
      '${ApiConstants.apiPrefix}/conversations/$conversationId/read',
      decoder: (_) {},
    );
  }
}