import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_user.freezed.dart';
part 'auth_user.g.dart';

/// The auth-side user shape returned inside [Session]. This is **not** the
/// full IncaCook user profile — that lives on the row created by
/// `POST /v1/users` and includes role / firstName / preferences. Use it
/// only for auth-related UI (showing the email on a "confirm signout"
/// dialog, gating actions on `emailConfirmedAt`, etc.).
@freezed
abstract class AuthUser with _$AuthUser {
  const factory AuthUser({
    required String id,
    required String email,
    String? phone,
    String? emailConfirmedAt,
    String? phoneConfirmedAt,
  }) = _AuthUser;

  factory AuthUser.fromJson(Map<String, dynamic> json) =>
      _$AuthUserFromJson(json);
}
