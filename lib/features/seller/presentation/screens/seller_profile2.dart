import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:homemade/features/seller/domain/seller_rating.dart';
import 'package:homemade/features/seller/presentation/widgets/profile_stats_section.dart';
import 'package:iconsax/iconsax.dart';
import 'package:homemade/core/common/widgets/appbar/appbar.dart';
import 'package:homemade/core/common/widgets/buttons/circular_icon_button.dart';
import 'package:homemade/core/constants/colors.dart';
import 'package:homemade/core/constants/sizes.dart';
import 'package:homemade/features/seller/domain/seller_profile.dart';
import 'package:homemade/features/seller/presentation/widgets/bio_section.dart';
import 'package:homemade/features/seller/presentation/widgets/location_section.dart';
import 'package:homemade/features/seller/presentation/widgets/reviews_section.dart';

class SellerProfileScreen extends StatelessWidget {
  const SellerProfileScreen({super.key, required this.profile});

  final SellerProfile profile;

  @override
  Widget build(BuildContext context) {
    final List<SellerRating> ratings = profile.ratings;
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: CustomAppBar(
        showBackArrow: true,
        title: Text('Profile', style: Theme.of(context).textTheme.titleMedium),
        actions: [
          CircularIconButton(
            icon: Iconsax.heart,
            iconColor: AppColors.primary,
            backgroundColor: AppColors.accent,
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
                const BioSection(),
                const Gap(AppSizes.spaceBtwSections),
                LocationSection(
                  profileLocation: profile.location,
                  neighborhood: profile.neighborhood,
                ),
                const Gap(AppSizes.spaceBtwSections),
                const ReviewsSection(),
                const Gap(AppSizes.spaceBtwSections * 2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


