import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import 'package:vinted_v2/core/constants/colors.dart';
import 'package:vinted_v2/core/constants/sizes.dart';
import 'package:vinted_v2/core/constants/text_strings.dart';
import 'package:vinted_v2/features/cart/domain/cart_line_item.dart';

class CartItemCard extends StatelessWidget {
  const CartItemCard({
    super.key,
    required this.item,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
  });

  final CartLineItem item;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final canIncrement = item.quantity < item.listing.portionsLeft;
    final canDecrement = item.quantity > 1;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          if (!item.isAvailable) _UnavailableBanner(onRemove: onRemove),
          Opacity(
            opacity: item.isAvailable ? 1.0 : 0.55,
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.sm + 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppSizes.cardRadiusMd),
                    child: Image.asset(
                      item.listing.imagePath,
                      width: 72,
                      height: 72,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const Gap(AppSizes.sm + 2),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.listing.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                        ),
                        if (item.selectedAddOns.isNotEmpty) ...[
                          const Gap(2),
                          Text(
                            item.selectedAddOns
                                .map((a) => a.label)
                                .join(' · '),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.grey),
                          ),
                        ],
                        const Gap(AppSizes.sm),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _CompactQuantity(
                              quantity: item.quantity,
                              enabled: item.isAvailable,
                              canIncrement: canIncrement,
                              canDecrement: canDecrement,
                              onIncrement: onIncrement,
                              onDecrement: onDecrement,
                            ),
                            const Spacer(),
                            Text(
                              '€${item.lineTotal.toStringAsFixed(2)}',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Gap(AppSizes.sm),
                  GestureDetector(
                    onTap: onRemove,
                    behavior: HitTestBehavior.opaque,
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(
                        Iconsax.trash,
                        size: 18,
                        color: AppColors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepButton(
            icon: Iconsax.minus,
            enabled: enabled && canDecrement,
            onTap: onDecrement,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              '$quantity',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          _StepButton(
            icon: Iconsax.add,
            enabled: enabled && canIncrement,
            onTap: onIncrement,
          ),
        ],
      ),
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
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: enabled ? AppColors.secondary : AppColors.buttonDisabled,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 12, color: AppColors.white),
      ),
    );
  }
}

class _UnavailableBanner extends StatelessWidget {
  const _UnavailableBanner({required this.onRemove});

  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    const bannerColor = Color(0xFFE53935);
    return Container(
      width: double.infinity,
      color: bannerColor.withValues(alpha: 0.12),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.sm + 2,
        vertical: AppSizes.sm,
      ),
      child: Row(
        children: [
          const Icon(Iconsax.warning_2, size: 16, color: bannerColor),
          const Gap(AppSizes.sm),
          Expanded(
            child: Text(
              AppTexts.cartUnavailableBody,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: bannerColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          GestureDetector(
            onTap: onRemove,
            child: Text(
              AppTexts.cartUnavailableRemove,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: bannerColor,
                fontWeight: FontWeight.w700,
                decoration: TextDecoration.underline,
                decorationColor: bannerColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
