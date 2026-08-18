import 'package:get/get.dart';

import 'package:incacook/core/services/supabase_oauth_service.dart';
import 'package:incacook/features/authentication/data/repositories/auth_repository.dart';
import 'package:incacook/features/authentication/services/oauth_session_snapshot.dart';

typedef OAuthSessionReader = OAuthSessionSnapshot? Function();
typedef OAuthSessionPersister =
    Future<void> Function(OAuthSessionSnapshot session);
typedef OAuthUserSync = Future<OAuthSyncResult> Function();

/// Reconciles a hosted OAuth callback that completed while the app process was
/// not alive. Supabase persists its session independently from IncaCook's
/// [TokenStorage], so bootstrap must copy and sync it before deciding that the
/// user is logged out.
class OAuthSessionRecovery extends GetxService {
  OAuthSessionRecovery({
    OAuthSessionReader? readSession,
    OAuthSessionPersister? persistSession,
    OAuthUserSync? syncUser,
  }) : _readSession = readSession ?? _readCurrentSupabaseSession,
       _persistSession = persistSession ?? _persistCurrentSession,
       _syncUser = syncUser ?? _syncCurrentUser;

  static OAuthSessionRecovery get instance => Get.find();

  final OAuthSessionReader _readSession;
  final OAuthSessionPersister _persistSession;
  final OAuthUserSync _syncUser;

  /// Returns null when there is no Supabase session to recover. A non-null
  /// result has already been persisted and synchronized with the backend.
  Future<OAuthSyncResult?> recover() async {
    final session = _readSession();
    if (session == null) return null;
    await _persistSession(session);
    return _syncUser();
  }

  static OAuthSessionSnapshot? _readCurrentSupabaseSession() =>
      SupabaseOAuthService.instance.currentSessionSnapshot;

  static Future<void> _persistCurrentSession(OAuthSessionSnapshot session) =>
      AuthRepository.instance.persistOAuthSession(
        accessToken: session.accessToken,
        refreshToken: session.refreshToken,
        expiresAt: session.expiresAt,
      );

  static Future<OAuthSyncResult> _syncCurrentUser() =>
      AuthRepository.instance.syncOAuthUser();
}
