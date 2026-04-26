import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:homemade/core/constants/colors.dart';

class FavoriteButton extends StatelessWidget {
  const FavoriteButton({super.key, required this.isSaved, this.onTap});

  final bool isSaved;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          isSaved ? Iconsax.heart5 : Iconsax.heart,
          size: 20,
          color: isSaved ? const Color(0xFFE53935) : AppColors.secondary,
        ),
      ),
    );
  }
}
