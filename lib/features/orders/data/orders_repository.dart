import 'package:get/get.dart';

import 'package:incacook/core/constants/api_constants.dart';
import 'package:incacook/core/models/address.dart';
import 'package:incacook/core/models/cart_item.dart';
import 'package:incacook/core/models/fulfillment_options.dart';
import 'package:incacook/core/network/api_client.dart';
import 'package:incacook/core/services/map/models/map_route.dart';
import 'package:incacook/features/orders/data/buyer_order_detail.dart';
import 'package:incacook/features/orders/data/order_summary.dart';

/// Slim result of `POST /v1/orders`. The full response includes the
/// order + Stripe `paymentIntentClientSecret`; we only need the id +
/// status for the dev demo (Stripe is bypassed by NODE_ENV=development
/// on the server, which auto-confirms PENDING orders).
class CreateOrderResult {
  const CreateOrderResult({
    required this.id,
    required this.orderNumber,
    required this.status,
    this.paymentIntentClientSecret,
  });

  final String id;
  final String orderNumber;
  final String status;
  final String? paymentIntentClientSecret;
}

/// Identity of the assigned delivery driver, from the tracking endpoint.
/// Null until a driver claims the delivery — the buyer must never see a
/// driver before assignment.
class TrackingDriver {
  const TrackingDriver({
    required this.firstName,
    required this.lastName,
    this.avatarPath,
    this.phone,
    this.totalDeliveries = 0,
  });

  final String firstName;
  final String lastName;

  /// Storage path in `avatars/`; resolve with [ApiConstants.publicImageUrl].
  final String? avatarPath;
  final String? phone;

  /// Lifetime completed deliveries, shown to the buyer as the driver's
  /// experience. `0` is truthful for a driver on their first job.
  final int totalDeliveries;

  String get fullName => '$firstName $lastName'.trim();

  factory TrackingDriver.fromJson(Map<String, dynamic> m) => TrackingDriver(
        firstName: (m['firstName'] as String?) ?? '',
        lastName: (m['lastName'] as String?) ?? '',
        avatarPath: m['avatarPath'] as String?,
        phone: m['phone'] as String?,
        totalDeliveries: (m['totalDeliveries'] as num?)?.toInt() ?? 0,
      );
}

/// Map-tracking snapshot for an order (`GET /v1/orders/:id/tracking`).
/// The real pickup/dropoff/driver coordinates + statuses the buyer's
/// tracking map needs for its initial frame and route leg. Live driver
/// movement after this arrives over the `/tracking` socket.
class OrderTrackingSnapshot {
  const OrderTrackingSnapshot({
    required this.orderStatus,
    this.cancellationReason,
    this.fulfillmentChoice = 'DELIVERY',
    this.deliveryStatus,
    this.deliveryId,
    this.pickup,
    this.dropoff,
    this.driver,
    this.driverInfo,
  });

  /// Backend `OrderStatus` string (PENDING … READY … IN_DELIVERY …).
  final String orderStatus;

  /// Reason an order was cancelled (e.g. `seller_unavailable`), or null.
  final String? cancellationReason;

  /// `DELIVERY` | `PICKUP`.
  final String fulfillmentChoice;
  bool get isPickup => fulfillmentChoice == 'PICKUP';
  final String? deliveryStatus;
  final String? deliveryId;

  /// Seller pickup location (null if not geocoded).
  final MapPoint? pickup;

  /// Client dropoff location (null if not geocoded).
  final MapPoint? dropoff;

  /// Assigned driver's last-known point (null until a driver is assigned
  /// and has pushed a fix).
  final MapPoint? driver;

  /// Assigned driver's identity (null until a driver claims the delivery —
  /// present as soon as assigned, even before the first location fix).
  final TrackingDriver? driverInfo;

  factory OrderTrackingSnapshot.fromJson(Map<String, dynamic> json) {
    MapPoint? toPoint(dynamic raw) {
      if (raw == null) return null;
      final m = raw as Map<String, dynamic>;
      return MapPoint(
        lat: (m['lat'] as num).toDouble(),
        lng: (m['lng'] as num).toDouble(),
      );
    }

    final di = json['driverInfo'];
    return OrderTrackingSnapshot(
      orderStatus: json['orderStatus'] as String,
      cancellationReason: json['cancellationReason'] as String?,
      fulfillmentChoice: json['fulfillmentChoice'] as String? ?? 'DELIVERY',
      deliveryStatus: json['deliveryStatus'] as String?,
      deliveryId: json['deliveryId'] as String?,
      pickup: toPoint(json['pickup']),
      dropoff: toPoint(json['dropoff']),
      driver: toPoint(json['driver']),
      driverInfo: di == null
          ? null
          : TrackingDriver.fromJson(di as Map<String, dynamic>),
    );
  }
}

/// Reception-proof QR payload for a buyer's IN_DELIVERY order
/// (`GET /v1/orders/:id/delivery-qr`).
class BuyerDeliveryQr {
  const BuyerDeliveryQr({
    required this.orderId,
    required this.deliveryId,
    required this.deliveryToken,
    required this.qrData,
  });

  final String orderId;
  final String deliveryId;
  final String deliveryToken;

  /// The string to encode in the QR the buyer displays.
  final String qrData;

  factory BuyerDeliveryQr.fromJson(Map<String, dynamic> json) {
    return BuyerDeliveryQr(
      orderId: json['orderId'] as String? ?? '',
      deliveryId: json['deliveryId'] as String? ?? '',
      deliveryToken: json['deliveryToken'] as String? ?? '',
      qrData: json['qrData'] as String? ?? '',
    );
  }
}

/// Delivery completion proof for an order (`GET /v1/orders/:id/delivery-proof`).
/// When [deliveredAsAbsent] is true the order was left at the door with a
/// [photoUrl] (a storage path — resolve via [ApiConstants.publicImageUrl]) +
/// GPS + [takenAt]; for a normal QR delivery those fields are null.
class DeliveryProof {
  const DeliveryProof({
    required this.orderId,
    required this.deliveryId,
    required this.deliveredAsAbsent,
    required this.status,
    this.deliveredAt,
    this.photoUrl,
    this.lat,
    this.lng,
    this.takenAt,
    this.note,
    this.contactAttemptedAt,
  });

  final String orderId;
  final String deliveryId;
  final bool deliveredAsAbsent;
  final String status;
  final DateTime? deliveredAt;
  final String? photoUrl;
  final double? lat;
  final double? lng;
  final DateTime? takenAt;
  final String? note;
  final DateTime? contactAttemptedAt;

  /// True only when there's an actual absent-dropoff photo to show.
  bool get hasAbsentPhoto =>
      deliveredAsAbsent && photoUrl != null && photoUrl!.isNotEmpty;

  factory DeliveryProof.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic v) =>
        v is String && v.isNotEmpty ? DateTime.tryParse(v) : null;
    return DeliveryProof(
      orderId: json['orderId'] as String? ?? '',
      deliveryId: json['deliveryId'] as String? ?? '',
      deliveredAsAbsent: json['deliveredAsAbsent'] as bool? ?? false,
      status: json['status'] as String? ?? '',
      deliveredAt: parseDate(json['deliveredAt']),
      photoUrl: json['photoUrl'] as String?,
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
      takenAt: parseDate(json['takenAt']),
      note: json['note'] as String?,
      contactAttemptedAt: parseDate(json['contactAttemptedAt']),
    );
  }
}

/// Repository for buyer-side `/v1/orders/*` endpoints.
class OrdersRepository extends GetxService {
  OrdersRepository({ApiClient? api}) : _api = api ?? Get.find<ApiClient>();

  static OrdersRepository get instance => Get.find();

  final ApiClient _api;

  /// `POST /v1/orders` — places an order. The buyer is resolved from
  /// the JWT. Server returns the created order + a Stripe PaymentIntent
  /// client secret; in dev mode (NODE_ENV=development on the server)
  /// the order is auto-confirmed and the seller sees it immediately.
  Future<CreateOrderResult> createOrder({
    required List<CartItem> items,
    required FulfillmentChoice fulfillmentChoice,
    Address? dropoffAddress,
    String? dropoffAddressId,
    String? deliveryInstructions,
    DateTime? scheduledAt,
    String? note,
    bool termsAccepted = false,
  }) async {
    assert(
      (dropoffAddress == null) != (dropoffAddressId == null) ||
          fulfillmentChoice == FulfillmentChoice.pickup,
      'Provide exactly one of dropoffAddress or dropoffAddressId for delivery',
    );

    final body = <String, dynamic>{
      'items': items
          .map<Map<String, dynamic>>((i) => {
                'listingId': i.listing.id,
                'quantity': i.quantity,
                'addOnIds': i.selectedAddOns.isEmpty
                    ? null
                    : i.selectedAddOns.map((a) => a.id).toList(),
                'note': i.note,
              }..removeWhere((_, v) => v == null))
          .toList(),
      'fulfillmentChoice': fulfillmentChoice == FulfillmentChoice.delivery
          ? 'DELIVERY'
          : 'PICKUP',
      'dropoffAddressId': ?dropoffAddressId,
      'dropoffAddress': dropoffAddress == null ? null : _addressJson(dropoffAddress),
      'deliveryInstructions': ?deliveryInstructions,
      'deliveryTiming': scheduledAt == null ? 'ASAP' : 'SCHEDULED',
      'scheduledAt': scheduledAt?.toIso8601String(),
      'note': ?note,
      'termsAccepted': termsAccepted,
    }..removeWhere((_, v) => v == null);

    final result = await _api.post<CreateOrderResult>(
      '${ApiConstants.apiPrefix}/orders',
      body: body,
      requiresIdempotencyKey: true,
      decoder: (json) {
        final map = json! as Map<String, dynamic>;
        final order = map['order'] as Map<String, dynamic>;
        return CreateOrderResult(
          id: order['id'] as String,
          orderNumber: order['orderNumber'] as String,
          status: order['status'] as String,
          paymentIntentClientSecret:
              map['paymentIntentClientSecret'] as String?,
        );
      },
    );
    return result.data;
  }

  /// `POST /v1/orders/:id/confirm-pickup` — buyer or seller marks a
  /// PICKUP order as delivered. The backend then broadcasts
  /// `order:status = DELIVERED` over the tracking socket, which triggers
  /// the completion popup on the tracking screen.
  Future<void> confirmPickup(String orderId) async {
    await _api.post<void>(
      '${ApiConstants.apiPrefix}/orders/$orderId/confirm-pickup',
      decoder: (_) {},
    );
  }

  /// `POST /v1/orders/:id/confirm-payment` — tell the backend the card
  /// charge succeeded. The server re-verifies the PaymentIntent with
  /// Stripe and, only then, advances the order PENDING → CONFIRMED so it
  /// reaches the seller. Safe to call more than once (idempotent).
  Future<void> confirmPayment(String orderId) async {
    await _api.post<void>(
      '${ApiConstants.apiPrefix}/orders/$orderId/confirm-payment',
      decoder: (_) {},
    );
  }

  /// `GET /v1/orders/me` — the buyer's own orders, newest first. Backs the
  /// profile "Mes commandes" history screen.
  Future<List<OrderSummary>> listMyOrders({int limit = 50, int offset = 0}) async {
    final result = await _api.get<List<OrderSummary>>(
      '${ApiConstants.apiPrefix}/orders/me',
      queryParameters: {'limit': '$limit', 'offset': '$offset'},
      decoder: (json) => (json! as List<dynamic>)
          .map((e) => OrderSummary.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
    return result.data;
  }

  /// `GET /v1/sellers/me/orders` — the seller's own orders, newest first.
  /// Backs the seller profile "Mes commandes" screen (with paid badges).
  Future<List<OrderSummary>> listSellerOrders({
    int limit = 50,
    int offset = 0,
  }) async {
    final result = await _api.get<List<OrderSummary>>(
      '${ApiConstants.apiPrefix}/sellers/me/orders',
      queryParameters: {'limit': '$limit', 'offset': '$offset'},
      decoder: (json) => (json! as List<dynamic>)
          .map((e) => OrderSummary.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
    return result.data;
  }

  /// `GET /v1/orders/:id` — the caller's full order (items, add-ons, price
  /// breakdown, delivery address). Backs the buyer order-detail screen.
  /// Throws [ApiFailure] if the order isn't the caller's.
  Future<BuyerOrderDetail> getOrderDetail(String orderId) async {
    final result = await _api.get<BuyerOrderDetail>(
      '${ApiConstants.apiPrefix}/orders/$orderId',
      decoder: (json) =>
          BuyerOrderDetail.fromJson(json! as Map<String, dynamic>),
    );
    return result.data;
  }

  /// `GET /v1/orders/:id/tracking` — real pickup/dropoff/driver
  /// coordinates + statuses for the tracking map's initial frame. Live
  /// driver movement afterwards streams over the `/tracking` socket.
  Future<OrderTrackingSnapshot> getTracking(String orderId) async {
    final result = await _api.get<OrderTrackingSnapshot>(
      '${ApiConstants.apiPrefix}/orders/$orderId/tracking',
      decoder: (json) =>
          OrderTrackingSnapshot.fromJson(json! as Map<String, dynamic>),
    );
    return result.data;
  }

  /// `GET /v1/orders/:id/delivery-qr` — the buyer→driver reception proof QR
  /// for an IN_DELIVERY order. The buyer renders [BuyerDeliveryQr.qrData] and
  /// the assigned driver scans it to confirm delivery. Throws [ApiFailure] if
  /// the order isn't in delivery / not the caller's.
  Future<BuyerDeliveryQr> fetchDeliveryQr(String orderId) async {
    final result = await _api.get<BuyerDeliveryQr>(
      '${ApiConstants.apiPrefix}/orders/$orderId/delivery-qr',
      decoder: (json) => BuyerDeliveryQr.fromJson(json! as Map<String, dynamic>),
    );
    return result.data;
  }

  /// `POST /v1/orders/:id/no-driver-decision` — buyer's choice when no driver
  /// accepted the delivery (order is NO_DRIVER_AVAILABLE). [decision] is
  /// `SWITCH_TO_PICKUP` or `CANCEL_AND_REFUND`. Throws [ApiFailure] if not
  /// allowed (e.g. not the buyer, or no decision pending).
  Future<void> noDriverDecision(String orderId, String decision) async {
    await _api.post<void>(
      '${ApiConstants.apiPrefix}/orders/$orderId/no-driver-decision',
      body: {'decision': decision},
      decoder: (_) {},
    );
  }

  /// `POST /v1/orders/:id/disputes` — buyer post-delivery claim. Returns the
  /// backend's buyer-facing [message] (auto-refunded / under review / no refund).
  /// Throws [ApiFailure] on a rejected request (wrong buyer, duplicate, missing
  /// proof, window elapsed).
  Future<String> createDispute(
    String orderId, {
    required String type,
    String? description,
    List<String>? photoUrls,
    List<String>? proofFileUrls,
  }) async {
    final result = await _api.post<String>(
      '${ApiConstants.apiPrefix}/orders/$orderId/disputes',
      body: {
        'type': type,
        'description': ?description,
        'photoUrls': ?photoUrls,
        'proofFileUrls': ?proofFileUrls,
      },
      decoder: (json) {
        final map = json as Map<String, dynamic>?;
        return (map?['message'] as String?) ?? 'Votre signalement a bien été enregistré.';
      },
    );
    return result.data;
  }

  /// `GET /v1/orders/:id/delivery-proof` — delivery completion proof (buyer or
  /// seller of the order only). Used to show the client-absent photo + GPS +
  /// timestamp on a delivered order. Throws [ApiFailure] if not the caller's.
  Future<DeliveryProof> fetchDeliveryProof(String orderId) async {
    final result = await _api.get<DeliveryProof>(
      '${ApiConstants.apiPrefix}/orders/$orderId/delivery-proof',
      decoder: (json) => DeliveryProof.fromJson(json! as Map<String, dynamic>),
    );
    return result.data;
  }

  static Map<String, dynamic> _addressJson(Address a) {
    return <String, dynamic>{
      'fullAddress': a.fullAddress,
      'city': a.city,
      'postalCode': a.postalCode,
      'type': ?a.type?.name.toUpperCase(),
      'customLabel': ?a.customLabel,
      'apartment': ?a.apartment,
      'floor': ?a.floor,
      'digicode': ?a.digicode,
      'deliveryNotes': ?a.deliveryNotes,
      'lat': ?a.coordinate?.lat,
      'lng': ?a.coordinate?.lng,
    }..removeWhere((_, v) => v == null);
  }
}
