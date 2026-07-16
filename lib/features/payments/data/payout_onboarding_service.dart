import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:incacook/core/constants/api_constants.dart';
import 'package:incacook/core/controllers/user_controller.dart';
import 'package:incacook/core/network/api_client.dart';
import 'package:incacook/core/network/api_response.dart';
import 'package:incacook/core/utils/log.dart';

/// Drives the seller / driver Stripe Connect Express payout onboarding so
/// they can add the bank/debit card that receives their earnings.
///
/// Flow: `POST /v1/stripe/onboarding/account-link` creates (or reuses) the
/// Connect account and returns a short-lived hosted Account Link, which we open
/// in the system browser. Stripe's `return_url` bounces to
/// `incacook://stripe/return` (via the backend bridge), which — together with
/// app-resume — tells us the user is back, so we reconcile the live payout
/// status server-side instead of guessing or waiting on the webhook.
class PayoutOnboardingService {
  const PayoutOnboardingService._();

  /// Requests a fresh Account Link, opens it, then waits for the user to return
  /// and reconciles payout status. Surfaces failures as a SnackBar on [context].
  /// Returns true when the hosted page was opened.
  static Future<bool> openOnboarding(BuildContext context) async {
    try {
      final result = await _requestAccountLink();
      final uri = Uri.parse(result.data);
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
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
      await _awaitReturn();
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
  static Future<void> openDashboard(BuildContext context) async {
    try {
      final result = await ApiClient.instance.post<String>(
        '${ApiConstants.apiPrefix}/stripe/onboarding/dashboard-link',
        decoder: (json) => (json! as Map<String, dynamic>)['url'] as String,
      );
      final opened = await launchUrl(
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
  static Future<ApiSuccess<String>> _requestAccountLink() async {
    for (var attempt = 1; ; attempt++) {
      try {
        return await ApiClient.instance.post<String>(
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
  static Future<void> _awaitReturn() async {
    final completer = Completer<void>();
    final appLinks = AppLinks();
    final observer = _ResumeObserver(() {
      if (!completer.isCompleted) completer.complete();
    });

    final linkSub = appLinks.uriLinkStream.listen((uri) {
      if (uri.scheme == 'incacook' &&
          uri.host == 'stripe' &&
          !completer.isCompleted) {
        completer.complete();
      }
    }, onError: (Object _) {});
    WidgetsBinding.instance.addObserver(observer);

    try {
      await completer.future.timeout(
        const Duration(minutes: 5),
        onTimeout: () {},
      );
    } finally {
      await linkSub.cancel();
      WidgetsBinding.instance.removeObserver(observer);
    }
  }

  /// Forces the backend to re-read live Connect status
  /// (`GET /v1/stripe/onboarding/status` → `accounts.retrieve` → persist
  /// `stripeOnboardingCompleted`), so we don't depend on the `account.updated`
  /// webhook, then refreshes the local user snapshot the payout gate reads.
  ///
  /// Android can resume the app before Stripe's account object has fully
  /// settled, so poll briefly instead of doing a single stale read.
  static Future<void> _reconcilePayoutStatus() async {
    for (var attempt = 0; attempt < 6; attempt++) {
      try {
        final result = await ApiClient.instance.get<Object?>(
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
        break;
      }
      await Future<void>.delayed(const Duration(seconds: 2));
    }
    try {
      await UserController.instance.refreshFromServer();
    } catch (e) {
      logWarning('[Payout] refreshFromServer failed: $e');
    }
  }

  static void _toast(BuildContext context, String message) {
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
