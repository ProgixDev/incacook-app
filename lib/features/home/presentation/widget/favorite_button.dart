import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class FavoriteButton extends StatelessWidget {
  const FavoriteButton({super.key, required this.isSaved, this.onTap});

  final bool isSaved;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: scheme.surface,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: scheme.shadow.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          isSaved ? Iconsax.heart5 : Iconsax.heart,
          size: 20,
          color: isSaved ? const Color(0xFFE53935) : scheme.onSurface,
        ),
      ),
    );
  }
}
