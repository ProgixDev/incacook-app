import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:homemade/core/constants/sizes.dart';

class HorizontalSeparator extends StatelessWidget {
  const HorizontalSeparator({
    super.key,
    this.color,
    this.opacity = 0.3,
    this.height = 1,
    this.horizontalMargin = AppSizes.md,
  });

  final Color? color;
  final double opacity;
  final double height;
  final double horizontalMargin;

  @override
  Widget build(BuildContext context) {
    final resolved = color ?? Theme.of(context).colorScheme.outline;
    return Column(
      children: [
        Gap(horizontalMargin),
        Container(
          height: height,
          color: resolved.withValues(alpha: opacity),
        ),
        Gap(horizontalMargin),
      ],
    );
  }
}
