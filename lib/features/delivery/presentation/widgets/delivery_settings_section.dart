import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/features/authentication/services/sign_out_service.dart';
import 'package:incacook/features/settings/domain/setting_menu_item.dart';
import 'package:incacook/features/settings/presentation/widgets/appearance_sheet.dart';
import 'package:incacook/features/settings/presentation/widgets/profile_menu_card.dart';
import 'package:incacook/features/wallet/presentation/wallet_screen.dart';

/// Settings panel shown in the delivery sheet's body when the
/// [DeliveryNavTab.settings] tab is selected. Reuses the client's
/// [SettingMenuSection] so the visual language matches the main settings
/// screen — currently just appearance + logout, more can be added.
class DeliverySettingsSection extends StatelessWidget {
  const DeliverySettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final accountItems = <SettingMenuItem>[
      SettingMenuItem(
        icon: Iconsax.card,
        title: AppTexts.settingsWallet,
        onTap: () => Get.to<void>(() => const WalletScreen()),
      ),
    ];

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
      child: Column(
        children: [
          SettingMenuSection(items: accountItems),
          const SizedBox(height: AppSizes.md),
          SettingMenuSection(items: supportItems),
          const SizedBox(height: AppSizes.md),
          SettingMenuSection(items: logoutItems),
        ],
      ),
    );
  }
}
