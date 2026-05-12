import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:incacook/core/models/auth/auth_user.dart';

part 'session.freezed.dart';
part 'session.g.dart';

/// The session payload returned by `/v1/auth/signup`, `/auth/signin`,
/// and `/auth/refresh`.
///
/// [accessToken] has a 1-hour TTL; [expiresAt] is Unix seconds.
/// [refreshToken] lives until explicit signout.
@freezed
abstract class Session with _$Session {
  const factory Session({
    required String accessToken,
    required String refreshToken,
    required int expiresAt,
    required AuthUser user,
  }) = _Session;

  factory Session.fromJson(Map<String, dynamic> json) =>
      _$SessionFromJson(json);
}
