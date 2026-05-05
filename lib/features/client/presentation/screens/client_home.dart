import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:homemade/core/constants/sizes.dart';
import 'package:homemade/core/constants/text_strings.dart';
import 'package:homemade/core/utils/device/device_utility.dart';
import 'package:homemade/features/catalog/presentation/screens/product_detail.dart';
import 'package:homemade/features/client/controllers/filter_controller.dart';
import 'package:homemade/features/client/data/client_mock_data.dart';
import 'package:homemade/features/client/domain/food_listing.dart';
import 'package:homemade/features/client/domain/kitchen.dart';
import 'package:homemade/features/client/presentation/widget/category_hub.dart';
import 'package:homemade/features/client/presentation/widget/food_listing_card.dart';
import 'package:homemade/core/widgets/decor/decor_blob.dart';
import 'package:homemade/features/client/presentation/widget/client_home_appbar.dart';
import 'package:homemade/features/client/presentation/widget/client_home_search_bar.dart';
import 'package:homemade/features/client/presentation/widget/client_home_section.dart';
import 'package:homemade/features/client/presentation/widget/kitchen_card.dart';
import 'package:homemade/features/seller/data/seller_mock_data.dart';
import 'package:homemade/features/seller/presentation/screens/seller_profile.dart';

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

  late final List<FoodListing> _listings = ClientMockData.listings();
  late final List<Kitchen> _kitchens = ClientMockData.kitchens();
  late final List<FoodListing> _solidarityListings =
      ClientMockData.solidarityListings();

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
                  child: Expanded(child: ClientHomeSearchBar()),
                ),
                const Gap(AppSizes.md + 2),

                //* categories — main pills + subcategory circles. Drives
                //* filter.category, filter.cuisines, filter.diets, and
                //* filter.dishTypes via FilterController internally.
                const CategoryHubSection(),

                const Gap(AppSizes.spaceBtwSections - AppSizes.sm),

                //* food near you (filtered)
                Obx(() {
                  final filtered = _filter.apply(_listings);
                  return ClientHomeSection(
                    title: AppTexts.clientHomeSectionFoodNearYou,
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
