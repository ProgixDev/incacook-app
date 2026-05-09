import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/core/widgets/decor/decor_blob.dart';
import 'package:incacook/features/payments/presentation/widgets/payout_setup_banner.dart';
import 'package:incacook/features/seller/presentation/widgets/order_requests_section.dart';
import 'package:incacook/features/seller/presentation/widgets/seller_home_appbar.dart';
import 'package:incacook/features/seller/presentation/widgets/today_snapshot_card.dart';

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
    // Stub — replace with the Stripe Connect onboarding flow once the
    // StripeConnectService + PayoutOnboardingScreen ship.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(AppTexts.payoutGatingSnackbarSeller),
      ),
    );
  }
}
