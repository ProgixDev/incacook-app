import 'package:flutter/material.dart';
import 'package:homemade/core/constants/colors.dart';

class KitchenTagChip extends StatelessWidget {
  const KitchenTagChip({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppColors.grey,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
