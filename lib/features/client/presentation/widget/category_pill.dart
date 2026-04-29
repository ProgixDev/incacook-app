import 'package:flutter/material.dart';
import 'package:homemade/core/constants/sizes.dart';
import 'package:homemade/core/utils/theme/theme_extensions.dart';
import 'package:homemade/core/widgets/effects/frosted_surface.dart';

class CategoryPill extends StatelessWidget {
  const CategoryPill({
    super.key,
    required this.label,
    required this.selected,
    this.imagePath,
    this.icon,
    this.emoji,
    this.onTap,
  });

  final String label;
  final String? imagePath;
  final IconData? icon;
  final String? emoji;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final scheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: TweenAnimationBuilder<double>(
        //* t == 0 → unselected look, t == 1 → selected. The tween rebuilds
        //* whenever [selected] flips and animates from the previous value.
        tween: Tween<double>(end: selected ? 1.0 : 0.0),
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        builder: (context, t, _) {
          final bgTint = Color.lerp(
            colors.frostedTint,
            colors.selectedSurface,
            t,
          );
          final contentColor = Color.lerp(
            scheme.onSurface,
            colors.selectedOnSurface,
            t,
          )!;
          return LayoutBuilder(
            builder: (context, constraints) {
              //* Size every internal dimension off the cell's shortest side
              //* so the pill stays balanced whether the cell is tall+narrow
              //* or short+wide. Bounds keep things sane at the extremes.
              final shortSide = constraints.biggest.shortestSide;
              final pad = (shortSide * 0.08).clamp(4.0, 12.0);
              final imageSize = (shortSide * 0.55).clamp(16.0, 72.0);
              final iconSize = (shortSide * 0.50).clamp(14.0, 64.0);
              final fontSize = (shortSide * 0.18).clamp(9.0, 14.0);
              final gap = (pad * 0.4).clamp(2.0, 8.0);

              final textStyle = Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: contentColor,
                    fontSize: fontSize,
                  );

              return FrostedSurface(
                borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
                tint: bgTint,
                padding: EdgeInsets.all(pad),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (imagePath != null)
                      SizedBox(
                        width: imageSize,
                        height: imageSize,
                        child: Image.asset(imagePath!, fit: BoxFit.contain),
                      )
                    else if (icon != null)
                      Icon(icon, size: iconSize, color: contentColor)
                    else if (emoji != null)
                      Text(emoji!, style: TextStyle(fontSize: iconSize)),
                    SizedBox(height: gap),
                    Flexible(
                      child: Text(
                        label,
                        style: textStyle,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
