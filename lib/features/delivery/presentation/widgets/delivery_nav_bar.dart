import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import 'package:homemade/features/delivery/presentation/widgets/go_online_button.dart';

class DeliveryNavBar extends StatelessWidget {
  const DeliveryNavBar({super.key});

  //* Geometry — derived from the pill button so the notch hugs it exactly.
  //* See [_NavBarPainter] for the path math.
  static const double _barVisibleHeight = 88;
  static const double overhang = GoOnlineButton.height / 2; // 28
  static const double totalHeight = _barVisibleHeight + overhang; // 116

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: totalHeight,
      child: CustomPaint(
        painter: _NavBarPainter(
          surfaceColor: scheme.surface,
          shadowColor: scheme.shadow.withValues(alpha: 0.18),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            //* Drive (left) + Earnings (right) — vertically centered in the
            //* visible bar area (below the notch).
            Padding(
              padding: const EdgeInsets.only(top: overhang),
              child: SizedBox(
                height: _barVisibleHeight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const [
                    Expanded(
                      child: _NavItem(
                        icon: Iconsax.driver_2,
                        label: 'Drive',
                        selected: true,
                      ),
                    ),
                    SizedBox(width: GoOnlineButton.width),
                    Expanded(
                      child: _NavItem(
                        icon: Iconsax.dollar_circle,
                        label: 'Earnings',
                        selected: false,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            //* Go Online pill — bottom of the pill aligns with the bottom
            //* of the notch (its top half overhangs above the bar).
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Center(child: GoOnlineButton()),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
  });

  final IconData icon;
  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = selected ? scheme.onSurface : scheme.onSurfaceVariant;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 26),
        const Gap(4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: color,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _NavBarPainter extends CustomPainter {
  const _NavBarPainter({required this.surfaceColor, required this.shadowColor});

  final Color surfaceColor;
  final Color shadowColor;

  //* All bar geometry derives from the pill button. The notch mirrors the
  //* pill's bottom-half silhouette: the descending curve drops vertically
  //* from the bar's top edge, then bends horizontally into the flat bottom
  //* (control at the outer-bottom corner of the curve's bbox).
  static const double _cornerRadius = 24;
  //* See-through stripe between the pill button and the dip's edges —
  //* same value used both vertically (under the button) and horizontally
  //* (around the button's sides), so the gap reads as uniform.
  static const double _bottomGap = 6;
  static const double _pillWidth = GoOnlineButton.width + _bottomGap * 2;
  static const double _pillHeight = GoOnlineButton.height;
  static const double _overhang = _pillHeight / 2;
  static const double _dipDepth = _pillHeight / 2 + _bottomGap;
  //* Dip's outline mirrors the pill's outline horizontally:
  //*   28-wide curve  +  112-wide flat  +  28-wide curve  =  168 total.
  //* So [_dipHalfWidth] = pillWidth/2 and each curve covers pillHeight/2.
  static const double _dipHalfWidth = _pillWidth / 2;
  static const double _flatHalfWidth = _pillWidth / 2 - _pillHeight / 2;

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final barTop = _overhang;

    final path = Path()
      ..moveTo(0, barTop + _cornerRadius)
      ..quadraticBezierTo(0, barTop, _cornerRadius, barTop)
      ..lineTo(centerX - _dipHalfWidth, barTop)
      //* descending curve into the dip — control at the outer-bottom corner
      //* (start_x, bottom) drops the curve vertically from the bar's top
      //* edge and lands it horizontally on the flat bottom, so the bend
      //* lives at the inside of the dip (mirroring the pill's silhouette).
      ..quadraticBezierTo(
        centerX - _dipHalfWidth,
        barTop + _dipDepth,
        centerX - _flatHalfWidth,
        barTop + _dipDepth,
      )
      ..lineTo(centerX + _flatHalfWidth, barTop + _dipDepth)
      //* ascending curve out of the dip — mirror of the descending one.
      ..quadraticBezierTo(
        centerX + _dipHalfWidth,
        barTop + _dipDepth,
        centerX + _dipHalfWidth,
        barTop,
      )
      ..lineTo(size.width - _cornerRadius, barTop)
      ..quadraticBezierTo(
        size.width,
        barTop,
        size.width,
        barTop + _cornerRadius,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawShadow(path, shadowColor, 8, true);
    canvas.drawPath(path, Paint()..color = surfaceColor);
  }

  @override
  bool shouldRepaint(_NavBarPainter old) =>
      old.surfaceColor != surfaceColor || old.shadowColor != shadowColor;
}
