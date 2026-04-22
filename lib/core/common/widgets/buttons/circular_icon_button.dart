import 'package:flutter/material.dart';
import 'package:vinted_v2/core/constants/sizes.dart';

class CircularIconButton extends StatelessWidget {
  const CircularIconButton({
    super.key,
    this.size,
    required this.icon,
    this.backgroundColor = Colors.blue,
    this.iconColor = Colors.white,
    this.onPressed,
  });

  final double? size;
  final IconData icon;
  final Color? backgroundColor;
  final Color iconColor;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size ?? AppSizes.lg * 1.8,
        height: size ?? AppSizes.lg * 1.8,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Icon(icon, color: iconColor, size: AppSizes.lg - 2),
      ),
    );
  }
}
