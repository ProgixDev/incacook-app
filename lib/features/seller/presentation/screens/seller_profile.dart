import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:incacook/core/models/seller_rating.dart';
import 'package:incacook/features/client/data/kitchens_repository.dart';
import 'package:incacook/features/seller/presentation/widgets/profile_stats_section.dart';
import 'package:iconsax/iconsax.dart';
import 'package:incacook/core/common/widgets/appbar/appbar.dart';
import 'package:incacook/core/common/widgets/buttons/circular_icon_button.dart';
import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/models/seller_profile.dart';
import 'package:incacook/features/seller/presentation/widgets/bio_section.dart';
import 'package:incacook/features/seller/presentation/widgets/location_section.dart';
import 'package:incacook/features/seller/presentation/widgets/reviews_section.dart';

class SellerProfileScreen extends StatelessWidget {
  const SellerProfileScreen({super.key, required this.profile});

  final SellerProfile profile;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final List<SellerRating> ratings = profile.stats.criteriaRatings;
    final hasLocation = profile.location.lat != 0 || profile.location.lng != 0;
    return Scaffold(
      appBar: CustomAppBar(
        showBackArrow: true,
        title: Text('Profile', style: Theme.of(context).textTheme.titleMedium),
        actions: [
          CircularIconButton(
            icon: Iconsax.heart,
            iconColor: scheme.primary,
            backgroundColor: scheme.surface,
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
        child: SingleChildScrollView(
          child: SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ProfileStatsSection(profile: profile, ratings: ratings),
                const Gap(AppSizes.spaceBtwSections),
                // Sections with no real backing are hidden (real-but-sparse):
                // bio only when set, location only when geocoded, reviews only
                // when present (no reviews list endpoint yet).
                if (profile.bio.trim().isNotEmpty) ...[
                  BioSection(bio: profile.bio),
                  const Gap(AppSizes.spaceBtwSections),
                ],
                if (hasLocation) ...[
                  LocationSection(
                    profileLocation: profile.location,
                    neighborhood: profile.neighborhood,
                  ),
                  const Gap(AppSizes.spaceBtwSections),
                ],
                if (profile.recentReviews.isNotEmpty) ...[
                  ReviewsSection(reviews: profile.recentReviews),
                  const Gap(AppSizes.spaceBtwSections),
                ],
                const Gap(AppSizes.spaceBtwSections),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Fetches a real seller profile by id (`GET /v1/sellers/:id`) and renders
/// [SellerProfileScreen] — replaces the old `SellerMockData.demoSeller()` push.
class SellerProfileLoader extends StatefulWidget {
  const SellerProfileLoader({super.key, required this.sellerId});

  final String sellerId;

  @override
  State<SellerProfileLoader> createState() => _SellerProfileLoaderState();
}

class _SellerProfileLoaderState extends State<SellerProfileLoader> {
  late final Future<SellerProfile> _future = KitchensRepository().getSeller(
    widget.sellerId,
  );

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SellerProfile>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final profile = snapshot.data;
        if (snapshot.hasError || profile == null) {
          return Scaffold(
            appBar: const CustomAppBar(showBackArrow: true),
            body: const Center(child: Text('Profil indisponible')),
          );
        }
        return SellerProfileScreen(profile: profile);
      },
    );
  }
}
