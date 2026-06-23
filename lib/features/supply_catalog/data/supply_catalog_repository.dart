import 'package:incacook/core/constants/api_constants.dart';
import 'package:incacook/core/network/api_client.dart';

/// A product in the admin-managed catalog, sold to sellers. Distinct from a
/// seller's own dish `Listing`. Mirrors backend `CatalogProductResponseDto`.
class CatalogItem {
  const CatalogItem({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrls,
    required this.priceCents,
    required this.currency,
  });

  final String id;
  final String name;
  final String? description;
  final List<String> imageUrls;
  final int priceCents;
  final String currency;

  String? get imageUrl => imageUrls.isNotEmpty ? imageUrls.first : null;

  factory CatalogItem.fromJson(Map<String, dynamic> json) {
    return CatalogItem(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      imageUrls:
          (json['imageUrls'] as List<dynamic>? ?? []).map((e) => e as String).toList(),
      priceCents: (json['priceCents'] as num).toInt(),
      currency: (json['currency'] as String?) ?? 'usd',
    );
  }
}

/// Result of starting a catalog purchase — `clientSecret` confirms the card.
class CatalogCheckout {
  const CatalogCheckout({
    required this.orderId,
    required this.clientSecret,
    required this.totalCents,
    required this.currency,
  });

  final String orderId;
  final String? clientSecret;
  final int totalCents;
  final String currency;

  factory CatalogCheckout.fromJson(Map<String, dynamic> json) {
    return CatalogCheckout(
      orderId: json['orderId'] as String,
      clientSecret: json['clientSecret'] as String?,
      totalCents: (json['totalCents'] as num).toInt(),
      currency: (json['currency'] as String?) ?? 'usd',
    );
  }
}

/// One line item on a catalog order. Mirrors backend item response.
class CatalogOrderLine {
  const CatalogOrderLine({
    required this.name,
    required this.unitPriceCents,
    required this.quantity,
    required this.lineTotalCents,
  });

  final String name;
  final int unitPriceCents;
  final int quantity;
  final int lineTotalCents;

  factory CatalogOrderLine.fromJson(Map<String, dynamic> json) {
    return CatalogOrderLine(
      name: (json['name'] as String?) ?? '',
      unitPriceCents: (json['unitPriceCents'] as num?)?.toInt() ?? 0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      lineTotalCents: (json['lineTotalCents'] as num?)?.toInt() ?? 0,
    );
  }
}

/// A seller's catalog purchase. Mirrors backend `CatalogOrderResponseDto`.
class CatalogOrder {
  const CatalogOrder({
    required this.id,
    required this.status,
    required this.totalCents,
    required this.currency,
    required this.createdAt,
    required this.paidAt,
    required this.items,
  });

  final String id;
  final String status; // PENDING | PAID | FAILED | CANCELLED | REFUNDED
  final int totalCents;
  final String currency;
  final DateTime createdAt;
  final DateTime? paidAt;
  final List<CatalogOrderLine> items;

  /// SAV claims are only eligible on a paid order within 14 days of payment.
  bool get isClaimEligible {
    if (status != 'PAID') return false;
    final start = paidAt ?? createdAt;
    return DateTime.now().difference(start).inDays <= 14;
  }

  factory CatalogOrder.fromJson(Map<String, dynamic> json) {
    return CatalogOrder(
      id: json['id'] as String,
      status: (json['status'] as String?) ?? 'PENDING',
      totalCents: (json['totalCents'] as num?)?.toInt() ?? 0,
      currency: (json['currency'] as String?) ?? 'usd',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      paidAt: json['paidAt'] != null ? DateTime.tryParse(json['paidAt'] as String) : null,
      items: ((json['items'] as List<dynamic>?) ?? const [])
          .map((e) => CatalogOrderLine.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// A seller's SAV (after-sales) claim. Mirrors backend `CatalogClaimResponseDto`.
class CatalogClaim {
  const CatalogClaim({
    required this.id,
    required this.catalogOrderId,
    required this.type,
    required this.status,
    required this.description,
    required this.createdAt,
    required this.refundAmountCents,
  });

  final String id;
  final String catalogOrderId;
  final String type; // NEVER_RECEIVED | DEFECTIVE | WRONG_ITEM
  // OPEN | ADMIN_REVIEW | REFUNDED | REPLACEMENT_REQUESTED | REJECTED | RESOLVED
  final String status;
  final String description;
  final DateTime createdAt;
  final int? refundAmountCents;

  factory CatalogClaim.fromJson(Map<String, dynamic> json) {
    return CatalogClaim(
      id: json['id'] as String,
      catalogOrderId: (json['catalogOrderId'] as String?) ?? '',
      type: (json['type'] as String?) ?? '',
      status: (json['status'] as String?) ?? 'OPEN',
      description: (json['description'] as String?) ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      refundAmountCents: (json['refundAmountCents'] as num?)?.toInt(),
    );
  }
}

/// Seller-facing catalog API (browse + purchase). All endpoints require the
/// SELLER role server-side, so buyers/public can't reach them.
class SupplyCatalogRepository {
  const SupplyCatalogRepository();

  static const String _base = '${ApiConstants.apiPrefix}/catalog';

  /// Active products available to buy.
  Future<List<CatalogItem>> listProducts() async {
    final res = await ApiClient.instance.get<List<CatalogItem>>(
      '$_base/products',
      decoder: (json) => (json! as List<dynamic>)
          .map((e) => CatalogItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
    return res.data;
  }

  /// Creates a PENDING order + PaymentIntent; returns the client secret.
  Future<CatalogCheckout> createOrder({
    required String productId,
    required int quantity,
  }) async {
    final res = await ApiClient.instance.post<CatalogCheckout>(
      '$_base/orders',
      body: {
        'items': [
          {'productId': productId, 'quantity': quantity},
        ],
      },
      decoder: (json) =>
          CatalogCheckout.fromJson(json! as Map<String, dynamic>),
    );
    return res.data;
  }

  /// Server-verified confirm after the card is confirmed in-app.
  Future<void> confirmPayment(String orderId) async {
    await ApiClient.instance.post<void>(
      '$_base/orders/$orderId/confirm-payment',
      decoder: (_) {},
    );
  }

  /// The seller's own catalog purchases, newest first.
  Future<List<CatalogOrder>> listMyOrders() async {
    final res = await ApiClient.instance.get<List<CatalogOrder>>(
      '$_base/orders',
      decoder: (json) => (json! as List<dynamic>)
          .map((e) => CatalogOrder.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
    return res.data;
  }

  /// The seller's own SAV claims (to show status next to orders).
  Future<List<CatalogClaim>> listMyClaims() async {
    final res = await ApiClient.instance.get<List<CatalogClaim>>(
      '$_base/claims',
      decoder: (json) => (json! as List<dynamic>)
          .map((e) => CatalogClaim.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
    return res.data;
  }

  /// Opens an after-sales (SAV) claim on a catalog order (within 14 days).
  Future<CatalogClaim> createClaim(
    String orderId, {
    required String type,
    required String description,
    List<String>? photoUrls,
  }) async {
    final res = await ApiClient.instance.post<CatalogClaim>(
      '$_base/orders/$orderId/claims',
      body: {
        'type': type,
        'description': description,
        if (photoUrls != null && photoUrls.isNotEmpty) 'photoUrls': photoUrls,
      },
      decoder: (json) => CatalogClaim.fromJson(json! as Map<String, dynamic>),
    );
    return res.data;
  }
}
