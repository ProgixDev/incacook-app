import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:vinted_v2/core/common/widgets/appbar/appbar.dart';
import 'package:vinted_v2/core/constants/colors.dart';
import 'package:vinted_v2/core/constants/image_strings.dart';
import 'package:vinted_v2/core/constants/sizes.dart';
import 'package:vinted_v2/features/catalog/presentation/screens/product_detail.dart';
import 'package:vinted_v2/features/home/domain/food_listing.dart';
import 'package:vinted_v2/features/map/presentation/widget/center_on_user_button.dart';
import 'package:vinted_v2/features/map/presentation/widget/map_filter_bar.dart';
import 'package:vinted_v2/features/map/presentation/widget/map_listing_sheet.dart';
import 'package:vinted_v2/features/map/presentation/widget/map_pin.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  //? static demo user location — swap for geolocator lookup later
  static final LatLng _userLocation = LatLng(48.8566, 2.3522);
  static const double _initialZoom = 14;
  static const Duration _urgentWindow = Duration(hours: 2, minutes: 30);

  final MapController _mapController = MapController();

  MapFilter _selectedFilter = MapFilter.all;
  String? _selectedId;

  late final List<_MapEntry> _entries = _buildEntries();

  List<_MapEntry> _buildEntries() {
    final now = DateTime.now();
    return [
      _MapEntry(
        position: LatLng(48.8580, 2.3530),
        listing: FoodListing(
          id: 'm1',
          name: 'Tajine poulet olives',
          imagePath: AppImages.foodTest,
          sellerName: 'Fatima',
          category: SellerCategory.social,
          distanceKm: 0.3,
          rating: 4.9,
          reviewCount: 24,
          dietaryTags: const [DietaryTag.halal, DietaryTag.spicy],
          portionsLeft: 4,
          fulfillment: Fulfillment.delivery,
          originalPrice: 8.00,
          price: 3.00,
          expiresAt: now.add(const Duration(hours: 2)),
        ),
      ),
      _MapEntry(
        position: LatLng(48.8610, 2.3490),
        listing: FoodListing(
          id: 'm2',
          name: 'Lasagne maison',
          imagePath: AppImages.foodTest,
          sellerName: 'Chez Luigi',
          category: SellerCategory.traiteur,
          distanceKm: 0.8,
          rating: 4.7,
          reviewCount: 56,
          portionsLeft: 6,
          fulfillment: Fulfillment.both,
          originalPrice: 12.00,
          price: 5.50,
          expiresAt: now.add(const Duration(hours: 5)),
        ),
      ),
      _MapEntry(
        position: LatLng(48.8550, 2.3580),
        listing: FoodListing(
          id: 'm3',
          name: 'Buddha bowl végé',
          imagePath: AppImages.foodTest,
          sellerName: 'Green Kitchen',
          category: SellerCategory.restaurant,
          distanceKm: 1.1,
          rating: 4.6,
          reviewCount: 89,
          dietaryTags: const [DietaryTag.vegan, DietaryTag.glutenFree],
          portionsLeft: 2,
          fulfillment: Fulfillment.pickup,
          originalPrice: 11.00,
          price: 4.50,
          expiresAt: now.add(const Duration(hours: 1, minutes: 30)),
        ),
      ),
      _MapEntry(
        position: LatLng(48.8540, 2.3460),
        listing: FoodListing(
          id: 'm4',
          name: 'Soupe de légumes',
          imagePath: AppImages.foodTest,
          sellerName: 'Chez Anna',
          category: SellerCategory.traiteur,
          distanceKm: 1.0,
          rating: 4.7,
          reviewCount: 18,
          portionsLeft: 2,
          fulfillment: Fulfillment.both,
          price: 4,
          expiresAt: now.add(const Duration(hours: 1)),
        ),
      ),
      _MapEntry(
        position: LatLng(48.8620, 2.3560),
        listing: FoodListing(
          id: 'm5',
          name: 'Quiche lorraine',
          imagePath: AppImages.foodTest,
          sellerName: 'Marc',
          category: SellerCategory.social,
          distanceKm: 0.5,
          rating: 4.8,
          reviewCount: 12,
          portionsLeft: 1,
          fulfillment: Fulfillment.pickup,
          price: 2.50,
          expiresAt: now.add(const Duration(hours: 3)),
        ),
      ),
      _MapEntry(
        position: LatLng(48.8595, 2.3440),
        listing: FoodListing(
          id: 'm6',
          name: 'Tarte aux pommes',
          imagePath: AppImages.foodTest,
          sellerName: 'Boulangerie Paul',
          category: SellerCategory.restaurant,
          distanceKm: 0.7,
          rating: 4.6,
          reviewCount: 41,
          portionsLeft: 3,
          fulfillment: Fulfillment.pickup,
          price: 2,
          expiresAt: now.add(const Duration(hours: 4)),
        ),
      ),
    ];
  }

  bool _isUrgent(_MapEntry e) =>
      e.listing.expiresAt.difference(DateTime.now()) <= _urgentWindow;

  bool _matchesFilter(_MapEntry e) {
    switch (_selectedFilter) {
      case MapFilter.all:
        return true;
      case MapFilter.social:
        return e.listing.category == SellerCategory.social;
      case MapFilter.traiteur:
        return e.listing.category == SellerCategory.traiteur;
      case MapFilter.restaurant:
        return e.listing.category == SellerCategory.restaurant;
      case MapFilter.urgent:
        return _isUrgent(e);
    }
  }

  List<_MapEntry> get _visibleEntries =>
      _entries.where(_matchesFilter).toList();

  void _centerOnUser() {
    _mapController.move(_userLocation, _initialZoom);
  }

  void _openSheetFor(_MapEntry entry) {
    setState(() => _selectedId = entry.listing.id);
    _mapController.move(entry.position, _mapController.camera.zoom);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MapListingSheet(
        listing: entry.listing,
        onViewDetail: () => Get.to(() => const ProductDetailScreen()),
        onOrder: () => Get.back<void>(),
      ),
    ).whenComplete(() {
      if (mounted) setState(() => _selectedId = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visibleEntries;

    return Scaffold(
      body: Stack(
        children: [
          //* full-screen map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _userLocation,
              initialZoom: _initialZoom,
              minZoom: 11,
              maxZoom: 18,
              interactionOptions: const InteractionOptions(
                flags:
                    InteractiveFlag.pinchZoom |
                    InteractiveFlag.drag |
                    InteractiveFlag.doubleTapZoom,
              ),
            ),
            children: [
              TileLayer(
                //? swap to a Mapbox styleUrl once a token is wired
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.vinted.v2',
                maxZoom: 19,
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _userLocation,
                    width: 44,
                    height: 44,
                    child: const _UserLocationDot(),
                  ),
                  for (final entry in visible)
                    Marker(
                      point: entry.position,
                      width: 84,
                      height: 72,
                      alignment: Alignment.topCenter,
                      child: MapPin(
                        listing: entry.listing,
                        isSelected: _selectedId == entry.listing.id,
                        isUrgent: _isUrgent(entry),
                        onTap: () => _openSheetFor(entry),
                      ),
                    ),
                ],
              ),
            ],
          ),

          //* top: back button + filter bar
          Align(
            alignment: Alignment.topCenter,
            child: _TopSection(
              selectedFilter: _selectedFilter,
              onFilterSelect: (f) => setState(() => _selectedFilter = f),
            ),
          ),

          //* center-on-user FAB
          Positioned(
            right: AppSizes.md,
            bottom: AppSizes.md,
            child: SafeArea(child: CenterOnUserButton(onTap: _centerOnUser)),
          ),
        ],
      ),
    );
  }
}

class _TopSection extends StatelessWidget {
  const _TopSection({
    required this.selectedFilter,
    required this.onFilterSelect,
  });

  final MapFilter selectedFilter;
  final ValueChanged<MapFilter> onFilterSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CustomAppBar(showBackArrow: true),
        const Gap(AppSizes.sm),
        MapFilterBar(selected: selectedFilter, onSelect: onFilterSelect),
      ],
    );
  }
}

class _MapEntry {
  const _MapEntry({required this.position, required this.listing});

  final LatLng position;
  final FoodListing listing;
}

class _UserLocationDot extends StatelessWidget {
  const _UserLocationDot();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.20),
            shape: BoxShape.circle,
          ),
        ),
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.white, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.2),
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
