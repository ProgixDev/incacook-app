import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/widgets/decor/decor_blob.dart';
import 'package:incacook/features/supply_catalog/presentation/screens/supply_catalog_screen.dart';
import 'package:incacook/features/payments/data/payout_onboarding_service.dart';
import 'package:incacook/features/payments/presentation/widgets/payout_setup_banner.dart';
import 'package:incacook/features/seller/presentation/widgets/order_requests_section.dart';
import 'package:incacook/features/seller/presentation/widgets/seller_home_appbar.dart';
import 'package:incacook/features/seller/presentation/widgets/today_snapshot_card.dart';
import 'package:incacook/features/subscriptions/presentation/widgets/subscription_card.dart';

class SellerHomeScreen extends StatelessWidget {
  const SellerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appBarHeight =
        MediaQuery.viewPaddingOf(context).top + AppSizes.appBarHeight;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const SellerHomeAppBar(),
      body: Stack(
        children: [
          //* decorative top-right blob (purely cosmetic, no input).
          const Positioned(
            top: -8,
            right: -16,
            child: IgnorePointer(child: DecorBlob()),
          ),
          ListView(
            padding: EdgeInsets.only(
              top: appBarHeight + AppSizes.md,
              bottom: AppSizes.spaceBtwSections,
            ),
            children: [
              //* Payout setup nudge — visible until the seller completes
              //* Stripe Connect Express onboarding. Tap is stubbed until the
              //* StripeConnectService lands.
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                child: PayoutSetupBanner(
                  onTap: () => _onPayoutSetupTap(context),
                ),
              ),
              const Gap(AppSizes.md),
              //* Platform subscription status + renewal + manage (Stripe
              //* Billing Portal). Visible here because Accueil is only
              //* reachable once the subscription is active.
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSizes.md),
                child: SubscriptionCard(),
              ),
              const Gap(AppSizes.md),
              //* Shortcut to the admin-managed supply catalog (sellers buy
              //* products from the platform).
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                child: _CatalogShortcut(
                  onTap: () => Get.to<void>(() => const SupplyCatalogScreen()),
                ),
              ),
              const Gap(AppSizes.md),
              //? today snapshot owns its horizontal padding so order requests
              //? can run edge-to-edge for the carousel peek.
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSizes.md),
                child: TodaySnapshotCard(),
              ),
              const Gap(AppSizes.spaceBtwSections),
              const OrderRequestsSection(),
            ],
          ),
        ],
      ),
    );
  }

  void _onPayoutSetupTap(BuildContext context) {
    // Opens Stripe Connect Express onboarding so the seller can add the
    // bank/debit card that receives their earnings.
    PayoutOnboardingService.openOnboarding(context);
  }
}

/// Tappable card on the seller dashboard linking to the supply catalog.
class _CatalogShortcut extends StatelessWidget {
  const _CatalogShortcut({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: scheme.primaryContainer.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Row(
          children: [
            Icon(Iconsax.shop, color: scheme.primary),
            const Gap(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Catalogue fournisseur',
                    style: text.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Achetez des produits pour votre activité',
                    style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            Icon(Iconsax.arrow_right_3, color: scheme.onSurfaceVariant, size: 18),
          ],
        ),
      ),
    );
  }
}
