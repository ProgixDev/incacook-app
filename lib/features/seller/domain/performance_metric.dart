import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:homemade/core/constants/text_strings.dart';

class PerformanceMetric {
  const PerformanceMetric({required this.type, required this.percent});

  final PerformanceMetricType type;
  final int percent;
}

enum PerformanceMetricType {
  hygiene(
    label: AppTexts.sellerPerformanceHygiene,
    icon: Iconsax.shield_tick,
    color: Colors.green,
  ),
  punctuality(
    label: AppTexts.sellerPerformancePunctuality,
    icon: Iconsax.clock,
    color: Colors.blue,
  ),
  accuracy(
    label: AppTexts.sellerPerformanceAccuracy,
    icon: Iconsax.check,
    color: Colors.orange,
  ),
  communication(
    label: AppTexts.sellerPerformanceCommunication,
    icon: Iconsax.message,
    color: Colors.purple,
  ),
  foodQuality(
    label: AppTexts.sellerPerformanceFoodQuality,
    icon: Iconsax.star,
    color: Colors.red,
  );

  const PerformanceMetricType({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;
}
