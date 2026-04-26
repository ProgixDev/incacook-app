import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:homemade/core/constants/colors.dart';

class KitchenMetaItem extends StatelessWidget {
  const KitchenMetaItem({super.key, required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: const Color(0xFF2E7D32)),
        const Gap(4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.grey,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
