import 'package:flutter_test/flutter_test.dart';

import 'package:incacook/core/controllers/user_controller.dart';
import 'package:incacook/core/models/auth/driver_account.dart';
import 'package:incacook/core/models/auth/seller_account.dart';
import 'package:incacook/core/models/auth/user.dart';
import 'package:incacook/core/network/token_storage.dart';
import 'package:incacook/features/authentication/data/models/user_role.dart';
import 'package:incacook/features/authentication/data/repositories/users_repository.dart';

/// The wallet's payout-setup prompt must reach BOTH earner roles.
///
/// It was conditioned on driver state, so it never rendered for a seller —
/// whose `driverAccount` is null. Combined with the seller's only other route
/// to Connect setup sitting behind `SubscriptionGate`, a seller whose
/// subscription lapsed could see a balance they had no way to withdraw: they
/// had to pay €4/mo to reach money already earned. Sellers earn before
/// subscribing, so that state is ordinary, not an edge case.
///
/// Wallet lives under the ungated Profil tab, which is what makes it the right
/// owner of setup/resume.
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

  group('needsPayoutSetup', () {
    test('prompts a seller who has not completed Connect', () {
      final c = controller();
      c.user.value = userWith(seller: const SellerAccount());

      // The regression: this was false for every seller, always.
      expect(c.needsPayoutSetup, isTrue);
    });

    test('stops prompting a seller once Connect is complete', () {
      final c = controller();
      c.user.value =
          userWith(seller: const SellerAccount(stripeOnboardingCompleted: true));

      expect(c.needsPayoutSetup, isFalse);
    });

    test('prompts a driver who has not completed Connect', () {
      final c = controller();
      c.user.value = userWith(driver: const DriverAccount());

      expect(c.needsPayoutSetup, isTrue);
    });

    test('stops prompting a driver once Connect is complete', () {
      final c = controller();
      c.user.value =
          userWith(driver: const DriverAccount(stripeOnboardingCompleted: true));

      expect(c.needsPayoutSetup, isFalse);
    });

    test('does not prompt when signed out', () {
      final c = controller();
      c.user.value = null;

      expect(c.needsPayoutSetup, isFalse);
    });

    test('reacts to onboarding completing, so the card hides without a restart',
        () {
      final c = controller();
      c.user.value = userWith(seller: const SellerAccount());
      expect(c.needsPayoutSetup, isTrue);

      c.user.value =
          userWith(seller: const SellerAccount(stripeOnboardingCompleted: true));
      expect(c.needsPayoutSetup, isFalse);
    });
  });

  // Gates the profile "Paiement" tile (Stripe Express dashboard). It must be the
  // mirror of needsPayoutSetup for earners, but — crucially — false for buyers,
  // who have no payout account at all.
  group('payoutReady', () {
    test('false for a seller who has not completed Connect', () {
      final c = controller();
      c.user.value = userWith(seller: const SellerAccount());

      expect(c.payoutReady, isFalse);
    });

    test('true for a seller once Connect is complete', () {
      final c = controller();
      c.user.value =
          userWith(seller: const SellerAccount(stripeOnboardingCompleted: true));

      expect(c.payoutReady, isTrue);
    });

    test('true for a driver once Connect is complete', () {
      final c = controller();
      c.user.value =
          userWith(driver: const DriverAccount(stripeOnboardingCompleted: true));

      expect(c.payoutReady, isTrue);
    });

    test('false for a buyer (no payout account, not just "not set up")', () {
      final c = controller();
      // A buyer has neither seller nor driver account.
      c.user.value = User(
        id: 'b1',
        email: 'buyer@incacook.fr',
        role: UserRole.buyer,
        firstName: 'B',
        lastName: 'Uyer',
      );

      expect(c.payoutReady, isFalse);
      // And it must not merely be the inverse of needsPayoutSetup here:
      expect(c.needsPayoutSetup, isFalse);
    });

    test('false when signed out', () {
      final c = controller();
      c.user.value = null;

      expect(c.payoutReady, isFalse);
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
