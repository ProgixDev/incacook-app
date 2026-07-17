import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:incacook/core/controllers/user_controller.dart';
import 'package:incacook/core/network/api_client.dart';
import 'package:incacook/core/network/api_response.dart';
import 'package:incacook/core/network/token_storage.dart';
import 'package:incacook/features/authentication/data/repositories/users_repository.dart';
import 'package:incacook/features/payments/data/payout_onboarding_service.dart';

/// D3 (`findings/04-connect-onboarding-return.md` §D3/R6, test T6):
/// `_awaitReturn` used to match `incacook://stripe/...` on scheme+host only,
/// ignoring `uri.path` — so Stripe's `refresh_url` bounce (an expired
/// Account Link) was treated exactly like a completed return: it polled a
/// status that could not have changed, left the banner up, and never minted
/// a fresh link. This proves the fix: a `refresh` bounce mints and reopens a
/// new Account Link; a `return` bounce does not.
void main() {
  late _FakeApiClient apiClient;
  late _FakeLinkSource linkSource;
  late List<Uri> launchedUrls;
  late PayoutOnboardingService service;

  Future<bool> fakeLauncher(Uri url, {LaunchMode mode = LaunchMode.platformDefault}) async {
    launchedUrls.add(url);
    return true;
  }

  setUp(() {
    apiClient = _FakeApiClient();
    linkSource = _FakeLinkSource();
    launchedUrls = [];
    service = PayoutOnboardingService(
      apiClient: apiClient,
      userController: UserController(
        usersRepository: _FakeUsersRepository(),
        tokenStorage: _FakeTokenStorage(),
      ),
      linkSource: linkSource,
      urlLauncher: fakeLauncher,
    );
  });

  Future<BuildContext> pumpContext(WidgetTester tester) async {
    late BuildContext ctx;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            ctx = context;
            return const SizedBox();
          },
        ),
      ),
    );
    return ctx;
  }

  // Runs the whole exchange inside `tester.runAsync` — the service's async
  // orchestration (Stream subscriptions, `Completer.timeout`'s real Timer)
  // isn't driven by the widget tree, so it needs the real event loop, not
  // fake-clock frame pumps: a bare `tester.pump()` never advances the
  // completer's 5-minute timeout, and the test hangs until the test
  // runner's own 10-minute ceiling kills it.
  Future<void> settle() => Future<void>.delayed(Duration.zero);

  testWidgets('refresh_url bounce mints and reopens a fresh Account Link', (
    tester,
  ) async {
    final ctx = await pumpContext(tester);

    await tester.runAsync(() async {
      final result = service.openOnboarding(ctx);
      await settle(); // POST #1 + launch #1 + _awaitReturn armed

      linkSource.emit(Uri.parse('incacook://stripe/refresh'));
      await settle(); // refresh handled: POST #2 + launch #2 + re-armed

      linkSource.emit(Uri.parse('incacook://stripe/return'));

      expect(await result, isTrue);
      expect(
        apiClient.accountLinkPosts,
        2,
        reason: 'expired link must be re-minted',
      );
      expect(launchedUrls.length, 2, reason: 'the fresh link must be reopened');
      expect(launchedUrls[1], isNot(launchedUrls[0]));
    });
  });

  testWidgets('return_url bounce reconciles without minting a second link', (
    tester,
  ) async {
    final ctx = await pumpContext(tester);

    await tester.runAsync(() async {
      final result = service.openOnboarding(ctx);
      await settle(); // POST #1 + launch #1 + _awaitReturn armed

      linkSource.emit(Uri.parse('incacook://stripe/return'));

      expect(await result, isTrue);
      expect(apiClient.accountLinkPosts, 1);
      expect(launchedUrls.length, 1);
    });
  });

  // D2 (finding 04 §D2/R3): the app process can die while the hosted
  // onboarding tab is open, killing `_awaitReturn`'s listener with it.
  // `reconcileFromDeepLink` is the entry point the app-wide main.dart
  // listener calls instead, for exactly that case.
  group('reconcileFromDeepLink (cold-start return, D2)', () {
    test('a return bounce reconciles status without minting a link', () async {
      await service.reconcileFromDeepLink(Uri.parse('incacook://stripe/return'));

      expect(apiClient.statusGets, 1);
      expect(apiClient.accountLinkPosts, 0);
      expect(launchedUrls, isEmpty);
    });

    test('a refresh bounce is a no-op (no auto-relaunch on cold boot)', () async {
      await service.reconcileFromDeepLink(Uri.parse('incacook://stripe/refresh'));

      expect(apiClient.statusGets, 0);
      expect(apiClient.accountLinkPosts, 0);
      expect(launchedUrls, isEmpty);
    });
  });

  // D6 (finding 04 §D6): the status GET is the only thing that tells the app
  // whether onboarding actually completed. If it throws, the old code only
  // logged and returned — the banner stayed exactly as it was, with no way
  // for the user to tell "not done yet" apart from "we couldn't check".
  // `reconcileFailed` is the reactive signal the banner reads instead.
  group('reconcileFailed (D6 — silent status-check failure)', () {
    test('starts false', () {
      expect(service.reconcileFailed.value, isFalse);
    });

    test('a return bounce reconciles cleanly → stays false even though '
        'the local refreshFromServer always throws in this fake', () async {
      // _FakeUsersRepository throws UnimplementedError on every call, so
      // every test in this file already exercises a failing
      // refreshFromServer. Asserting false here pins the distinction: only
      // the STATUS GET failing is user-facing; the local cache refresh
      // failing is the existing "best-effort, next poll retries" case.
      await service.reconcileFromDeepLink(
        Uri.parse('incacook://stripe/return'),
      );

      expect(service.reconcileFailed.value, isFalse);
    });

    test(
      'cold-start reconcile sets reconcileFailed when the status GET throws',
      () async {
        apiClient.failStatusGet = true;

        await service.reconcileFromDeepLink(
          Uri.parse('incacook://stripe/return'),
        );

        expect(service.reconcileFailed.value, isTrue);
      },
    );

    testWidgets(
      'warm-path reconcile (end of openOnboarding) sets reconcileFailed '
      'when the status GET throws',
      (tester) async {
        final ctx = await pumpContext(tester);
        apiClient.failStatusGet = true;

        await tester.runAsync(() async {
          final result = service.openOnboarding(ctx);
          await settle(); // POST #1 + launch #1 + _awaitReturn armed

          linkSource.emit(Uri.parse('incacook://stripe/return'));

          expect(await result, isTrue);
          expect(service.reconcileFailed.value, isTrue);
        });
      },
    );

    test('a later successful reconcile clears a previous failure', () async {
      apiClient.failStatusGet = true;
      await service.reconcileFromDeepLink(
        Uri.parse('incacook://stripe/return'),
      );
      expect(service.reconcileFailed.value, isTrue);

      apiClient.failStatusGet = false;
      await service.reconcileFromDeepLink(
        Uri.parse('incacook://stripe/return'),
      );

      expect(service.reconcileFailed.value, isFalse);
    });
  });
}

class _FakeApiClient implements ApiClient {
  int accountLinkPosts = 0;
  int statusGets = 0;
  bool failStatusGet = false;

  @override
  Future<ApiSuccess<T>> post<T>(
    String path, {
    required T Function(Object? json) decoder,
    Object? body,
    String? idempotencyKey,
    bool requiresIdempotencyKey = false,
  }) async {
    if (path.contains('account-link')) {
      accountLinkPosts++;
      return ApiSuccess<T>(
        decoder({'url': 'https://stripe.example/link-$accountLinkPosts'}),
      );
    }
    throw UnimplementedError('unexpected POST $path');
  }

  @override
  Future<ApiSuccess<T>> get<T>(
    String path, {
    required T Function(Object? json) decoder,
    Map<String, dynamic>? queryParameters,
  }) async {
    if (path.contains('status')) {
      statusGets++;
      if (failStatusGet) {
        throw const ApiFailure(
          statusCode: 0,
          code: 'INCACOOK_OFFLINE',
          message: 'offline',
        );
      }
      return ApiSuccess<T>(
        decoder({
          'onboardingCompleted': true,
          'chargesEnabled': true,
          'payoutsEnabled': true,
          'detailsSubmitted': true,
        }),
      );
    }
    throw UnimplementedError('unexpected GET $path');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _FakeLinkSource implements PayoutReturnLinkSource {
  final StreamController<Uri> _controller = StreamController<Uri>.broadcast();

  @override
  Stream<Uri> get uriLinkStream => _controller.stream;

  void emit(Uri uri) => _controller.add(uri);
}

class _FakeUsersRepository implements UsersRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _FakeTokenStorage implements TokenStorage {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}
