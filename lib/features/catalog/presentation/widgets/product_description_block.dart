import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:homemade/core/constants/colors.dart';
import 'package:homemade/core/constants/sizes.dart';
import 'package:homemade/core/constants/text_strings.dart';

class ProductDescriptionBlock extends StatelessWidget {
  const ProductDescriptionBlock({super.key, required this.description});

  final String description;

  @override
  Widget build(BuildContext context) {
    final bodyStyle = Theme.of(
      context,
    ).textTheme.bodyMedium?.copyWith(color: AppColors.grey, height: 1.5);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppTexts.productDescription,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Gap(AppSizes.sm),
        Text.rich(
          TextSpan(
            style: bodyStyle,
            children: [
              TextSpan(text: '$description. '),
              TextSpan(
                text: AppTexts.productReadMore,
                style: bodyStyle?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
