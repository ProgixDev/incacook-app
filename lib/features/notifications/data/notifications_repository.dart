import 'package:get/get.dart';

import 'package:incacook/core/constants/api_constants.dart';
import 'package:incacook/core/network/api_client.dart';
import 'package:incacook/features/notifications/domain/app_notification.dart';

/// A page of the notification inbox + the unread badge count.
class NotificationsPage {
  const NotificationsPage({
    required this.items,
    required this.hasMore,
    required this.unreadCount,
  });

  final List<AppNotification> items;
  final bool hasMore;
  final int unreadCount;
}

/// REST surface for the notification inbox under `/v1/notifications/*`.
class NotificationsRepository extends GetxService {
  NotificationsRepository({ApiClient? api}) : _api = api ?? Get.find<ApiClient>();

  static NotificationsRepository get instance => Get.find();

  final ApiClient _api;

  /// `GET /v1/notifications` — newest-first page. Pass [before] (an id) to
  /// page older. Returns the items, a `hasMore` flag, and the unread count.
  Future<NotificationsPage> list({int limit = 30, String? before}) async {
    final result = await _api.get<NotificationsPage>(
      '${ApiConstants.apiPrefix}/notifications',
      queryParameters: {
        'limit': '$limit',
        'before': ?before,
      },
      decoder: (json) {
        // The current backend returns `{ items, hasMore, unreadCount }`. An
        // older deployed build returns a bare array of notifications (the
        // envelope's `data` is the list itself). Accept both so the inbox
        // works regardless of which server version is live — otherwise the
        // `as Map` cast throws on the array shape and the screen shows
        // "Impossible de charger les notifications".
        if (json is List) {
          final items = json
              .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
              .toList();
          return NotificationsPage(
            items: items,
            // The legacy array shape carries no cursor/meta; disable paging
            // (avoids re-fetching page 1 if the old server ignores `before`)
            // and derive the badge from what we have.
            hasMore: false,
            unreadCount: items.where((n) => !n.read).length,
          );
        }
        final m = json! as Map<String, dynamic>;
        return NotificationsPage(
          items: (m['items'] as List<dynamic>? ?? const [])
              .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
              .toList(),
          hasMore: m['hasMore'] as bool? ?? false,
          unreadCount: (m['unreadCount'] as num?)?.toInt() ?? 0,
        );
      },
    );
    return result.data;
  }

  /// `GET /v1/notifications/unread-count` — badge count for the bell.
  Future<int> unreadCount() async {
    final result = await _api.get<int>(
      '${ApiConstants.apiPrefix}/notifications/unread-count',
      decoder: (json) =>
          ((json! as Map<String, dynamic>)['count'] as num?)?.toInt() ?? 0,
    );
    return result.data;
  }

  /// `POST /v1/notifications/:id/read`.
  Future<void> markRead(String id) async {
    await _api.post<void>(
      '${ApiConstants.apiPrefix}/notifications/$id/read',
      decoder: (_) {},
    );
  }

  /// `POST /v1/notifications/read-all`.
  Future<void> markAllRead() async {
    await _api.post<void>(
      '${ApiConstants.apiPrefix}/notifications/read-all',
      decoder: (_) {},
    );
  }
}
