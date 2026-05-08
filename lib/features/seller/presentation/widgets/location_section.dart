import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:incacook/core/common/styles/shadows_styles.dart';
import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/core/services/map/models/map_route.dart';
import 'package:incacook/core/utils/theme/theme_extensions.dart';

class LocationSection extends StatefulWidget {
  const LocationSection({
    super.key,
    required this.neighborhood,
    required this.profileLocation,
  });

  final String neighborhood;
  final MapPoint profileLocation;

  @override
  State<LocationSection> createState() => _LocationSectionState();
}

class _LocationSectionState extends State<LocationSection> {
  static const double _pinSize = 32;

  MapboxMap? _map;
  ScreenCoordinate? _pinScreenCoord;

  Future<void> _onMapCreated(MapboxMap map) async {
    _map = map;
    await map.scaleBar.updateSettings(ScaleBarSettings(enabled: false));
    await _projectPin();
  }

  void _onCameraChange(CameraChangedEventData _) {
    unawaited(_projectPin());
  }

  Future<void> _projectPin() async {
    if (_map == null) return;
    final coord = await _map!.pixelForCoordinate(
      Point(
        coordinates: Position(
          widget.profileLocation.lng,
          widget.profileLocation.lat,
        ),
      ),
    );
    if (!mounted) return;
    setState(() => _pinScreenCoord = coord);
  }

  @override
  Widget build(BuildContext context) {
    final styleUri = context.isDark ? MapboxStyles.DARK : MapboxStyles.LIGHT;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppTexts.sellerLocationTitle,
          style: Theme.of(context).textTheme.titleMedium,
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
              child: Stack(
                children: [
                  MapWidget(
                    styleUri: styleUri,
                    cameraOptions: CameraOptions(
                      center: Point(
                        coordinates: Position(
                          widget.profileLocation.lng,
                          widget.profileLocation.lat,
                        ),
                      ),
                      zoom: 14.0,
                    ),
                    onMapCreated: _onMapCreated,
                    onCameraChangeListener: _onCameraChange,
                  ),
                  if (_pinScreenCoord != null)
                    Positioned(
                      left: _pinScreenCoord!.x - _pinSize / 2,
                      top: _pinScreenCoord!.y - _pinSize,
                      width: _pinSize,
                      height: _pinSize,
                      child: const Icon(
                        Iconsax.location5,
                        size: _pinSize,
                        color: Color(0xFFE8823B),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        const Gap(AppSizes.sm),
        Row(
          children: [
            Icon(
              Iconsax.location,
              size: 14,
              color: Theme.of(context).colorScheme.primary,
            ),
            const Gap(6),
            Text(
              widget.neighborhood,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ],
    );
  }
}
