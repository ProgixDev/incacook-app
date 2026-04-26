import 'package:flutter/material.dart';
import 'package:homemade/core/constants/colors.dart';

class CustomShadowStyle {
  static BoxShadow customCircleShadows({
    double offsetX = 0,
    double offsetY = 4,
    double blurRadius = 16,
    double alpha = 0.15,
  }) => BoxShadow(
    color: AppColors.black.withValues(alpha: alpha),
    blurRadius: blurRadius,
    offset: Offset(offsetX, offsetY),
  );
}
