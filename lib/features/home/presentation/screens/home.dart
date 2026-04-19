import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:vinted_v2/core/constants/colors.dart';
import 'package:vinted_v2/core/constants/image_strings.dart';
import 'package:vinted_v2/core/constants/sizes.dart';
import 'package:vinted_v2/core/constants/text_strings.dart';
import 'package:vinted_v2/core/utils/device_utils.dart';
import 'package:vinted_v2/core/widgets/layouts/grid_layout.dart';
import 'package:vinted_v2/features/home/domain/brand.dart';
import 'package:vinted_v2/features/home/domain/food_offer.dart';
import 'package:vinted_v2/features/home/domain/promo_banner.dart';
import 'package:vinted_v2/features/home/presentation/widget/active_order_strip.dart';
import 'package:vinted_v2/features/home/presentation/widget/brand_card.dart';
import 'package:vinted_v2/features/home/presentation/widget/category_chip.dart';
import 'package:vinted_v2/features/home/presentation/widget/craving_header.dart';
import 'package:vinted_v2/features/home/presentation/widget/food_offer_card.dart';
import 'package:vinted_v2/features/home/presentation/widget/home_appbar.dart';
import 'package:vinted_v2/features/home/presentation/widget/home_search_bar.dart';
import 'package:vinted_v2/features/home/presentation/widget/promo_banner_carousel.dart';
import 'package:vinted_v2/features/home/presentation/widget/section_header.dart';
import 'package:vinted_v2/features/orders/presentation/screens/order_tracking.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedCategoryIndex = 1; //? Food selected by default

  //? demo flag — swap for real "hasActiveOrder" check once orders are wired
  final bool _hasActiveOrder = true;

  static const List<PromoBanner> _promos = [
    PromoBanner(
      title: AppTexts.homePromo1Title,
      subtitle: AppTexts.homePromo1Subtitle,
      ctaLabel: AppTexts.homePromo1Cta,
      imagePath: AppImages.foodTest,
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.white,
    ),
    PromoBanner(
      title: AppTexts.homePromo2Title,
      subtitle: AppTexts.homePromo2Subtitle,
      ctaLabel: AppTexts.homePromo2Cta,
      imagePath: AppImages.foodTest,
      backgroundColor: AppColors.secondary,
      foregroundColor: AppColors.white,
    ),
    PromoBanner(
      title: AppTexts.homePromo3Title,
      subtitle: AppTexts.homePromo3Subtitle,
      ctaLabel: AppTexts.homePromo3Cta,
      imagePath: AppImages.foodTest,
      backgroundColor: Color(0xFFE8823B),
      foregroundColor: AppColors.white,
    ),
  ];

  static const List<_Category> _categories = [
    _Category(name: 'Plats', imagePath: AppImages.crafts),
    _Category(name: 'Boulang.', imagePath: AppImages.food),
    _Category(name: 'Desserts', imagePath: AppImages.plants),
    _Category(name: 'Épicerie', imagePath: AppImages.secondHand),
    _Category(name: 'Frais', imagePath: AppImages.wellness),
    _Category(name: 'Boissons', imagePath: AppImages.wellness),
  ];

  static const List<FoodOffer> _offers = [
    FoodOffer(
      titleLeading: 'Grilled',
      titleTrailing: 'Chicken Breast',
      imagePath: AppImages.foodTest,
      deliveryMinutes: 22,
      freeDelivery: true,
      price: 3.97,
      weightGrams: 320,
      calories: 162,
      containOffers: false,
      discountLabel: '25% Off Prices',
    ),
    FoodOffer(
      titleLeading: 'Spaghetti',
      titleTrailing: 'Meat Sauce',
      imagePath: AppImages.foodTest,
      deliveryMinutes: 35,
      freeDelivery: false,
      price: 2.50,
      weightGrams: 280,
      calories: 210,
      containOffers: true,
      discountLabel: '15% Off Prices',
    ),
    FoodOffer(
      titleLeading: 'Veggie',
      titleTrailing: 'Bowl',
      imagePath: AppImages.foodTest,
      deliveryMinutes: 18,
      freeDelivery: false,
      price: 4.20,
      weightGrams: 260,
      calories: 145,
      containOffers: true,
      discountLabel: 'Buy 1 Get 1',
    ),
  ];

  static const List<Brand> _brands = [
    Brand(
      name: 'Talabat Mart',
      imagePath: AppImages.foodTest,
      tagline: 'Freshness guaranteed',
      rating: 4.9,
      minDeliveryMinutes: 25,
      maxDeliveryMinutes: 60,
    ),
    Brand(
      name: 'LuLu Express',
      imagePath: AppImages.foodTest,
      tagline: 'Daily essentials',
      rating: 4.7,
      minDeliveryMinutes: 30,
      maxDeliveryMinutes: 55,
    ),
    Brand(
      name: 'Burger House',
      imagePath: AppImages.foodTest,
      tagline: 'Loved by locals',
      rating: 4.8,
      minDeliveryMinutes: 15,
      maxDeliveryMinutes: 35,
    ),
    Brand(
      name: 'Sushi Corner',
      imagePath: AppImages.foodTest,
      tagline: 'Chef specials',
      rating: 4.6,
      minDeliveryMinutes: 20,
      maxDeliveryMinutes: 40,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      extendBody: true,
      appBar: const HomeAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: AppSizes.spaceBtwSections * 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //* active order strip — only while a delivery is in progress
            if (_hasActiveOrder) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSizes.md,
                  AppSizes.md,
                  AppSizes.md,
                  0,
                ),
                child: ActiveOrderStrip(
                  onTap: () => Get.to(() => const OrderTrackingScreen()),
                ),
              ),
            ],

            //* craving heading
            const Padding(
              padding: EdgeInsets.all(AppSizes.md),
              child: CravingHeader(),
            ),

            //* search bar + filter button
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSizes.md),
              child: HomeSearchBar(),
            ),
            const Gap(AppSizes.spaceBtwSections),

            //* promo banner carousel
            PromoBannerCarousel(banners: _promos, onBannerTap: (_) {}),
            const Gap(AppSizes.spaceBtwSections),

            //* category header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
              child: SectionHeader(
                title: AppTexts.homeCategory,
                onSeeAllTap: () {},
              ),
            ),
            const Gap(AppSizes.md),

            //* category carousel — horizontal chips
            SizedBox(
              height: 64,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                itemCount: _categories.length,
                separatorBuilder: (_, _) => const Gap(AppSizes.md),
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  return CategoryChip(
                    label: category.name,
                    imagePath: category.imagePath,
                    selected: _selectedCategoryIndex == index,
                    onTap: () => setState(() => _selectedCategoryIndex = index),
                  );
                },
              ),
            ),
            const Gap(AppSizes.spaceBtwSections),

            //* nearby offers carousel
            SizedBox(
              height: DeviceUtils.getScreenHeight() * 0.36,
              child: PageView.builder(
                controller: PageController(viewportFraction: 0.85),
                padEnds: false,
                itemCount: _offers.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.only(
                      left: index == 0 ? AppSizes.md : AppSizes.sm,
                      right: AppSizes.sm,
                    ),
                    child: FoodOfferCard(
                      offer: _offers[index],
                      onAddToCart: () {},
                    ),
                  );
                },
              ),
            ),
            const Gap(AppSizes.spaceBtwSections),

            //* big brands header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
              child: SectionHeader(
                title: AppTexts.homeBrandsNearYou,
                onSeeAllTap: () {},
              ),
            ),
            const Gap(AppSizes.md),

            //* brands grid — 1 column stacked list of wide cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
              child: CustomGridLayout(
                itemCount: _brands.length,
                columns: 1,
                spacing: AppSizes.md,
                childAspectRatio: 3.6,
                itemBuilder: (context, index) {
                  return BrandCard(brand: _brands[index], onTap: () {});
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Category {
  const _Category({required this.name, required this.imagePath});

  final String name;
  final String imagePath;
}
