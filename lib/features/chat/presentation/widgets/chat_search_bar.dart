import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:vinted_v2/core/constants/colors.dart';
import 'package:vinted_v2/core/constants/sizes.dart';
import 'package:vinted_v2/core/constants/text_strings.dart';

class ChatSearchBar extends StatelessWidget {
  const ChatSearchBar({super.key, this.onChanged, this.controller});

  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(32),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        cursorColor: AppColors.secondary,
        style: Theme.of(context).textTheme.bodyMedium,
        decoration: InputDecoration(
          isCollapsed: true,
          hintText: AppTexts.chatSearchHint,
          hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.grey,
          ),
          prefixIcon: const Padding(
            padding: EdgeInsets.only(left: AppSizes.md, right: AppSizes.sm),
            child: Icon(
              Iconsax.search_normal_1,
              color: AppColors.grey,
              size: 20,
            ),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSizes.md,
            vertical: 18,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }
}
