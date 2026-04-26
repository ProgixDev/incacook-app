import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import 'package:homemade/core/common/widgets/appbar/appbar.dart';
import 'package:homemade/core/common/widgets/custon_shapes/container/circular_container.dart';
import 'package:homemade/core/constants/colors.dart';
import 'package:homemade/core/constants/sizes.dart';
import 'package:homemade/core/constants/text_strings.dart';
import 'package:homemade/features/profile/domain/Setting_menu_item.dart';
import 'package:homemade/features/profile/presentation/widgets/profile_menu_card.dart';
import 'package:homemade/features/profile/presentation/widgets/profile_user_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final accountItems = <SettingMenuItem>[
      SettingMenuItem(
        icon: Iconsax.cup,
        title: AppTexts.settingsWallet,
        trailingText: '0 points',
        showChevron: false,
        onTap: () {},
      ),
      SettingMenuItem(
        icon: Iconsax.clipboard_text,
        title: AppTexts.settingsOrders,
        onTap: () {},
      ),
      SettingMenuItem(
        icon: Iconsax.card,
        title: AppTexts.settingsPay,
        trailingText: '\$0.00',
        showChevron: false,
        onTap: () {},
      ),
      SettingMenuItem(
        icon: Iconsax.ticket_discount,
        title: AppTexts.settingsVouchers,
        onTap: () {},
      ),
      // SettingMenuItem(
      //   icon: Iconsax.crown_1,
      //   title: AppTexts.settingsPro,
      //   onTap: () {},
      // ),
    ];

    final supportItems = <SettingMenuItem>[
      SettingMenuItem(
        icon: Iconsax.message_question,
        title: AppTexts.settingsGetHelp,
        onTap: () {},
      ),
      SettingMenuItem(
        icon: Iconsax.info_circle,
        title: AppTexts.settingsAboutApp,
        onTap: () {},
      ),
    ];

    final logoutItems = <SettingMenuItem>[
      SettingMenuItem(
        icon: Iconsax.logout,
        title: AppTexts.settingsLogout,
        showChevron: false,
        onTap: () {},
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      extendBody: false,
      appBar: CustomAppBar(
        title: Text(
          AppTexts.profileTitle,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () {},
            child: const CustomCircularContainer(
              size: 44,
              backgroundColor: AppColors.accent,
              child: Icon(
                Iconsax.notification,
                color: AppColors.secondary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.md,
          AppSizes.md,
          AppSizes.md,
          AppSizes.spaceBtwSections * 2,
        ),
        child: Column(
          children: [
            ProfileUserCard(onEdit: () {}),
            const Gap(AppSizes.md),
            SettingMenuSection(
              title: AppTexts.profileSectionSettings,
              items: accountItems,
            ),
            const Gap(AppSizes.md),
            SettingMenuSection(
              title: AppTexts.profileSectionSupport,
              items: supportItems,
            ),
            const Gap(AppSizes.md),
            SettingMenuSection(items: logoutItems),
            const Gap(AppSizes.spaceBtwSections * 4),
          ],
        ),
      ),
    );
  }
}
