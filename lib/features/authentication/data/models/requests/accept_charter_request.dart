import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:incacook/core/models/auth/charter.dart';

part 'accept_charter_request.freezed.dart';
part 'accept_charter_request.g.dart';

/// Body of `POST /v1/users/me/charters` (§3.11). Idempotent on
/// `(userId, charter, version)`.
@freezed
abstract class AcceptCharterRequest with _$AcceptCharterRequest {
  const factory AcceptCharterRequest({
    required Charter charter,
    required String version,
  }) = _AcceptCharterRequest;

  factory AcceptCharterRequest.fromJson(Map<String, dynamic> json) =>
      _$AcceptCharterRequestFromJson(json);
}
