import 'package:get/get.dart';

import 'package:incacook/core/constants/api_constants.dart';
import 'package:incacook/core/network/api_client.dart';

/// Repository for the authenticated device-token endpoints
/// (`/v1/device-tokens`). Reuses the shared [ApiClient] so the bearer
/// token + envelope handling are identical to every other call.
class DeviceTokensRepository extends GetxService {
  DeviceTokensRepository({ApiClient? api}) : _api = api ?? Get.find<ApiClient>();

  static DeviceTokensRepository get instance => Get.find();

  final ApiClient _api;

  /// `POST /v1/device-tokens` — register/refresh this device's FCM token.
  /// Backend upserts on the unique token, so calling it repeatedly is safe.
  Future<void> register({
    required String token,
    required String platform,
  }) async {
    await _api.post<void>(
      '${ApiConstants.apiPrefix}/device-tokens',
      body: {'token': token, 'platform': platform},
      decoder: (_) {},
    );
  }

  /// `DELETE /v1/device-tokens` — unregister this device's token (logout).
  Future<void> unregister({required String token}) async {
    await _api.delete<void>(
      '${ApiConstants.apiPrefix}/device-tokens',
      body: {'token': token},
      decoder: (_) {},
    );
  }
}
