/// Full buyer-facing order, parsed from `GET /v1/orders/:id`
/// (`OrderResponseDto`). Powers the order-detail screen reached by tapping a
/// row in "Mes commandes". Richer than [OrderSummary]: line items, add-ons,
/// the price breakdown, the delivery address, and instructions.
class BuyerOrderDetail {
  const BuyerOrderDetail({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.fulfillmentChoice,
    required this.subtotalCents,
    required this.deliveryFeeCents,
    required this.platformBuyerFeeCents,
    required this.buyerTotalCents,
    required this.placedAt,
    required this.items,
    this.dropoffFullAddress,
    this.dropoffCity,
    this.dropoffPostalCode,
    this.deliveryInstructions,
    this.note,
    this.expectedAt,
  });

  final String id;
  final String orderNumber;

  /// Backend `OrderStatus`: PENDING | CONFIRMED | PREPARING | READY |
  /// PICKED_UP | IN_DELIVERY | NO_DRIVER_AVAILABLE | DELIVERED | COMPLETED |
  /// CANCELLED | REFUNDED | DISPUTED.
  final String status;

  /// `DELIVERY` or `PICKUP`.
  final String fulfillmentChoice;

  final int subtotalCents;
  final int deliveryFeeCents;
  final int platformBuyerFeeCents;
  final int buyerTotalCents;

  final DateTime placedAt;
  final DateTime? expectedAt;

  /// Delivery address fields. Null for PICKUP orders (no delivery address).
  /// Parsed directly (not via the `Address` model) to sidestep its saved-type
  /// enum decoding, which we don't need here and which can reject the server's
  /// uppercase `type`.
  final String? dropoffFullAddress;
  final String? dropoffCity;
  final String? dropoffPostalCode;
  final String? deliveryInstructions;
  final String? note;

  final List<BuyerOrderItem> items;

  bool get isDelivery => fulfillmentChoice != 'PICKUP';

  /// Street line, e.g. "12 rue des Lilas". Null/empty when no dropoff.
  String? get dropoffLine1 =>
      (dropoffFullAddress?.isNotEmpty ?? false) ? dropoffFullAddress : null;

  /// "postalCode city", e.g. "75011 Paris". Empty when neither is present.
  String get dropoffLine2 =>
      '${dropoffPostalCode ?? ''} ${dropoffCity ?? ''}'.trim();

  /// Statuses where live tracking ("suivi") is meaningful — the order is paid
  /// and in-flight, up to and including out-for-delivery. Excludes PENDING
  /// (unpaid) and terminal states (delivered/completed/cancelled/refunded).
  static const _trackableStatuses = {
    'CONFIRMED',
    'PREPARING',
    'READY',
    'PICKED_UP',
    'IN_DELIVERY',
    'NO_DRIVER_AVAILABLE',
  };

  /// Whether the "Suivre ma commande" entry point should be offered.
  bool get isTrackable => _trackableStatuses.contains(status);

  factory BuyerOrderDetail.fromJson(Map<String, dynamic> json) {
    final rawItems = (json['items'] as List?)?.cast<dynamic>() ?? const [];
    final rawAddress = json['dropoffAddress'];
    final address = rawAddress is Map<String, dynamic> ? rawAddress : null;
    return BuyerOrderDetail(
      id: json['id'] as String,
      orderNumber: json['orderNumber'] as String? ?? '',
      status: json['status'] as String? ?? 'PENDING',
      fulfillmentChoice: json['fulfillmentChoice'] as String? ?? 'DELIVERY',
      subtotalCents: (json['subtotalCents'] as num?)?.toInt() ?? 0,
      deliveryFeeCents: (json['deliveryFeeCents'] as num?)?.toInt() ?? 0,
      platformBuyerFeeCents:
          (json['platformBuyerFeeCents'] as num?)?.toInt() ?? 0,
      buyerTotalCents: (json['buyerTotalCents'] as num?)?.toInt() ?? 0,
      placedAt: DateTime.tryParse(json['placedAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      expectedAt: DateTime.tryParse(json['expectedAt'] as String? ?? ''),
      dropoffFullAddress: address?['fullAddress'] as String?,
      dropoffCity: address?['city'] as String?,
      dropoffPostalCode: address?['postalCode'] as String?,
      deliveryInstructions: json['deliveryInstructions'] as String?,
      note: json['note'] as String?,
      items: rawItems
          .map((e) => BuyerOrderItem.fromJson(e as Map<String, dynamic>))
          .toList(growable: false),
    );
  }
}

/// One line item on a buyer order.
class BuyerOrderItem {
  const BuyerOrderItem({
    required this.listingName,
    required this.unitPriceCents,
    required this.quantity,
    required this.lineTotalCents,
    required this.addOns,
    this.listingImageUrl,
    this.note,
  });

  final String listingName;
  final String? listingImageUrl;
  final int unitPriceCents;
  final int quantity;
  final int lineTotalCents;
  final String? note;
  final List<BuyerOrderAddOn> addOns;

  factory BuyerOrderItem.fromJson(Map<String, dynamic> json) {
    final rawAddOns = (json['addOns'] as List?)?.cast<dynamic>() ?? const [];
    return BuyerOrderItem(
      listingName: json['listingName'] as String? ?? '',
      listingImageUrl: json['listingImageUrl'] as String?,
      unitPriceCents: (json['unitPriceCents'] as num?)?.toInt() ?? 0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      lineTotalCents: (json['lineTotalCents'] as num?)?.toInt() ?? 0,
      note: json['note'] as String?,
      addOns: rawAddOns
          .map((e) => BuyerOrderAddOn.fromJson(e as Map<String, dynamic>))
          .toList(growable: false),
    );
  }
}

/// An add-on chosen on a line item (label + price delta snapshot).
class BuyerOrderAddOn {
  const BuyerOrderAddOn({required this.label, required this.priceDeltaCents});

  final String label;
  final int priceDeltaCents;

  factory BuyerOrderAddOn.fromJson(Map<String, dynamic> json) => BuyerOrderAddOn(
        label: json['label'] as String? ?? '',
        priceDeltaCents: (json['priceDeltaCents'] as num?)?.toInt() ?? 0,
      );
}

/// French label for a backend `OrderStatus`. Shared by the history and detail
/// screens so status wording stays consistent.
String orderStatusLabel(String status) {
  switch (status) {
    case 'PENDING':
      return 'En attente';
    case 'CONFIRMED':
      return 'Confirmée';
    case 'PREPARING':
      return 'En préparation';
    case 'READY':
      return 'Prête';
    case 'PICKED_UP':
      return 'Récupérée';
    case 'IN_DELIVERY':
      return 'En livraison';
    case 'NO_DRIVER_AVAILABLE':
      return 'Aucun livreur';
    case 'DELIVERED':
      return 'Livrée';
    case 'COMPLETED':
      return 'Terminée';
    case 'CANCELLED':
      return 'Annulée';
    case 'REFUNDED':
      return 'Remboursée';
    case 'DISPUTED':
      return 'Litige';
    default:
      return status;
  }
}
