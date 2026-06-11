import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/core/models/listing.dart';
import 'package:incacook/core/models/listing_filter.dart';
import 'package:incacook/core/models/listing_mappers.dart';
import 'package:incacook/core/services/location/location_service.dart';
import 'package:incacook/core/utils/device/device_utility.dart';
import 'package:incacook/features/catalog/data/repositories/listings_repository.dart';
import 'package:incacook/features/catalog/presentation/screens/product_detail.dart';
import 'package:incacook/features/client/controllers/filter_controller.dart';
import 'package:incacook/features/client/data/client_mock_data.dart';
import 'package:incacook/core/models/food_listing.dart';
import 'package:incacook/core/models/kitchen.dart';
import 'package:incacook/features/client/presentation/widget/category_hub.dart';
import 'package:incacook/features/client/presentation/widget/food_listing_card.dart';
import 'package:incacook/core/widgets/decor/decor_blob.dart';
import 'package:incacook/features/client/presentation/widget/client_home_appbar.dart';
import 'package:incacook/features/client/presentation/widget/client_home_search_bar.dart';
import 'package:incacook/features/client/presentation/widget/client_home_section.dart';
import 'package:incacook/features/client/presentation/widget/kitchen_card.dart';
import 'package:incacook/features/seller/data/seller_mock_data.dart';
import 'package:incacook/features/seller/presentation/screens/seller_profile.dart';

class ClientHomeScreen extends StatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  State<ClientHomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<ClientHomeScreen> {
  final FilterController _filter = FilterController.instance;
  final ScrollController _scrollController = ScrollController();

  final Set<String> _savedKitchenIds = <String>{};

  //* Drives the appbar slide. Toggled in [_handleScroll] when the user
  //* changes scroll direction.
  bool _appBarVisible = true;

  // Real backend feed for the "food near you" section. The other two
  // sections (kitchens, solidarity) still use mock data — they live on
  // different endpoints / shapes that haven't been wired yet.
  List<Listing> _realListings = const [];
  bool _loadingFeed = true;
  String? _feedError;

  // Real buyer location (null until resolved / when permission denied).
  // Sent to the backend feed so distance filter + sort work server-side.
  double? _lat;
  double? _lng;
  String? _locationNote;

  // Debounced refetch when the filter changes (category hub / filters sheet).
  Worker? _filterWorker;

  late final List<Kitchen> _kitchens = ClientMockData.kitchens();
  late final List<FoodListing> _solidarityListings =
      ClientMockData.solidarityListings();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    // Refetch from the backend (debounced) whenever the filter changes —
    // category hub, cuisine/diet/dish chips, distance, stock.
    _filterWorker = debounce<ListingFilter>(
      _filter.filter,
      (_) => _loadFeed(),
      time: const Duration(milliseconds: 350),
    );
    _init();
  }

  /// Resolve the user's location (best-effort), then load the feed.
  Future<void> _init() async {
    await _resolveLocation();
    await _loadFeed();
  }

  /// Reads the device location via [LocationService]. On denial / disabled
  /// services we keep going with no point (distance filter/sort disabled) and
  /// surface a clear note — never crash.
  Future<void> _resolveLocation() async {
    try {
      final loc = Get.isRegistered<LocationService>()
          ? LocationService.instance
          : Get.put(LocationService(), permanent: true);
      final pos = await loc.getCurrent();
      if (!mounted) return;
      if (pos != null) {
        _lat = pos.latitude;
        _lng = pos.longitude;
        _locationNote = null;
      } else {
        _lat = null;
        _lng = null;
        _locationNote =
            'Localisation désactivée — activez-la pour filtrer par distance.';
      }
    } catch (_) {
      _lat = null;
      _lng = null;
      _locationNote = 'Localisation indisponible.';
    }
  }

  /// `GET /v1/listings` — the buyer feed, filtered SERVER-SIDE from the active
  /// [FilterController] (category, cuisine, diet, dish type, distance, stock)
  /// plus the real buyer location. Buyer-feed-only fields (sellerName,
  /// distanceKm, lat/lng, rating, …) come back populated.
  Future<void> _loadFeed() async {
    setState(() {
      _loadingFeed = true;
      _feedError = null;
    });
    try {
      final result = await ListingsRepository().getFeed(
        _filter.toQuery(lat: _lat, lng: _lng),
      );
      if (!mounted) return;
      setState(() {
        _realListings = result.items;
        _loadingFeed = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingFeed = false;
        _feedError = e.toString();
      });
    }
  }

  Widget _buildFeedSection(BuildContext context) {
    final sectionHeight = DeviceUtils.getScreenHeight(context) * 0.4;
    if (_loadingFeed) {
      return ClientHomeSection(
        title: AppTexts.clientHomeSectionFoodNearYou,
        height: sectionHeight,
        children: const [Center(child: CircularProgressIndicator())],
      );
    }
    if (_feedError != null) {
      return ClientHomeSection(
        title: AppTexts.clientHomeSectionFoodNearYou,
        height: sectionHeight,
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off, size: 36),
                const Gap(AppSizes.sm),
                ElevatedButton(
                  onPressed: _loadFeed,
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          ),
        ],
      );
    }
    if (_realListings.isEmpty) {
      return ClientHomeSection(
        title: AppTexts.clientHomeSectionFoodNearYou,
        height: sectionHeight,
        children: const [
          Center(child: Text('Aucun produit pour le moment.')),
        ],
      );
    }
    return ClientHomeSection(
      title: AppTexts.clientHomeSectionFoodNearYou,
      height: sectionHeight,
      children: [
        for (final l in _realListings)
          FoodListingCard(
            listing: _toFoodListing(l),
            onTap: () => Get.to(() => ProductDetailScreen(listing: l)),
          ),
      ],
    );
  }

  /// Adapter for the existing [FoodListingCard] — shared mapping so the feed
  /// and the map stay in sync (see [ListingToFoodListing]).
  FoodListing _toFoodListing(Listing l) => l.toFoodListing();

  void _handleScroll() {
    final direction = _scrollController.position.userScrollDirection;
    if (direction == ScrollDirection.reverse && _appBarVisible) {
      setState(() => _appBarVisible = false);
    } else if (direction == ScrollDirection.forward && !_appBarVisible) {
      setState(() => _appBarVisible = true);
    }
  }

  @override
  void dispose() {
    _filterWorker?.dispose();
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    super.dispose();
  }

  void _toggleKitchenSaved(String id) {
    setState(() {
      if (_savedKitchenIds.contains(id)) {
        _savedKitchenIds.remove(id);
      } else {
        _savedKitchenIds.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    //* With extendBodyBehindAppBar the body's y=0 is the screen top, so the
    //* blob can bleed behind the (transparent) appbar. We add the appbar +
    //* status bar height back into the scroll view's top padding so the
    //* visible content stays in the same place.

    final appBarHeight =
        MediaQuery.viewPaddingOf(context).top + AppSizes.appBarHeight;

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(appBarHeight),
        child: AnimatedSlide(
          offset: _appBarVisible ? Offset.zero : const Offset(0, -1),
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          child: const ClientHomeAppBar(),
        ),
      ),
      body: Stack(
        children: [
          //* decorative top-right blob (purely cosmetic, no input).
          const Positioned(top: -8, right: -16, child: DecorBlob()),
          SingleChildScrollView(
            controller: _scrollController,
            padding: EdgeInsets.only(
              top: appBarHeight + AppSizes.md,
              bottom: AppSizes.spaceBtwSections * 2,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //* search bar + Filtres button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                  child: ClientHomeSearchBar(),
                ),
                const Gap(AppSizes.md + 2),

                //* categories — main pills + subcategory circles. Drives
                //* filter.category, filter.cuisines, filter.diets, and
                //* filter.dishTypes via FilterController internally.
                const CategoryHubSection(),

                const Gap(AppSizes.spaceBtwSections - AppSizes.sm),

                //* food near you — real `GET /v1/listings` feed, filtered
                //* client-side by [FilterController]. Loading / error /
                //* empty states are rendered as single-card placeholders
                //* inside the horizontal section so the layout doesn't jump.
                //* location note when permission is denied/disabled (the feed
                //* still works, just without distance filtering/sort).
                if (_locationNote != null) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                    child: Text(
                      _locationNote!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const Gap(AppSizes.sm),
                ],

                //* food near you — real `GET /v1/listings` feed, filtered
                //* SERVER-SIDE from FilterController + buyer location.
                _buildFeedSection(context),
                const Gap(AppSizes.spaceBtwSections),

                //* kitchens near you
                ClientHomeSection(
                  title: AppTexts.clientHomeSectionKitchensNearYou,
                  height: DeviceUtils.getScreenHeight(context) * 0.4,
                  children: [
                    for (final kitchen in _kitchens)
                      KitchenCard(
                        kitchen: kitchen,
                        isSaved: _savedKitchenIds.contains(kitchen.id),
                        onTap: () => Get.to(
                          () => SellerProfileScreen(
                            profile: SellerMockData.demoSeller(),
                          ),
                        ),
                        onToggleSaved: () => _toggleKitchenSaved(kitchen.id),
                      ),
                  ],
                ),

                const Gap(AppSizes.spaceBtwSections),

                //* partages solidaires (free food)
                ClientHomeSection(
                  title: AppTexts.clientHomeSectionSolidarity,
                  height: DeviceUtils.getScreenHeight(context) * 0.4,
                  children: [
                    for (final listing in _solidarityListings)
                      FoodListingCard(
                        listing: listing,
                        onTap: () => Get.to(() => const ProductDetailScreen()),
                      ),
                  ],
                ),

                const Gap(AppSizes.spaceBtwSections * 2),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
