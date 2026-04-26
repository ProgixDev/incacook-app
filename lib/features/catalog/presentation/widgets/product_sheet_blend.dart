import 'dart:ui';

import 'package:flutter/material.dart';

/// Frosted-glass strip that blurs whatever is painted behind it and fades
/// that blurred image into a solid sheet color through a vertical gradient.
///
/// Must be stacked **over** the image (i.e. the image has to be painted
/// earlier in the same Stack), otherwise there's nothing to blur and the
/// effect degrades to a plain gradient.
///
/// The optional [child] is rendered on top of the blur layer — useful for
/// placing content (e.g. a product title) so it visually sits inside the
/// frosted zone while remaining sharp and readable.
class ProductSheetBlend extends StatelessWidget {
  const ProductSheetBlend({
    super.key,
    this.height = 130,
    this.cornerRadius = 32,
    this.blurSigma = 22,
    this.sheetColor,
    this.child,
    this.childPadding = const EdgeInsets.fromLTRB(16, 0, 16, 12),
  });

  final double height;
  final double cornerRadius;
  final double blurSigma;
  final Color? sheetColor;
  final Widget? child;
  final EdgeInsetsGeometry childPadding;

  @override
  Widget build(BuildContext context) {
    final resolvedSheet =
        sheetColor ?? Theme.of(context).scaffoldBackgroundColor;
    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(cornerRadius)),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Stack(
          children: [
            //* layer 1: blur + transparent→sheet gradient
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.0, 0.45, 1.0],
                      colors: [
                        resolvedSheet.withValues(alpha: 0.0),
                        resolvedSheet.withValues(alpha: 0.55),
                        resolvedSheet,
                      ],
                    ),
                  ),
                ),
              ),
            ),

            //* layer 2: optional content, pinned to the bottom of the strip
            if (child != null)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Padding(padding: childPadding, child: child!),
              ),
          ],
        ),
      ),
    );
  }
}
