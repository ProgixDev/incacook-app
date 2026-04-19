import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:vinted_v2/core/common/widgets/appbar/appbar.dart';
import 'package:vinted_v2/core/constants/colors.dart';
import 'package:vinted_v2/core/constants/image_strings.dart';
import 'package:vinted_v2/core/constants/sizes.dart';
import 'package:vinted_v2/core/constants/text_strings.dart';
import 'package:vinted_v2/core/utils/device/device_utility.dart';
import 'package:vinted_v2/features/catalog/presentation/widgets/product_bottom_bar.dart';
import 'package:vinted_v2/features/catalog/presentation/widgets/product_description_block.dart';
import 'package:vinted_v2/features/catalog/presentation/widgets/product_image_header.dart';
import 'package:vinted_v2/features/catalog/presentation/widgets/product_info_pill_bar.dart';
import 'package:vinted_v2/features/catalog/presentation/widgets/product_reviews_section.dart';
import 'package:vinted_v2/features/catalog/presentation/widgets/product_sheet_blend.dart';
import 'package:vinted_v2/features/catalog/presentation/widgets/product_title_price_row.dart';
import 'package:vinted_v2/features/catalog/presentation/widgets/seller_card.dart';
import 'package:vinted_v2/features/orders/presentation/screens/order_summary.dart';

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
                              const SellerCard(),
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

          //* floating bottom action bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: ProductBottomBar(
              onAddToCart: () {},
              onOrder: () => Get.to(() => const OrderSummaryScreen()),
            ),
          ),
        ],
      ),
    );
  }
}
