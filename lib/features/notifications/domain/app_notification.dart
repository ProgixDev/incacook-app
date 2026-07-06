/// One row in the notification inbox (the bell). Mirrors the backend
/// `GET /v1/notifications` payload. Named `AppNotification` to avoid clashing
/// with Flutter's `Notification` class.
class AppNotification {
  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.data,
    required this.read,
    required this.createdAt,
  });

  final String id;

  /// FCM-style event type (e.g. `order_paid`, `delivery_assigned`). Drives the
  /// icon and the tap deep-link.
  final String type;
  final String title;
  final String body;

  /// Mirrors the push data payload (`orderId`, `deliveryId`, …) so a tap can
  /// deep-link exactly like the push does.
  final Map<String, String> data;

  final bool read;
  final DateTime createdAt;

  String? get orderId => data['orderId'];
  String? get deliveryId => data['deliveryId'];

  AppNotification copyWith({bool? read}) => AppNotification(
        id: id,
        type: type,
        title: title,
        body: body,
        data: data,
        read: read ?? this.read,
        createdAt: createdAt,
      );

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    final data = <String, String>{};
    if (rawData is Map) {
      rawData.forEach((k, v) {
        if (v != null) data['$k'] = '$v';
      });
    }
    return AppNotification(
      id: json['id'] as String,
      type: json['type'] as String? ?? '',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      data: data,
      read: json['read'] as bool? ?? false,
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '')?.toLocal() ??
              DateTime.now(),
    );
  }
}
