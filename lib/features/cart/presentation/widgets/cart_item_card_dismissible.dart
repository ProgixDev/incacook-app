import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import 'package:incacook/core/common/widgets/misc/price_display.dart';
import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/widgets/effects/frosted_surface.dart';
import 'package:incacook/core/models/cart_item.dart';

class CartItemCardDismissible extends StatelessWidget {
  const CartItemCardDismissible({
    super.key,
    required this.item,
    this.canIncrement = true,
    this.canDecrement = true,
    required this.onDismissed,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
  });

  final CartItem item;
  final bool canIncrement;
  final bool canDecrement;
  final VoidCallback onDismissed;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFE53935).withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSizes.lg),
        child: const Icon(Iconsax.trash, color: Color(0xFFE53935), size: 28),
      ),
      onDismissed: (_) => onDismissed,
      child: FrostedSurface(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            Opacity(
              opacity: item.isAvailable ? 1.0 : 0.55,
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.sm + 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(
                        AppSizes.cardRadiusMd,
                      ),
                      child: Container(
                        width: 80,
                        height: 80,
                        color: scheme.surfaceContainerLow,
                        child: Image.asset(
                          item.listing.imageUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const Gap(AppSizes.md - 4),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.listing.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const Gap(AppSizes.sm),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: PriceDisplay(
                                  price: item.unitPrice,
                                  priceSize: 16,
                                ),
                              ),
                              _CompactQuantity(
                                quantity: item.quantity,
                                enabled: item.isAvailable,
                                canIncrement: canIncrement,
                                canDecrement: canDecrement,
                                onIncrement: onIncrement,
                                onDecrement: onDecrement,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompactQuantity extends StatelessWidget {
  const _CompactQuantity({
    required this.quantity,
    required this.enabled,
    required this.canIncrement,
    required this.canDecrement,
    required this.onIncrement,
    required this.onDecrement,
  });

  final int quantity;
  final bool enabled;
  final bool canIncrement;
  final bool canDecrement;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _StepButton(
          icon: Iconsax.minus,
          enabled: enabled && canDecrement,
          onTap: onDecrement,
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            quantity.toString().padLeft(2, '0'),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: scheme.primary,
            ),
          ),
        ),
        _StepButton(
          icon: Iconsax.add,
          enabled: enabled && canIncrement,
          onTap: onIncrement,
        ),
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final disabled = scheme.onSurface.withValues(alpha: 0.38);
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: scheme.surface,
          shape: BoxShape.circle,
          border: Border.all(
            color: enabled
                ? scheme.onSurfaceVariant.withValues(alpha: 0.35)
                : scheme.outline,
          ),
        ),
        child: Icon(
          icon,
          size: 12,
          color: enabled ? scheme.onSurface : disabled,
        ),
      ),
    );
  }
}
