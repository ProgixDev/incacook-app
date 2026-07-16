import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/core/utils/theme/theme_extensions.dart';
import 'package:incacook/core/widgets/effects/frosted_surface.dart';

/// Prompt shown on the seller / delivery home screens until the user
/// finishes Stripe Connect Express onboarding. Tap [onTap] to open the
/// hosted Stripe flow (wired once `StripeConnectService` lands).
///
/// The banner is a skeleton today — visuals only, no Stripe wiring. The
/// signup flow no longer collects payout details, so this is the
/// post-signup nudge that takes its place.
class PayoutSetupBanner extends StatelessWidget {
  const PayoutSetupBanner({
    super.key,
    required this.onTap,
    this.pendingVerification = false,
  });

  final VoidCallback onTap;

  /// True when the earner already submitted their details and Stripe is
  /// verifying them (`PayoutSetupState.pendingVerification`) — swaps the
  /// "set up payments / Commencer" copy for "verification in progress", and
  /// the CTA re-opens Stripe to check status instead of starting over.
  final bool pendingVerification;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = context.appColors;
    final textTheme = Theme.of(context).textTheme;

    return FrostedSurface(
      borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
      padding: const EdgeInsets.all(AppSizes.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: colors.selectedSurface,
              shape: BoxShape.circle,
            ),
            child: Icon(
              pendingVerification ? Iconsax.clock : Iconsax.card_pos,
              color: colors.selectedOnSurface,
              size: 20,
            ),
          ),
          const Gap(AppSizes.md - 2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  pendingVerification
                      ? AppTexts.payoutSetupBannerPendingTitle
                      : AppTexts.payoutSetupBannerTitle,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Gap(2),
                Text(
                  pendingVerification
                      ? AppTexts.payoutSetupBannerPendingSubtitle
                      : AppTexts.payoutSetupBannerSubtitle,
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const Gap(AppSizes.sm),
          TextButton(
            onPressed: onTap,
            style: TextButton.styleFrom(
              foregroundColor: scheme.primary,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.md,
                vertical: AppSizes.sm,
              ),
            ),
            child: Text(
              pendingVerification
                  ? AppTexts.payoutSetupBannerPendingCta
                  : AppTexts.payoutSetupBannerCta,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
