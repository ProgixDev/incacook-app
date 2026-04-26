import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:homemade/core/constants/colors.dart';
import 'package:homemade/core/constants/sizes.dart';
import 'package:homemade/core/constants/text_strings.dart';
import 'package:homemade/core/utils/device/device_utility.dart';
import 'package:homemade/features/catalog/presentation/screens/product_detail.dart';
import 'package:homemade/features/home/controllers/filter_controller.dart';
import 'package:homemade/features/home/data/home_mock_data.dart';
import 'package:homemade/features/home/domain/food_listing.dart';
import 'package:homemade/features/home/domain/kitchen.dart';
import 'package:homemade/features/home/presentation/widget/active_filters_strip.dart';
import 'package:homemade/features/home/presentation/widget/categories_row.dart';
import 'package:homemade/features/home/presentation/widget/filters_button.dart';
import 'package:homemade/features/home/presentation/widget/food_listing_card.dart';
import 'package:homemade/core/widgets/decor/decor_blob.dart';
import 'package:homemade/features/home/presentation/widget/home_appbar.dart';
import 'package:homemade/features/home/presentation/widget/home_search_bar.dart';
import 'package:homemade/features/home/presentation/widget/home_section.dart';
import 'package:homemade/features/home/presentation/widget/kitchen_card.dart';
import 'package:homemade/features/seller/data/seller_mock_data.dart';
import 'package:homemade/features/seller/presentation/screens/seller_profile2.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FilterController _filter = FilterController.instance;
  final ScrollController _scrollController = ScrollController();

  final Set<String> _savedKitchenIds = <String>{};

  //* Drives the appbar slide. Toggled in [_handleScroll] when the user
  //* changes scroll direction.
  bool _appBarVisible = true;

  late final List<FoodListing> _listings = HomeMockData.listings();
  late final List<Kitchen> _kitchens = HomeMockData.kitchens();
  late final List<FoodListing> _solidarityListings =
      HomeMockData.solidarityListings();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
  }

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
      backgroundColor: AppColors.lightBackground,
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(appBarHeight),
        child: AnimatedSlide(
          offset: _appBarVisible ? Offset.zero : const Offset(0, -1),
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          child: const HomeAppBar(),
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
                  child: Row(
                    children: const [
                      Expanded(child: HomeSearchBar()),
                      Gap(AppSizes.sm),
                      FiltersButton(),
                    ],
                  ),
                ),
                const Gap(AppSizes.md + 2),

                //* categories (Tout + 3) — drives filter.category
                Obx(
                  () => CategoriesRow(
                    selected: _filter.filter.value.category,
                    onSelect: _filter.setCategory,
                  ),
                ),
                const Gap(AppSizes.sm),

                //* active filter chips (auto-hides when no filters)
                const ActiveFiltersStrip(),
                const Gap(AppSizes.spaceBtwSections - AppSizes.sm),

                //* food near you (filtered)
                Obx(() {
                  final filtered = _filter.apply(_listings);
                  return HomeSection(
                    title: AppTexts.homeSectionFoodNearYou,
                    height: DeviceUtils.getScreenHeight(context) * 0.4,
                    children: [
                      for (final listing in filtered)
                        FoodListingCard(
                          listing: listing,
                          onTap: () =>
                              Get.to(() => const ProductDetailScreen()),
                        ),
                    ],
                  );
                }),
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
        ],
      ),
    );
  }
}
