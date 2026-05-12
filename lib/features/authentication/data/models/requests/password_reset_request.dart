import 'package:freezed_annotation/freezed_annotation.dart';

part 'password_reset_request.freezed.dart';
part 'password_reset_request.g.dart';

/// Body of `POST /v1/auth/password/reset-request`.
///
/// Triggers Supabase to email a magic link to [email]. If [redirectTo] is
/// provided, Supabase appends recovery tokens as a URL fragment on that
/// value. Use it to hand off to the in-app deep-link handler at
/// `incacook://auth/recover#...`.
@freezed
abstract class PasswordResetRequest with _$PasswordResetRequest {
  const factory PasswordResetRequest({
    required String email,
    String? redirectTo,
  }) = _PasswordResetRequest;

  factory PasswordResetRequest.fromJson(Map<String, dynamic> json) =>
      _$PasswordResetRequestFromJson(json);
}
