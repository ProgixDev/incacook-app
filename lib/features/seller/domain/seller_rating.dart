import 'package:flutter/material.dart';
import 'package:homemade/core/constants/text_strings.dart';

/// How a [RatingCriterion]'s value is expressed and rendered.
enum RatingValueType {
  percent(maxValue: 100.0),
  score5(maxValue: 5.0);

  const RatingValueType({required this.maxValue});

  final double maxValue;

  /// Formats [value] for display next to the criterion label.
  /// percent → "88%", score5 → "4.8/5".
  String format(double value) {
    return switch (this) {
      RatingValueType.percent =>
        '${value.toInt()}${AppTexts.ratingPercentSuffix}',
      RatingValueType.score5 =>
        '${value.toStringAsFixed(1)}${AppTexts.ratingScoreSuffix}',
    };
  }

  /// Builds the small caption shown beneath the bar.
  /// percent → "89 commandes vérifiées", score5 → "Basé sur 89 avis".
  String subtitleFor(int sampleCount) {
    return switch (this) {
      RatingValueType.percent =>
        '$sampleCount ${AppTexts.ratingVerifiedOrders}',
      RatingValueType.score5 =>
        '${AppTexts.ratingBasedOn} $sampleCount ${AppTexts.ratingReviews}',
    };
  }
}

/// The three criteria sellers are rated on.
enum RatingCriterion {
  hygiene(
    label: AppTexts.ratingHygiene,
    color: Color(0xFF2E7D32),
    valueType: RatingValueType.percent,
  ),
  foodQuality(
    label: AppTexts.ratingFoodQuality,
    color: Color(0xFFE57825),
    valueType: RatingValueType.score5,
  ),
  packaging(
    label: AppTexts.ratingPackaging,
    color: Color(0xFF1976D2),
    valueType: RatingValueType.score5,
  );

  const RatingCriterion({
    required this.label,
    required this.color,
    required this.valueType,
  });

  final String label;
  final Color color;
  final RatingValueType valueType;
}

/// A seller's rating on a single [criterion]. [value] is on the criterion's
/// own scale (0–100 for percent, 0–5 for score5). [sampleCount] is the
/// number of verified orders (percent) or reviews (score5) backing it.
class SellerRating {
  const SellerRating({
    required this.criterion,
    required this.value,
    required this.sampleCount,
  });

  final RatingCriterion criterion;
  final double value;
  final int sampleCount;

  /// 0..1 fill ratio for the progress bar.
  double get fillRatio =>
      (value / criterion.valueType.maxValue).clamp(0.0, 1.0);

  /// Right-aligned value text (e.g. "100%", "4.8/5").
  String get formattedValue => criterion.valueType.format(value);

  /// Caption beneath the bar (e.g. "89 commandes vérifiées").
  String get subtitle => criterion.valueType.subtitleFor(sampleCount);
}
