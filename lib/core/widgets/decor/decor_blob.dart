import 'package:flutter/material.dart';
import 'package:homemade/core/utils/device/device_utility.dart';
import 'package:homemade/core/utils/theme/theme_extensions.dart';

/// Decorative organic blob anchored to the top-right corner of a screen.
/// Drawn with cubic Béziers — coordinates are normalized to the [SizedBox]
/// so the shape scales cleanly.
///
/// The fill defaults to [AppColorExtensions.decorBlobTint] so it adapts to
/// light/dark mode. Pass an explicit [color] to override.
///
/// Wrap in [IgnorePointer] when placing — it's purely cosmetic.
class DecorBlob extends StatelessWidget {
  const DecorBlob({
    super.key,
    this.color,
    this.width,
    this.height,
  });

  final Color? color;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final fill = color ?? context.appColors.decorBlobTint;
    return SizedBox(
      width: width ?? DeviceUtils.getScreenWidth(context) * 0.6,
      height: height ?? DeviceUtils.getScreenHeight(context) * 0.36,
      child: CustomPaint(painter: _DecorBlobPainter(color: fill)),
    );
  }
}

class _DecorBlobPainter extends CustomPainter {
  const _DecorBlobPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final w = size.width;
    final h = size.height;
    final path = Path();

    //* Top edge — anchors from x≈20% across to the right corner with a
    //* subtle wave so it doesn't read as a ruler-straight line.
    path.moveTo(w * 0.20, 0);
    path.cubicTo(w * 0.40, -h * 0.02, w * 0.70, h * 0.02, w, 0);

    //* Right edge of the upper lobe.
    path.lineTo(w, h * 0.45);

    //* Bottom of the upper lobe arcing inward toward the neck.
    path.cubicTo(
      w * 0.95, h * 0.55,
      w * 0.80, h * 0.50,
      w * 0.65, h * 0.55,
    );

    //* Soft neck connecting the two lobes.
    path.cubicTo(
      w * 0.55, h * 0.60,
      w * 0.55, h * 0.70,
      w * 0.50, h * 0.78,
    );

    //* Bottom of the lower lobe.
    path.cubicTo(
      w * 0.45, h * 0.90,
      w * 0.28, h * 0.94,
      w * 0.22, h * 0.80,
    );

    //* Left edge of the lower lobe arcing back up to the neck.
    path.cubicTo(
      w * 0.18, h * 0.68,
      w * 0.32, h * 0.55,
      w * 0.25, h * 0.45,
    );

    //* Left edge of the upper lobe sweeping back to the top anchor.
    path.cubicTo(
      w * 0.18, h * 0.30,
      w * 0.16, h * 0.15,
      w * 0.20, 0,
    );
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _DecorBlobPainter old) => old.color != color;
}
