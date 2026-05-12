import 'package:get/get.dart';

import 'package:incacook/core/constants/api_constants.dart';
import 'package:incacook/core/models/auth/buyer_account.dart';
import 'package:incacook/core/network/api_client.dart';
import 'package:incacook/features/authentication/data/models/requests/buyer_preferences_request.dart';

/// Repository for buyer-only endpoints under `/v1/buyers/me/*`.
class BuyersRepository extends GetxService {
  BuyersRepository({ApiClient? api}) : _api = api ?? Get.find<ApiClient>();

  static BuyersRepository get instance => Get.find();

  final ApiClient _api;

  /// `PUT /v1/buyers/me/preferences` (§3.13). The buyer's dietary tags
  /// and allergens are replaced wholesale in one call; either array may
  /// be empty (the wizard's preferences step is user-skippable).
  Future<BuyerAccount> setPreferences(BuyerPreferencesRequest req) async {
    final result = await _api.put<BuyerAccount>(
      '${ApiConstants.apiPrefix}/buyers/me/preferences',
      body: req.toJson(),
      decoder: (json) => BuyerAccount.fromJson(json! as Map<String, dynamic>),
    );
    return result.data;
  }
}
