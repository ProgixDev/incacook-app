import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import 'package:vinted_v2/core/common/widgets/appbar/appbar.dart';
import 'package:vinted_v2/core/common/widgets/custon_shapes/container/circular_container.dart';
import 'package:vinted_v2/core/constants/colors.dart';
import 'package:vinted_v2/core/constants/sizes.dart';
import 'package:vinted_v2/core/constants/text_strings.dart';
import 'package:vinted_v2/features/profile/domain/profile_menu_item.dart';
import 'package:vinted_v2/features/profile/presentation/widgets/profile_menu_card.dart';
import 'package:vinted_v2/features/profile/presentation/widgets/profile_user_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final accountItems = <ProfileMenuItem>[
      ProfileMenuItem(
        icon: Iconsax.cup,
        title: AppTexts.profileRewards,
        trailingText: '0 points',
        showChevron: false,
        onTap: () {},
      ),
      ProfileMenuItem(
        icon: Iconsax.clipboard_text,
        title: AppTexts.profileOrders,
        onTap: () {},
      ),
      ProfileMenuItem(
        icon: Iconsax.card,
        title: AppTexts.profilePay,
        trailingText: '\$0.00',
        showChevron: false,
        onTap: () {},
      ),
      ProfileMenuItem(
        icon: Iconsax.ticket_discount,
        title: AppTexts.profileVouchers,
        onTap: () {},
      ),
      ProfileMenuItem(
        icon: Iconsax.crown_1,
        title: AppTexts.profilePro,
        onTap: () {},
      ),
    ];

    final supportItems = <ProfileMenuItem>[
      ProfileMenuItem(
        icon: Iconsax.message_question,
        title: AppTexts.profileGetHelp,
        onTap: () {},
      ),
      ProfileMenuItem(
        icon: Iconsax.info_circle,
        title: AppTexts.profileAboutApp,
        onTap: () {},
      ),
    ];

    final logoutItems = <ProfileMenuItem>[
      ProfileMenuItem(
        icon: Iconsax.logout,
        title: AppTexts.profileLogout,
        showChevron: false,
        onTap: () {},
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      extendBody: false,
      appBar: CustomAppBar(
        leading: const CustomCircularContainer(
          size: 44,
          backgroundColor: AppColors.accent,
          child: Icon(Iconsax.user, color: AppColors.secondary, size: 20),
        ),
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
            ProfileMenuCard(
              title: AppTexts.profileSectionSettings,
              items: accountItems,
            ),
            const Gap(AppSizes.md),
            ProfileMenuCard(
              title: AppTexts.profileSectionSupport,
              items: supportItems,
            ),
            const Gap(AppSizes.md),
            ProfileMenuCard(items: logoutItems),
          ],
        ),
      ),
    );
  }
}
