import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';

import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/widgets/effects/frosted_surface.dart';
import 'package:incacook/features/authentication/presentation/widgets/signup_flow/signup_step_layout.dart';
import 'package:incacook/features/payments/data/payout_onboarding_service.dart';

/// Final, **optional** signup step for sellers & drivers: set up Stripe
/// Connect so they can receive their earnings. Tapping "Configurer" opens
/// Stripe's hosted onboarding (bank / debit card). It's skippable — the
/// bottom bar's Continue finishes registration, and the dashboard payout
/// banner re-prompts later.
class PayoutSetupPage extends StatelessWidget {
  const PayoutSetupPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SignupStepLayout(
      title: 'Recevez vos paiements',
      description:
          'Ajoutez votre carte / compte bancaire pour recevoir vos gains. '
          'C\'est sécurisé via Stripe. Vous pouvez aussi le faire plus tard.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FrostedSurface(
            borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
            padding: const EdgeInsets.all(AppSizes.lg),
            child: Column(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Iconsax.card_pos, color: scheme.primary, size: 26),
                ),
                const Gap(AppSizes.md),
                Text(
                  'Configuration des paiements',
                  style:
                      textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                  textAlign: TextAlign.center,
                ),
                const Gap(AppSizes.xs),
                Text(
                  'Stripe collecte votre carte/IBAN en toute sécurité. '
                  'IncaCook ne stocke jamais vos coordonnées bancaires.',
                  style: textTheme.bodySmall
                      ?.copyWith(color: scheme.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
                const Gap(AppSizes.lg),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        PayoutOnboardingService.openOnboarding(context),
                    icon: const Icon(Iconsax.card_add, size: 18),
                    label: const Text('Configurer les paiements'),
                  ),
                ),
              ],
            ),
          ),
          const Gap(AppSizes.md),
          Row(
            children: [
              Icon(Iconsax.info_circle, size: 16, color: scheme.onSurfaceVariant),
              const Gap(AppSizes.xs),
              Expanded(
                child: Text(
                  'Optionnel — appuyez sur Continuer pour terminer; vous pourrez '
                  'configurer vos paiements plus tard depuis votre profil.',
                  style: textTheme.bodySmall
                      ?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
