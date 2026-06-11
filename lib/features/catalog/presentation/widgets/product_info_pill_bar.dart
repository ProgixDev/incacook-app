import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/constants/text_strings.dart';

class ProductInfoPillBar extends StatelessWidget {
  const ProductInfoPillBar({
    super.key,
    this.deliveryLabel,
    this.prepLabel,
  });

  /// Override for the left pill (defaults to "Livraison gratuite"). Pass the
  /// listing's actual fulfillment string ("Sur place", "Livraison", "Sur
  /// place + Livraison") to keep the pill real.
  final String? deliveryLabel;

  /// Override for the right pill (defaults to the demo "20-25 min"). Pass
  /// `"${prepMinutes} min"` to render the listing's real prep time.
  final String? prepLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(
          child: _InfoItem(
            icon: Iconsax.truck_fast,
            label: deliveryLabel ?? AppTexts.productFreeDelivery,
          ),
        ),
        const _VerticalDivider(),
        Expanded(
          child: _InfoItem(
            icon: Iconsax.clock,
            label: prepLabel ?? AppTexts.productPrepTime,
          ),
        ),
      ],
    );
  }
}

class _InfoItem extends StatelessWidget {
  const _InfoItem({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 16, color: scheme.onSurface),
        const Gap(AppSizes.xs),
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 24,
      color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.25),
    );
  }
}
