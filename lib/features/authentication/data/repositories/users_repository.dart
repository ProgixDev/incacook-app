import 'package:get/get.dart';

import 'package:incacook/core/constants/api_constants.dart';
import 'package:incacook/core/models/auth/address_record.dart';
import 'package:incacook/core/models/auth/charter.dart';
import 'package:incacook/core/models/auth/onboarding_state.dart';
import 'package:incacook/core/models/auth/user.dart';
import 'package:incacook/core/network/api_client.dart';
import 'package:incacook/features/authentication/data/models/requests/accept_charter_request.dart';
import 'package:incacook/features/authentication/data/models/requests/complete_profile_request.dart';
import 'package:incacook/features/authentication/data/models/requests/upsert_address_request.dart';

/// Repository for `/v1/users/*` and `/v1/users/me/*`.
///
/// Gate 2 lives here (`completeProfile`), plus the per-concept
/// endpoints that aren't role-specific: address upsert, charter
/// acceptance, the user aggregate read, and the onboarding completeness
/// state — the keystone of cold-start resume.
class UsersRepository extends GetxService {
  UsersRepository({ApiClient? api}) : _api = api ?? Get.find<ApiClient>();

  static UsersRepository get instance => Get.find();

  final ApiClient _api;

  /// `POST /v1/users` (§3.3) — Gate 2. Idempotent on the user's JWT.
  /// Returns the created [User] aggregate (with the role-specific
  /// account stub already provisioned, empty).
  Future<User> completeProfile(CompleteProfileRequest req) async {
    final result = await _api.post<User>(
      '${ApiConstants.apiPrefix}/users',
      body: req.toJson(),
      requiresIdempotencyKey: true,
      decoder: (json) => User.fromJson(json! as Map<String, dynamic>),
    );
    return result.data;
  }

  /// `GET /v1/users/me` (§3.22) — the full aggregate, used for
  /// post-login routing and for refreshing the UI after a per-concept
  /// PUT lands.
  Future<User> getMe() async {
    final result = await _api.get<User>(
      '${ApiConstants.apiPrefix}/users/me',
      decoder: (json) => User.fromJson(json! as Map<String, dynamic>),
    );
    return result.data;
  }

  /// `GET /v1/users/me/onboarding` (§4.1) — the wizard's resume cursor.
  ///
  /// Called on cold-start (when tokens exist but the wizard has no
  /// in-memory progress) and after every role-specific PUT/POST (to
  /// confirm the step status flipped and learn the new `next`).
  Future<OnboardingState> fetchOnboarding() async {
    final result = await _api.get<OnboardingState>(
      '${ApiConstants.apiPrefix}/users/me/onboarding',
      decoder: (json) =>
          OnboardingState.fromJson(json! as Map<String, dynamic>),
    );
    return result.data;
  }

  /// `POST /v1/users/me/charters` (§3.11) — records the caller's
  /// acceptance of one charter version. Idempotent.
  Future<CharterAcceptance> acceptCharter(AcceptCharterRequest req) async {
    final result = await _api.post<CharterAcceptance>(
      '${ApiConstants.apiPrefix}/users/me/charters',
      body: req.toJson(),
      decoder: (json) =>
          CharterAcceptance.fromJson(json! as Map<String, dynamic>),
    );
    return result.data;
  }

  /// `PUT /v1/users/me/addresses/:kind` (§3.12) — upserts the address
  /// of the given kind for the current user. The role/kind pairing is
  /// enforced server-side.
  Future<AddressRecord> upsertAddress({
    required AddressKind kind,
    required UpsertAddressRequest req,
  }) async {
    final result = await _api.put<AddressRecord>(
      '${ApiConstants.apiPrefix}/users/me/addresses/${kind.wire}',
      body: req.toJson(),
      decoder: (json) => AddressRecord.fromJson(json! as Map<String, dynamic>),
    );
    return result.data;
  }
}
