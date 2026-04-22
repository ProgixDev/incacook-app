import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:vinted_v2/core/constants/colors.dart';
import 'package:vinted_v2/core/constants/sizes.dart';

class HorizontalSeparator extends StatelessWidget {
  const HorizontalSeparator({
    super.key,
    this.color = AppColors.secondary,
    this.opacity = 0.3,
    this.height = 1,
    this.horizontalMargin = AppSizes.md,
  });

  final Color color;
  final double opacity;
  final double height;
  final double horizontalMargin;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Gap(horizontalMargin),
        Container(
          height: height,
          color: color.withValues(alpha: opacity),
        ),
        Gap(horizontalMargin),
      ],
    );
  }
}
