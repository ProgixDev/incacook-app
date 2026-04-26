import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:homemade/core/constants/colors.dart';
import 'package:homemade/core/constants/sizes.dart';
import 'package:homemade/core/constants/text_strings.dart';

/// Asks the user whether to clear the existing cart when adding an item from
/// a different seller. Resolves to `true` if they confirm.
class DifferentSellerDialog extends StatelessWidget {
  const DifferentSellerDialog({super.key, required this.currentSellerName});

  final String currentSellerName;

  static Future<bool> show(
    BuildContext context, {
    required String currentSellerName,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (_) =>
          DifferentSellerDialog(currentSellerName: currentSellerName),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppTexts.cartDifferentSellerTitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const Gap(AppSizes.sm + 2),
            Text(
              AppTexts.cartDifferentSellerBody(currentSellerName),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.grey,
                height: 1.35,
              ),
            ),
            const Gap(AppSizes.lg),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.secondary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: AppColors.lightGrey),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                      textStyle: Theme.of(context).textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    child: const Text(AppTexts.cartDifferentSellerCancel),
                  ),
                ),
                const Gap(AppSizes.sm + 2),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: AppColors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                      textStyle: Theme.of(context).textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    child: const Text(AppTexts.cartDifferentSellerConfirm),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
