import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
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
    final scheme = Theme.of(context).colorScheme;
    return Dialog(
      backgroundColor: scheme.surface,
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
              ),
            ),
            const Gap(AppSizes.sm + 2),
            Text(
              AppTexts.cartDifferentSellerBody(currentSellerName),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
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
                      foregroundColor: scheme.onSurface,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: scheme.outline),
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
