import 'package:get/get.dart';

import 'package:incacook/core/constants/api_constants.dart';
import 'package:incacook/core/network/api_client.dart';

/// One row in the driver's "available deliveries" list. Carries the
/// real data the incoming-order modal renders + the geo points the
/// map route needs (so we don't have to fall back to mocks once a
/// real delivery is dispatched).
class DeliverySummary {
  const DeliverySummary({
    required this.id,
    required this.orderId,
    required this.orderNumber,
    required this.feeCents,
    required this.dropoffCity,
    required this.dropoffPostalCode,
    this.sellerNeighborhood,
    this.sellerName,
    this.recipientName,
    this.pickupLat,
    this.pickupLng,
    this.pickupFullAddress,
    this.dropoffLat,
    this.dropoffLng,
    this.dropoffFullAddress,
    this.orderTotalCents,
    this.placedAt,
    this.itemCount,
  });

  final String id;
  final String orderId;
  final String orderNumber;
  final int feeCents;
  final String dropoffCity;
  final String dropoffPostalCode;
  final String? sellerNeighborhood;

  /// Enrichment (server populates on `available` listing only).
  final String? sellerName;

  /// Buyer's display name — who the driver hands the food to at dropoff.
  final String? recipientName;
  final double? pickupLat;
  final double? pickupLng;
  final String? pickupFullAddress;
  final double? dropoffLat;
  final double? dropoffLng;
  final String? dropoffFullAddress;
  final int? orderTotalCents;
  final DateTime? placedAt;
  final int? itemCount;

  double get feeEuros => feeCents / 100.0;
  double? get totalEuros => orderTotalCents == null ? null : orderTotalCents! / 100.0;

  factory DeliverySummary.fromJson(Map<String, dynamic> json) {
    return DeliverySummary(
      id: json['id'] as String,
      orderId: json['orderId'] as String,
      orderNumber: json['orderNumber'] as String? ?? '',
      feeCents: (json['driverPayoutCents'] as num?)?.toInt() ?? 0,
      dropoffCity: json['dropoffCity'] as String? ?? '',
      dropoffPostalCode: json['dropoffPostalCode'] as String? ?? '',
      sellerNeighborhood: json['pickupNeighborhood'] as String?,
      sellerName: json['sellerName'] as String?,
      recipientName: json['recipientName'] as String?,
      pickupLat: (json['pickupLat'] as num?)?.toDouble(),
      pickupLng: (json['pickupLng'] as num?)?.toDouble(),
      pickupFullAddress: json['pickupFullAddress'] as String?,
      dropoffLat: (json['dropoffLat'] as num?)?.toDouble(),
      dropoffLng: (json['dropoffLng'] as num?)?.toDouble(),
      dropoffFullAddress: json['dropoffFullAddress'] as String?,
      orderTotalCents: (json['orderTotalCents'] as num?)?.toInt(),
      placedAt: json['placedAt'] != null
          ? DateTime.tryParse(json['placedAt'] as String)
          : null,
      itemCount: (json['itemCount'] as num?)?.toInt(),
    );
  }
}

/// Repository for driver-side delivery endpoints under
/// `/v1/drivers/me/deliveries/*` plus the online toggle.
class DeliveriesRepository extends GetxService {
  DeliveriesRepository({ApiClient? api}) : _api = api ?? Get.find<ApiClient>();

  static DeliveriesRepository get instance => Get.find();

  final ApiClient _api;

  /// `POST /v1/drivers/me/online`. Optionally piggy-backs a position
  /// fix so the matching system has a starting point.
  Future<void> setOnline({
    required bool isOnline,
    double? lat,
    double? lng,
  }) async {
    await _api.post<void>(
      '${ApiConstants.apiPrefix}/drivers/me/online',
      body: {
        'isOnline': isOnline,
        'lat': ?lat,
        'lng': ?lng,
      },
      decoder: (_) {},
    );
  }

  /// `GET /v1/drivers/me/deliveries/available`. FIFO list of SEARCHING
  /// deliveries the driver can claim.
  Future<List<DeliverySummary>> listAvailable({int limit = 10, int offset = 0}) async {
    final result = await _api.get<List<DeliverySummary>>(
      '${ApiConstants.apiPrefix}/drivers/me/deliveries/available',
      queryParameters: {'limit': '$limit', 'offset': '$offset'},
      // TransformInterceptor on the server hoists `items` to top-level
      // `data` for paginated lists, so the decoder receives a List.
      decoder: (json) => (json! as List<dynamic>)
          .map((e) => DeliverySummary.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
    return result.data;
  }

  /// `POST /v1/drivers/me/deliveries/:id/claim`. Atomic — returns 409
  /// if another driver claimed it first.
  Future<void> claim(String deliveryId) async {
    await _api.post<void>(
      '${ApiConstants.apiPrefix}/drivers/me/deliveries/$deliveryId/claim',
      decoder: (_) {},
    );
  }

  /// `POST /v1/drivers/me/deliveries/:id/arrive-pickup`.
  /// ASSIGNED/EN_ROUTE_TO_PICKUP → AT_PICKUP.
  Future<void> arrivePickup(String deliveryId) async {
    await _api.post<void>(
      '${ApiConstants.apiPrefix}/drivers/me/deliveries/$deliveryId/arrive-pickup',
      decoder: (_) {},
    );
  }

  /// `POST /v1/drivers/me/deliveries/:id/confirm-pickup`.
  /// Driver scans the seller's pickup QR and submits its token (+ optional
  /// GPS). On success: PICKED_UP, Order → IN_DELIVERY. Throws [ApiFailure] on
  /// an invalid/duplicate scan so the caller can surface the message.
  Future<void> confirmPickup(
    String deliveryId, {
    required String pickupToken,
    double? lat,
    double? lng,
  }) async {
    await _api.post<void>(
      '${ApiConstants.apiPrefix}/drivers/me/deliveries/$deliveryId/confirm-pickup',
      body: {
        'pickupToken': pickupToken,
        'lat': ?lat,
        'lng': ?lng,
      },
      decoder: (_) {},
    );
  }

  /// `POST /v1/drivers/me/deliveries/:id/confirm-delivery`.
  /// Driver scans the buyer's reception QR and submits its token (+ optional
  /// GPS). On success: DELIVERED, Order → DELIVERED, triggers Stripe transfers.
  /// Throws [ApiFailure] on an invalid/duplicate scan so the caller can
  /// surface the message.
  Future<void> confirmDelivery(
    String deliveryId, {
    required String deliveryToken,
    double? lat,
    double? lng,
  }) async {
    await _api.post<void>(
      '${ApiConstants.apiPrefix}/drivers/me/deliveries/$deliveryId/confirm-delivery',
      body: {
        'deliveryToken': deliveryToken,
        'lat': ?lat,
        'lng': ?lng,
      },
      decoder: (_) {},
    );
  }

  /// `POST /v1/drivers/me/deliveries/:id/confirm-absent-dropoff`.
  /// Client-absent fallback: leaves the order at the door with a mandatory
  /// photo ([photoUrl] is the storage path from the upload flow) + GPS. On
  /// success: DELIVERED, Order → DELIVERED. Throws [ApiFailure] on a failed
  /// confirmation so the caller can surface the message.
  Future<void> confirmAbsentDropoff(
    String deliveryId, {
    required String photoUrl,
    required double lat,
    required double lng,
    String? note,
  }) async {
    await _api.post<void>(
      '${ApiConstants.apiPrefix}/drivers/me/deliveries/$deliveryId/confirm-absent-dropoff',
      body: {
        'photoUrl': photoUrl,
        'lat': lat,
        'lng': lng,
        'note': ?note,
      },
      decoder: (_) {},
    );
  }

  /// `POST /v1/drivers/me/deliveries/:id/report-seller-unavailable`.
  /// Driver arrived but the seller couldn't provide the order (absent / no
  /// food), before pickup. Cancels + refunds the order and compensates the
  /// driver. Throws [ApiFailure] on a rejected report.
  Future<void> reportSellerUnavailable(
    String deliveryId, {
    required String reason,
    required double lat,
    required double lng,
    String? note,
    String? photoUrl,
  }) async {
    await _api.post<void>(
      '${ApiConstants.apiPrefix}/drivers/me/deliveries/$deliveryId/report-seller-unavailable',
      body: {
        'reason': reason,
        'lat': lat,
        'lng': lng,
        'note': ?note,
        'photoUrl': ?photoUrl,
      },
      decoder: (_) {},
    );
  }
}
