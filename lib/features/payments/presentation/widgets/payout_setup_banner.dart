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
    this.reconcileFailed = false,
  });

  final VoidCallback onTap;

  /// True when the earner already submitted their details and Stripe is
  /// verifying them (`PayoutSetupState.pendingVerification`) — swaps the
  /// "set up payments / Commencer" copy for "verification in progress", and
  /// the CTA re-opens Stripe to check status instead of starting over.
  final bool pendingVerification;

  /// True when the last status check itself failed (D6) — offline,
  /// transport stall — rather than "not done yet". Takes priority over
  /// [pendingVerification]: if we couldn't check, we don't actually know
  /// whether verification is still pending. The CTA reuses the same [onTap]
  /// (re-opens Stripe, which re-triggers the reconcile at the end), so no
  /// separate retry callback is needed.
  final bool reconcileFailed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = context.appColors;
    final textTheme = Theme.of(context).textTheme;

    final IconData icon;
    final String title;
    final String subtitle;
    final String cta;
    if (reconcileFailed) {
      icon = Iconsax.warning_2;
      title = AppTexts.payoutSetupBannerErrorTitle;
      subtitle = AppTexts.payoutSetupBannerErrorSubtitle;
      cta = AppTexts.payoutSetupBannerErrorCta;
    } else if (pendingVerification) {
      icon = Iconsax.clock;
      title = AppTexts.payoutSetupBannerPendingTitle;
      subtitle = AppTexts.payoutSetupBannerPendingSubtitle;
      cta = AppTexts.payoutSetupBannerPendingCta;
    } else {
      icon = Iconsax.card_pos;
      title = AppTexts.payoutSetupBannerTitle;
      subtitle = AppTexts.payoutSetupBannerSubtitle;
      cta = AppTexts.payoutSetupBannerCta;
    }

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
            child: Icon(icon, color: colors.selectedOnSurface, size: 20),
          ),
          const Gap(AppSizes.md - 2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Gap(2),
                Text(
                  subtitle,
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
              cta,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
