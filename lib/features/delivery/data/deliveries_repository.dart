import 'package:get/get.dart';

import 'package:incacook/core/constants/api_constants.dart';
import 'package:incacook/core/enums/order_stage.dart';
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
    this.status,
  });

  final String id;
  final String orderId;
  final String orderNumber;

  /// Backend [DeliveryStatus] string (e.g. `ASSIGNED`, `PICKED_UP`). Null on
  /// the available-list rows (all `SEARCHING`); populated by `listMine`, where
  /// it drives active-job restoration on relaunch. See [restoredStage].
  final String? status;
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

  /// Backend delivery statuses that mean "a job is in progress" — the ones we
  /// restore on relaunch. Terminal (DELIVERED/CANCELLED/FAILED) and pre-claim
  /// (UNASSIGNED/SEARCHING) states are excluded.
  static const Set<String> activeStatuses = {
    'ASSIGNED',
    'EN_ROUTE_TO_PICKUP',
    'AT_PICKUP',
    'PICKED_UP',
    'EN_ROUTE_TO_DROPOFF',
    'AT_DROPOFF',
  };

  bool get isActive => status != null && activeStatuses.contains(status);

  /// Maps the backend [DeliveryStatus] onto the driver-app [OrderStage] used by
  /// the lifecycle card / route controller. Null for non-active statuses.
  OrderStage? get restoredStage {
    switch (status) {
      case 'ASSIGNED':
      case 'EN_ROUTE_TO_PICKUP':
        return OrderStage.prepared;
      case 'AT_PICKUP':
        return OrderStage.arrivedPickup;
      case 'PICKED_UP':
      case 'EN_ROUTE_TO_DROPOFF':
        return OrderStage.onTheWay;
      case 'AT_DROPOFF':
        return OrderStage.arrivedDropoff;
      default:
        return null;
    }
  }

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
      status: json['status'] as String?,
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

  /// `GET /v1/drivers/me/deliveries`. The driver's own deliveries (active +
  /// history), newest first. Carries `status` + the geo enrichment, so it can
  /// restore an in-progress job's map/route after an app relaunch.
  Future<List<DeliverySummary>> listMine({int limit = 20, int offset = 0}) async {
    final result = await _api.get<List<DeliverySummary>>(
      '${ApiConstants.apiPrefix}/drivers/me/deliveries',
      queryParameters: {'limit': '$limit', 'offset': '$offset'},
      // Same TransformInterceptor list-hoisting as listAvailable.
      decoder: (json) => (json! as List<dynamic>)
          .map((e) => DeliverySummary.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
    return result.data;
  }

  /// The driver's current in-progress delivery, if any — the newest row whose
  /// status is still active. Null when the driver has no active job. Used on
  /// relaunch to resume the delivery the app was killed mid-way through.
  Future<DeliverySummary?> activeMine() async {
    final list = await listMine();
    for (final d in list) {
      if (d.isActive) return d;
    }
    return null;
  }

  /// `GET /v1/drivers/me/stats/today`. Today's completed-delivery count and
  /// summed payout (earnings, in cents). Online-time is not server-tracked —
  /// the driver dashboard measures it on the device.
  Future<({int earningsCents, int deliveriesCount})> todayStats() async {
    final result = await _api.get<({int earningsCents, int deliveriesCount})>(
      '${ApiConstants.apiPrefix}/drivers/me/stats/today',
      decoder: (json) {
        final m = json! as Map<String, dynamic>;
        return (
          earningsCents: (m['earningsCents'] as num?)?.toInt() ?? 0,
          deliveriesCount: (m['deliveriesCount'] as num?)?.toInt() ?? 0,
        );
      },
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
