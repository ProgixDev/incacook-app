import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/controllers/user_controller.dart';
import 'package:incacook/core/models/auth/payout_readiness.dart';
import 'package:incacook/core/widgets/decor/decor_blob.dart';
import 'package:incacook/features/supply_catalog/presentation/screens/supply_catalog_screen.dart';
import 'package:incacook/features/payments/data/payout_onboarding_service.dart';
import 'package:incacook/features/payments/presentation/widgets/payout_setup_banner.dart';
import 'package:incacook/features/seller/presentation/widgets/order_requests_section.dart';
import 'package:incacook/features/seller/presentation/widgets/seller_home_appbar.dart';
import 'package:incacook/features/seller/presentation/widgets/today_snapshot_card.dart';
import 'package:incacook/features/subscriptions/presentation/widgets/subscription_card.dart';

class SellerHomeScreen extends StatefulWidget {
  const SellerHomeScreen({super.key});

  @override
  State<SellerHomeScreen> createState() => _SellerHomeScreenState();
}

class _SellerHomeScreenState extends State<SellerHomeScreen> {
  final RefreshController _refreshController = RefreshController();

  Future<void> _onRefresh() async {
    // Refresh user data and controller states
    try {
      await UserController.instance.refreshFromServer();
      _refreshController.refreshCompleted();
    } catch (e) {
      _refreshController.refreshFailed();
    }
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

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
          SmartRefresher(
            controller: _refreshController,
            onRefresh: _onRefresh,
            enablePullDown: true,
            header: const WaterDropMaterialHeader(),
            child: ListView(
            padding: EdgeInsets.only(
              top: appBarHeight + AppSizes.md,
              bottom: AppSizes.spaceBtwSections,
            ),
            children: [
              //* Payout setup nudge — visible until the seller completes
              //* Stripe Connect Express onboarding.
              Obx(
                () => UserController.instance.sellerPayoutReady
                    ? const SizedBox.shrink()
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSizes.md,
                            ),
                            child: PayoutSetupBanner(
                              onTap: () => _onPayoutSetupTap(context),
                              // Details already with Stripe → swap the
                              // setup CTA for "verification in progress".
                              pendingVerification:
                                  UserController.instance.payoutSetupState ==
                                  PayoutSetupState.pendingVerification,
                              // D6: the last status check itself failed —
                              // distinct from "not done yet".
                              reconcileFailed: PayoutOnboardingService
                                  .instance
                                  .reconcileFailed
                                  .value,
                            ),
                          ),
                          const Gap(AppSizes.md),
                        ],
                      ),
              ),
              //* Platform subscription status + renewal + store subscription
              //* management. Visible here because Accueil is only reachable
              //* once the subscription is active.
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
          ),
        ],
      ),
    );
  }

  void _onPayoutSetupTap(BuildContext context) {
    // Opens Stripe Connect Express onboarding so the seller can add the
    // bank/debit card that receives their earnings.
    PayoutOnboardingService.instance.openOnboarding(context);
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
                    style: text.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Achetez des produits pour votre activité',
                    style: text.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Iconsax.arrow_right_3,
              color: scheme.onSurfaceVariant,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
