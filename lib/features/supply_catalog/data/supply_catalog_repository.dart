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
}
