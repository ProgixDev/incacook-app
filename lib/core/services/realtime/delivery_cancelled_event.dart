/// Realtime `delivery:cancelled` event pushed to the assigned driver's
/// per-user room when their delivery is cancelled/failed server-side.
class DeliveryCancelledEvent {
  const DeliveryCancelledEvent({
    required this.deliveryId,
    required this.orderId,
    required this.status,
    required this.reason,
    required this.message,
  });

  final String deliveryId;
  final String orderId;

  /// Backend status the delivery/order moved to (e.g. CANCELLED / FAILED).
  final String status;

  /// Reason code (e.g. seller_cannot_provide / seller_unavailable / driver_disappeared).
  final String reason;

  /// Buyer/driver-facing message to surface.
  final String message;

  factory DeliveryCancelledEvent.fromJson(Map<String, dynamic> json) {
    return DeliveryCancelledEvent(
      deliveryId: json['deliveryId'] as String? ?? '',
      orderId: json['orderId'] as String? ?? '',
      status: json['status'] as String? ?? '',
      reason: json['reason'] as String? ?? '',
      message: json['message'] as String? ?? '',
    );
  }
}
