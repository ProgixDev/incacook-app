import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:incacook/core/utils/theme/theme_extensions.dart';

/// A drop-in replacement for [showModalBottomSheet] that paints a frosted
/// blur of the underlying screen behind the sheet content.
///
/// The builder you pass should return the sheet content with its own
/// background and shape — this helper always sets the modal's
/// [backgroundColor] to transparent so the blur is visible.
///
/// The barrier color defaults to [AppColorExtensions.barrierOverlay] so it
/// adapts to light/dark mode (dark mode uses a stronger overlay). Pass
/// [barrierColor] to override.
Future<T?> showBlurredModalBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isScrollControlled = true,
  bool isDismissible = true,
  bool enableDrag = true,
  bool useSafeArea = false,
  RouteSettings? routeSettings,
  AnimationController? transitionAnimationController,
  ShapeBorder? shape,
  Clip? clipBehavior,
  BoxConstraints? constraints,
  double sigma = 10,
  Color? barrierColor,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    useSafeArea: useSafeArea,
    routeSettings: routeSettings,
    transitionAnimationController: transitionAnimationController,
    shape: shape,
    clipBehavior: clipBehavior,
    constraints: constraints,
    backgroundColor: Colors.transparent,
    barrierColor: barrierColor ?? context.appColors.barrierOverlay,
    showDragHandle: false,
    builder: (ctx) => Stack(
      children: [
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
            child: const SizedBox.shrink(),
          ),
        ),
        Builder(builder: builder),
      ],
    ),
  );
}
