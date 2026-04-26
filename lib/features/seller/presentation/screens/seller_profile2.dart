import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import 'package:homemade/core/common/widgets/appbar/appbar.dart';
import 'package:homemade/core/common/widgets/buttons/circular_icon_button.dart';
import 'package:homemade/core/common/widgets/custon_shapes/container/circular_container.dart';
import 'package:homemade/core/common/widgets/custon_shapes/container/circular_image.dart';
import 'package:homemade/core/constants/colors.dart';
import 'package:homemade/core/constants/image_strings.dart';
import 'package:homemade/core/constants/sizes.dart';
import 'package:homemade/core/utils/device/device_utility.dart';
import 'package:homemade/features/seller/domain/seller_profile.dart';
import 'package:homemade/features/seller/presentation/widgets/bio_section.dart';
import 'package:homemade/features/seller/presentation/widgets/location_section.dart';
import 'package:homemade/features/seller/presentation/widgets/performance_row.dart';
import 'package:homemade/features/seller/presentation/widgets/reviews_section.dart';

class SellerProfileScreen extends StatelessWidget {
  const SellerProfileScreen({super.key, required this.profile});

  final SellerProfile profile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: CustomAppBar(
        showBackArrow: true,
        title: Text('Profile'),
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
                SizedBox(
                  width: DeviceUtils.getScreenWidth(context) * 0.9,
                  height: DeviceUtils.getScreenHeight(context) * 0.52,
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.topCenter,
                        child: CustomCircularImage(
                          image: AppImages.profilePic,
                          size: 250,
                        ),
                      ),
                      Positioned(
                        top: 50,
                        left: 95,
                        child: CustomCircularContainer(
                          backgroundColor: AppColors.primary,
                          size: 40,
                          child: Icon(
                            Icons.check,
                            color: AppColors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                            child: Container(
                              width: DeviceUtils.getScreenWidth(context) * 0.9,
                              height:
                                  DeviceUtils.getScreenHeight(context) * 0.33,
                              padding: EdgeInsets.all(AppSizes.md),
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
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        profile.name,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium!
                                            .copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      Column(
                                        children: [
                                          Text(
                                            '30',
                                            style: Theme.of(context)
                                                .textTheme
                                                .headlineMedium!
                                                .copyWith(
                                                  color: AppColors.primary,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                          Text(
                                            'Contributions',
                                            style: Theme.of(
                                              context,
                                            ).textTheme.labelMedium,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const Gap(AppSizes.sm),
                                  PerformanceRow(
                                    metric: profile.performance[0],
                                  ),
                                  const Gap(AppSizes.xs),
                                  PerformanceRow(
                                    metric: profile.performance[1],
                                  ),
                                  const Gap(AppSizes.xs),
                                  PerformanceRow(
                                    metric: profile.performance[2],
                                  ),
                                  const Gap(AppSizes.xs),
                                  PerformanceRow(
                                    metric: profile.performance[3],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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
