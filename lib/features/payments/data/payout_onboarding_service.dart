import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:incacook/core/constants/api_constants.dart';
import 'package:incacook/core/controllers/user_controller.dart';
import 'package:incacook/core/network/api_client.dart';
import 'package:incacook/core/network/api_response.dart';
import 'package:incacook/core/utils/log.dart';

/// Abstraction over [AppLinks]'s incoming-URI stream so tests can feed
/// synthetic `incacook://stripe/...` deep links without touching platform
/// channels.
abstract class PayoutReturnLinkSource {
  Stream<Uri> get uriLinkStream;
}

class _AppLinksSource implements PayoutReturnLinkSource {
  final AppLinks _appLinks = AppLinks();

  @override
  Stream<Uri> get uriLinkStream => _appLinks.uriLinkStream;
}

/// Matches `launchUrl`'s signature so the real `url_launcher` function (the
/// default) can be swapped for a recording fake in tests.
typedef UrlLauncher = Future<bool> Function(Uri url, {LaunchMode mode});

/// How the user's return from the hosted onboarding page was detected.
enum _ReturnKind {
  /// `incacook://stripe/return` (or an app-resume with no deep link at all —
  /// R2/R14, which can't distinguish return from refresh either).
  completed,

  /// `incacook://stripe/refresh` — Stripe's `refresh_url`, hit when the
  /// Account Link expired or was otherwise invalid. Must mint a fresh link,
  /// not be treated as a completed return.
  refresh,

  /// Neither arrived within the wait window.
  timeout,
}

/// Drives the seller / driver Stripe Connect Express payout onboarding so
/// they can add the bank/debit card that receives their earnings.
///
/// Flow: `POST /v1/stripe/onboarding/account-link` creates (or reuses) the
/// Connect account and returns a short-lived hosted Account Link, which we open
/// in the system browser. Stripe's `return_url` bounces to
/// `incacook://stripe/return` (via the backend bridge), which — together with
/// app-resume — tells us the user is back, so we reconcile the live payout
/// status server-side instead of guessing or waiting on the webhook.
/// Stripe's `refresh_url` bounces to `incacook://stripe/refresh` when the
/// Account Link expired or was otherwise invalid; that case mints a fresh
/// link and reopens it instead of polling a status that can't have changed.
class PayoutOnboardingService extends GetxService {
  PayoutOnboardingService({
    ApiClient? apiClient,
    UserController? userController,
    PayoutReturnLinkSource? linkSource,
    UrlLauncher? urlLauncher,
  }) : _apiClient = apiClient ?? Get.find<ApiClient>(),
       _userController = userController ?? Get.find<UserController>(),
       _linkSource = linkSource ?? _AppLinksSource(),
       _urlLauncher = urlLauncher ?? launchUrl;

  static PayoutOnboardingService get instance => Get.find();

  final ApiClient _apiClient;
  final UserController _userController;
  final PayoutReturnLinkSource _linkSource;
  final UrlLauncher _urlLauncher;

  /// True when the last reconcile attempt (warm return or cold-start deep
  /// link) couldn't even ask the backend for live status — network stall,
  /// offline, cold instance. The banner reads this to tell "not done yet"
  /// apart from "we couldn't check" (D6), instead of silently staying in
  /// whatever state it was in. Reset at the start of every attempt, so a
  /// later successful reconcile clears a previous failure automatically.
  /// Deliberately NOT set when the subsequent local
  /// [UserController.refreshFromServer] fails — the backend/DB state is
  /// already correct by that point; only the local cache read is stale,
  /// which the rest of the codebase already treats as best-effort.
  final RxBool reconcileFailed = false.obs;

  /// How many times a `refresh_url` bounce is allowed to re-mint and reopen
  /// a fresh Account Link before giving up and falling through to reconcile
  /// (belt-and-braces so a link that keeps expiring immediately can't loop
  /// forever).
  static const int _maxRefreshRetries = 2;

  /// Requests a fresh Account Link, opens it, then waits for the user to return
  /// and reconciles payout status. Surfaces failures as a SnackBar on [context].
  /// Returns true when the hosted page was opened.
  Future<bool> openOnboarding(BuildContext context) async {
    try {
      var result = await _requestAccountLink();
      for (var refreshAttempt = 0; ; refreshAttempt++) {
        final uri = Uri.parse(result.data);
        final opened = await _urlLauncher(
          uri,
          mode: LaunchMode.externalApplication,
        );
        if (!opened) {
          if (context.mounted) {
            _toast(
              context,
              'Impossible d\'ouvrir la configuration des paiements.',
            );
          }
          return false;
        }
        // Wait for the user to come back (deep link or app-resume), THEN refresh —
        // the old code refreshed the instant the browser opened, so status never
        // updated. Reconcile pulls the live Connect state server-side.
        final kind = await _awaitReturn();
        if (kind == _ReturnKind.refresh &&
            refreshAttempt < _maxRefreshRetries) {
          logInfo('[Payout] refresh_url bounce — minting a fresh link');
          result = await _requestAccountLink();
          continue;
        }
        break;
      }
      await _reconcilePayoutStatus();
      return true;
    } on ApiFailure catch (e) {
      if (context.mounted) {
        // Transport-level stalls (cold backend / flaky network) get a warmer,
        // actionable message than the raw "server unreachable" copy — the user
        // just needs to retry once the instance has woken.
        final isTransport =
            e.code == 'INCACOOK_OFFLINE' || e.code == 'INCACOOK_TIMEOUT';
        _toast(
          context,
          isTransport
              ? 'Le serveur démarre, réessayez dans quelques instants.'
              : 'Configuration des paiements impossible : ${e.message}',
        );
      }
      return false;
    } catch (e) {
      if (context.mounted) {
        _toast(context, 'Configuration des paiements impossible: $e');
      }
      return false;
    }
  }

  /// Opens the seller/driver's Stripe Express dashboard (manage bank account,
  /// view Stripe-side payout history) in the system browser. This is the
  /// profile "Paiement" action — distinct from [openOnboarding] (which *sets
  /// up* payouts) and from the wallet (the internal balance).
  ///
  /// The backend 403s (`PayoutSetupRequired`) until onboarding is complete, so
  /// callers should keep the entry point disabled until then; this still fails
  /// gracefully with a SnackBar if it is reached in that state anyway.
  Future<void> openDashboard(BuildContext context) async {
    try {
      final result = await _apiClient.post<String>(
        '${ApiConstants.apiPrefix}/stripe/onboarding/dashboard-link',
        decoder: (json) => (json! as Map<String, dynamic>)['url'] as String,
      );
      final opened = await _urlLauncher(
        Uri.parse(result.data),
        mode: LaunchMode.externalApplication,
      );
      if (!opened && context.mounted) {
        _toast(context, 'Impossible d\'ouvrir votre tableau de bord Stripe.');
      }
    } on ApiFailure catch (e) {
      if (context.mounted) {
        _toast(context, 'Tableau de bord indisponible : ${e.message}');
      }
    } catch (e) {
      if (context.mounted) {
        _toast(context, 'Tableau de bord indisponible : $e');
      }
    }
  }

  /// How many times to attempt the Account Link before surfacing a failure.
  /// This is the heaviest call in the app (the backend wakes and round-trips to
  /// Stripe), so a cold/slept Railway instance can time out or drop the first
  /// attempt(s). Each retry gives the instance more time to warm, with a
  /// growing backoff between tries.
  static const int _accountLinkMaxAttempts = 3;

  /// Requests the hosted Account Link, retrying on a transport-level stall with
  /// increasing backoff so a cold backend has time to spin up. Only transport
  /// failures (`statusCode == 0`, no HTTP response) are retried — a real
  /// 4xx/5xx has a non-zero status and rethrows immediately.
  Future<ApiSuccess<String>> _requestAccountLink() async {
    for (var attempt = 1; ; attempt++) {
      try {
        return await _apiClient.post<String>(
          '${ApiConstants.apiPrefix}/stripe/onboarding/account-link',
          decoder: (json) => (json! as Map<String, dynamic>)['url'] as String,
        );
      } on ApiFailure catch (e) {
        if (e.statusCode != 0 || attempt >= _accountLinkMaxAttempts) rethrow;
        final backoff = Duration(seconds: 2 * attempt);
        logWarning(
          '[Payout] account-link transport stall '
          '(attempt $attempt/$_accountLinkMaxAttempts) — '
          'retrying in ${backoff.inSeconds}s',
        );
        await Future<void>.delayed(backoff);
      }
    }
  }

  /// Completes when the user returns from the hosted onboarding — whichever
  /// comes first: an incoming `incacook://stripe/...` deep link, or the app
  /// being resumed. Times out after 5 min so it can never hang forever.
  Future<_ReturnKind> _awaitReturn() async {
    final completer = Completer<_ReturnKind>();
    final observer = _ResumeObserver(() {
      if (!completer.isCompleted) completer.complete(_ReturnKind.completed);
    });

    final linkSub = _linkSource.uriLinkStream.listen((uri) {
      if (uri.scheme == 'incacook' &&
          uri.host == 'stripe' &&
          !completer.isCompleted) {
        completer.complete(
          uri.path == '/refresh' ? _ReturnKind.refresh : _ReturnKind.completed,
        );
      }
    }, onError: (Object _) {});
    WidgetsBinding.instance.addObserver(observer);

    try {
      return await completer.future.timeout(
        const Duration(minutes: 5),
        onTimeout: () => _ReturnKind.timeout,
      );
    } finally {
      await linkSub.cancel();
      WidgetsBinding.instance.removeObserver(observer);
    }
  }

  /// Called from the app-wide deep-link listener (`main.dart`) for an
  /// `incacook://stripe/...` URI that arrives with no in-flight
  /// [openOnboarding] call to catch it — the cold-start case, where the app
  /// process died while the hosted onboarding browser tab was open and
  /// `_awaitReturn`'s listener died with it. A `return` bounce reconciles
  /// live status exactly like the warm path; a `refresh` bounce is a no-op
  /// here — auto-reopening the browser on cold boot would be a surprising
  /// side effect unrelated to this session, and the banner already
  /// correctly shows "not complete" since nothing changed. (D3 already
  /// covers the in-flight refresh case.)
  Future<void> reconcileFromDeepLink(Uri uri) async {
    if (uri.path == '/refresh') {
      logInfo('[Payout] cold-start refresh_url bounce — no action');
      return;
    }
    await _reconcilePayoutStatus();
  }

  /// Forces the backend to re-read live Connect status
  /// (`GET /v1/stripe/onboarding/status` → `accounts.retrieve` → persist
  /// `stripeOnboardingCompleted`), so we don't depend on the `account.updated`
  /// webhook, then refreshes the local user snapshot the payout gate reads.
  ///
  /// Android can resume the app before Stripe's account object has fully
  /// settled, so poll briefly instead of doing a single stale read.
  Future<void> _reconcilePayoutStatus() async {
    reconcileFailed.value = false;
    for (var attempt = 0; attempt < 6; attempt++) {
      try {
        final result = await _apiClient.get<Object?>(
          '${ApiConstants.apiPrefix}/stripe/onboarding/status',
          decoder: (json) => json,
        );
        final data = result.data;
        if (data is Map<String, dynamic>) {
          final completed = data['onboardingCompleted'] == true;
          logInfo(
            '[Payout] status completed=$completed '
            'charges=${data['chargesEnabled']} payouts=${data['payoutsEnabled']} '
            'details=${data['detailsSubmitted']} attempt=${attempt + 1}',
          );
          if (completed) break;
        }
      } catch (e) {
        logWarning(
          '[Payout] status refresh failed: $e (users/me will still refresh)',
        );
        reconcileFailed.value = true;
        break;
      }
      await Future<void>.delayed(const Duration(seconds: 2));
    }
    try {
      await _userController.refreshFromServer();
    } catch (e) {
      logWarning('[Payout] refreshFromServer failed: $e');
    }
  }

  void _toast(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

/// Fires [onResume] once the app returns to the foreground.
class _ResumeObserver with WidgetsBindingObserver {
  _ResumeObserver(this.onResume);
  final VoidCallback onResume;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) onResume();
  }
}
