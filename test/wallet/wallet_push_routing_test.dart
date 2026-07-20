import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:incacook/core/controllers/user_controller.dart';
import 'package:incacook/core/network/api_client.dart';
import 'package:incacook/core/network/api_response.dart';
import 'package:incacook/core/network/token_storage.dart';
import 'package:incacook/features/authentication/data/repositories/users_repository.dart';
import 'package:incacook/features/notifications/controllers/notifications_controller.dart';
import 'package:incacook/features/notifications/data/notifications_repository.dart';
import 'package:incacook/features/notifications/domain/app_notification.dart';
import 'package:incacook/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:incacook/features/wallet/presentation/wallet_screen.dart';

/// Also stands in as the WalletScreen's ApiClient — its real WalletRepository
/// is constructed by production navigation code (no test seam reachable from
/// here), so `getSummary()` must resolve without touching the network.
class _FakeApiClient extends ApiClient {
  _FakeApiClient() : super(dio: Dio(), tokenStorage: TokenStorage());

  static const _walletSummary = {
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
    return ApiSuccess<T>(decoder(_walletSummary));
  }
}

class _FakeTokenStorage implements TokenStorage {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

/// A `wallet_funds_available` push carries no `orderId` (it isn't
/// order-scoped) — the pre-fix tap handler required one, so this
/// notification was a dead end: tapping it in the bell inbox did nothing but
/// mark it read.
AppNotification _walletNotification() => AppNotification(
  id: 'n1',
  type: 'wallet_funds_available',
  title: 'Gains disponibles',
  body: '12,00 € sont maintenant disponibles.',
  data: const {},
  read: false,
  createdAt: DateTime(2026, 1, 1),
);

class _FakeNotificationsRepository extends NotificationsRepository {
  _FakeNotificationsRepository() : super(api: _FakeApiClient());

  @override
  Future<NotificationsPage> list({int limit = 30, String? before}) async {
    return NotificationsPage(
      items: [_walletNotification()],
      hasMore: false,
      unreadCount: 1,
    );
  }

  @override
  Future<void> markRead(String id) async {}
}

void main() {
  tearDown(Get.reset);

  testWidgets(
    'tapping a wallet_funds_available notification navigates to Wallet',
    (tester) async {
      // The real WalletScreen() is constructed by production navigation code
      // (no test seam reachable from here), so its real WalletRepository()
      // needs a registered ApiClient, and its UserController Obx needs a
      // registered UserController — same as production boot.
      Get.put<ApiClient>(_FakeApiClient());
      Get.put<UserController>(
        UserController(
          usersRepository: UsersRepository(api: _FakeApiClient()),
          tokenStorage: _FakeTokenStorage(),
        ),
      );
      Get.put<NotificationsController>(
        NotificationsController(repository: _FakeNotificationsRepository()),
      );

      await tester.pumpWidget(
        const GetMaterialApp(home: NotificationsScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Gains disponibles'), findsOneWidget);
      expect(find.byType(WalletScreen), findsNothing);

      await tester.tap(find.text('Gains disponibles'));
      await tester.pumpAndSettle();

      expect(find.byType(WalletScreen), findsOneWidget);
    },
  );
}
