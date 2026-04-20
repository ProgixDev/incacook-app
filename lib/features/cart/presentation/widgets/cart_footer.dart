import 'package:flutter/material.dart';
import 'package:vinted_v2/core/constants/colors.dart';
import 'package:vinted_v2/core/constants/sizes.dart';
import 'package:vinted_v2/core/constants/text_strings.dart';

class CartFooter extends StatelessWidget {
  const CartFooter({
    super.key,
    required this.total,
    required this.onContinue,
    this.enabled = true,
  });

  final double total;
  final VoidCallback onContinue;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.lightBackground,
        border: Border(top: BorderSide(color: AppColors.lightGrey, width: 1)),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSizes.md,
        AppSizes.md,
        AppSizes.md,
        AppSizes.md,
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: enabled ? onContinue : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: AppColors.white,
              disabledBackgroundColor: AppColors.buttonDisabled,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
              textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            child: Text(
              '${AppTexts.cartContinueCta} — €${total.toStringAsFixed(2)}',
            ),
          ),
        ),
      ),
    );
  }
}

class CartSubtotalRow extends StatelessWidget {
  const CartSubtotalRow({super.key, required this.subtotal});

  final double subtotal;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          AppTexts.cartSubtotalLabel,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          '€${subtotal.toStringAsFixed(2)}',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
