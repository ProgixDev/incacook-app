import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:homemade/core/constants/colors.dart';
import 'package:homemade/core/constants/text_strings.dart';

class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({super.key, this.onTap, this.onChanged});

  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AbsorbPointer(
        absorbing: onTap != null,
        child: TextField(
          onChanged: onChanged,
          cursorColor: AppColors.secondary,
          style: Theme.of(context).textTheme.bodyMedium,
          decoration: InputDecoration(
            isCollapsed: true,
            hintText: AppTexts.homeSearchHint,
            hintStyle: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.grey),
            prefixIcon: const Icon(
              Iconsax.search_normal_1,
              color: AppColors.secondary,
              size: 22,
            ),
            filled: true,
            fillColor: AppColors.accent,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(32),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(32),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(32),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }
}
