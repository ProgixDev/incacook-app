import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/core/widgets/effects/frosted_surface.dart';

class ChatSearchBar extends StatelessWidget {
  const ChatSearchBar({super.key, this.onChanged, this.controller});

  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return FrostedSurface(
      borderRadius: BorderRadius.circular(32),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        cursorColor: scheme.onSurface,
        style: Theme.of(context).textTheme.bodyMedium,
        decoration: InputDecoration(
          isCollapsed: true,
          hintText: AppTexts.chatSearchHint,
          hintStyle: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
          prefixIcon: Icon(
            Iconsax.search_normal_1,
            color: scheme.onSurface,
            size: 22,
          ),
          filled: true,
          fillColor: Colors.transparent,
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
    );
  }
}
