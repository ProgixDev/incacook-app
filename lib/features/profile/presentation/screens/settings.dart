import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import 'package:homemade/core/common/widgets/appbar/appbar.dart';
import 'package:homemade/core/common/widgets/custon_shapes/container/circular_container.dart';
import 'package:homemade/core/constants/colors.dart';
import 'package:homemade/core/constants/sizes.dart';
import 'package:homemade/core/constants/text_strings.dart';
import 'package:homemade/core/widgets/decor/decor_blob.dart';
import 'package:homemade/features/orders/domain/saved_address.dart';
import 'package:homemade/features/profile/domain/Setting_menu_item.dart';
import 'package:homemade/features/profile/presentation/widgets/profile_menu_card.dart';
import 'package:homemade/features/profile/presentation/widgets/profile_user_card.dart';
import 'package:homemade/features/profile/presentation/widgets/saved_addresses_sheet.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

//* placeholder addresses — swap for a real source once persistence lands.
const List<SavedAddress> _mockSavedAddresses = [
  SavedAddress(
    id: 'addr-home',
    type: SavedAddressType.home,
    line1: '12 rue Saint-Sabin',
    line2: '75011 Paris, France',
  ),
  SavedAddress(
    id: 'addr-work',
    type: SavedAddressType.work,
    line1: '24 rue Lafayette',
    line2: '75009 Paris, France',
  ),
  SavedAddress(
    id: 'addr-sister',
    type: SavedAddressType.other,
    customLabel: 'Chez ma sœur',
    line1: '47 boulevard Voltaire',
    line2: '75011 Paris, France',
  ),
  SavedAddress(
    id: 'addr-parents',
    type: SavedAddressType.other,
    customLabel: 'Maison parents',
    line1: '8 rue de la Paix',
    line2: '92500 Rueil-Malmaison, France',
    inRange: false,
  ),
];

class _SettingsScreenState extends State<SettingsScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _appBarVisible = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
  }

  void _handleScroll() {
    final direction = _scrollController.position.userScrollDirection;
    if (direction == ScrollDirection.reverse && _appBarVisible) {
      setState(() => _appBarVisible = false);
    } else if (direction == ScrollDirection.forward && !_appBarVisible) {
      setState(() => _appBarVisible = true);
    }
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appBarHeight =
        MediaQuery.viewPaddingOf(context).top + AppSizes.appBarHeight;

    final accountItems = <SettingMenuItem>[
      SettingMenuItem(
        icon: Iconsax.card,
        title: AppTexts.settingsWallet,
        trailingText: '€0.00',
        showChevron: false,
        onTap: () {},
      ),
      SettingMenuItem(
        icon: Iconsax.clipboard_text,
        title: AppTexts.settingsOrders,
        onTap: () {},
      ),
      // SettingMenuItem(
      //   icon: Iconsax.ticket_discount,
      //   title: AppTexts.settingsVouchers,
      //   onTap: () {},
      // ),
      SettingMenuItem(
        icon: Iconsax.location,
        title: AppTexts.settingsAddresses,
        onTap: () =>
            SavedAddressesSheet.show(context, addresses: _mockSavedAddresses),
      ),
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
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(appBarHeight),
        child: AnimatedSlide(
          offset: _appBarVisible ? Offset.zero : const Offset(0, -1),
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          child: CustomAppBar(
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
        ),
      ),
      body: Stack(
        children: [
          //* decorative top-right blob (purely cosmetic, no input).
          const Positioned(
            top: -8,
            right: -16,
            child: IgnorePointer(child: DecorBlob()),
          ),
          SingleChildScrollView(
            controller: _scrollController,
            padding: EdgeInsets.fromLTRB(
              AppSizes.md,
              appBarHeight + AppSizes.md,
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
        ],
      ),
    );
  }
}
