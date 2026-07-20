import 'package:flutter_test/flutter_test.dart';

import 'package:incacook/core/controllers/user_controller.dart';
import 'package:incacook/core/models/auth/driver_account.dart';
import 'package:incacook/core/models/auth/seller_account.dart';
import 'package:incacook/core/models/auth/user.dart';
import 'package:incacook/core/network/token_storage.dart';
import 'package:incacook/features/authentication/data/models/user_role.dart';
import 'package:incacook/features/authentication/data/repositories/users_repository.dart';

/// `SubscriptionGate` (subscription_gate.dart:22-31) decides paywall-vs-content
/// for Accueil/Commandes/Mes plats purely off this getter (DEC-3) — it has
/// real branches (status normalization, TRIALING counted active, an expiry
/// comparison, a dev/test fallback) with no prior test coverage.
void main() {
  UserController controller() => UserController(
    usersRepository: _FakeUsersRepository(),
    tokenStorage: _FakeTokenStorage(),
  );

  User userWith({SellerAccount? seller, DriverAccount? driver}) => User(
    id: 'u1',
    email: 'qa@incacook.fr',
    role: seller != null ? UserRole.seller : UserRole.driver,
    firstName: 'QA',
    lastName: 'Tester',
    sellerAccount: seller,
    driverAccount: driver,
  );

  group('hasActiveSellerSubscription', () {
    test('true for ACTIVE within the current period', () {
      final c = controller();
      c.user.value = userWith(
        seller: SellerAccount(
          subscriptionStatus: 'ACTIVE',
          subscriptionCurrentPeriodEnd: DateTime.now()
              .add(const Duration(days: 10))
              .toIso8601String(),
        ),
      );
      expect(c.hasActiveSellerSubscription, isTrue);
    });

    test('true for TRIALING (counted as active, not just ACTIVE)', () {
      final c = controller();
      c.user.value = userWith(
        seller: SellerAccount(
          subscriptionStatus: 'TRIALING',
          subscriptionCurrentPeriodEnd: DateTime.now()
              .add(const Duration(days: 3))
              .toIso8601String(),
        ),
      );
      expect(c.hasActiveSellerSubscription, isTrue);
    });

    test('false for EXPIRED', () {
      final c = controller();
      c.user.value = userWith(
        seller: const SellerAccount(subscriptionStatus: 'EXPIRED'),
      );
      expect(c.hasActiveSellerSubscription, isFalse);
    });

    test('false for CANCELLED', () {
      final c = controller();
      c.user.value = userWith(
        seller: const SellerAccount(subscriptionStatus: 'CANCELLED'),
      );
      expect(c.hasActiveSellerSubscription, isFalse);
    });

    test('false for the default NONE status', () {
      final c = controller();
      c.user.value = userWith(seller: const SellerAccount());
      expect(c.hasActiveSellerSubscription, isFalse);
    });

    test('false when status is ACTIVE but the period has already elapsed', () {
      final c = controller();
      c.user.value = userWith(
        seller: SellerAccount(
          subscriptionStatus: 'ACTIVE',
          subscriptionCurrentPeriodEnd: DateTime.now()
              .subtract(const Duration(days: 1))
              .toIso8601String(),
        ),
      );
      expect(c.hasActiveSellerSubscription, isFalse);
    });

    test(
      'true for ACTIVE with no subscriptionCurrentPeriodEnd (documented dev/test fallback)',
      () {
        final c = controller();
        c.user.value = userWith(
          seller: const SellerAccount(subscriptionStatus: 'ACTIVE'),
        );
        expect(c.hasActiveSellerSubscription, isTrue);
      },
    );

    test('false for a driver (no sellerAccount at all)', () {
      final c = controller();
      c.user.value = userWith(driver: const DriverAccount());
      expect(c.hasActiveSellerSubscription, isFalse);
    });

    test('true for ACTIVE with an unparseable expiry string (fails open)', () {
      final c = controller();
      c.user.value = userWith(
        seller: const SellerAccount(
          subscriptionStatus: 'ACTIVE',
          subscriptionCurrentPeriodEnd: 'not-a-date',
        ),
      );
      expect(c.hasActiveSellerSubscription, isTrue);
    });

    test('true for ACTIVE with an empty-string expiry (same as null)', () {
      final c = controller();
      c.user.value = userWith(
        seller: const SellerAccount(
          subscriptionStatus: 'ACTIVE',
          subscriptionCurrentPeriodEnd: '',
        ),
      );
      expect(c.hasActiveSellerSubscription, isTrue);
    });

    test('status comparison is case-insensitive', () {
      final c = controller();
      c.user.value = userWith(
        seller: SellerAccount(
          subscriptionStatus: 'active',
          subscriptionCurrentPeriodEnd: DateTime.now()
              .add(const Duration(days: 1))
              .toIso8601String(),
        ),
      );
      expect(c.hasActiveSellerSubscription, isTrue);
    });
  });
}

class _FakeUsersRepository implements UsersRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _FakeTokenStorage implements TokenStorage {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}
