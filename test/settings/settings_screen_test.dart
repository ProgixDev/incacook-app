import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/core/controllers/user_controller.dart';
import 'package:incacook/core/models/auth/user.dart';
import 'package:incacook/core/network/api_client.dart';
import 'package:incacook/core/network/token_storage.dart';
import 'package:incacook/features/authentication/data/models/user_role.dart';
import 'package:incacook/features/authentication/data/repositories/users_repository.dart';
import 'package:incacook/features/notifications/controllers/notifications_controller.dart';
import 'package:incacook/features/notifications/data/notifications_repository.dart';
import 'package:incacook/features/settings/presentation/screens/settings.dart';

ApiClient _fakeApiClient() => ApiClient(dio: Dio(), tokenStorage: TokenStorage());

/// Real [UsersRepository] except `getMe`, which is short-circuited to fail
/// fast instead of hitting the network — Settings' initState fire-and-forget
/// refresh (`.ignore()`) swallows this.
class _FakeUsersRepository extends UsersRepository {
  _FakeUsersRepository({required super.api});

  @override
  Future<User> getMe() => Future<User>.error(Exception('no network in tests'));
}

/// Real [NotificationsRepository] except `unreadCount`, stubbed to zero.
class _FakeNotificationsRepository extends NotificationsRepository {
  _FakeNotificationsRepository({required super.api});

  @override
  Future<int> unreadCount() async => 0;
}

/// #49 / #51 / #54 — Settings must render the new privacy-policy,
/// delete-account, and blocked-users entries for every role.
void main() {
  setUp(() {
    Get.testMode = true;
    Get.put<UsersRepository>(_FakeUsersRepository(api: _fakeApiClient()));
    Get.put<UserController>(
      UserController(
        usersRepository: Get.find<UsersRepository>(),
        tokenStorage: TokenStorage(),
      ),
    );
    Get.put<NotificationsController>(
      NotificationsController(repository: _FakeNotificationsRepository(api: _fakeApiClient())),
    );
  });

  tearDown(Get.reset);

  Future<void> pumpFor(WidgetTester tester, UserRole role) async {
    UserController.instance.setUser(
      User(
        id: 'u1',
        email: 'qa@incacook.fr',
        role: role,
        firstName: 'QA',
        lastName: 'Tester',
      ),
    );
    await tester.pumpWidget(GetMaterialApp(home: const SettingsScreen()));
    await tester.pump();
  }

  for (final role in UserRole.values) {
    testWidgets('renders privacy, delete-account, blocked-users for $role', (tester) async {
      await pumpFor(tester, role);

      expect(find.text(AppTexts.settingsPrivacyPolicy), findsOneWidget);
      expect(find.text(AppTexts.settingsDeleteAccount), findsOneWidget);
      expect(find.text(AppTexts.settingsBlockedUsers), findsOneWidget);
    });
  }
}
