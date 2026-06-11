import 'package:get/get.dart';

import 'package:incacook/core/constants/api_constants.dart';
import 'package:incacook/core/network/api_client.dart';
import 'package:incacook/core/services/realtime/chat_message.dart';

/// Persisted-message REST surface — paginated history loader for
/// ChatScreen + the send call. Each send returns the persisted
/// [Message] (the same payload the realtime socket echoes back via
/// `message:new`), so callers can render an optimistic bubble without
/// waiting on the socket round-trip.
class MessagesRepository extends GetxService {
  MessagesRepository({ApiClient? api}) : _api = api ?? Get.find<ApiClient>();

  static MessagesRepository get instance => Get.find();

  final ApiClient _api;

  /// `GET /v1/conversations/:id/messages?limit=&before=` — newest
  /// first. Pass the oldest already-loaded id as [before] for
  /// scroll-back pagination (ULID cursor, no offset arithmetic).
  Future<List<Message>> listMessages(
    String conversationId, {
    int? limit,
    String? before,
  }) async {
    final result = await _api.get<List<Message>>(
      '${ApiConstants.apiPrefix}/conversations/$conversationId/messages',
      queryParameters: {
        'limit': ?limit,
        'before': ?before,
      },
      decoder: (json) => (json! as List<dynamic>)
          .map((e) => Message.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
    return result.data;
  }

  /// `POST /v1/conversations/:id/messages` — persist + broadcast.
  Future<Message> send(String conversationId, String text) async {
    final result = await _api.post<Message>(
      '${ApiConstants.apiPrefix}/conversations/$conversationId/messages',
      body: {'text': text},
      decoder: (json) => Message.fromJson(json! as Map<String, dynamic>),
    );
    return result.data;
  }
}