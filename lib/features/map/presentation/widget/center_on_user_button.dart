import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class CenterOnUserButton extends StatelessWidget {
  const CenterOnUserButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: scheme.surface,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: scheme.shadow.withValues(alpha: 0.15),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(Iconsax.gps, size: 22, color: scheme.onSurface),
      ),
    );
  }
}
