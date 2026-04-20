import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import 'package:vinted_v2/core/common/widgets/appbar/appbar.dart';
import 'package:vinted_v2/core/constants/colors.dart';
import 'package:vinted_v2/core/constants/sizes.dart';
import 'package:vinted_v2/core/constants/text_strings.dart';
import 'package:vinted_v2/features/home/domain/food_listing.dart';
import 'package:vinted_v2/features/seller/domain/seller_profile.dart';

class SellerProfileScreen extends StatefulWidget {
  const SellerProfileScreen({super.key, required this.profile});

  final SellerProfile profile;

  @override
  State<SellerProfileScreen> createState() => _SellerProfileScreenState();
}

class _SellerProfileScreenState extends State<SellerProfileScreen> {
  late String _selectedCategory = widget.profile.menuCategories.isNotEmpty
      ? widget.profile.menuCategories.first
      : '';
  bool _isFavorited = false;

  @override
  Widget build(BuildContext context) {
    final profile = widget.profile;
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: CustomAppBar(
        showBackArrow: true,
        actions: [
          _CircleIconButton(
            icon: _isFavorited ? Iconsax.heart5 : Iconsax.heart,
            iconColor: _isFavorited
                ? const Color(0xFFE53935)
                : AppColors.secondary,
            onTap: () => setState(() => _isFavorited = !_isFavorited),
          ),
          const Gap(AppSizes.sm),
          _CircleIconButton(icon: Iconsax.share, onTap: () {}),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.md,
                AppSizes.md,
                AppSizes.md,
                AppSizes.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _HeroCard(profile: profile),
                  const Gap(AppSizes.lg),
                  _TrustStatsBar(profile: profile),
                  const Gap(AppSizes.lg),
                  _PerformanceSection(metrics: profile.performance),
                  const Gap(AppSizes.lg),
                  _CategoryTabs(
                    categories: profile.menuCategories,
                    selected: _selectedCategory,
                    onSelect: (c) => setState(() => _selectedCategory = c),
                  ),
                  const Gap(AppSizes.md),
                  _ListingsHeader(),
                  const Gap(AppSizes.md),
                  _ListingsGrid(listings: profile.listings),
                  const Gap(AppSizes.lg),
                  _BioSection(profile: profile),
                  const Gap(AppSizes.lg),
                  _VerificationsSection(items: profile.verifications),
                  const Gap(AppSizes.lg),
                  _ReviewsSection(profile: profile),
                  const Gap(AppSizes.lg),
                  _LocationSection(profile: profile),
                  const Gap(AppSizes.md),
                ],
              ),
            ),
          ),
          // _ActionBar(
          //   isFavorited: _isFavorited,
          //   onToggleFavorite: () =>
          //       setState(() => _isFavorited = !_isFavorited),
          //   onMessage: () {},
          //   onOrder: () {},
          // ),
        ],
      ),
    );
  }
}

//──────────────────────────────────────────────────────────────────────────────
//* shared helpers

Color _barColor(int percent) {
  if (percent >= 90) return const Color(0xFF2E7D32);
  if (percent >= 75) return const Color(0xFFE8823B);
  if (percent >= 60) return const Color(0xFFF9A825);
  return const Color(0xFFE53935);
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.onTap,
    this.iconColor = AppColors.secondary,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: AppSizes.lg * 1.8,
        height: AppSizes.lg * 1.8,
        decoration: const BoxDecoration(
          color: AppColors.accent,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
    );
  }
}

class _SurfaceCard extends StatelessWidget {
  const _SurfaceCard({
    required this.child,
    this.padding = const EdgeInsets.all(AppSizes.md),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
      ),
      child: child,
    );
  }
}

//──────────────────────────────────────────────────────────────────────────────
//* section 2 — hero card

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.profile});

  final SellerProfile profile;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SurfaceCard(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
                child: Image.asset(
                  profile.avatarPath,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
              const Gap(AppSizes.md - 2),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _CategoryRatingRow(profile: profile),
                    const Gap(4),
                    Text(
                      profile.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        height: 1.15,
                      ),
                    ),
                    const Gap(6),
                    _SellerTypeBadge(category: profile.category),
                    const Gap(4),
                    Text(
                      profile.cuisineType,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Gap(4),
                    Row(
                      children: [
                        const Icon(
                          Iconsax.location,
                          size: 14,
                          color: AppColors.grey,
                        ),
                        const Gap(4),
                        Flexible(
                          child: Text(
                            '${profile.distanceKm.toStringAsFixed(1)}km · ${profile.neighborhood}',
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.grey),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Gap(AppSizes.sm),
              _QuickActionArrow(onTap: () {}),
            ],
          ),
        ),
        const Gap(AppSizes.sm + 2),
        _SurfaceCard(
          child: Row(
            children: [
              _PillStat(
                icon: Iconsax.clock,
                label:
                    '${AppTexts.sellerProfilePrepTimePrefix} ${profile.prepMinMinutes}–${profile.prepMaxMinutes} min',
              ),
              const Gap(AppSizes.md),
              _PillStat(
                icon: Iconsax.truck_fast,
                label:
                    '${AppTexts.sellerProfileDeliveryFeePrefix} €${profile.deliveryFee.toStringAsFixed(2)}',
              ),
            ],
          ),
        ),
        if (profile.promoText != null) ...[
          const Gap(AppSizes.sm + 2),
          _PromoBanner(text: profile.promoText!),
        ],
      ],
    );
  }
}

class _CategoryRatingRow extends StatelessWidget {
  const _CategoryRatingRow({required this.profile});

  final SellerProfile profile;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: Text(
            profile.categoryTag,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const Gap(6),
        Text(
          '·',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.grey),
        ),
        const Gap(6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.black,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Iconsax.star1, size: 10, color: Color(0xFFFFC107)),
              const Gap(3),
              Text(
                profile.rating.toStringAsFixed(1),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SellerTypeBadge extends StatelessWidget {
  const _SellerTypeBadge({required this.category});

  final SellerCategory category;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.lightGrey),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 14,
            height: 14,
            child: Image.asset(category.imagePath, fit: BoxFit.contain),
          ),
          const Gap(4),
          Text(
            category.label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionArrow extends StatelessWidget {
  const _QuickActionArrow({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: const BoxDecoration(
          color: Color(0xFFE8823B),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Iconsax.arrow_right_3,
          size: 18,
          color: AppColors.white,
        ),
      ),
    );
  }
}

class _PillStat extends StatelessWidget {
  const _PillStat({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.secondary),
        const Gap(6),
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _PromoBanner extends StatelessWidget {
  const _PromoBanner({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFE8823B);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md - 2,
        vertical: AppSizes.sm + 2,
      ),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
        border: Border.all(color: accent.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          const Icon(Iconsax.gift, size: 16, color: accent),
          const Gap(AppSizes.sm + 2),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: accent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//──────────────────────────────────────────────────────────────────────────────
//* section 3 — trust stats bar

class _TrustStatsBar extends StatelessWidget {
  const _TrustStatsBar({required this.profile});

  final SellerProfile profile;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      padding: const EdgeInsets.all(AppSizes.md),
      child: Column(
        children: [
          Row(
            children: [
              _StatBlock(
                icon: Iconsax.star1,
                value: profile.rating.toStringAsFixed(1),
                label: AppTexts.sellerTrustAverageRating,
              ),
              _StatBlock(
                icon: Iconsax.message_tick,
                value: '${profile.responseRatePercent}%',
                label: AppTexts.sellerTrustFastResponse,
              ),
              _StatBlock(
                icon: Iconsax.box,
                value: '${profile.mealsSold}',
                label: AppTexts.sellerTrustMealsSold,
              ),
            ],
          ),
          const Gap(AppSizes.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Iconsax.heart5, size: 18, color: Color(0xFF2E7D32)),
              const Gap(AppSizes.sm),
              Text(
                '${profile.mealsSaved} ${AppTexts.sellerTrustMealsSaved}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF2E7D32),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatBlock extends StatelessWidget {
  const _StatBlock({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 18, color: AppColors.secondary),
          const Gap(4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const Gap(2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.grey, height: 1.2),
          ),
        ],
      ),
    );
  }
}

//──────────────────────────────────────────────────────────────────────────────
//* section 4 — performance progress bars

class _PerformanceSection extends StatelessWidget {
  const _PerformanceSection({required this.metrics});

  final List<PerformanceMetric> metrics;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppTexts.sellerPerformanceTitle,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const Gap(AppSizes.md),
          for (int i = 0; i < metrics.length; i++) ...[
            _PerformanceRow(metric: metrics[i]),
            if (i < metrics.length - 1) const Gap(AppSizes.md),
          ],
        ],
      ),
    );
  }
}

class _PerformanceRow extends StatelessWidget {
  const _PerformanceRow({required this.metric});

  final PerformanceMetric metric;

  @override
  Widget build(BuildContext context) {
    final color = _barColor(metric.percent);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(metric.icon, size: 16, color: AppColors.secondary),
            const Gap(AppSizes.sm),
            Expanded(
              child: Text(
                metric.label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              '${metric.percent}%',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const Gap(6),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: metric.percent / 100,
            minHeight: 8,
            backgroundColor: AppColors.lightGrey,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        const Gap(4),
        Text(
          metric.caption,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.grey),
        ),
      ],
    );
  }
}

//──────────────────────────────────────────────────────────────────────────────
//* section 6 — category tabs

class _CategoryTabs extends StatelessWidget {
  const _CategoryTabs({
    required this.categories,
    required this.selected,
    required this.onSelect,
  });

  final List<String> categories;
  final String selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: AppColors.black,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Iconsax.setting_4,
              color: AppColors.white,
              size: 18,
            ),
          ),
          const Gap(AppSizes.sm),
          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (_, _) => const Gap(AppSizes.sm),
              itemBuilder: (context, index) {
                final cat = categories[index];
                final isSelected = selected == cat;
                return GestureDetector(
                  onTap: () => onSelect(cat),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    curve: Curves.easeOut,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.md,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFE8823B)
                          : AppColors.white,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFFE8823B)
                            : AppColors.lightGrey,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        cat,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: isSelected
                              ? AppColors.white
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

//──────────────────────────────────────────────────────────────────────────────
//* section 7 — listings header + grid

class _ListingsHeader extends StatelessWidget {
  const _ListingsHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppTexts.sellerListingsTitle,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const Gap(2),
        Text(
          AppTexts.sellerListingsSubtitle,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.grey),
        ),
      ],
    );
  }
}

class _ListingsGrid extends StatelessWidget {
  const _ListingsGrid({required this.listings});

  final List<FoodListing> listings;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72,
        mainAxisSpacing: AppSizes.md - 4,
        crossAxisSpacing: AppSizes.md - 4,
      ),
      itemCount: listings.length,
      itemBuilder: (_, i) => _ListingCard(listing: listings[i]),
    );
  }
}

class _ListingCard extends StatelessWidget {
  const _ListingCard({required this.listing});

  final FoodListing listing;

  int? get _discountPercent {
    final original = listing.originalPrice;
    if (original == null || original <= listing.price) return null;
    final pct = ((original - listing.price) / original * 100).round();
    return pct;
  }

  String _expiryLabel() {
    final diff = listing.expiresAt.difference(DateTime.now());
    if (diff.isNegative) return '0min';
    final minutes = diff.inMinutes;
    if (minutes < 60) return '${minutes}min';
    return '${minutes ~/ 60}h';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              AspectRatio(
                aspectRatio: 1.1,
                child: Image.asset(listing.imagePath, fit: BoxFit.cover),
              ),
              if (_discountPercent != null)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 8,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.black,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '-$_discountPercent% Off',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 10.5,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    listing.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Gap(2),
                  Row(
                    children: [
                      const Icon(
                        Iconsax.clock,
                        size: 12,
                        color: AppColors.grey,
                      ),
                      const Gap(4),
                      Text(
                        _expiryLabel(),
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: AppColors.grey),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Flexible(
                              child: Text(
                                '€${listing.price.toStringAsFixed(2)}',
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textPrimary,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE8823B),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Iconsax.add,
                            size: 16,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//──────────────────────────────────────────────────────────────────────────────
//* section 8 — bio

class _BioSection extends StatelessWidget {
  const _BioSection({required this.profile});

  final SellerProfile profile;

  String _memberSinceLabel() {
    const months = [
      'janvier',
      'février',
      'mars',
      'avril',
      'mai',
      'juin',
      'juillet',
      'août',
      'septembre',
      'octobre',
      'novembre',
      'décembre',
    ];
    final m = months[profile.memberSince.month - 1];
    final capitalized = '${m[0].toUpperCase()}${m.substring(1)}';
    return '$capitalized ${profile.memberSince.year}';
  }

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${AppTexts.sellerBioTitlePrefix} ${profile.name.split(' ').first}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const Gap(AppSizes.md - 4),
          Text(
            '"${profile.bio}"',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textPrimary,
              fontStyle: FontStyle.italic,
              height: 1.4,
            ),
          ),
          const Gap(AppSizes.sm),
          GestureDetector(
            onTap: () {},
            child: Text(
              AppTexts.sellerBioSeeMore,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.secondary,
                fontWeight: FontWeight.w700,
                decoration: TextDecoration.underline,
                decorationColor: AppColors.secondary,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSizes.md - 2),
            child: Divider(height: 1, color: AppColors.lightGrey),
          ),
          _BioFact(
            labelPrefix: AppTexts.sellerBioLanguagesLabel,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (int i = 0; i < profile.languageCodes.length; i++) ...[
                  _LanguagePill(code: profile.languageCodes[i]),
                  if (i < profile.languageCodes.length - 1) const Gap(6),
                ],
              ],
            ),
          ),
          const Gap(6),
          _BioFact(
            labelPrefix: AppTexts.sellerBioMemberSincePrefix,
            trailing: Text(
              _memberSinceLabel(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Gap(6),
          _BioFact(
            labelPrefix: AppTexts.sellerBioLastActivePrefix,
            trailing: Text(
              profile.lastActiveAgo,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xFF2E7D32),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BioFact extends StatelessWidget {
  const _BioFact({required this.labelPrefix, required this.trailing});

  final String labelPrefix;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          labelPrefix,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.grey),
        ),
        const Gap(6),
        Flexible(child: trailing),
      ],
    );
  }
}

class _LanguagePill extends StatelessWidget {
  const _LanguagePill({required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.lightGrey),
      ),
      child: Text(
        code,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w800,
          fontSize: 11,
        ),
      ),
    );
  }
}

//──────────────────────────────────────────────────────────────────────────────
//* section 9 — verifications

class _VerificationsSection extends StatelessWidget {
  const _VerificationsSection({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppTexts.sellerVerificationsTitle,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const Gap(AppSizes.md - 4),
          for (final item in items) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  const Icon(
                    Iconsax.tick_circle,
                    size: 16,
                    color: Color(0xFF2E7D32),
                  ),
                  const Gap(AppSizes.sm),
                  Expanded(
                    child: Text(
                      item,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const Gap(AppSizes.sm),
          GestureDetector(
            onTap: () {},
            child: Text(
              AppTexts.sellerVerificationsSeeAll,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.secondary,
                fontWeight: FontWeight.w700,
                decoration: TextDecoration.underline,
                decorationColor: AppColors.secondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//──────────────────────────────────────────────────────────────────────────────
//* section 10 — reviews

class _ReviewsSection extends StatelessWidget {
  const _ReviewsSection({required this.profile});

  final SellerProfile profile;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${AppTexts.sellerReviewsTitlePrefix} (${profile.reviewCount})',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const Gap(AppSizes.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      const Icon(
                        Iconsax.star1,
                        size: 18,
                        color: Color(0xFFFFC107),
                      ),
                      const Gap(6),
                      Text(
                        profile.rating.toStringAsFixed(1),
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              height: 1,
                            ),
                      ),
                    ],
                  ),
                  const Gap(4),
                  Text(
                    '${profile.reviewCount} ${AppTexts.sellerReviewsSeeAllSuffix}',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppColors.grey),
                  ),
                ],
              ),
              const Gap(AppSizes.md),
              Expanded(child: _RatingDistribution(profile: profile)),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSizes.md - 2),
            child: Divider(height: 1, color: AppColors.lightGrey),
          ),
          Text(
            AppTexts.sellerReviewsWhatPeopleSay,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const Gap(AppSizes.sm),
          Wrap(
            spacing: AppSizes.sm,
            runSpacing: AppSizes.sm,
            children: [
              for (final tag in profile.sentimentTags) _SentimentChip(tag: tag),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSizes.md - 2),
            child: Divider(height: 1, color: AppColors.lightGrey),
          ),
          for (int i = 0; i < profile.recentReviews.length; i++) ...[
            _ReviewCard(review: profile.recentReviews[i]),
            if (i < profile.recentReviews.length - 1)
              const Gap(AppSizes.md - 4),
          ],
          const Gap(AppSizes.md),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.secondary,
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: const BorderSide(color: AppColors.lightGrey),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
                textStyle: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              child: Text(
                '${AppTexts.sellerReviewsSeeAllPrefix} ${profile.reviewCount} ${AppTexts.sellerReviewsSeeAllSuffix}',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RatingDistribution extends StatelessWidget {
  const _RatingDistribution({required this.profile});

  final SellerProfile profile;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final stars in [5, 4, 3, 2, 1])
          Padding(
            padding: const EdgeInsets.only(bottom: 3),
            child: Row(
              children: [
                Text(
                  '$stars★',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.grey),
                ),
                const Gap(6),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: (profile.ratingDistribution[stars] ?? 0) / 100,
                      minHeight: 6,
                      backgroundColor: AppColors.lightGrey,
                      valueColor: const AlwaysStoppedAnimation(
                        Color(0xFFFFC107),
                      ),
                    ),
                  ),
                ),
                const Gap(6),
                SizedBox(
                  width: 32,
                  child: Text(
                    '${(profile.ratingDistribution[stars] ?? 0).toStringAsFixed(0)}%',
                    textAlign: TextAlign.right,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppColors.grey),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _SentimentChip extends StatelessWidget {
  const _SentimentChip({required this.tag});

  final SentimentTag tag;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.lightGrey),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            tag.label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Gap(6),
          Text(
            '${tag.count}',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.grey),
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});

  final SellerReview review;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md - 2),
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(AppSizes.cardRadiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipOval(
                child: Image.asset(
                  review.avatarPath,
                  width: 32,
                  height: 32,
                  fit: BoxFit.cover,
                ),
              ),
              const Gap(AppSizes.sm),
              Expanded(
                child: Text(
                  '${review.authorName} · ${review.timeAgoLabel}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const Gap(6),
          Row(
            children: [
              for (int i = 0; i < 5; i++)
                Icon(
                  Iconsax.star1,
                  size: 12,
                  color: i < review.rating
                      ? const Color(0xFFFFC107)
                      : AppColors.lightGrey,
                ),
            ],
          ),
          const Gap(6),
          Text(
            '"${review.body}"',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textPrimary,
              fontStyle: FontStyle.italic,
              height: 1.35,
            ),
          ),
          const Gap(AppSizes.sm),
          Row(
            children: [
              const Icon(Iconsax.like_1, size: 12, color: AppColors.grey),
              const Gap(4),
              Flexible(
                child: Text(
                  '${review.helpfulCount} ${AppTexts.sellerReviewsHelpfulSuffix}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.grey),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

//──────────────────────────────────────────────────────────────────────────────
//* section 11 — location

class _LocationSection extends StatelessWidget {
  const _LocationSection({required this.profile});

  final SellerProfile profile;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppTexts.sellerLocationTitle,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const Gap(AppSizes.md - 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
          child: SizedBox(
            height: 160,
            child: IgnorePointer(
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: profile.location,
                  initialZoom: 14,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.none,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.vinted.v2',
                    maxZoom: 19,
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: profile.location,
                        width: 40,
                        height: 40,
                        child: const Icon(
                          Iconsax.location5,
                          size: 32,
                          color: Color(0xFFE8823B),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        const Gap(AppSizes.sm + 2),
        Row(
          children: [
            const Icon(Iconsax.location, size: 14, color: AppColors.grey),
            const Gap(6),
            Text(
              profile.neighborhood,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const Gap(2),
        Text(
          AppTexts.sellerLocationExactNote,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.grey),
        ),
        const Gap(AppSizes.sm),
        Row(
          children: [
            const Icon(Iconsax.truck_fast, size: 14, color: AppColors.grey),
            const Gap(6),
            Text(
              '${AppTexts.sellerLocationDeliveryRadiusPrefix} ${profile.deliveryRadiusKm.toStringAsFixed(0)} km',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textPrimary),
            ),
          ],
        ),
        const Gap(4),
        Row(
          children: [
            const Icon(Iconsax.clock, size: 14, color: AppColors.grey),
            const Gap(6),
            Flexible(
              child: Text(
                '${AppTexts.sellerLocationSchedulePrefix} ${profile.availabilitySchedule}',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textPrimary),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

//──────────────────────────────────────────────────────────────────────────────
//* section 12 — sticky action bar

class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.isFavorited,
    required this.onToggleFavorite,
    required this.onMessage,
    required this.onOrder,
  });

  final bool isFavorited;
  final VoidCallback onToggleFavorite;
  final VoidCallback onMessage;
  final VoidCallback onOrder;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSizes.md,
        AppSizes.sm + 2,
        AppSizes.md,
        AppSizes.sm + 2,
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            GestureDetector(
              onTap: onToggleFavorite,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.lightGrey),
                ),
                child: Icon(
                  isFavorited ? Iconsax.heart5 : Iconsax.heart,
                  size: 20,
                  color: isFavorited
                      ? const Color(0xFFE53935)
                      : AppColors.secondary,
                ),
              ),
            ),
            const Gap(AppSizes.sm),
            Expanded(
              child: OutlinedButton(
                onPressed: onMessage,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.secondary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: AppColors.lightGrey),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                  textStyle: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Iconsax.message, size: 16),
                    const Gap(6),
                    const Text(AppTexts.sellerActionMessage),
                  ],
                ),
              ),
            ),
            const Gap(AppSizes.sm),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: onOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE8823B),
                  foregroundColor: AppColors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                  textStyle: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(AppTexts.sellerActionOrder),
                    const Gap(6),
                    const Icon(Iconsax.arrow_right_3, size: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
