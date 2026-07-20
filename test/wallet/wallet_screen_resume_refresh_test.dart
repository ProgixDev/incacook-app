import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:incacook/core/controllers/user_controller.dart';
import 'package:incacook/core/network/api_client.dart';
import 'package:incacook/core/network/api_response.dart';
import 'package:incacook/core/network/token_storage.dart';
import 'package:incacook/features/authentication/data/repositories/users_repository.dart';
import 'package:incacook/features/wallet/data/wallet_repository.dart';
import 'package:incacook/features/wallet/presentation/wallet_screen.dart';

class _FakeApiClient extends ApiClient {
  _FakeApiClient() : super(dio: Dio(), tokenStorage: TokenStorage());

  int getSummaryCalls = 0;

  static const _payload = {
    'availableCents': 0,
    'pendingCents': 0,
    'heldCents': 0,
    'paidOutCents': 0,
    'debtCents': 0,
    'minWithdrawalCents': 5000,
    'canWithdraw': false,
    'entries': <dynamic>[],
  };

  @override
  Future<ApiSuccess<T>> get<T>(
    String path, {
    required T Function(Object? json) decoder,
    Map<String, dynamic>? queryParameters,
  }) async {
    getSummaryCalls++;
    return ApiSuccess<T>(decoder(_payload));
  }
}

class _FakeUsersRepository extends UsersRepository {
  _FakeUsersRepository() : super(api: _FakeApiClient());
}

class _FakeTokenStorage implements TokenStorage {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

void main() {
  tearDown(Get.reset);

  testWidgets(
    'refetches the wallet summary on every app-lifecycle resume',
    (tester) async {
      final api = _FakeApiClient();
      Get.put<UserController>(
        UserController(
          usersRepository: _FakeUsersRepository(),
          tokenStorage: _FakeTokenStorage(),
        ),
      );

      await tester.pumpWidget(
        GetMaterialApp(
          home: WalletScreen(repository: WalletRepository(api: api)),
        ),
      );
      await tester.pumpAndSettle();

      expect(api.getSummaryCalls, 1, reason: 'initial fetch on mount');

      tester.binding
          .handleAppLifecycleStateChanged(AppLifecycleState.paused);
      tester.binding
          .handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();

      expect(
        api.getSummaryCalls,
        2,
        reason: 'resume must trigger a refetch — this is the whole fix',
      );

      // A second resume (e.g. backgrounding again briefly) refetches again —
      // this isn't a one-shot "first resume only" listener.
      tester.binding
          .handleAppLifecycleStateChanged(AppLifecycleState.paused);
      tester.binding
          .handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();

      expect(api.getSummaryCalls, 3);
    },
  );

  testWidgets(
    'stops observing after the screen is disposed',
    (tester) async {
      final api = _FakeApiClient();
      Get.put<UserController>(
        UserController(
          usersRepository: _FakeUsersRepository(),
          tokenStorage: _FakeTokenStorage(),
        ),
      );

      await tester.pumpWidget(
        GetMaterialApp(
          home: WalletScreen(repository: WalletRepository(api: api)),
        ),
      );
      await tester.pumpAndSettle();
      expect(api.getSummaryCalls, 1);

      // Navigate away — WalletScreen is disposed.
      await tester.pumpWidget(const GetMaterialApp(home: SizedBox()));
      await tester.pumpAndSettle();

      // A resume after disposal must not touch the now-gone State (would
      // throw/leak if the observer wasn't removed in dispose()).
      tester.binding
          .handleAppLifecycleStateChanged(AppLifecycleState.paused);
      tester.binding
          .handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();

      expect(api.getSummaryCalls, 1, reason: 'no call after dispose');
    },
  );
}
