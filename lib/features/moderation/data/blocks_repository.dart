import 'package:get/get.dart';

import 'package:incacook/core/constants/api_constants.dart';
import 'package:incacook/core/network/api_client.dart';
import 'package:incacook/features/moderation/data/blocked_user.dart';

/// Repository for `/v1/users/me/blocks*` (#54) — blocking/unblocking a user
/// and listing the caller's current blocks (surfaced in Settings →
/// "Utilisateurs bloqués", reversible per Apple's moderation expectations).
class BlocksRepository extends GetxService {
  BlocksRepository({ApiClient? api}) : _api = api ?? Get.find<ApiClient>();

  static BlocksRepository get instance =>
      Get.isRegistered<BlocksRepository>() ? Get.find() : Get.put(BlocksRepository());

  final ApiClient _api;

  /// `POST /v1/users/me/blocks/:userId`. Idempotent server-side.
  Future<void> block(String userId) async {
    await _api.post<void>(
      '${ApiConstants.apiPrefix}/users/me/blocks/$userId',
      decoder: (_) {},
    );
  }

  /// `DELETE /v1/users/me/blocks/:userId`.
  Future<void> unblock(String userId) async {
    await _api.delete<void>(
      '${ApiConstants.apiPrefix}/users/me/blocks/$userId',
      decoder: (_) {},
    );
  }

  /// `GET /v1/users/me/blocks` — the caller's current blocked-user list.
  Future<List<BlockedUser>> list() async {
    final result = await _api.get<List<BlockedUser>>(
      '${ApiConstants.apiPrefix}/users/me/blocks',
      decoder: (json) => (json! as List<dynamic>)
          .map((e) => BlockedUser.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
    return result.data;
  }
}
