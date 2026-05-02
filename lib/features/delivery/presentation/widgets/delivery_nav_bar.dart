import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';

import 'package:homemade/core/constants/text_strings.dart';
import 'package:homemade/features/delivery/presentation/widgets/go_online_button.dart';

/// Tab indices for the delivery bottom-sheet body. Drive shows the
/// pickup/stats cards; settings shows the appearance + logout panel.
enum DeliveryNavTab { drive, settings }

class DeliveryNavBar extends StatelessWidget {
  const DeliveryNavBar({
    super.key,
    required this.frostedness,
    required this.selectedTab,
    required this.onTabSelected,
  });

  /// 1.0 → fully frosted (collapsed sheet, blur over the map).
  /// 0.0 → fully solid surface (expanded sheet, blends with content below).
  /// Animations between the two values are interpolated.
  final ValueListenable<double> frostedness;

  /// Currently active tab. The bar listens to this so selected styling
  /// stays in lockstep with the body content the parent renders.
  final ValueListenable<DeliveryNavTab> selectedTab;

  final ValueChanged<DeliveryNavTab> onTabSelected;

  //* Geometry — derived from the pill button so the notch hugs it exactly.
  static const double _barVisibleHeight = 88;
  static const double overhang = GoOnlineButton.height / 2; // 28
  static const double totalHeight = _barVisibleHeight + overhang; // 116

  /// Surface tint shared with the bottom-sheet body so the bar and body
  /// read as one continuous panel. [t] matches the `frostedness` value:
  /// 1 = collapsed (over the map, slight see-through), 0 = expanded
  /// (fully opaque, flush with the sheet body).
  static Color surfaceTintFor(ColorScheme scheme, double t) =>
      scheme.surface.withValues(alpha: 1.0 - 0.12 * t);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: totalHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          //* Shadow + frosted/solid fill, both following the dipped silhouette.
          _NavBarBackground(frostedness: frostedness),

          //* Drive (left) + Settings (right) — vertically centered in the
          //* visible bar area (below the notch).
          Padding(
            padding: const EdgeInsets.only(top: overhang),
            child: SizedBox(
              height: _barVisibleHeight,
              child: ValueListenableBuilder<DeliveryNavTab>(
                valueListenable: selectedTab,
                builder: (context, tab, _) => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: _NavItem(
                        icon: Iconsax.driver_2,
                        label: AppTexts.deliveryDashboardDriveTab,
                        selected: tab == DeliveryNavTab.drive,
                        onTap: () => onTabSelected(DeliveryNavTab.drive),
                      ),
                    ),
                    const SizedBox(width: GoOnlineButton.width),
                    Expanded(
                      child: _NavItem(
                        icon: Iconsax.setting_2,
                        label: AppTexts.deliveryDashboardSettingsTab,
                        selected: tab == DeliveryNavTab.settings,
                        onTap: () => onTabSelected(DeliveryNavTab.settings),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          //* Go Online pill — bottom of the pill aligns with the bottom of
          //* the notch (its top half overhangs above the bar).
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Center(child: GoOnlineButton()),
          ),
        ],
      ),
    );
  }
}

class _NavBarBackground extends StatelessWidget {
  const _NavBarBackground({required this.frostedness});

  final ValueListenable<double> frostedness;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shadowColor = scheme.shadow.withValues(alpha: 0.18);

    return ValueListenableBuilder<double>(
      valueListenable: frostedness,
      builder: (context, t, _) {
        //* No BackdropFilter — Mapbox is a PlatformView and Flutter can't
        //* sample it for blur. Instead the surface stays opaque-ish and
        //* gives up a sliver of alpha when collapsed over the map, so the
        //* frostedness signal still reads as "lightening up" without
        //* faking a blur that wouldn't be doing any real work.
        final tint = DeliveryNavBar.surfaceTintFor(scheme, t);
        //* Border fades with t — visible when over the map (the silhouette
        //* needs definition against a low-contrast backdrop), 0 when the bar
        //* is flush against the same-colored sheet body.
        final borderColor = scheme.outlineVariant.withValues(alpha: 0.45 * t);

        return Stack(
          fit: StackFit.expand,
          children: [
            //* Drop shadow tracing the dipped silhouette.
            CustomPaint(
              painter: _NavBarShadowPainter(shadowColor: shadowColor),
            ),
            //* Tinted fill, clipped to the silhouette so the dip is honored.
            ClipPath(
              clipper: const _NavBarClipper(),
              child: Container(color: tint),
            ),
            //* Border last so it sits over the fill, defining the curve.
            if (borderColor.a > 0)
              CustomPaint(
                painter: _NavBarBorderPainter(borderColor: borderColor),
              ),
          ],
        );
      },
    );
  }
}

//* Path geometry — derived from the pill button so the notch hugs it.
//* The notch mirrors the pill's bottom-half silhouette: the descending
//* curve drops vertically from the bar's top edge, then bends horizontally
//* into the flat bottom.
const double _cornerRadius = 24;
//* See-through stripe between the pill button and the dip's edges — same
//* value used both vertically (under the button) and horizontally (around
//* the button's sides), so the gap reads as uniform.
const double _bottomGap = 6;
const double _pillWidth = GoOnlineButton.width + _bottomGap * 2;
const double _pillHeight = GoOnlineButton.height;
const double _overhang = _pillHeight / 2;
const double _dipDepth = _pillHeight / 2 + _bottomGap;
const double _dipHalfWidth = _pillWidth / 2;
const double _flatHalfWidth = _pillWidth / 2 - _pillHeight / 2;

//* Top contour only — corners + dip. Used for both the clip/shadow (closed
//* by sweeping down the sides and across the bottom) and the border (open,
//* so the bottom edge isn't stroked where the bar meets the sheet body).
void _addNavBarTopContour(Path path, Size size) {
  final centerX = size.width / 2;
  const barTop = _overhang;

  path
    ..moveTo(0, barTop + _cornerRadius)
    ..quadraticBezierTo(0, barTop, _cornerRadius, barTop)
    ..lineTo(centerX - _dipHalfWidth, barTop)
    //* descending curve — control at outer-bottom corner drops vertically
    //* then bends horizontally into the flat bottom.
    ..quadraticBezierTo(
      centerX - _dipHalfWidth,
      barTop + _dipDepth,
      centerX - _flatHalfWidth,
      barTop + _dipDepth,
    )
    ..lineTo(centerX + _flatHalfWidth, barTop + _dipDepth)
    //* ascending curve — mirror of the descending one.
    ..quadraticBezierTo(
      centerX + _dipHalfWidth,
      barTop + _dipDepth,
      centerX + _dipHalfWidth,
      barTop,
    )
    ..lineTo(size.width - _cornerRadius, barTop)
    ..quadraticBezierTo(size.width, barTop, size.width, barTop + _cornerRadius);
}

Path _buildNavBarPath(Size size) {
  final path = Path();
  _addNavBarTopContour(path, size);
  return path
    ..lineTo(size.width, size.height)
    ..lineTo(0, size.height)
    ..close();
}

Path _buildNavBarBorderPath(Size size) {
  final path = Path();
  _addNavBarTopContour(path, size);
  return path;
}

class _NavBarShadowPainter extends CustomPainter {
  const _NavBarShadowPainter({required this.shadowColor});

  final Color shadowColor;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawShadow(_buildNavBarPath(size), shadowColor, 8, true);
  }

  @override
  bool shouldRepaint(_NavBarShadowPainter old) =>
      old.shadowColor != shadowColor;
}

class _NavBarBorderPainter extends CustomPainter {
  const _NavBarBorderPainter({required this.borderColor});

  final Color borderColor;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      _buildNavBarBorderPath(size),
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );
  }

  @override
  bool shouldRepaint(_NavBarBorderPainter old) =>
      old.borderColor != borderColor;
}

class _NavBarClipper extends CustomClipper<Path> {
  const _NavBarClipper();

  @override
  Path getClip(Size size) => _buildNavBarPath(size);

  @override
  bool shouldReclip(_NavBarClipper old) => false;
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = selected ? scheme.onSurface : scheme.onSurfaceVariant;

    return GestureDetector(
      onTap: onTap,
      //* opaque so taps anywhere in the item's box switch tabs without
      //* falling through to the outer sheet-toggle gesture.
      behavior: HitTestBehavior.opaque,
      child: Column(
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
      ),
    );
  }
}
