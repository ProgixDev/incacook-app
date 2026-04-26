import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:homemade/core/common/widgets/misc/horizontal_separator.dart';
import 'package:homemade/core/constants/colors.dart';
import 'package:homemade/core/constants/sizes.dart';
import 'package:homemade/core/constants/text_strings.dart';

class OrderSummaryBlock extends StatelessWidget {
  const OrderSummaryBlock({
    super.key,
    required this.subtotal,
    required this.shipping,
  });

  final double subtotal;
  final double shipping;

  @override
  Widget build(BuildContext context) {
    final total = subtotal + shipping;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          AppTexts.cartOrderSummaryTitle,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const Gap(AppSizes.md),
        _SummaryRow(label: AppTexts.cartSubtotalLabel, value: subtotal),
        const Gap(AppSizes.sm),
        _SummaryRow(label: AppTexts.cartShippingLabel, value: shipping),
        const Gap(AppSizes.md - 4),
        const HorizontalSeparator(),
        const Gap(AppSizes.md - 4),
        _SummaryRow(
          label: AppTexts.cartTotalLabel,
          value: total,
          emphasize: true,
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final double value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final labelStyle = emphasize
        ? Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          )
        : Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.grey,
            fontWeight: FontWeight.w500,
          );
    final valueStyle = emphasize
        ? Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          )
        : Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          );
    return Row(
      children: [
        Text(label, style: labelStyle),
        const Spacer(),
        Text('€${value.toStringAsFixed(2)}', style: valueStyle),
      ],
    );
  }
}
