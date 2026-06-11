import 'package:get/get.dart';

import 'package:incacook/core/constants/api_constants.dart';
import 'package:incacook/core/network/api_client.dart';

/// Repository for `POST /v1/reports` (user-submitted moderation reports).
class ReportsRepository extends GetxService {
  ReportsRepository({ApiClient? api}) : _api = api ?? Get.find<ApiClient>();

  final ApiClient _api;

  /// Files a report. [type] is the backend `ReportReason` string
  /// (`NON_FAIT_MAISON` | `MAUVAISE_HYGIENE` | `OTHER`). Provide a target:
  /// [listingId] (a dish) or [sellerId] (a seller). [reason] is an optional
  /// free-text comment.
  Future<void> submit({
    required String type,
    String? listingId,
    String? sellerId,
    String? reason,
  }) async {
    await _api.post<void>(
      '${ApiConstants.apiPrefix}/reports',
      body: {
        'type': type,
        'listingId': ?listingId,
        'sellerId': ?sellerId,
        if (reason != null && reason.trim().isNotEmpty) 'reason': reason.trim(),
      },
      decoder: (_) {},
    );
  }
}
