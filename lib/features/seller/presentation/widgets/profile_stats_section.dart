import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:incacook/core/common/widgets/custon_shapes/container/circular_container.dart';
import 'package:incacook/core/common/widgets/custon_shapes/container/circular_image.dart';
import 'package:incacook/core/constants/image_strings.dart';
import 'package:incacook/core/utils/theme/brand_colors.dart';
import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/utils/device/device_utility.dart';
import 'package:incacook/core/models/seller_profile.dart';
import 'package:incacook/core/models/seller_rating.dart';
import 'package:incacook/features/seller/presentation/widgets/seller_rating_row.dart';

class ProfileStatsSection extends StatelessWidget {
  const ProfileStatsSection({
    super.key,
    required this.profile,
    required this.ratings,
  });

  final SellerProfile profile;
  final List<SellerRating> ratings;

  /// Profile picture diameter.
  static const double _imageSize = 250;

  /// How far the glass card cuts into the image's bottom — keeps the
  /// "image peeking above the card" silhouette identical to before.
  static const double _imageOverlap = 100;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: DeviceUtils.getScreenWidth(context) * 0.9,
      child: Stack(
        children: [
          //* 1) profile image — real avatar (network) with asset fallback.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Align(
              alignment: Alignment.topCenter,
              child: profile.avatarUrl.isEmpty
                  ? const CustomCircularImage(
                      image: AppImages.profilePic,
                      size: _imageSize,
                    )
                  : CustomCircularImage(
                      image: profile.avatarUrl,
                      size: _imageSize,
                      isNetworkImage: true,
                    ),
            ),
          ),

          //* 2) verified badge — only for verified sellers.
          if (profile.verifications.isNotEmpty)
            const Positioned(
              top: 50,
              left: 95,
              child: CustomCircularContainer(
                backgroundColor: BrandColors.primary,
                size: 40,
                child: Icon(Icons.check, color: Colors.white, size: 20),
              ),
            ),

          //* 3) glass card — the only non-positioned child, so the Stack's
          //* height grows with its natural content. No fixed height = no
          //* overflow when the rating list grows.
          Padding(
            padding: const EdgeInsets.only(top: _imageSize - _imageOverlap),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSizes.md),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile.name,
                            style: Theme.of(context).textTheme.titleMedium!
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                          Column(
                            children: [
                              Text(
                                '${profile.stats.reviewCount}',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium!
                                    .copyWith(
                                      color: Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              Text(
                                'Avis',
                                style: Theme.of(
                                  context,
                                ).textTheme.labelMedium,
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Gap(AppSizes.md),
                      for (var i = 0; i < ratings.length; i++) ...[
                        SellerRatingRow(rating: ratings[i]),
                        if (i != ratings.length - 1) const Gap(AppSizes.md),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
