import 'package:flutter_test/flutter_test.dart';

import 'package:incacook/features/authentication/data/repositories/auth_repository.dart';
import 'package:incacook/features/authentication/services/oauth_session_recovery.dart';
import 'package:incacook/features/authentication/services/oauth_session_snapshot.dart';

void main() {
  const snapshot = OAuthSessionSnapshot(
    accessToken: 'facebook-access-token',
    refreshToken: 'facebook-refresh-token',
    expiresAt: 123456,
  );

  test('returns null without a Supabase OAuth session', () async {
    var persisted = false;
    var synced = false;
    final recovery = OAuthSessionRecovery(
      readSession: () => null,
      persistSession: (_) async => persisted = true,
      syncUser: () async {
        synced = true;
        return const OAuthSyncResult(profileExists: false, needsEmail: false);
      },
    );

    expect(await recovery.recover(), isNull);
    expect(persisted, isFalse);
    expect(synced, isFalse);
  });

  test(
    'persists and syncs a session completed while the app was dead',
    () async {
      OAuthSessionSnapshot? persisted;
      var syncCalls = 0;
      const sync = OAuthSyncResult(profileExists: false, needsEmail: true);
      final recovery = OAuthSessionRecovery(
        readSession: () => snapshot,
        persistSession: (value) async => persisted = value,
        syncUser: () async {
          syncCalls += 1;
          return sync;
        },
      );

      expect(await recovery.recover(), same(sync));
      expect(persisted, snapshot);
      expect(syncCalls, 1);
    },
  );

  test('never syncs when token persistence fails', () async {
    var synced = false;
    final recovery = OAuthSessionRecovery(
      readSession: () => snapshot,
      persistSession: (_) async => throw StateError('secure storage failed'),
      syncUser: () async {
        synced = true;
        return const OAuthSyncResult(profileExists: false, needsEmail: false);
      },
    );

    await expectLater(recovery.recover(), throwsStateError);
    expect(synced, isFalse);
  });
}
