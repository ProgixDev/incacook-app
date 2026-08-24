import 'package:get/get.dart';

import 'package:incacook/core/constants/api_constants.dart';
import 'package:incacook/core/network/api_client.dart';

/// Repository for `POST /v1/reports` (user-submitted moderation reports).
class ReportsRepository extends GetxService {
  ReportsRepository({ApiClient? api}) : _api = api ?? Get.find<ApiClient>();

  final ApiClient _api;

  /// Files a report. [type] is the backend `ReportReason` string
  /// (`NON_FAIT_MAISON` | `MAUVAISE_HYGIENE` | `SPAM` | `INAPPROPRIATE` |
  /// `OFFENSIVE` | `FAKE` | `DUPLICATE` | `OTHER`). Provide exactly one
  /// target: [listingId] (a dish), [sellerId] (a seller), [messageId] (a
  /// chat message — #54), or [userId] (a user — #54). [reason] is an
  /// optional free-text comment.
  Future<void> submit({
    required String type,
    String? listingId,
    String? sellerId,
    String? messageId,
    String? userId,
    String? reason,
  }) async {
    await _api.post<void>(
      '${ApiConstants.apiPrefix}/reports',
      body: {
        'type': type,
        'listingId': ?listingId,
        'sellerId': ?sellerId,
        'messageId': ?messageId,
        'userId': ?userId,
        if (reason != null && reason.trim().isNotEmpty) 'reason': reason.trim(),
      },
      decoder: (_) {},
    );
  }
}
