import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import 'package:latlong2/latlong.dart';
import 'package:homemade/core/common/styles/shadows_styles.dart';
import 'package:homemade/core/constants/colors.dart';
import 'package:homemade/core/constants/sizes.dart';
import 'package:homemade/core/constants/text_strings.dart';

class LocationSection extends StatelessWidget {
  const LocationSection({
    super.key,
    required this.neighborhood,
    required this.profileLocation,
  });

  final String neighborhood;
  final LatLng profileLocation;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppTexts.sellerLocationTitle,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(color: AppColors.textPrimary),
        ),
        const Gap(AppSizes.md),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
          child: Container(
            height: 160,
            decoration: BoxDecoration(
              boxShadow: [CustomShadowStyle.customCircleShadows()],
            ),
            child: IgnorePointer(
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: profileLocation,
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
                        point: profileLocation,
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
        const Gap(AppSizes.sm),
        Row(
          children: [
            const Icon(Iconsax.location, size: 14, color: AppColors.primary),
            const Gap(6),
            Text(
              neighborhood,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
