import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:incacook/core/common/widgets/appbar/appbar.dart';
import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/utils/popups/blurred_modal_sheet.dart';
import 'package:incacook/core/utils/theme/theme_extensions.dart';
import 'package:incacook/features/catalog/presentation/screens/product_detail.dart';
import 'package:incacook/features/map/controllers/map_controller.dart';
import 'package:incacook/features/map/domain/map_entry.dart';
import 'package:incacook/features/map/presentation/widget/center_on_user_button.dart';
import 'package:incacook/features/map/presentation/widget/map_filter_bar.dart';
import 'package:incacook/features/map/presentation/widget/map_listing_sheet.dart';
import 'package:incacook/features/map/presentation/widget/map_pin.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  //* Pin bbox dimensions. Width is just slack for the pill content; height
  //* must accommodate the tallest possible state (~72dp halo at peak) so
  //* the halo doesn't clip when [Align.bottomCenter] places the pin tip at
  //* the SizedBox's bottom edge.
  static const double _pinWidth = 90;
  static const double _pinHeight = 80;
  static const double _userDotSize = 44;

  void _openSheetFor(BuildContext context, MapEntry entry) {
    final controller = MapController.instance;
    controller.setSelected(entry.listing.id);
    unawaited(controller.flyToCurrentZoom(entry.position));

    showBlurredModalBottomSheet<void>(
      context: context,
      builder: (_) => MapListingSheet(
        listing: entry.listing,
        // Open the real backend record this pin was built from.
        onViewDetail: () =>
            Get.to(() => ProductDetailScreen(listing: entry.source)),
        onOrder: () => Get.back<void>(),
      ),
    ).whenComplete(() => controller.setSelected(null));
  }

  @override
  Widget build(BuildContext context) {
    final controller = MapController.instance;
    final styleUri = context.isDark ? MapboxStyles.DARK : MapboxStyles.LIGHT;

    return Scaffold(
      appBar: const CustomAppBar(showBackArrow: true),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          //* full-screen map
          MapWidget(
            styleUri: styleUri,
            cameraOptions: CameraOptions(
              center: Point(coordinates: controller.userLocation.value),
              zoom: MapController.initialZoom,
            ),
            onMapCreated: controller.onMapCreated,
            onCameraChangeListener: controller.onCameraChange,
          ),

          //* user location dot — anchored at the projected screen point
          Obx(() {
            final coord = controller.userScreenCoord.value;
            if (coord == null) return const SizedBox.shrink();
            return Positioned(
              left: coord.x - _userDotSize / 2,
              top: coord.y - _userDotSize / 2,
              width: _userDotSize,
              height: _userDotSize,
              child: const _UserLocationDot(),
            );
          }),

          //* food pins — bottom-center of each pin (i.e. the tail tip) is
          //* anchored at the projected screen coord. Align(bottomCenter)
          //* inside a fixed-height SizedBox makes the math simple:
          //*   top = y - pinHeight  → SizedBox bottom = y
          //*   tail tip == MapPin's bbox bottom == SizedBox bottom == y
          Obx(() {
            final visible = controller.visibleEntries;
            final coords = controller.pinScreenCoords;
            return Stack(
              children: [
                for (var i = 0; i < visible.length; i++)
                  if (i < coords.length && coords[i] != null)
                    Positioned(
                      left: coords[i]!.x - _pinWidth / 2,
                      top: coords[i]!.y - _pinHeight,
                      width: _pinWidth,
                      height: _pinHeight,
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Obx(
                          () => MapPin(
                            listing: visible[i].listing,
                            isSelected:
                                controller.selectedId.value ==
                                visible[i].listing.id,
                            isUrgent: controller.isUrgent(visible[i]),
                            onTap: () => _openSheetFor(context, visible[i]),
                          ),
                        ),
                      ),
                    ),
              ],
            );
          }),

          //* top: filter bar — pushed below the (transparent) appbar since
          //* extendBodyBehindAppBar puts y=0 at the screen top.
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.viewPaddingOf(context).top +
                    AppSizes.appBarHeight +
                    AppSizes.sm,
              ),
              child: Obx(
                () => MapFilterBar(
                  selected: controller.selectedFilter.value,
                  onSelect: controller.setFilter,
                ),
              ),
            ),
          ),

          //* center-on-user FAB
          Positioned(
            right: AppSizes.md,
            bottom: AppSizes.md,
            child: SafeArea(
              child: CenterOnUserButton(onTap: controller.centerOnUser),
            ),
          ),
        ],
      ),
    );
  }
}

class _UserLocationDot extends StatelessWidget {
  const _UserLocationDot();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: scheme.primary.withValues(alpha: 0.20),
            shape: BoxShape.circle,
          ),
        ),
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: scheme.primary,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
