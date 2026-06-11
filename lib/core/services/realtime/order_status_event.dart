/// Status transition broadcast for an order, as received over the
/// tracking WebSocket on the `order:status` event. Status strings
/// mirror the backend `OrderStatus` enum
/// (`PENDING | CONFIRMED | PREPARING | READY | IN_DELIVERY |
///  DELIVERED | COMPLETED | CANCELLED | REFUNDED | DISPUTED`).
class OrderStatusEvent {
  const OrderStatusEvent({
    required this.orderId,
    required this.status,
    required this.at,
  });

  final String orderId;
  final String status;
  final DateTime at;

  factory OrderStatusEvent.fromJson(Map<String, dynamic> json) {
    return OrderStatusEvent(
      orderId: json['orderId'] as String,
      status: json['status'] as String,
      at: DateTime.parse(json['at'] as String),
    );
  }
}