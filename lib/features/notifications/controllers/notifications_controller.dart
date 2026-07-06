import 'package:get/get.dart';

import 'package:incacook/features/notifications/data/notifications_repository.dart';
import 'package:incacook/features/notifications/domain/app_notification.dart';

/// Backs the notification inbox screen and the app-bar bell badge. Kept as a
/// permanent (`fenix`) singleton so the badge count survives screen pops.
class NotificationsController extends GetxController {
  NotificationsController({NotificationsRepository? repository})
      : _repo = repository ?? NotificationsRepository.instance;

  static NotificationsController get instance => Get.find();

  final NotificationsRepository _repo;

  final RxList<AppNotification> items = <AppNotification>[].obs;
  final RxBool loading = false.obs;
  final RxBool loadingMore = false.obs;
  final RxBool hasMore = false.obs;
  final RxnString error = RxnString();
  final RxInt unreadCount = 0.obs;

  /// Loads the first page (pull-to-refresh and initial open both call this).
  Future<void> refreshInbox() async {
    loading.value = true;
    error.value = null;
    try {
      final page = await _repo.list();
      items.assignAll(page.items);
      hasMore.value = page.hasMore;
      unreadCount.value = page.unreadCount;
    } catch (e) {
      error.value = '$e';
    } finally {
      loading.value = false;
    }
  }

  /// Appends the next page (older notifications).
  Future<void> loadMore() async {
    if (loadingMore.value || !hasMore.value || items.isEmpty) return;
    loadingMore.value = true;
    try {
      final page = await _repo.list(before: items.last.id);
      items.addAll(page.items);
      hasMore.value = page.hasMore;
      unreadCount.value = page.unreadCount;
    } catch (_) {
      // Keep what we have; the list just won't grow this time.
    } finally {
      loadingMore.value = false;
    }
  }

  /// Lightweight badge refresh — used by the bell without opening the inbox.
  Future<void> refreshUnreadCount() async {
    try {
      unreadCount.value = await _repo.unreadCount();
    } catch (_) {
      // Non-critical; leave the last known count.
    }
  }

  /// Marks one notification read, optimistically. Reverts nothing on failure —
  /// the next refresh reconciles.
  Future<void> markRead(AppNotification n) async {
    if (n.read) return;
    final i = items.indexWhere((e) => e.id == n.id);
    if (i != -1) {
      items[i] = items[i].copyWith(read: true);
      if (unreadCount.value > 0) unreadCount.value -= 1;
    }
    try {
      await _repo.markRead(n.id);
    } catch (_) {/* reconciled on next refresh */}
  }

  /// Marks every notification read, optimistically.
  Future<void> markAllRead() async {
    if (unreadCount.value == 0) return;
    items.assignAll(items.map((e) => e.copyWith(read: true)));
    unreadCount.value = 0;
    try {
      await _repo.markAllRead();
    } catch (_) {/* reconciled on next refresh */}
  }
}
