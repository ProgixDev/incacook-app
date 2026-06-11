import 'package:get/get.dart';

import 'package:incacook/core/constants/api_constants.dart';
import 'package:incacook/core/network/api_client.dart';
import 'package:incacook/features/wallet/data/wallet_models.dart';

/// Repository for the internal wallet API (`/v1/wallet/me`,
/// `/v1/wallet/me/withdraw`). All amounts are computed server-side.
class WalletRepository extends GetxService {
  WalletRepository({ApiClient? api}) : _api = api ?? Get.find<ApiClient>();

  static WalletRepository get instance => Get.find();

  final ApiClient _api;

  /// `GET /v1/wallet/me` — balance + recent ledger entries.
  Future<WalletSummary> getSummary() async {
    final res = await _api.get<WalletSummary>(
      '${ApiConstants.apiPrefix}/wallet/me',
      decoder: (json) =>
          WalletSummary.fromJson(json! as Map<String, dynamic>),
    );
    return res.data;
  }

  /// `POST /v1/wallet/me/withdraw` — withdraw the full available balance to the
  /// user's Connect account. Server rejects when balance < 50 € (the button is
  /// also gated client-side). Returns the new transfer id.
  Future<String> withdraw() async {
    final res = await _api.post<String>(
      '${ApiConstants.apiPrefix}/wallet/me/withdraw',
      body: const <String, dynamic>{},
      decoder: (json) =>
          (json! as Map<String, dynamic>)['transferId'] as String? ?? '',
    );
    return res.data;
  }
}
