import 'package:freezed_annotation/freezed_annotation.dart';

part 'password_update_request.freezed.dart';
part 'password_update_request.g.dart';

/// Body of `POST /v1/auth/password/update`.
///
/// Authenticated — the bearer is either the normal session access token
/// (in-app password change) or the recovery access token recovered from
/// the `incacook://auth/recover` deep link fragment.
@freezed
abstract class PasswordUpdateRequest with _$PasswordUpdateRequest {
  const factory PasswordUpdateRequest({required String newPassword}) =
      _PasswordUpdateRequest;

  factory PasswordUpdateRequest.fromJson(Map<String, dynamic> json) =>
      _$PasswordUpdateRequestFromJson(json);
}
