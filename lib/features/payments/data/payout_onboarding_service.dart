import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:incacook/core/constants/api_constants.dart';
import 'package:incacook/core/network/api_client.dart';
import 'package:incacook/core/network/api_response.dart';

/// Drives the seller / driver Stripe Connect Express payout onboarding so
/// they can add the bank/debit card that receives their earnings.
///
/// Flow: `POST /v1/stripe/onboarding/account-link` creates (or reuses) the
/// Connect account and returns a short-lived hosted Account Link, which we
/// open in the system browser. Stripe redirects back to the configured
/// return/refresh URLs when the user finishes.
class PayoutOnboardingService {
  const PayoutOnboardingService._();

  /// Requests a fresh Account Link and opens it. Surfaces failures as a
  /// SnackBar on [context]. Returns true when the hosted page was opened.
  static Future<bool> openOnboarding(BuildContext context) async {
    try {
      final result = await ApiClient.instance.post<String>(
        '${ApiConstants.apiPrefix}/stripe/onboarding/account-link',
        decoder: (json) =>
            (json! as Map<String, dynamic>)['url'] as String,
      );
      final uri = Uri.parse(result.data);
      final opened =
          await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened && context.mounted) {
        _toast(context, 'Impossible d\'ouvrir la configuration des paiements.');
      }
      return opened;
    } on ApiFailure catch (e) {
      if (context.mounted) {
        _toast(context, 'Configuration des paiements impossible: ${e.message}');
      }
      return false;
    } catch (e) {
      if (context.mounted) {
        _toast(context, 'Configuration des paiements impossible: $e');
      }
      return false;
    }
  }

  static void _toast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
