import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:incacook/core/controllers/user_controller.dart';
import 'package:incacook/features/subscriptions/presentation/screens/subscription_paywall_screen.dart';

/// Wraps a seller-only feature screen. Reactively shows the paywall when
/// the seller's $4/mo subscription is inactive, and the real [child] once
/// it's active. Used for the Accueil / Commandes / Catalogue tabs; the
/// Profil tab is intentionally left ungated so settings + payout
/// onboarding stay reachable. The backend enforces the same gate, so this
/// is UX, not security.
class SubscriptionGate extends StatelessWidget {
  const SubscriptionGate({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final userCtrl = Get.find<UserController>();
    return Obx(() {
      final active =
          userCtrl.user.value?.sellerAccount?.subscriptionActive ?? false;
      return active ? child : const SubscriptionPaywallScreen();
    });
  }
}
