/// Lightweight order row for the profile "Mes commandes" history screens
/// (buyer + seller). Parses the same `OrderResponseDto` shape returned by
/// both `GET /v1/orders/me` and `GET /v1/sellers/me/orders`.
class OrderSummary {
  const OrderSummary({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.buyerTotalCents,
    required this.placedAt,
    required this.fulfillmentChoice,
    required this.itemCount,
  });

  final String id;
  final String orderNumber;

  /// Backend `OrderStatus`: PENDING | CONFIRMED | PREPARING | READY |
  /// IN_DELIVERY | DELIVERED | COMPLETED | CANCELLED | REFUNDED | DISPUTED.
  final String status;
  final int buyerTotalCents;
  final DateTime placedAt;

  /// `DELIVERY` or `PICKUP`.
  final String fulfillmentChoice;
  final int itemCount;

  double get totalEuros => buyerTotalCents / 100.0;

  /// Paid = the Stripe payment succeeded. We only advance an order past
  /// PENDING once the charge is confirmed, so any status from CONFIRMED
  /// onward (and not refunded) means the seller received the money.
  static const _paidStatuses = {
    'CONFIRMED',
    'PREPARING',
    'READY',
    'IN_DELIVERY',
    'DELIVERED',
    'COMPLETED',
  };

  bool get isPaid => _paidStatuses.contains(status);

  /// Successfully completed (delivered / picked up).
  bool get isCompleted => status == 'DELIVERED' || status == 'COMPLETED';

  bool get isCancelled => status == 'CANCELLED' || status == 'REFUNDED';

  factory OrderSummary.fromJson(Map<String, dynamic> json) {
    final rawItems = (json['items'] as List?)?.cast<dynamic>() ?? const [];
    final count = rawItems.fold<int>(
      0,
      (sum, e) => sum + ((e as Map<String, dynamic>)['quantity'] as num? ?? 0).toInt(),
    );
    return OrderSummary(
      id: json['id'] as String,
      orderNumber: json['orderNumber'] as String? ?? '',
      status: json['status'] as String? ?? 'PENDING',
      buyerTotalCents: (json['buyerTotalCents'] as num?)?.toInt() ?? 0,
      placedAt: DateTime.tryParse(json['placedAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      fulfillmentChoice: json['fulfillmentChoice'] as String? ?? 'DELIVERY',
      itemCount: count,
    );
  }
}
