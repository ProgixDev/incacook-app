import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:homemade/core/constants/colors.dart';
import 'package:homemade/core/constants/sizes.dart';
import 'package:homemade/features/orders/domain/saved_address.dart';

class AddressCard extends StatelessWidget {
  const AddressCard({
    super.key,
    required this.address,
    required this.selected,
    required this.onTap,
    required this.onEdit,
  });

  final SavedAddress address;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(AppSizes.md - 2),
        decoration: BoxDecoration(
          color: selected ? AppColors.secondary : AppColors.accent,
          borderRadius: BorderRadius.circular(60),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: Icon(
                address.type.icon,
                size: 20,
                color: selected ? AppColors.primary : AppColors.secondary,
              ),
            ),
            const Gap(AppSizes.md - 2),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    address.label,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: selected ? AppColors.white : AppColors.textPrimary,
                    ),
                  ),
                  const Gap(2),
                  Text(
                    address.line1,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: selected ? AppColors.white : AppColors.grey,
                    ),
                  ),
                  Text(
                    address.line2,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: selected ? AppColors.white : AppColors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const Gap(AppSizes.sm),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 150),
              opacity: selected ? 1 : 0,
              child: Padding(
                padding: const EdgeInsets.only(left: AppSizes.sm - 2),
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    size: 14,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
