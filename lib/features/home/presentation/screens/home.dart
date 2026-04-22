import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:vinted_v2/core/constants/colors.dart';
import 'package:vinted_v2/core/constants/sizes.dart';
import 'package:vinted_v2/core/constants/text_strings.dart';
import 'package:vinted_v2/core/enums/food_enums.dart';
import 'package:vinted_v2/core/utils/device/device_utility.dart';
import 'package:vinted_v2/features/catalog/presentation/screens/product_detail.dart';
import 'package:vinted_v2/features/home/data/home_mock_data.dart';
import 'package:vinted_v2/features/home/domain/food_listing.dart';
import 'package:vinted_v2/features/home/domain/kitchen.dart';
import 'package:vinted_v2/features/home/presentation/widget/categories_row.dart';
import 'package:vinted_v2/features/home/presentation/widget/food_listing_card.dart';
import 'package:vinted_v2/features/home/presentation/widget/home_appbar.dart';
import 'package:vinted_v2/features/home/presentation/widget/home_search_bar.dart';
import 'package:vinted_v2/features/home/presentation/widget/home_section.dart';
import 'package:vinted_v2/features/home/presentation/widget/kitchen_card.dart';
import 'package:vinted_v2/features/seller/data/seller_mock_data.dart';
import 'package:vinted_v2/features/seller/presentation/screens/seller_profile2.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  //* null == "Tout" (all categories)
  SellerCategory? _selectedCategory;

  final Set<String> _savedKitchenIds = <String>{};

  late final List<FoodListing> _listings = HomeMockData.listings();
  late final List<Kitchen> _kitchens = HomeMockData.kitchens();
  late final List<FoodListing> _solidarityListings =
      HomeMockData.solidarityListings();

  List<FoodListing> get _filteredListings {
    if (_selectedCategory == null) return _listings;
    return _listings.where((l) => l.category == _selectedCategory).toList();
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
            //* search bar
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSizes.md),
              child: HomeSearchBar(),
            ),
            const Gap(AppSizes.md + 2),

            //* categories (Tout + 3)
            CategoriesRow(
              selected: _selectedCategory,
              onSelect: (cat) => setState(() => _selectedCategory = cat),
            ),
            const Gap(AppSizes.spaceBtwSections - AppSizes.sm),

            //* food near you
            HomeSection(
              title: AppTexts.homeSectionFoodNearYou,
              height: DeviceUtils.getScreenHeight(context) * 0.4,
              children: [
                for (final listing in filtered)
                  FoodListingCard(
                    listing: listing,
                    onTap: () => Get.to(() => const ProductDetailScreen()),
                  ),
              ],
            ),
            // const Gap(AppSizes.spaceBtwItems),

            //* kitchens near you
            HomeSection(
              title: AppTexts.homeSectionKitchensNearYou,
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

            //* partages solidaires (free food)
            HomeSection(
              title: AppTexts.homeSectionSolidarity,
              height: DeviceUtils.getScreenHeight(context) * 0.4,
              children: [
                for (final listing in _solidarityListings)
                  FoodListingCard(
                    listing: listing,
                    onTap: () => Get.to(() => const ProductDetailScreen()),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
