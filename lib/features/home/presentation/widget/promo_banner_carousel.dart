import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:vinted_v2/core/constants/colors.dart';
import 'package:vinted_v2/core/constants/sizes.dart';
import 'package:vinted_v2/core/utils/device/device_utility.dart';
import 'package:vinted_v2/features/home/domain/promo_banner.dart';
import 'package:vinted_v2/features/home/presentation/widget/promo_banner_card.dart';

class PromoBannerCarousel extends StatefulWidget {
  const PromoBannerCarousel({
    super.key,
    required this.banners,
    this.autoAdvance = const Duration(seconds: 5),
    this.onBannerTap,
  });

  final List<PromoBanner> banners;
  final Duration autoAdvance;
  final ValueChanged<int>? onBannerTap;

  @override
  State<PromoBannerCarousel> createState() => _PromoBannerCarouselState();
}

class _PromoBannerCarouselState extends State<PromoBannerCarousel> {
  final _controller = PageController(viewportFraction: 0.88);
  Timer? _timer;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    if (widget.banners.length > 1) {
      _timer = Timer.periodic(widget.autoAdvance, (_) => _advance());
    }
  }

  void _advance() {
    if (!_controller.hasClients) return;
    final next = (_currentIndex + 1) % widget.banners.length;
    _controller.animateToPage(
      next,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: DeviceUtils.getScreenHeight(context) * 0.18,
          child: PageView.builder(
            controller: _controller,
            onPageChanged: (i) => setState(() => _currentIndex = i),
            itemCount: widget.banners.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(
                  left: index == 0 ? AppSizes.md : AppSizes.xs,
                  right: index == widget.banners.length - 1
                      ? AppSizes.md
                      : AppSizes.xs,
                ),
                child: PromoBannerCard(
                  banner: widget.banners[index],
                  onTap: () => widget.onBannerTap?.call(index),
                ),
              );
            },
          ),
        ),
        const Gap(AppSizes.sm + 2),
        SmoothPageIndicator(
          controller: _controller,
          count: widget.banners.length,
          effect: ExpandingDotsEffect(
            activeDotColor: AppColors.secondary,
            dotColor: AppColors.secondary.withValues(alpha: 0.25),
            dotHeight: 6,
            dotWidth: 6,
            expansionFactor: 3,
          ),
        ),
      ],
    );
  }
}
