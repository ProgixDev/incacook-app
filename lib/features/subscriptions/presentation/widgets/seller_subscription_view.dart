import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'package:incacook/core/common/styles/loaders.dart';
import 'package:incacook/core/config/revenuecat_config.dart';
import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/core/controllers/user_controller.dart';
import 'package:incacook/core/enums/food_enums.dart';
import 'package:incacook/core/network/api_response.dart';
import 'package:incacook/core/services/revenuecat_service.dart';
import 'package:incacook/core/utils/log.dart';
import 'package:incacook/core/utils/theme/theme_extensions.dart';
import 'package:incacook/features/authentication/data/repositories/sellers_repository.dart';

enum _Plan { standard, premium }

/// Reusable seller-subscription UI + RevenueCat purchase/restore/backend-sync
/// logic, used by the post-login paywall (`SubscriptionPaywallScreen`) — the
/// seller subscription is intentionally not a signup step (see
/// `signup_flow_controller.dart`'s seller branch); it's taken here the first
/// time a lapsed/new seller opens a gated tab.
///
/// The host supplies the seller [category] (drives the offering + prices) and
/// decides what "activated" means via [onActivated] — the paywall refreshes
/// the user so the gate reveals the home.
///
/// Renders a non-scrolling [Column]; the host wraps it in its own
/// scroll/scaffold/layout. Never logs tokens. Stripe is untouched — this is
/// RevenueCat only (subscription), Stripe stays for orders/wallet/payouts.
class SellerSubscriptionView extends StatefulWidget {
  const SellerSubscriptionView({
    required this.category,
    required this.onActivated,
    super.key,
  });

  final SellerCategory category;
  final Future<void> Function() onActivated;

  @override
  State<SellerSubscriptionView> createState() => _SellerSubscriptionViewState();
}

class _SellerSubscriptionViewState extends State<SellerSubscriptionView> {
  final RevenueCatService _revenueCat = Get.find();
  final SellersRepository _sellers = SellersRepository.instance;

  Package? _standardPkg;
  Package? _premiumPkg;
  _Plan? _selected;
  bool _loadingOfferings = true;
  bool _busy = false;
  // Precise unavailability message (null once the products are available).
  String? _unavailableReason;

  SellerCategory get _category => widget.category;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final offeringId = RevenueCatConfig.offeringIdForCategory(_category);
    logInfo('[Subscription] category=${_category.name} offeringId=$offeringId');

    // Identify the subscriber with the backend user id so the RevenueCat
    // webhook can map events back to this seller (= app_user_id).
    final userId = UserController.instance.user.value?.id;
    if (userId != null && userId.isNotEmpty) {
      await _revenueCat.login(userId);
    }

    final result = await _revenueCat.loadOfferingForCategory(_category);
    final offering = result.offering;
    if (offering != null) {
      for (final p in offering.availablePackages) {
        if (p.identifier == RevenueCatConfig.packageStandard) _standardPkg = p;
        if (p.identifier == RevenueCatConfig.packagePremium) _premiumPkg = p;
      }
    }
    _unavailableReason = _resolveUnavailableReason(result);
    if (mounted) setState(() => _loadingOfferings = false);
  }

  /// Maps the load result to a precise, actionable message — or null when both
  /// expected packages are present (so the banner stays hidden).
  String? _resolveUnavailableReason(OfferingResult result) {
    if (_standardPkg != null && _premiumPkg != null) return null;
    switch (result.failure) {
      case OfferingFailure.keyMissing:
        return AppTexts.subscriptionErrorKeyMissing;
      case OfferingFailure.storeError:
        return AppTexts.subscriptionErrorStore;
      case OfferingFailure.offeringMissing:
        return AppTexts.subscriptionErrorOfferingMissing;
      case null:
        // Offering loaded but the expected packages are empty / mismatched.
        return AppTexts.subscriptionErrorPackagesEmpty;
    }
  }

  /// True once loading is done and at least one expected package is missing
  /// (RevenueCat misconfigured / products not live / SDK key absent).
  bool get _productsUnavailable => !_loadingOfferings && _unavailableReason != null;

  Package? _packageFor(_Plan plan) => plan == _Plan.premium ? _premiumPkg : _standardPkg;

  String _priceFor(_Plan plan) {
    final pkg = _packageFor(plan);
    // Dynamic store price when available; otherwise the static business price.
    if (pkg != null) return pkg.storeProduct.priceString;
    return RevenueCatConfig.fallbackPrice(_category, premium: plan == _Plan.premium);
  }

  Future<void> _subscribe() async {
    if (_busy) return;
    final plan = _selected;
    if (plan == null) {
      CustomLoaders.warningSnackBar(
        title: AppTexts.signupSubscriptionTitle,
        message: AppTexts.signupSubscriptionSelectPlanError,
      );
      return;
    }
    final pkg = _packageFor(plan);
    if (pkg == null) {
      CustomLoaders.errorSnackBar(
        title: AppTexts.signupSubscriptionTitle,
        message: AppTexts.signupSubscriptionUnavailable,
      );
      return;
    }
    logInfo('[Subscription] selected plan=${plan.name}');
    setState(() => _busy = true);
    try {
      final outcome = await _revenueCat.purchase(pkg);
      if (outcome.cancelled) return; // user dismissed — silent
      logSuccess('[Subscription] entitlement returned: ${outcome.entitlementId ?? 'none'}');
      if (!outcome.hasActiveEntitlement) {
        CustomLoaders.errorSnackBar(
          title: AppTexts.signupSubscriptionTitle,
          message: AppTexts.signupSubscriptionError,
        );
        return;
      }
      await _syncAndActivate(outcome);
    } on RevenueCatException catch (e) {
      CustomLoaders.errorSnackBar(title: AppTexts.signupSubscriptionTitle, message: e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _restore() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final outcome = await _revenueCat.restore();
      logSuccess('[Subscription] restore entitlement: ${outcome.entitlementId ?? 'none'}');
      if (!outcome.hasActiveEntitlement) {
        CustomLoaders.warningSnackBar(
          title: AppTexts.signupSubscriptionRestoreCta,
          message: AppTexts.signupSubscriptionRestoreNone,
        );
        return;
      }
      await _syncAndActivate(outcome);
    } on RevenueCatException catch (e) {
      CustomLoaders.errorSnackBar(title: AppTexts.signupSubscriptionRestoreCta, message: e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Syncs the result with the backend and then hands off to [onActivated].
  /// The local entitlement already authorises proceeding; a failed sync is
  /// logged but not fatal — the RevenueCat webhook reconciles the backend.
  Future<void> _syncAndActivate(SubscriptionOutcome outcome) async {
    try {
      final result = await _sellers.syncSubscription(
        entitlementId: outcome.entitlementId,
        productId: outcome.productId,
        expiresAtMs: outcome.expiresAtMs,
        isTrial: outcome.isTrial,
        revenueCatCustomerId: UserController.instance.user.value?.id,
        category: _category,
      );
      logSuccess('[Subscription] backend sync: active=${result.active} status=${result.status}');
    } on ApiFailure catch (e) {
      logWarning('[Subscription] backend sync failed: ${e.code} (webhook will reconcile)');
    }
    await widget.onActivated();
    if (!mounted) return;
    CustomLoaders.successSnackBar(
      title: AppTexts.signupSubscriptionTitle,
      message: AppTexts.signupSubscriptionSuccess,
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_productsUnavailable) ...[
          _UnavailableBanner(
            message: _unavailableReason ?? AppTexts.signupSubscriptionUnavailable,
          ),
          const Gap(AppSizes.md),
        ],
        _PlanCard(
          label: AppTexts.signupSubscriptionPlanStandard,
          price: _priceFor(_Plan.standard),
          loadingPrice: _loadingOfferings,
          disabled: !_loadingOfferings && _standardPkg == null,
          perks: const [AppTexts.signupSubscriptionStandardCommission],
          selected: _selected == _Plan.standard,
          onTap: (_busy || _standardPkg == null)
              ? null
              : () => setState(() => _selected = _Plan.standard),
        ),
        const Gap(AppSizes.sm),
        _PlanCard(
          label: AppTexts.signupSubscriptionPlanPremium,
          price: _priceFor(_Plan.premium),
          loadingPrice: _loadingOfferings,
          highlight: true,
          disabled: !_loadingOfferings && _premiumPkg == null,
          perks: const [
            AppTexts.signupSubscriptionPremiumCommission,
            AppTexts.signupSubscriptionPremiumPerkFeatured,
            AppTexts.signupSubscriptionPremiumPerkCommission,
          ],
          selected: _selected == _Plan.premium,
          onTap: (_busy || _premiumPkg == null)
              ? null
              : () => setState(() => _selected = _Plan.premium),
        ),
        const Gap(AppSizes.md),
        _InfoLine(icon: Iconsax.gift, text: AppTexts.signupSubscriptionTrialNote),
        const Gap(AppSizes.sm),
        _InfoLine(icon: Iconsax.shield_tick, text: AppTexts.signupSubscriptionSecureNote),
        const Gap(AppSizes.lg),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _busy ? null : _subscribe,
            child: _busy
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text(AppTexts.signupSubscriptionSubscribeCta),
          ),
        ),
        const Gap(AppSizes.xs),
        Center(
          child: TextButton(
            onPressed: _busy ? null : _restore,
            child: Text(
              AppTexts.signupSubscriptionRestoreCta,
              style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}

class _UnavailableBanner extends StatelessWidget {
  const _UnavailableBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppSizes.sm + 4),
      decoration: BoxDecoration(
        color: scheme.errorContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Iconsax.warning_2, size: 18, color: scheme.error),
          const Gap(AppSizes.sm),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.error),
            ),
          ),
        ],
      ),
    );
  }
}

/// Selectable subscription plan card (rounded, green-accent selected, dimmed
/// + non-tappable when its store product is unavailable).
class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.label,
    required this.price,
    required this.perks,
    required this.selected,
    required this.onTap,
    this.loadingPrice = false,
    this.highlight = false,
    this.disabled = false,
  });

  final String label;
  final String price;
  final List<String> perks;
  final bool selected;
  final VoidCallback? onTap;
  final bool loadingPrice;
  final bool highlight;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Opacity(
      opacity: disabled ? 0.5 : 1.0,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.all(AppSizes.md),
          decoration: BoxDecoration(
            color: selected ? colors.selectedSurface : scheme.surface,
            borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
            border: Border.all(
              color: selected
                  ? colors.selectedOnSurface
                  : scheme.outline.withValues(alpha: 0.4),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    selected ? Iconsax.tick_circle : Iconsax.record_circle,
                    size: 20,
                    color: selected ? scheme.primary : scheme.onSurfaceVariant,
                  ),
                  const Gap(AppSizes.sm),
                  Text(
                    label,
                    style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  if (highlight) ...[
                    const Gap(AppSizes.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: scheme.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '★',
                        style: textTheme.labelSmall?.copyWith(color: scheme.primary),
                      ),
                    ),
                  ],
                  const Spacer(),
                  if (loadingPrice)
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    Text(
                      price,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: scheme.primary,
                      ),
                    ),
                ],
              ),
              const Gap(AppSizes.sm),
              ...perks.map(
                (perk) => Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Iconsax.tick_circle, size: 14, color: scheme.primary),
                      const Gap(AppSizes.xs),
                      Expanded(
                        child: Text(
                          perk,
                          style: textTheme.bodySmall
                              ?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: scheme.onSurfaceVariant),
        const Gap(AppSizes.xs),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ),
      ],
    );
  }
}
