import 'package:get/get.dart';

import 'package:incacook/core/constants/api_constants.dart';
import 'package:incacook/core/network/api_client.dart';
import 'package:incacook/features/reviews/data/review.dart';

/// Repository for the reviews API (`/v1/orders/:id/review`,
/// `/v1/sellers/:id/reviews`). Reuses the shared [ApiClient].
class ReviewsRepository extends GetxService {
  ReviewsRepository({ApiClient? api}) : _api = api ?? Get.find<ApiClient>();

  static ReviewsRepository get instance => Get.find();

  final ApiClient _api;

  /// `POST /v1/orders/:orderId/review` — buyer reviews a DELIVERED order.
  /// One review per order (server 409s on a duplicate). Criteria are
  /// optional: [hygiene] is binary (0 or 100); [foodQuality]/[packaging]
  /// are 1–5. The server re-validates all of this.
  Future<void> submit({
    required String orderId,
    required int rating,
    required String body,
    int? hygiene,
    int? foodQuality,
    int? packaging,
  }) async {
    final criteria = <Map<String, dynamic>>[
      if (hygiene != null) {'criterion': 'HYGIENE', 'value': hygiene},
      if (foodQuality != null) {'criterion': 'FOOD_QUALITY', 'value': foodQuality},
      if (packaging != null) {'criterion': 'PACKAGING', 'value': packaging},
    ];
    await _api.post<void>(
      '${ApiConstants.apiPrefix}/orders/$orderId/review',
      body: {
        'rating': rating,
        'body': body,
        if (criteria.isNotEmpty) 'criteriaRatings': criteria,
      },
      decoder: (_) {},
    );
  }

  /// `GET /v1/sellers/:sellerId/reviews` — paginated, newest first.
  Future<List<Review>> listForSeller(
    String sellerId, {
    int limit = 20,
    int offset = 0,
  }) async {
    final result = await _api.get<List<Review>>(
      '${ApiConstants.apiPrefix}/sellers/$sellerId/reviews',
      queryParameters: {'limit': '$limit', 'offset': '$offset'},
      decoder: (json) => (json! as List<dynamic>)
          .map((e) => Review.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
    return result.data;
  }
}
