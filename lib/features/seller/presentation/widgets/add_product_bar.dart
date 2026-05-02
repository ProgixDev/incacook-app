import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';

import 'package:homemade/core/constants/sizes.dart';
import 'package:homemade/core/constants/text_strings.dart';
import 'package:homemade/core/widgets/effects/frosted_surface.dart';

class AddProductBar extends StatelessWidget {
  const AddProductBar({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return FrostedSurface(
      borderRadius: BorderRadius.circular(80),
      padding: const EdgeInsets.fromLTRB(
        AppSizes.md,
        AppSizes.sm,
        AppSizes.sm,
        AppSizes.sm,
      ),
      child: Row(
        children: [
          Icon(Iconsax.box_1, color: scheme.onSurface, size: 24),
          const Gap(AppSizes.md),
          Expanded(
            child: Text(
              AppTexts.sellerProductsAddCta,
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: scheme.primary,
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(Iconsax.add, color: scheme.onPrimary, size: 24),
            ),
          ),
        ],
      ),
    );
  }
}
