import 'package:get/get.dart';

import 'package:incacook/core/constants/api_constants.dart';
import 'package:incacook/core/models/auth/charter.dart';
import 'package:incacook/core/network/api_client.dart';

/// Repository for `/v1/charters/*` — the versioned-acceptance system
/// for CGU / CGV / HYGIENE / FAIT_MAISON / PUNCTUALITY / CARE.
///
/// Bumping a charter version invalidates existing acceptances (keyed
/// on `(userId, charter, version)`), so the wizard fetches the active
/// versions just before showing each charter screen and posts the
/// version back via `UsersRepository.acceptCharter`.
class ChartersRepository extends GetxService {
  ChartersRepository({ApiClient? api}) : _api = api ?? Get.find<ApiClient>();

  static ChartersRepository get instance => Get.find();

  final ApiClient _api;

  /// `GET /v1/charters/active` (§3.10) — public. Returns the current
  /// version of each charter.
  Future<ActiveCharters> getActive() async {
    final result = await _api.get<ActiveCharters>(
      '${ApiConstants.apiPrefix}/charters/active',
      decoder: (json) => ActiveCharters.fromJson(json! as Map<String, dynamic>),
    );
    return result.data;
  }
}
