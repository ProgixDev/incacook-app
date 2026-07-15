import 'package:get/get.dart';

import 'package:incacook/core/constants/api_constants.dart';
import 'package:incacook/core/network/api_client.dart';

/// One line in a seller's order — name + quantity + unit price are
/// the only fields the home-screen request card displays today.
class SellerOrderItem {
  const SellerOrderItem({
    required this.listingName,
    required this.quantity,
    required this.unitPriceCents,
    this.note,
  });

  final String listingName;
  final int quantity;
  final int unitPriceCents;
  final String? note;

  double get unitPriceEuros => unitPriceCents / 100.0;

  factory SellerOrderItem.fromJson(Map<String, dynamic> json) {
    return SellerOrderItem(
      listingName: json['listingName'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      unitPriceCents: (json['unitPriceCents'] as num?)?.toInt() ?? 0,
      note: json['note'] as String?,
    );
  }
}

/// One row in the seller's incoming-orders dashboard. Carries the
/// fields the home request card + the Commandes list card need.
class SellerOrderSummary {
  const SellerOrderSummary({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.buyerTotalCents,
    required this.sellerEarningsCents,
    required this.placedAt,
    required this.fulfillmentChoice,
    required this.items,
    this.driverAssigned = false,
    this.note,
    this.cancellationReason,
  });

  final String id;
  final String orderNumber;

  /// Backend [OrderStatus] string: `PENDING | CONFIRMED | PREPARING |
  /// READY | IN_DELIVERY | DELIVERED | COMPLETED | CANCELLED |
  /// REFUNDED | DISPUTED`.
  final String status;

  final int buyerTotalCents;
  final int sellerEarningsCents;
  final DateTime placedAt;

  /// `DELIVERY` or `PICKUP`.
  final String fulfillmentChoice;

  /// Whether a driver currently holds this order's delivery.
  ///
  /// [status] can't answer this: `READY` is entered when the seller marks the
  /// food ready — which spawns the delivery with no driver — and stays `READY`
  /// after a driver claims it. So every delivery order spends real time
  /// READY-with-no-driver, and driver-directed CTAs gate on this instead.
  /// Always false for `PICKUP` orders.
  final bool driverAssigned;

  final List<SellerOrderItem> items;

  /// Buyer's order-level note (separate from per-item notes).
  final String? note;

  /// Reason an order was cancelled (e.g. `seller_unavailable`), or null.
  final String? cancellationReason;

  double get totalEuros => buyerTotalCents / 100.0;

  factory SellerOrderSummary.fromJson(Map<String, dynamic> json) {
    final rawItems =
        (json['items'] as List?)?.cast<dynamic>() ?? const <dynamic>[];
    return SellerOrderSummary(
      id: json['id'] as String,
      orderNumber: json['orderNumber'] as String,
      status: json['status'] as String,
      buyerTotalCents: (json['buyerTotalCents'] as num).toInt(),
      sellerEarningsCents:
          (json['sellerEarningsCents'] as num?)?.toInt() ??
          (json['buyerTotalCents'] as num).toInt(),
      placedAt: DateTime.parse(json['placedAt'] as String),
      fulfillmentChoice: json['fulfillmentChoice'] as String,
      driverAssigned: json['driverAssigned'] as bool? ?? false,
      note: json['note'] as String?,
      cancellationReason: json['cancellationReason'] as String?,
      items: rawItems
          .map((e) => SellerOrderItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Repository for seller-side `/v1/sellers/me/*` and the seller's
/// half of the order lifecycle on `/v1/orders/:id/*`.
class SellerOrdersRepository extends GetxService {
  SellerOrdersRepository({ApiClient? api})
    : _api = api ?? Get.find<ApiClient>();

  static SellerOrdersRepository get instance => Get.find();

  final ApiClient _api;

  /// `GET /v1/sellers/me/orders` — list of orders for the seller
  /// resolved from the JWT. Newest first. Pass [status] (backend
  /// OrderStatus enum string, e.g. `CONFIRMED`) to filter server-side.
  Future<List<SellerOrderSummary>> listIncoming({
    int limit = 50,
    int offset = 0,
    String? status,
  }) async {
    final result = await _api.get<List<SellerOrderSummary>>(
      '${ApiConstants.apiPrefix}/sellers/me/orders',
      queryParameters: {
        'limit': '$limit',
        'offset': '$offset',
        'status': ?status,
      },
      // The backend's TransformInterceptor hoists `items` into top-level
      // `data` whenever it detects pagination, so the decoder receives
      // a List directly (matching ListingsRepository.getFeed shape).
      decoder: (json) => (json! as List<dynamic>)
          .map((e) => SellerOrderSummary.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
    return result.data;
  }

  /// `POST /v1/orders/:id/cancel` — seller refuses a CONFIRMED order.
  /// [reason] must be 3-500 chars (server-validated). Refunds the
  /// buyer's PaymentIntent and restores the inventory we decremented
  /// at order creation.
  Future<void> cancel(String orderId, {required String reason}) async {
    await _api.post<void>(
      '${ApiConstants.apiPrefix}/orders/$orderId/cancel',
      body: {'reason': reason},
      decoder: (_) {},
    );
  }

  /// `POST /v1/sellers/me/orders/:id/cannot-provide` — seller proactively
  /// cancels an order they can't fulfil (before pickup). Refunds the buyer,
  /// cancels any delivery, and adds a light seller strike. Throws [ApiFailure]
  /// if not allowed (wrong seller, pickup confirmed, already resolved).
  Future<void> cannotProvide(String orderId, {String? note}) async {
    await _api.post<void>(
      '${ApiConstants.apiPrefix}/sellers/me/orders/$orderId/cannot-provide',
      body: {'note': ?note},
      decoder: (_) {},
    );
  }

  /// `POST /v1/orders/:id/start-preparing` — CONFIRMED → PREPARING.
  Future<void> startPreparing(String orderId) async {
    await _api.post<void>(
      '${ApiConstants.apiPrefix}/orders/$orderId/start-preparing',
      decoder: (_) {},
    );
  }

  /// `POST /v1/orders/:id/mark-ready` — PREPARING → READY. For
  /// delivery orders, the server creates a `Delivery` row with status
  /// SEARCHING at this point so drivers can claim it.
  Future<void> markReady(String orderId) async {
    await _api.post<void>(
      '${ApiConstants.apiPrefix}/orders/$orderId/mark-ready',
      decoder: (_) {},
    );
  }

  /// `GET /v1/sellers/me/orders/:orderId/pickup-qr` — the pickup-proof QR the
  /// seller shows to the assigned driver. Throws [ApiFailure] if the order
  /// isn't ready / not the caller's.
  Future<SellerPickupQr> fetchPickupQr(String orderId) async {
    final result = await _api.get<SellerPickupQr>(
      '${ApiConstants.apiPrefix}/sellers/me/orders/$orderId/pickup-qr',
      decoder: (json) => SellerPickupQr.fromJson(json! as Map<String, dynamic>),
    );
    return result.data;
  }
}

/// Pickup-proof QR payload for a seller's delivery order.
class SellerPickupQr {
  const SellerPickupQr({
    required this.orderId,
    required this.deliveryId,
    required this.pickupToken,
    required this.qrData,
  });

  final String orderId;
  final String deliveryId;
  final String pickupToken;

  /// The string to encode in the QR the seller displays.
  final String qrData;

  factory SellerPickupQr.fromJson(Map<String, dynamic> json) {
    return SellerPickupQr(
      orderId: json['orderId'] as String? ?? '',
      deliveryId: json['deliveryId'] as String? ?? '',
      pickupToken: json['pickupToken'] as String? ?? '',
      qrData: json['qrData'] as String? ?? '',
    );
  }
}
