import 'package:flutter/painting.dart';

class PromoBanner {
  const PromoBanner({
    required this.title,
    required this.subtitle,
    required this.ctaLabel,
    required this.imagePath,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final String title;
  final String subtitle;
  final String ctaLabel;
  final String imagePath;
  final Color backgroundColor;
  final Color foregroundColor;
}
