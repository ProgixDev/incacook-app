import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:vinted_v2/core/common/widgets/appbar/appbar.dart';
import 'package:vinted_v2/core/constants/colors.dart';
import 'package:vinted_v2/core/constants/image_strings.dart';
import 'package:vinted_v2/core/constants/sizes.dart';
import 'package:vinted_v2/core/constants/text_strings.dart';
import 'package:vinted_v2/core/utils/device/device_utility.dart';
import 'package:vinted_v2/features/cart/controllers/cart_controller.dart';
import 'package:vinted_v2/features/cart/presentation/widgets/different_seller_dialog.dart';
import 'package:vinted_v2/features/cart/presentation/widgets/floating_cart_bar.dart';
import 'package:vinted_v2/features/catalog/presentation/widgets/added_to_cart_overlay.dart';
import 'package:vinted_v2/features/catalog/presentation/widgets/product_bottom_bar.dart';
import 'package:vinted_v2/features/catalog/presentation/widgets/product_description_block.dart';
import 'package:vinted_v2/features/catalog/presentation/widgets/product_image_header.dart';
import 'package:vinted_v2/features/catalog/presentation/widgets/product_info_pill_bar.dart';
import 'package:vinted_v2/features/catalog/presentation/widgets/product_reviews_section.dart';
import 'package:vinted_v2/features/catalog/presentation/widgets/product_sheet_blend.dart';
import 'package:vinted_v2/features/catalog/presentation/widgets/product_title_price_row.dart';
import 'package:vinted_v2/features/catalog/presentation/widgets/seller_card.dart';
import 'package:vinted_v2/features/home/domain/food_listing.dart';
import 'package:vinted_v2/features/orders/domain/product_add_on.dart';
import 'package:vinted_v2/features/orders/presentation/widgets/order_customize_sheet.dart';
import 'package:vinted_v2/features/seller/domain/seller_profile.dart';
import 'package:vinted_v2/features/seller/presentation/screens/seller_profile.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:latlong2/latlong.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  //? how tall the frosted-glass strip is. Title + price sit at its bottom,
  //? the top portion shows the blurred image fading into the sheet.
  static const double _blendHeight = 120;

  //? how much bottom padding the scroll content reserves so the floating
  //? bottom bar never covers anything meaningful.
  static const double _bottomBarClearance = 104;

  final PageController _pageController = PageController();
  bool _isFavorited = false;

  static const List<String> _productImages = [
    AppImages.foodTest,
    AppImages.foodTest,
    AppImages.foodTest,
  ];

  //? demo listing passed to the order customize sheet — swap for a real
  //? model once the catalog data layer is wired
  static final FoodListing _demoListing = FoodListing(
    id: 'demo-product-1',
    name: 'Tajine poulet olives',
    imagePath: AppImages.foodTest,
    sellerName: 'Fatima K.',
    category: SellerCategory.social,
    distanceKm: 0.3,
    rating: 4.9,
    reviewCount: 24,
    portionsLeft: 4,
    fulfillment: Fulfillment.both,
    originalPrice: 8.00,
    price: 3.00,
    expiresAt: DateTime.now().add(const Duration(hours: 3)),
  );

  static const List<ProductAddOn> _demoAddOns = [
    ProductAddOn(id: 'bread', label: 'Avec pain', priceDelta: 0.50),
    ProductAddOn(
      id: 'sauce',
      label: 'Supplément sauce piquante',
      priceDelta: 0.50,
    ),
    ProductAddOn(id: 'kids', label: 'Portion enfant', priceDelta: -1.00),
  ];

  //? demo seller profile shown when tapping the SellerCard below
  static final SellerProfile _demoSellerProfile = SellerProfile(
    id: 'fatima-k',
    name: 'Fatima K.',
    avatarPath: AppImages.profilePic,
    category: SellerCategory.social,
    categoryTag: 'Fait maison',
    cuisineType: 'Cuisine nord-africaine',
    rating: 4.9,
    reviewCount: 247,
    distanceKm: 0.4,
    neighborhood: 'Bastille, Paris 11ème',
    prepMinMinutes: 30,
    prepMaxMinutes: 45,
    deliveryFee: 2.50,
    responseRatePercent: 98,
    mealsSold: 247,
    mealsSaved: 312,
    promoText: AppTexts.sellerProfileFirstOrderPromo,
    performance: const [
      PerformanceMetric(
        icon: Iconsax.shield_tick,
        label: AppTexts.sellerPerformanceHygiene,
        percent: 95,
        caption: "Toujours emballé proprement",
      ),
      PerformanceMetric(
        icon: Iconsax.clock,
        label: AppTexts.sellerPerformancePunctuality,
        percent: 92,
        caption: "Préparé à l'heure 92% du temps",
      ),
      PerformanceMetric(
        icon: Iconsax.tick_circle,
        label: AppTexts.sellerPerformanceAccuracy,
        percent: 100,
        caption: "Aucune erreur dans les 50 derniers",
      ),
      PerformanceMetric(
        icon: Iconsax.message_tick,
        label: AppTexts.sellerPerformanceCommunication,
        percent: 88,
        caption: "Répond en moyenne en 3 min",
      ),
      PerformanceMetric(
        icon: Iconsax.heart5,
        label: AppTexts.sellerPerformanceFoodQuality,
        percent: 96,
        caption: "Basé sur 247 avis clients",
      ),
    ],
    menuCategories: const ['Tout', 'Plats', 'Desserts', 'Entrées', 'Boissons'],
    listings: [
      FoodListing(
        id: 's1',
        name: 'Tajine poulet',
        imagePath: AppImages.foodTest,
        sellerName: 'Fatima K.',
        category: SellerCategory.social,
        distanceKm: 0.4,
        rating: 4.9,
        reviewCount: 24,
        portionsLeft: 3,
        fulfillment: Fulfillment.both,
        originalPrice: 7.00,
        price: 3.50,
        expiresAt: DateTime.now().add(const Duration(hours: 2)),
      ),
      FoodListing(
        id: 's2',
        name: 'Chorba maison',
        imagePath: AppImages.foodTest,
        sellerName: 'Fatima K.',
        category: SellerCategory.social,
        distanceKm: 0.4,
        rating: 4.8,
        reviewCount: 18,
        portionsLeft: 5,
        fulfillment: Fulfillment.both,
        originalPrice: 3.50,
        price: 2.00,
        expiresAt: DateTime.now().add(const Duration(hours: 4)),
      ),
      FoodListing(
        id: 's3',
        name: 'Salade marocaine',
        imagePath: AppImages.foodTest,
        sellerName: 'Fatima K.',
        category: SellerCategory.social,
        distanceKm: 0.4,
        rating: 4.7,
        reviewCount: 12,
        portionsLeft: 4,
        fulfillment: Fulfillment.both,
        originalPrice: 4.00,
        price: 2.50,
        expiresAt: DateTime.now().add(const Duration(hours: 3)),
      ),
      FoodListing(
        id: 's4',
        name: 'Baklava',
        imagePath: AppImages.foodTest,
        sellerName: 'Fatima K.',
        category: SellerCategory.social,
        distanceKm: 0.4,
        rating: 5.0,
        reviewCount: 33,
        portionsLeft: 6,
        fulfillment: Fulfillment.both,
        originalPrice: 5.00,
        price: 3.00,
        expiresAt: DateTime.now().add(const Duration(hours: 5)),
      ),
    ],
    bio:
        "Je cuisine chaque jour pour ma famille à Bastille depuis 15 ans. Plutôt que de jeter mes restes, je partage avec mes voisins à prix doux. Une cuisine saine, épicée, et pleine d'amour.",
    languageCodes: const ['FR', 'DZ'],
    memberSince: DateTime(2024, 3, 1),
    lastActiveAgo: 'il y a 2h',
    verifications: const [
      AppTexts.sellerVerificationIdentity,
      AppTexts.sellerVerificationHygieneCharter,
      AppTexts.sellerVerificationPhone,
      AppTexts.sellerVerificationAddress,
    ],
    ratingDistribution: const {5: 89, 4: 8, 3: 2, 2: 1, 1: 0},
    sentimentTags: const [
      SentimentTag(label: 'Délicieux', count: 82),
      SentimentTag(label: 'Copieux', count: 47),
      SentimentTag(label: 'Épicé', count: 34),
      SentimentTag(label: "À l'heure", count: 98),
    ],
    recentReviews: [
      SellerReview(
        authorName: 'Marie D.',
        avatarPath: AppImages.profilePic,
        rating: 5,
        body:
            'Excellent tajine, vraiment comme à la maison. Fatima est adorable en plus !',
        timeAgoLabel: 'il y a 2 jours',
        helpfulCount: 12,
      ),
      SellerReview(
        authorName: 'Karim B.',
        avatarPath: AppImages.profilePic,
        rating: 5,
        body: 'Portions généreuses, livraison à l\'heure. Top.',
        timeAgoLabel: 'il y a 5 jours',
        helpfulCount: 7,
      ),
    ],
    location: LatLng(48.8532, 2.3692),
    deliveryRadiusKm: 3,
    availabilitySchedule: 'Lun–Ven · 18h–22h',
  );

  void _openSellerProfile() {
    Get.to<void>(() => SellerProfileScreen(profile: _demoSellerProfile));
  }

  Future<void> _openOrderSheet() async {
    final customization = await OrderCustomizeSheet.show(
      context,
      listing: _demoListing,
      addOns: _demoAddOns,
    );
    if (customization == null || !mounted) return;

    await CartController.instance.tryAdd(
      customization,
      resolveConflict: (currentSellerName) => DifferentSellerDialog.show(
        context,
        currentSellerName: currentSellerName,
      ),
    );
  }

  //? sample reviews — swap with a real data source when the API is wired
  static const List<ProductReview> _sampleReviews = [
    ProductReview(
      author: AppTexts.productReview1Author,
      avatarPath: AppImages.profilePic,
      rating: 5,
      body: AppTexts.productReview1Body,
      time: AppTexts.productReview1Time,
    ),
    ProductReview(
      author: AppTexts.productReview2Author,
      avatarPath: AppImages.profilePic,
      rating: 5,
      body: AppTexts.productReview2Body,
      time: AppTexts.productReview2Time,
    ),
    ProductReview(
      author: AppTexts.productReview3Author,
      avatarPath: AppImages.profilePic,
      rating: 4,
      body: AppTexts.productReview3Body,
      time: AppTexts.productReview3Time,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final imageHeight = DeviceUtils.getScreenHeight(context) * 0.55;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: AppColors.lightBackground,
      appBar: CustomAppBar(showBackArrow: true),
      body: Stack(
        children: [
          //* main scrollable content — image + sheet scroll as one
          Positioned.fill(
            child: SingleChildScrollView(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  //* 1. image slider — painted first, so the blend strip
                  //*    above has something behind it to blur
                  SizedBox(
                    width: double.infinity,
                    height: imageHeight,
                    child: ProductImageHeader(
                      pageController: _pageController,
                      images: _productImages,
                      isFavorited: _isFavorited,
                      onFavoriteTap: () =>
                          setState(() => _isFavorited = !_isFavorited),
                      height: imageHeight,
                      //? keep dots above the frosted-glass overlap
                      indicatorBottomPadding: _blendHeight + AppSizes.sm,
                    ),
                  ),

                  //* 2. sheet — overlaps the image by _blendHeight at its top
                  Padding(
                    padding: EdgeInsets.only(top: imageHeight - _blendHeight),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        //? frosted strip hosting the title + price so they
                        //? visually sit inside the blurred area
                        const ProductSheetBlend(
                          height: _blendHeight,
                          blurSigma: 6,
                          childPadding: EdgeInsets.fromLTRB(
                            AppSizes.md,
                            AppSizes.md,
                            AppSizes.md,
                            0,
                          ),
                          child: ProductTitlePriceRow(
                            titleLeading: 'Grilled',
                            titleMid: 'Chicken',
                            titleTrailing: 'Breast',
                            shortDescription: AppTexts.productSampleShortDesc,
                            price: '3.97',
                            rating: 3.9,
                            reviewsCount: 193,
                          ),
                        ),

                        //? solid sheet body continues below the blend
                        Container(
                          color: AppColors.lightBackground,
                          padding: const EdgeInsets.fromLTRB(
                            AppSizes.md,
                            AppSizes.lg,
                            AppSizes.md,
                            _bottomBarClearance,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const ProductInfoPillBar(),
                              const Gap(AppSizes.lg),
                              SellerCard(onCardTap: _openSellerProfile),
                              const Gap(AppSizes.lg),
                              const ProductDescriptionBlock(
                                description: AppTexts.productSampleLongDesc,
                              ),
                              const Gap(AppSizes.lg),
                              ProductReviewsSection(
                                averageRating: 3.9,
                                totalReviews: 193,
                                reviews: _sampleReviews,
                                onSeeAll: () {},
                              ),
                            ],
                          ),
                        ),
                        const Gap(AppSizes.lg),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          //* floating bottom stack — cart pill (when non-empty) + action bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const FloatingCartBar(),
                ProductBottomBar(
                  onAddToCart: () => AddedToCartOverlay.show(context),
                  onOrder: _openOrderSheet,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
