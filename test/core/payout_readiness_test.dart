import 'package:flutter_test/flutter_test.dart';

import 'package:incacook/core/controllers/user_controller.dart';
import 'package:incacook/core/models/auth/driver_account.dart';
import 'package:incacook/core/models/auth/payout_readiness.dart';
import 'package:incacook/core/models/auth/seller_account.dart';
import 'package:incacook/core/models/auth/user.dart';
import 'package:incacook/core/network/token_storage.dart';
import 'package:incacook/features/authentication/data/models/user_role.dart';
import 'package:incacook/features/authentication/data/repositories/users_repository.dart';

/// DEC-4: `/users/me` splits the collapsed `stripeOnboardingCompleted` gate
/// into three Stripe facts — `detailsSubmitted`, `chargesEnabled`,
/// `payoutsEnabled` — so the app can tell "never started" apart from
/// "submitted, Stripe is still verifying". The fields are nullable because an
/// old server won't send them; readiness then falls back to the legacy
/// boolean.
void main() {
  group('JSON parsing — split Stripe facts', () {
    test('seller parses the new fields when present (true)', () {
      final seller = SellerAccount.fromJson(const {
        'stripeOnboardingCompleted': true,
        'detailsSubmitted': true,
        'chargesEnabled': true,
        'payoutsEnabled': true,
      });

      expect(seller.stripeOnboardingCompleted, isTrue);
      expect(seller.detailsSubmitted, isTrue);
      expect(seller.chargesEnabled, isTrue);
      expect(seller.payoutsEnabled, isTrue);
    });

    test('seller parses the new fields when present (false)', () {
      final seller = SellerAccount.fromJson(const {
        'stripeOnboardingCompleted': false,
        'detailsSubmitted': false,
        'chargesEnabled': false,
        'payoutsEnabled': false,
      });

      expect(seller.detailsSubmitted, isFalse);
      expect(seller.chargesEnabled, isFalse);
      expect(seller.payoutsEnabled, isFalse);
    });

    test('seller tolerates an old server that omits the new fields', () {
      final seller = SellerAccount.fromJson(const {
        'stripeOnboardingCompleted': true,
      });

      // Absent must stay null — distinguishable from an explicit false.
      expect(seller.detailsSubmitted, isNull);
      expect(seller.chargesEnabled, isNull);
      expect(seller.payoutsEnabled, isNull);
      expect(seller.stripeOnboardingCompleted, isTrue);
    });

    test('driver parses the new fields when present', () {
      final driver = DriverAccount.fromJson(const {
        'stripeOnboardingCompleted': false,
        'detailsSubmitted': true,
        'chargesEnabled': false,
        'payoutsEnabled': false,
      });

      expect(driver.detailsSubmitted, isTrue);
      expect(driver.chargesEnabled, isFalse);
      expect(driver.payoutsEnabled, isFalse);
    });

    test('driver tolerates an old server that omits the new fields', () {
      final driver = DriverAccount.fromJson(const {
        'stripeOnboardingCompleted': false,
      });

      expect(driver.detailsSubmitted, isNull);
      expect(driver.chargesEnabled, isNull);
      expect(driver.payoutsEnabled, isNull);
    });
  });

  group('readiness matrix — payoutSetupStateFrom', () {
    test('(details=false, payouts=false) → notStarted', () {
      expect(
        payoutSetupStateFrom(
          detailsSubmitted: false,
          payoutsEnabled: false,
          stripeOnboardingCompleted: false,
        ),
        PayoutSetupState.notStarted,
      );
    });

    test('(details=true, payouts=false) → pendingVerification', () {
      expect(
        payoutSetupStateFrom(
          detailsSubmitted: true,
          payoutsEnabled: false,
          stripeOnboardingCompleted: false,
        ),
        PayoutSetupState.pendingVerification,
      );
    });

    test('(details=true, payouts=true) → ready', () {
      expect(
        payoutSetupStateFrom(
          detailsSubmitted: true,
          payoutsEnabled: true,
          stripeOnboardingCompleted: true,
        ),
        PayoutSetupState.ready,
      );
    });

    test('chargesEnabled does not affect readiness', () {
      // chargesEnabled isn't even an input to the derivation — assert the
      // account-level view agrees for both values.
      const ready = SellerAccount(
        detailsSubmitted: true,
        payoutsEnabled: true,
        chargesEnabled: false,
      );
      const pending = DriverAccount(
        detailsSubmitted: true,
        payoutsEnabled: false,
        chargesEnabled: true,
      );

      expect(ready.payoutSetupState, PayoutSetupState.ready);
      expect(pending.payoutSetupState, PayoutSetupState.pendingVerification);
    });

    test('absent facts + legacy stripeOnboardingCompleted=true → ready '
        '(back-compat fallback)', () {
      expect(
        payoutSetupStateFrom(
          detailsSubmitted: null,
          payoutsEnabled: null,
          stripeOnboardingCompleted: true,
        ),
        PayoutSetupState.ready,
      );
    });

    test('absent facts + legacy stripeOnboardingCompleted=false → notStarted',
        () {
      expect(
        payoutSetupStateFrom(
          detailsSubmitted: null,
          payoutsEnabled: null,
          stripeOnboardingCompleted: false,
        ),
        PayoutSetupState.notStarted,
      );
    });

    test('split facts win over a stale legacy boolean', () {
      // Stripe revoked payouts: the new facts say pending even if the
      // collapsed boolean hasn't been recomputed yet.
      expect(
        payoutSetupStateFrom(
          detailsSubmitted: true,
          payoutsEnabled: false,
          stripeOnboardingCompleted: true,
        ),
        PayoutSetupState.pendingVerification,
      );
    });
  });

  group('UserController — payoutSetupState / readiness getters', () {
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

    test('seller pendingVerification: submitted but payouts not enabled', () {
      final c = controller();
      c.user.value = userWith(
        seller: const SellerAccount(
          detailsSubmitted: true,
          payoutsEnabled: false,
        ),
      );

      expect(c.payoutSetupState, PayoutSetupState.pendingVerification);
      // Not ready → the setup surfaces still show (with pending copy).
      expect(c.sellerPayoutReady, isFalse);
      expect(c.needsPayoutSetup, isTrue);
      expect(c.payoutReady, isFalse);
    });

    test('driver ready via split facts even when the legacy boolean lags', () {
      final c = controller();
      c.user.value = userWith(
        driver: const DriverAccount(
          detailsSubmitted: true,
          payoutsEnabled: true,
        ),
      );

      expect(c.payoutSetupState, PayoutSetupState.ready);
      expect(c.driverPayoutReady, isTrue);
      expect(c.needsPayoutSetup, isFalse);
      expect(c.payoutReady, isTrue);
    });

    test('old server: legacy boolean still drives readiness', () {
      final c = controller();
      c.user.value = userWith(
        seller: const SellerAccount(stripeOnboardingCompleted: true),
      );

      expect(c.payoutSetupState, PayoutSetupState.ready);
      expect(c.sellerPayoutReady, isTrue);
      expect(c.needsPayoutSetup, isFalse);
    });

    test('buyer / signed out → notStarted (and never prompts)', () {
      final c = controller();
      c.user.value = User(
        id: 'b1',
        email: 'buyer@incacook.fr',
        role: UserRole.buyer,
        firstName: 'B',
        lastName: 'Uyer',
      );

      expect(c.payoutSetupState, PayoutSetupState.notStarted);
      expect(c.needsPayoutSetup, isFalse);

      c.user.value = null;
      expect(c.payoutSetupState, PayoutSetupState.notStarted);
      expect(c.needsPayoutSetup, isFalse);
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
