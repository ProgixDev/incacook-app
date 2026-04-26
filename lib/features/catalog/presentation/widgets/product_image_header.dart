import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:homemade/core/common/widgets/custon_shapes/container/circular_container.dart';
import 'package:homemade/core/constants/sizes.dart';
import 'package:homemade/core/utils/device/device_utility.dart';

class ProductImageHeader extends StatelessWidget {
  const ProductImageHeader({
    super.key,
    required this.pageController,
    required this.images,
    required this.isFavorited,
    required this.onFavoriteTap,
    this.height,
    this.indicatorBottomPadding = AppSizes.md,
  });

  final PageController pageController;
  final List<String> images;
  final bool isFavorited;
  final VoidCallback onFavoriteTap;
  final double? height;
  final double indicatorBottomPadding;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final topPadding = DeviceUtils.getStatusBarHeight() + AppSizes.sm;

    return SizedBox(
      height: height ?? DeviceUtils.getScreenHeight(context) * 0.42,
      child: Stack(
        children: [
          //* image slider (preserved from the original design)
          Positioned.fill(
            child: PageView.builder(
              controller: pageController,
              itemCount: images.length,
              itemBuilder: (context, index) {
                return Image.asset(images[index], fit: BoxFit.cover);
              },
            ),
          ),

          //* dot indicator
          Positioned(
            left: 0,
            right: 0,
            bottom: indicatorBottomPadding,
            child: Center(
              child: SmoothPageIndicator(
                controller: pageController,
                count: images.length,
                effect: ExpandingDotsEffect(
                  activeDotColor: scheme.onSurface,
                  dotColor: scheme.onSurface.withValues(alpha: 0.3),
                  dotHeight: 6,
                  dotWidth: 6,
                ),
              ),
            ),
          ),

          //* favorite button (back arrow is provided by the Scaffold's CustomAppBar)
          Positioned(
            top: topPadding,
            right: AppSizes.md,
            child: GestureDetector(
              onTap: onFavoriteTap,
              child: CustomCircularContainer(
                size: 44,
                backgroundColor: scheme.surface,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  transitionBuilder: (child, animation) =>
                      ScaleTransition(scale: animation, child: child),
                  child: Icon(
                    isFavorited ? Iconsax.heart5 : Iconsax.heart,
                    key: ValueKey<bool>(isFavorited),
                    color: isFavorited ? Colors.red : scheme.onSurface,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
