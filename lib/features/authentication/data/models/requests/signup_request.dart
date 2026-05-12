import 'package:freezed_annotation/freezed_annotation.dart';

part 'signup_request.freezed.dart';
part 'signup_request.g.dart';

/// Body of `POST /v1/auth/signup`.
///
/// Creates the auth account and returns a [Session]. The IncaCook profile
/// row (firstName / lastName / role) is created separately by
/// `POST /v1/users` once the wizard collects those fields.
@freezed
abstract class SignupRequest with _$SignupRequest {
  const factory SignupRequest({
    required String email,
    required String password,
  }) = _SignupRequest;

  factory SignupRequest.fromJson(Map<String, dynamic> json) =>
      _$SignupRequestFromJson(json);
}
