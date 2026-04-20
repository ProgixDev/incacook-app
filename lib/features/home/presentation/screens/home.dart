import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:vinted_v2/core/common/widgets/custon_shapes/container/circular_container.dart';
import 'package:vinted_v2/core/constants/colors.dart';
import 'package:vinted_v2/core/constants/image_strings.dart';
import 'package:vinted_v2/core/constants/sizes.dart';
import 'package:vinted_v2/core/constants/text_strings.dart';
import 'package:vinted_v2/core/utils/device/device_utility.dart';
import 'package:vinted_v2/features/catalog/presentation/screens/product_detail.dart';
import 'package:vinted_v2/features/home/domain/food_listing.dart';
import 'package:vinted_v2/features/map/presentation/screens/map.dart';
import 'package:vinted_v2/features/home/domain/restaurant_offer.dart';
import 'package:vinted_v2/features/home/presentation/widget/category_pill.dart';
import 'package:vinted_v2/features/home/presentation/widget/empty_feed_state.dart';
import 'package:vinted_v2/features/home/presentation/widget/feed_food_card.dart';
import 'package:vinted_v2/features/home/presentation/widget/home_appbar.dart';
import 'package:vinted_v2/features/home/presentation/widget/home_search_bar.dart';
import 'package:vinted_v2/features/home/presentation/widget/quick_filter_chip.dart';
import 'package:vinted_v2/features/home/presentation/widget/restaurant_offer_card.dart';
import 'package:vinted_v2/features/home/presentation/widget/section_header.dart';
import 'package:vinted_v2/features/home/presentation/widget/urgent_food_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  //* null == "Tout" (all categories)
  SellerCategory? _selectedCategory;

  final Set<_QuickFilter> _activeFilters = <_QuickFilter>{};
  final Set<String> _savedIds = <String>{};

  late final List<FoodListing> _listings = _buildListings();
  late final List<FoodListing> _urgentListings = _buildUrgentListings();
  static const List<RestaurantOffer> _restaurants = [
    RestaurantOffer(
      name: 'Le Bistro',
      imagePath: AppImages.foodTest,
      offerLabel: '-50% après 20h',
      rating: 4.7,
      distanceKm: 0.6,
    ),
    RestaurantOffer(
      name: 'Pizza Mamma',
      imagePath: AppImages.foodTest,
      offerLabel: 'Panier surprise',
      rating: 4.5,
      distanceKm: 0.9,
    ),
    RestaurantOffer(
      name: 'Sushi Corner',
      imagePath: AppImages.foodTest,
      offerLabel: '-30% fin de service',
      rating: 4.6,
      distanceKm: 1.2,
    ),
  ];

  List<FoodListing> _buildListings() {
    final now = DateTime.now();
    return [
      FoodListing(
        id: 'f1',
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
        expiresAt: now.add(const Duration(hours: 3, minutes: 30)),
      ),
      FoodListing(
        id: 'f2',
        name: 'Lasagne maison',
        imagePath: AppImages.foodTest,
        sellerName: 'Chez Luigi',
        category: SellerCategory.traiteur,
        distanceKm: 0.8,
        rating: 4.7,
        reviewCount: 56,
        dietaryTags: const [],
        portionsLeft: 6,
        fulfillment: Fulfillment.both,
        originalPrice: 12.00,
        price: 5.50,
        expiresAt: now.add(const Duration(hours: 5)),
      ),
      FoodListing(
        id: 'f3',
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
        expiresAt: now.add(const Duration(hours: 2)),
      ),
      FoodListing(
        id: 'f4',
        name: 'Quiche lorraine',
        imagePath: AppImages.foodTest,
        sellerName: 'Marc',
        category: SellerCategory.social,
        distanceKm: 0.5,
        rating: 4.8,
        reviewCount: 12,
        dietaryTags: const [],
        portionsLeft: 1,
        fulfillment: Fulfillment.pickup,
        price: 2.50,
        expiresAt: now.add(const Duration(hours: 1, minutes: 45)),
      ),
    ];
  }

  List<FoodListing> _buildUrgentListings() {
    final now = DateTime.now();
    return [
      FoodListing(
        id: 'u1',
        name: 'Tajine',
        imagePath: AppImages.foodTest,
        sellerName: 'Fatima',
        category: SellerCategory.social,
        distanceKm: 0.3,
        rating: 4.9,
        reviewCount: 24,
        portionsLeft: 2,
        fulfillment: Fulfillment.delivery,
        price: 3,
        expiresAt: now.add(const Duration(hours: 2)),
      ),
      FoodListing(
        id: 'u2',
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
      FoodListing(
        id: 'u3',
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
    ];
  }

  List<FoodListing> get _filteredListings {
    if (_selectedCategory == null) return _listings;
    return _listings.where((l) => l.category == _selectedCategory).toList();
  }

  void _toggleSaved(String id) {
    setState(() {
      if (_savedIds.contains(id)) {
        _savedIds.remove(id);
      } else {
        _savedIds.add(id);
      }
    });
  }

  void _toggleFilter(_QuickFilter filter) {
    setState(() {
      if (_activeFilters.contains(filter)) {
        _activeFilters.remove(filter);
      } else {
        _activeFilters.add(filter);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredListings;

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      extendBody: true,
      appBar: const HomeAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(
          top: AppSizes.md,
          bottom: AppSizes.spaceBtwSections * 2,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //* search bar + map button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
              child: Row(
                children: [
                  const Expanded(child: HomeSearchBar()),
                  const Gap(AppSizes.md),
                  GestureDetector(
                    onTap: () => Get.to(() => const MapScreen()),
                    child: CustomCircularContainer(
                      size: 56,
                      backgroundColor: AppColors.secondary,
                      child: const Icon(
                        Iconsax.map,
                        color: AppColors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Gap(AppSizes.md + 2),

            //* category tabs
            _CategoryTabs(
              selected: _selectedCategory,
              onSelect: (cat) => setState(() => _selectedCategory = cat),
            ),
            const Gap(AppSizes.md),

            //* quick filter chips
            _QuickFilterRow(active: _activeFilters, onToggle: _toggleFilter),
            const Gap(AppSizes.spaceBtwSections - 4),

            //* urgent section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
              child: SectionHeader(
                title: AppTexts.homeSectionUrgent,
                showSeeAll: true,
                onSeeAllTap: () {},
              ),
            ),
            const Gap(AppSizes.md),
            SizedBox(
              height: DeviceUtils.getScreenHeight(context) * 0.28,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                itemCount: _urgentListings.length,
                separatorBuilder: (_, _) => const Gap(AppSizes.md - 4),
                itemBuilder: (context, index) {
                  return UrgentFoodCard(
                    listing: _urgentListings[index],
                    onTap: () => Get.to(() => const ProductDetailScreen()),
                  );
                },
              ),
            ),
            const Gap(AppSizes.spaceBtwSections),

            //* main feed section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
              child: SectionHeader(title: AppTexts.homeSectionNearYou),
            ),
            const Gap(AppSizes.md),
            if (filtered.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                child: EmptyFeedState(onPostMeal: () {}, onExpandSearch: () {}),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                child: Column(
                  children: [
                    for (final listing in filtered) ...[
                      FeedFoodCard(
                        listing: listing,
                        isSaved: _savedIds.contains(listing.id),
                        onTap: () => Get.to(() => const ProductDetailScreen()),
                        onToggleSaved: () => _toggleSaved(listing.id),
                      ),
                      const Gap(AppSizes.md),
                    ],
                  ],
                ),
              ),
            const Gap(AppSizes.spaceBtwSections - AppSizes.md),

            //* restaurants section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
              child: SectionHeader(
                title: AppTexts.homeSectionRestaurants,
                showSeeAll: true,
                onSeeAllTap: () {},
              ),
            ),
            const Gap(AppSizes.md),
            SizedBox(
              height: DeviceUtils.getScreenHeight(context) * 0.28,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                itemCount: _restaurants.length,
                separatorBuilder: (_, _) => const Gap(AppSizes.md - 4),
                itemBuilder: (context, index) {
                  return RestaurantOfferCard(
                    offer: _restaurants[index],
                    onTap: () => Get.to(() => const ProductDetailScreen()),
                  );
                },
              ),
            ),
            const Gap(AppSizes.spaceBtwSections * 2.5),
          ],
        ),
      ),
    );
  }
}

class _CategoryTabs extends StatelessWidget {
  const _CategoryTabs({required this.selected, required this.onSelect});

  final SellerCategory? selected;
  final ValueChanged<SellerCategory?> onSelect;

  @override
  Widget build(BuildContext context) {
    final items = <(SellerCategory?, String, String?)>[
      (null, AppTexts.homeCategoryAll, AppImages.all),
      (
        SellerCategory.social,
        SellerCategory.social.label,
        SellerCategory.social.imagePath,
      ),
      (
        SellerCategory.traiteur,
        SellerCategory.traiteur.label,
        SellerCategory.traiteur.imagePath,
      ),
      (
        SellerCategory.restaurant,
        SellerCategory.restaurant.label,
        SellerCategory.restaurant.imagePath,
      ),
    ];

    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
        itemCount: items.length,
        separatorBuilder: (_, _) => const Gap(AppSizes.sm + 2),
        itemBuilder: (context, index) {
          final (cat, label, imagePath) = items[index];
          return CategoryPill(
            label: label,
            imagePath: imagePath,
            selected: selected == cat,
            onTap: () => onSelect(cat),
          );
        },
      ),
    );
  }
}

class _QuickFilterRow extends StatelessWidget {
  const _QuickFilterRow({required this.active, required this.onToggle});

  final Set<_QuickFilter> active;
  final ValueChanged<_QuickFilter> onToggle;

  @override
  Widget build(BuildContext context) {
    final specs = <(_QuickFilter, String, IconData?, Color?)>[
      (
        _QuickFilter.availableNow,
        AppTexts.homeFilterAvailableNow,
        Iconsax.clock,
        null,
      ),
      (_QuickFilter.nearby, AppTexts.homeFilterNearby, Iconsax.location, null),
      (_QuickFilter.cheap, AppTexts.homeFilterCheap, Iconsax.wallet_2, null),
      (
        _QuickFilter.halal,
        AppTexts.homeFilterHalal,
        null,
        DietaryTag.halal.color,
      ),
      (
        _QuickFilter.vegan,
        AppTexts.homeFilterVegan,
        null,
        DietaryTag.vegan.color,
      ),
      (
        _QuickFilter.glutenFree,
        AppTexts.homeFilterGlutenFree,
        null,
        DietaryTag.glutenFree.color,
      ),
    ];

    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
        itemCount: specs.length,
        separatorBuilder: (_, _) => const Gap(AppSizes.sm),
        itemBuilder: (context, index) {
          final (filter, label, icon, color) = specs[index];
          return QuickFilterChip(
            label: label,
            icon: icon,
            activeColor: color,
            selected: active.contains(filter),
            onTap: () => onToggle(filter),
          );
        },
      ),
    );
  }
}

enum _QuickFilter { availableNow, nearby, cheap, halal, vegan, glutenFree }
