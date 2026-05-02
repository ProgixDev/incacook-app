import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:homemade/core/common/widgets/appbar/appbar.dart';
import 'package:homemade/core/constants/image_strings.dart';
import 'package:homemade/core/constants/sizes.dart';
import 'package:homemade/core/constants/text_strings.dart';
import 'package:homemade/core/utils/device/device_utility.dart';
import 'package:homemade/features/cart/controllers/cart_controller.dart';
import 'package:homemade/features/cart/presentation/widgets/different_seller_dialog.dart';
import 'package:homemade/features/cart/presentation/widgets/floating_cart_bar.dart';
import 'package:homemade/features/catalog/presentation/widgets/added_to_cart_overlay.dart';
import 'package:homemade/features/catalog/presentation/widgets/product_bottom_bar.dart';
import 'package:homemade/features/catalog/presentation/widgets/product_description_block.dart';
import 'package:homemade/features/catalog/presentation/widgets/product_image_header.dart';
import 'package:homemade/features/catalog/presentation/widgets/product_info_pill_bar.dart';
import 'package:homemade/features/catalog/presentation/widgets/product_reviews_section.dart';
import 'package:homemade/features/catalog/presentation/widgets/product_sheet_blend.dart';
import 'package:homemade/features/catalog/presentation/widgets/product_title_price_row.dart';
import 'package:homemade/features/catalog/presentation/widgets/seller_card.dart';
import 'package:homemade/core/enums/food_enums.dart';
import 'package:homemade/core/enums/order_enums.dart';
import 'package:homemade/features/client/domain/food_listing.dart';
import 'package:homemade/features/orders/domain/order_customization.dart';
import 'package:homemade/features/orders/domain/product_add_on.dart';
import 'package:homemade/features/orders/presentation/widgets/order_customize_sheet.dart';
import 'package:homemade/features/seller/data/seller_mock_data.dart';
import 'package:get/get.dart';
import 'package:homemade/features/seller/presentation/screens/seller_profile.dart';

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
    category: SellerCategory.faitMaison,
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

  //? quick-add: no customize sheet, default quantity 1, no add-ons, no note
  Future<void> _quickAddToCart() async {
    final customization = OrderCustomization(
      listing: _demoListing,
      quantity: 1,
      selectedAddOns: const [],
      note: '',
      totalPrice: _demoListing.price,
    );

    final added = await CartController.instance.tryAdd(
      customization,
      resolveConflict: (currentSellerName) => DifferentSellerDialog.show(
        context,
        currentSellerName: currentSellerName,
      ),
    );
    if (!added || !mounted) return;

    await AddedToCartOverlay.show(context);
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
                          color: Theme.of(context).scaffoldBackgroundColor,
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
                              SellerCard(
                                onCardTap: () => Get.to(
                                  () => SellerProfileScreen(
                                    profile: SellerMockData.demoSeller(),
                                  ),
                                ),
                              ),
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
                  onAddToCart: _quickAddToCart,
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
