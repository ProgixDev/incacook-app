import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/core/controllers/user_controller.dart';
import 'package:incacook/features/authentication/services/sign_out_service.dart';
import 'package:incacook/features/payments/data/payout_onboarding_service.dart';
import 'package:incacook/features/settings/domain/setting_menu_item.dart';
import 'package:incacook/features/settings/presentation/widgets/appearance_sheet.dart';
import 'package:incacook/features/settings/presentation/widgets/profile_menu_card.dart';
import 'package:incacook/features/wallet/presentation/wallet_screen.dart';

/// Settings panel shown in the delivery sheet's body when the
/// [DeliveryNavTab.settings] tab is selected. Reuses the client's
/// [SettingMenuSection] so the visual language matches the main settings
/// screen — wallet + payout setup + appearance + logout.
class DeliverySettingsSection extends StatelessWidget {
  const DeliverySettingsSection({super.key});

  /// Opens Stripe Connect payout onboarding, then refreshes the driver
  /// profile so the entry hides itself once payouts are ready (no restart).
  Future<void> _configurePayments(BuildContext context) async {
    await PayoutOnboardingService.openOnboarding(context);
    try {
      await UserController.instance.refreshFromServer();
    } catch (_) {
      // Best-effort refresh — the next /users/me read will reconcile.
    }
  }

  @override
  Widget build(BuildContext context) {
    final supportItems = <SettingMenuItem>[
      SettingMenuItem(
        icon: Iconsax.brush_2,
        title: AppTexts.settingsAppearance,
        onTap: () => AppearanceSheet.show(context),
      ),
    ];

    final logoutItems = <SettingMenuItem>[
      SettingMenuItem(
        icon: Iconsax.logout,
        title: AppTexts.settingsLogout,
        showChevron: false,
        onTap: () => SignOutService.promptAndSignOut(context),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
      // Obx so the "Configurer mes paiements" row appears until payouts are
      // set up and disappears right after onboarding completes.
      child: Obx(() {
        final payoutReady = UserController.instance.driverPayoutReady;
        final accountItems = <SettingMenuItem>[
          SettingMenuItem(
            icon: Iconsax.card,
            title: AppTexts.settingsWallet,
            onTap: () => Get.to<void>(() => const WalletScreen()),
          ),
          if (!payoutReady)
            SettingMenuItem(
              icon: Iconsax.card_pos,
              title: AppTexts.incomingOrderConfigurePaymentsCta,
              onTap: () => _configurePayments(context),
            ),
        ];

        return Column(
          children: [
            SettingMenuSection(items: accountItems),
            const SizedBox(height: AppSizes.md),
            SettingMenuSection(items: supportItems),
            const SizedBox(height: AppSizes.md),
            SettingMenuSection(items: logoutItems),
          ],
        );
      }),
    );
  }
}
