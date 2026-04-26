import 'package:flutter/material.dart';

class PriceDisplay extends StatelessWidget {
  const PriceDisplay({
    super.key,
    required this.price,
    this.currencySize,
    this.priceSize,
  });

  final double price;
  final double? currencySize;
  final double? priceSize;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final titleMedium = Theme.of(context).textTheme.titleMedium;
    final headlineSmall = Theme.of(context).textTheme.headlineSmall;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          '€',
          style: titleMedium?.copyWith(
            color: scheme.primary,
            fontWeight: FontWeight.w700,
            fontSize: currencySize ?? titleMedium.fontSize,
          ),
        ),
        Text(
          price.toStringAsFixed(2),
          style: headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: priceSize ?? headlineSmall.fontSize,
          ),
        ),
      ],
    );
  }
}
