import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gap/gap.dart';
import 'package:incacook/features/settings/domain/setting_menu_item.dart';
import 'package:iconsax/iconsax.dart';
import 'package:incacook/core/common/widgets/appbar/appbar.dart';
import 'package:incacook/core/common/widgets/custon_shapes/container/circular_container.dart';
import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/core/models/address.dart';
import 'package:incacook/core/widgets/decor/decor_blob.dart';
import 'package:incacook/features/settings/presentation/widgets/profile_menu_card.dart';
import 'package:incacook/features/settings/presentation/widgets/profile_user_card.dart';
import 'package:incacook/features/settings/presentation/widgets/appearance_sheet.dart';
import 'package:incacook/features/settings/presentation/widgets/saved_addresses_sheet.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

//* placeholder addresses — swap for a real source once persistence lands.
const List<Address> _mockSavedAddresses = [
  Address(
    id: 'addr-home',
    type: SavedAddressType.home,
    fullAddress: '12 rue Saint-Sabin',
    city: 'Paris',
    postalCode: '75011',
  ),
  Address(
    id: 'addr-work',
    type: SavedAddressType.work,
    fullAddress: '24 rue Lafayette',
    city: 'Paris',
    postalCode: '75009',
  ),
  Address(
    id: 'addr-sister',
    type: SavedAddressType.other,
    customLabel: 'Chez ma sœur',
    fullAddress: '47 boulevard Voltaire',
    city: 'Paris',
    postalCode: '75011',
  ),
  Address(
    id: 'addr-parents',
    type: SavedAddressType.other,
    customLabel: 'Maison parents',
    fullAddress: '8 rue de la Paix',
    city: 'Rueil-Malmaison',
    postalCode: '92500',
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
        icon: Iconsax.brush_2,
        title: AppTexts.settingsAppearance,
        onTap: () => AppearanceSheet.show(context),
      ),
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
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            actions: [
              GestureDetector(
                onTap: () {},
                child: CustomCircularContainer(
                  size: 44,
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  child: Icon(
                    Iconsax.notification,
                    color: Theme.of(context).colorScheme.onSurface,
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
                const ProfileUserCard(),
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
