import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import 'package:incacook/core/common/styles/loaders.dart';
import 'package:incacook/core/config/stripe_config.dart';
import 'package:incacook/core/controllers/user_controller.dart';
import 'package:incacook/core/network/api_response.dart';
import 'package:incacook/features/orders/presentation/widgets/card_entry_sheet.dart';
import 'package:incacook/features/subscriptions/data/subscription_repository.dart';

/// Runs the in-app seller subscription purchase, mirroring the buyer
/// checkout: collect the card with Stripe's `CardField` popup → create the
/// subscription (server returns the first invoice's PaymentIntent secret) →
/// confirm the card → re-sync status from the server.
///
/// Returns true once the subscription is active. Callers own their own
/// busy/spinner state; this only drives the dialog + network + snackbars
/// (via [CustomLoaders], so feedback matches the rest of the app).
Future<bool> startCardSubscription(BuildContext context) async {
  if (!StripeConfig.isConfigured) {
    CustomLoaders.errorSnackBar(
      title: 'Paiement indisponible',
      message: "Le paiement n'est pas configuré.",
    );
    return false;
  }

  // 1. Collect the card → tokenized PaymentMethod id.
  final pmId = await showCardEntrySheet(context, brandLabel: 'd\'abonnement');
  if (pmId == null) return false; // user cancelled

  const repo = SubscriptionRepository();
  try {
    // 2. Create (or reuse) the subscription; get the PaymentIntent secret.
    final intent = await repo.createSubscription();

    // 3. Confirm the first invoice's PaymentIntent with the entered card.
    final secret = intent.clientSecret;
    if (secret != null && secret.isNotEmpty) {
      await Stripe.instance.confirmPayment(
        paymentIntentClientSecret: secret,
        data: PaymentMethodParams.cardFromMethodId(
          paymentMethodData: PaymentMethodDataCardFromMethod(
            paymentMethodId: pmId,
          ),
        ),
      );
    }

    // 4. Server re-syncs from Stripe (GET status), then refresh /users/me so
    //    the SubscriptionGate sees the active flag and unlocks the tabs.
    await repo.getStatus();
    final fresh = await UserController.instance.refreshFromServer();
    final active = fresh.sellerAccount?.subscriptionActive ?? false;
    if (active) {
      CustomLoaders.successSnackBar(title: 'Abonnement activé !');
    } else {
      CustomLoaders.warningSnackBar(
        title: 'Paiement reçu',
        message: 'Activation en cours…',
      );
    }
    return active;
  } on StripeException catch (e) {
    CustomLoaders.errorSnackBar(
      title: 'Paiement refusé',
      message: e.error.localizedMessage ?? 'La carte a été refusée.',
    );
    return false;
  } on ApiFailure catch (e) {
    CustomLoaders.errorSnackBar(
      title: 'Abonnement impossible',
      message: e.message,
    );
    return false;
  } catch (_) {
    CustomLoaders.errorSnackBar(
      title: 'Abonnement impossible',
      message: 'Une erreur est survenue. Réessaie plus tard.',
    );
    return false;
  }
}
