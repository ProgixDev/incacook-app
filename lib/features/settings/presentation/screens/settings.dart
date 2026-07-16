import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:incacook/core/controllers/user_controller.dart';
import 'package:incacook/features/authentication/data/models/user_role.dart';
import 'package:incacook/features/orders/presentation/screens/orders_history_screen.dart';
import 'package:incacook/features/notifications/controllers/notifications_controller.dart';
import 'package:incacook/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:incacook/features/settings/domain/setting_menu_item.dart';
import 'package:incacook/features/settings/presentation/screens/buyer_preferences_screen.dart';
import 'package:incacook/features/settings/presentation/screens/edit_profile.dart';
import 'package:iconsax/iconsax.dart';
import 'package:incacook/core/common/widgets/appbar/appbar.dart';
import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/core/widgets/decor/decor_blob.dart';
import 'package:incacook/core/widgets/effects/frosted_surface.dart';
import 'package:incacook/features/authentication/services/sign_out_service.dart';
import 'package:incacook/features/settings/presentation/widgets/profile_menu_card.dart';
import 'package:incacook/features/settings/presentation/widgets/profile_user_card.dart';
import 'package:incacook/features/settings/presentation/widgets/appearance_sheet.dart';
import 'package:incacook/features/settings/presentation/widgets/saved_addresses_sheet.dart';
import 'package:incacook/features/payments/data/payout_onboarding_service.dart';
import 'package:incacook/features/wallet/presentation/wallet_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _appBarVisible = true;

  final NotificationsController _notifications =
      Get.isRegistered<NotificationsController>()
          ? NotificationsController.instance
          : Get.put(NotificationsController(), permanent: true);

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    // Best-effort refresh so the profile card always reflects the latest
    // name / phone / photo — including a seller's registration photo,
    // which is set after the Gate-2 user cache was first populated.
    UserController.instance.refreshFromServer().ignore();
    // Light badge refresh for the bell (no full inbox load).
    _notifications.refreshUnreadCount();
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

  /// "Obtenir de l'aide" → opens the support email. Falls back to a snackbar
  /// with the address if no mail app is available.
  Future<void> _openSupport(BuildContext context) async {
    final uri = Uri(
      scheme: 'mailto',
      path: AppTexts.supportEmail,
      query: 'subject=${Uri.encodeComponent(AppTexts.supportEmailSubject)}',
    );
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppTexts.supportUnavailable)),
      );
    }
  }

  /// "À propos de l'application" → native about dialog (name + legalese).
  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: AppTexts.appName,
      applicationLegalese: AppTexts.appLegalese,
    );
  }

  @override
  Widget build(BuildContext context) {
    final appBarHeight =
        MediaQuery.viewPaddingOf(context).top + AppSizes.appBarHeight;

    // Wallet (earnings) only applies to sellers + drivers.
    final role = UserController.instance.user.value?.role;
    final isEarner = role == UserRole.seller || role == UserRole.driver;

    final accountItems = <SettingMenuItem>[
      if (isEarner)
        SettingMenuItem(
          icon: Iconsax.card,
          title: AppTexts.settingsWallet,
          onTap: () => Get.to<void>(() => const WalletScreen()),
        ),
      SettingMenuItem(
        icon: Iconsax.clipboard_text,
        title: AppTexts.settingsOrders,
        onTap: () {
          final isSeller =
              UserController.instance.user.value?.role == UserRole.seller;
          Get.to<void>(() => OrdersHistoryScreen(isSeller: isSeller));
        },
      ),
      SettingMenuItem(
        icon: Iconsax.location,
        title: AppTexts.settingsAddresses,
        onTap: () => SavedAddressesSheet.show(context),
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
        onTap: () => _openSupport(context),
      ),
      SettingMenuItem(
        icon: Iconsax.info_circle,
        title: AppTexts.settingsAboutApp,
        onTap: () => _showAbout(context),
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
                onTap: () async {
                  await Get.to<void>(() => const NotificationsScreen());
                  // Reconcile the badge after the user views the inbox.
                  _notifications.refreshUnreadCount();
                },
                behavior: HitTestBehavior.opaque,
                child: SizedBox(
                  width: 44,
                  height: 44,
                  child: Stack(
                    children: [
                      FrostedSurface(
                        shape: BoxShape.circle,
                        child: Center(
                          child: Icon(
                            Iconsax.notification,
                            color: Theme.of(context).colorScheme.onSurface,
                            size: 20,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Obx(() {
                          final count = _notifications.unreadCount.value;
                          if (count == 0) return const SizedBox.shrink();
                          return Container(
                            padding: const EdgeInsets.all(2),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.error,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                count > 9 ? '9+' : '$count',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onError,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
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
                ProfileUserCard(
                  onEditProfile: () =>
                      Get.to<void>(() => const EditProfileScreen()),
                  // Preferences edit dietary/allergens — buyer-only data, so
                  // the tile stays inert for sellers/drivers.
                  onPreferences: role == UserRole.buyer
                      ? () =>
                          Get.to<void>(() => const BuyerPreferencesScreen())
                      : null,
                  // "Paiement" opens the seller/driver's Stripe Express
                  // dashboard (manage bank account + Stripe payout history) —
                  // distinct from Portefeuille (internal balance). Stripe only
                  // serves it once onboarding is complete, so the tile stays
                  // disabled until payoutReady; buyers have no payout account.
                  onPayment: isEarner && UserController.instance.payoutReady
                      ? () => PayoutOnboardingService.openDashboard(context)
                      : null,
                ),
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
