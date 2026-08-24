import 'package:get/get.dart';

import 'package:incacook/features/moderation/data/blocks_repository.dart';

/// App-wide reactive set of the caller's blocked user ids.
///
/// Exists so a block/unblock performed from the chat header (or the
/// Settings blocked-users list) is reflected immediately in every open
/// conversation list — without waiting for a full refetch (#54). Screens
/// filter their own data against [blockedUserIds]; this controller never
/// owns the conversation list itself.
class BlockedUsersController extends GetxController {
  static BlockedUsersController get instance =>
      Get.isRegistered<BlockedUsersController>()
          ? Get.find()
          : Get.put(BlockedUsersController(), permanent: true);

  final RxSet<String> blockedUserIds = <String>{}.obs;
  bool _hydrated = false;

  /// Best-effort initial hydration from the backend. Safe to call
  /// repeatedly — only the first successful call populates the set from
  /// the server; local block()/unblock() calls stay authoritative after.
  Future<void> ensureHydrated() async {
    if (_hydrated) return;
    try {
      final blocked = await BlocksRepository.instance.list();
      blockedUserIds.addAll(blocked.map((b) => b.userId));
      _hydrated = true;
    } catch (_) {
      // Best-effort — screens fall back to server-side filtering/errors.
    }
  }

  bool isBlocked(String userId) => blockedUserIds.contains(userId);

  Future<void> block(String userId) async {
    await BlocksRepository.instance.block(userId);
    blockedUserIds.add(userId);
  }

  Future<void> unblock(String userId) async {
    await BlocksRepository.instance.unblock(userId);
    blockedUserIds.remove(userId);
  }
}
