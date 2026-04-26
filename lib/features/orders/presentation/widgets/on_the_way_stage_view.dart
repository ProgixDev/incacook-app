import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:homemade/core/constants/colors.dart';
import 'package:homemade/core/constants/image_strings.dart';

class OnTheWayStageView extends StatelessWidget {
  const OnTheWayStageView({super.key});

  //? placeholder coordinates — wire to real order tracking later
  static final LatLng _driver = LatLng(48.8566, 2.3522);
  static final LatLng _destination = LatLng(48.8606, 2.3376);

  LatLng get _center => LatLng(
    (_driver.latitude + _destination.latitude) / 2,
    (_driver.longitude + _destination.longitude) / 2,
  );

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        initialCenter: _center,
        initialZoom: 14,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.vinted.v2',
          maxZoom: 19,
        ),
        PolylineLayer(
          polylines: [
            Polyline(
              points: [_driver, _destination],
              strokeWidth: 4,
              color: AppColors.black,
            ),
          ],
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: _destination,
              width: 48,
              height: 48,
              alignment: Alignment.topCenter,
              child: const _DestinationMarker(),
            ),
            Marker(
              point: _driver,
              width: 56,
              height: 56,
              child: const _DriverMarker(),
            ),
          ],
        ),
      ],
    );
  }
}

class _DestinationMarker extends StatelessWidget {
  const _DestinationMarker();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: const BoxDecoration(
            color: AppColors.black,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.home_rounded,
            color: AppColors.white,
            size: 22,
          ),
        ),
        //? tiny tail to look like a pin pointing down
        Container(width: 2, height: 4, color: AppColors.black),
      ],
    );
  }
}

class _DriverMarker extends StatelessWidget {
  const _DriverMarker();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: const CircleAvatar(
        radius: 24,
        backgroundColor: Color(0xFFE8823B),
        backgroundImage: AssetImage(AppImages.profilePic),
      ),
    );
  }
}
