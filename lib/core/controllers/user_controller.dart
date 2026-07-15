import 'package:get/get.dart';

import 'package:incacook/core/models/auth/user.dart';
import 'package:incacook/core/network/api_response.dart';
import 'package:incacook/core/network/token_storage.dart';
import 'package:incacook/features/authentication/data/repositories/users_repository.dart';

/// Holds the currently signed-in user across the app.
///
/// Single permanent singleton registered in `main.dart`. Widgets read it
/// reactively via [Obx] — when the user signs in / out / updates their
/// profile, every screen that observes [user] repaints automatically.
///
/// **Hydration is driven by callers, not by this controller.** The
/// `PostAuthRouter` already calls `/users/me` to decide routing; it
/// writes the result here via [setUser]. The signup wizard calls
/// [setUser] with the response from `POST /v1/users` (Gate 2). Future
/// per-resource PUTs can call [refresh] when they need fresh aggregate
/// data. Keeping all fetches in the caller (instead of having the
/// controller auto-fetch on construct) means we never accidentally
/// double-fetch on cold start.
class UserController extends GetxController {
  UserController({UsersRepository? usersRepository, TokenStorage? tokenStorage})
    : _usersRepository = usersRepository ?? Get.find<UsersRepository>(),
      _tokenStorage = tokenStorage ?? Get.find<TokenStorage>();

  static UserController get instance => Get.find();

  final UsersRepository _usersRepository;
  final TokenStorage _tokenStorage;

  /// Current user. `null` when signed out OR before the post-auth flow
  /// has hydrated. Reactive — bind via [Obx].
  final Rxn<User> user = Rxn<User>();

  /// Email on the Supabase auth identity (`Session.user.email`).
  ///
  /// Distinct from [user.email] because it's available *before* Gate 2
  /// runs — i.e. for the `PostAuthNoProfile` path where the user signed
  /// in (or up via Google) but has no IncaCook `User` row yet. Hydrated
  /// by `AuthRepository._persistSession` after every successful auth
  /// call, so any screen reading it (e.g. the OTP page's "we sent a
  /// code to …" copy) shows the address the backend will actually
  /// resolve from the JWT.
  final RxnString authEmail = RxnString();

  /// Name claims pulled from the access-token JWT's `user_metadata`.
  /// Populated for OAuth sign-ins (Google sends `given_name` /
  /// `family_name`) so the signup wizard can pre-fill Gate 2's body
  /// for first-time NoProfile users — without this, the wizard reaches
  /// role selection with empty strings and POST `/v1/users` returns
  /// 400 from the length-≥2 validators. Stays null for email-password
  /// signups (Supabase emits empty user_metadata).
  final RxnString authFirstName = RxnString();
  final RxnString authLastName = RxnString();

  /// Convenience getters so widgets don't have to null-check repeatedly.
  /// Empty strings (not `null`) so they can drop into `Text(...)` directly.
  String get displayName {
    final u = user.value;
    if (u == null) return '';
    return '${u.firstName} ${u.lastName}'.trim();
  }

  /// First name to greet the user with, in priority order:
  /// firstName → full display name → seller display name → email prefix →
  /// "vendeur". Never empty (so it drops straight into "Bonjour …").
  String get greetingName {
    final u = user.value;
    final first = (u?.firstName ?? authFirstName.value ?? '').trim();
    if (first.isNotEmpty) return first;
    final full = displayName.trim();
    if (full.isNotEmpty) return full;
    final sellerName = (u?.sellerAccount?.displayName ?? '').trim();
    if (sellerName.isNotEmpty) return sellerName;
    final mail = (u?.email ?? authEmail.value ?? '').trim();
    if (mail.contains('@')) return mail.split('@').first;
    return 'vendeur';
  }

  /// Up to 2 uppercase initials for the avatar fallback (e.g. "GD" for
  /// "Ghassen DF"). Falls back to the email's first letter, then "?".
  String get initials {
    final u = user.value;
    final first = (u?.firstName ?? authFirstName.value ?? '').trim();
    final last = (u?.lastName ?? authLastName.value ?? '').trim();
    final letters =
        ((first.isNotEmpty ? first[0] : '') + (last.isNotEmpty ? last[0] : ''))
            .toUpperCase();
    if (letters.isNotEmpty) return letters;
    final mail = (u?.email ?? authEmail.value ?? '').trim();
    if (mail.isNotEmpty) return mail[0].toUpperCase();
    return '?';
  }

  String get email => user.value?.email ?? '';

  bool get isSignedIn => user.value != null;

  /// True once the seller finished Stripe Connect payout onboarding. Drives
  /// the seller home "set up payments" prompt. Reactive.
  bool get sellerPayoutReady =>
      user.value?.sellerAccount?.stripeOnboardingCompleted ?? false;

  /// True once the driver finished Stripe Connect payout onboarding. Drives the
  /// wallet "set up payments" prompt — NOT the ability to deliver. Reactive.
  bool get driverPayoutReady =>
      user.value?.driverAccount?.stripeOnboardingCompleted ?? false;

  /// Whether to show the wallet's "Configurer mes paiements" prompt: the
  /// connected earner — seller *or* driver — hasn't finished Stripe Connect
  /// payout onboarding. Connect gates withdrawal only, never earning, so this is
  /// a prompt and not a block.
  ///
  /// Role-agnostic deliberately. Wallet lives under the ungated Profil tab, and
  /// for a seller it is the only route to payout setup: once a subscription
  /// lapses, the home banner falls behind [SubscriptionGate] while earnings —
  /// which accrued without Connect — stay stranded. Withdrawing money already
  /// earned must never require an active subscription.
  bool get needsPayoutSetup {
    final u = user.value;
    final driver = u?.driverAccount;
    if (driver != null) return !driver.stripeOnboardingCompleted;
    final seller = u?.sellerAccount;
    if (seller != null) return !seller.stripeOnboardingCompleted;
    return false;
  }

  /// Whether the connected driver may claim deliveries — mirrors the backend
  /// claim gate, which is **KYC only**. Stripe Connect payout onboarding is NOT
  /// required to claim/earn (it's enforced at cashout instead), so a driver can
  /// accept deliveries before setting up payments.
  bool get canDriverClaim =>
      user.value?.driverAccount?.kycStatus.toUpperCase() == 'APPROVED';

  /// Seller subscription gate — the single rule the app uses to decide whether
  /// to show the paywall. True when the connected seller's plan is live by
  /// **date/status** (never by re-charging on every login):
  ///   * status is ACTIVE or TRIALING, AND
  ///   * the period end is in the future — OR null, which only happens as the
  ///     dev/test "+1 month" fallback the backend writes after activation.
  ///
  /// Mirrors the backend `isSubscriptionActive` rule (backend stays the source
  /// of truth — this just reads the hydrated `/users/me` snapshot). Reactive:
  /// bind inside an [Obx] so it re-evaluates when [user] is refreshed.
  bool get hasActiveSellerSubscription {
    final seller = user.value?.sellerAccount;
    if (seller == null) return false;
    final status = seller.subscriptionStatus.toUpperCase();
    if (status != 'ACTIVE' && status != 'TRIALING') return false;
    final iso = seller.subscriptionCurrentPeriodEnd;
    if (iso == null || iso.isEmpty) return true; // dev/test fallback: no expiry
    final expiresAt = DateTime.tryParse(iso);
    if (expiresAt == null) return true;
    return expiresAt.isAfter(DateTime.now());
  }

  /// Replaces the cached user. Called by:
  ///   * `PostAuthRouter.decide()` after `/users/me`,
  ///   * `SignupFlowController._submitCompleteProfile()` after Gate 2,
  ///   * [refreshFromServer] after a successful re-fetch.
  void setUser(User u) {
    user.value = u;
    // /users/me's email is always the same as the auth email — keep
    // them in sync so the two views can't drift.
    authEmail.value = u.email;
  }

  /// Stores the Supabase auth identity's email after any successful
  /// auth call. Called from `AuthRepository._persistSession`.
  void setAuthEmail(String email) => authEmail.value = email;

  /// Stores the OAuth-provider name claims (when present). Null /
  /// empty values are normalized to `null` so callers can use a single
  /// `value != null && value.isNotEmpty`-style check.
  void setAuthName({String? firstName, String? lastName}) {
    authFirstName.value = (firstName != null && firstName.isNotEmpty)
        ? firstName
        : null;
    authLastName.value = (lastName != null && lastName.isNotEmpty)
        ? lastName
        : null;
  }

  /// Reads the persisted auth email from [TokenStorage] and seeds
  /// [authEmail]. Called once on cold start from `BootstrapController`
  /// so the value survives hot restart / app relaunch — without this,
  /// the OTP page falls back to the wizard's debug seed because the
  /// in-memory cache is fresh.
  ///
  /// No-op if [authEmail] is already populated (means a live auth call
  /// beat us to it).
  Future<void> hydrateFromStorage() async {
    if (authEmail.value != null) return;
    final stored = await _tokenStorage.readAuthIdentity();
    if (stored.email != null && stored.email!.isNotEmpty) {
      authEmail.value = stored.email;
    }
    if (stored.firstName != null && stored.firstName!.isNotEmpty) {
      authFirstName.value = stored.firstName;
    }
    if (stored.lastName != null && stored.lastName!.isNotEmpty) {
      authLastName.value = stored.lastName;
    }
  }

  /// Re-fetches `/users/me` and updates the cache.
  ///
  /// Throws [ApiFailure] on failure — callers decide whether to surface
  /// it. Typical use: after a profile-update PUT, call this so the
  /// settings screen reflects the new name/avatar immediately. Named
  /// distinctly from [GetxController.refresh] (which is a local
  /// notify) to avoid surprises.
  Future<User> refreshFromServer() async {
    final fresh = await _usersRepository.getMe();
    setUser(fresh);
    return fresh;
  }

  /// Drops the cached user. Called by `SignOutService` so the next
  /// screen sees `null` before navigation lands on Welcome.
  void clear() {
    user.value = null;
    authEmail.value = null;
    authFirstName.value = null;
    authLastName.value = null;
  }
}
