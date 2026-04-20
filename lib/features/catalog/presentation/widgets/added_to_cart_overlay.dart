import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:vinted_v2/core/constants/animations.dart';
import 'package:vinted_v2/core/utils/device/device_utility.dart';

/// Full-screen confirmation overlay shown when an item is added to the cart.
///
/// Dark barrier behind a centered Lottie. The animation plays once and the
/// overlay auto-dismisses on completion.
class AddedToCartOverlay extends StatefulWidget {
  const AddedToCartOverlay({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (_) => const AddedToCartOverlay(),
    );
  }

  @override
  State<AddedToCartOverlay> createState() => _AddedToCartOverlayState();
}

class _AddedToCartOverlayState extends State<AddedToCartOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this)
    ..addStatusListener(_onStatus);

  void _onStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Lottie.asset(
        AppAnimations.success,
        controller: _controller,
        width: DeviceUtils.getScreenWidth(context) * 0.55,
        height: DeviceUtils.getScreenWidth(context) * 0.55,
        repeat: false,
        onLoaded: (composition) {
          _controller
            // ..duration = composition.duration
            ..duration = const Duration(seconds: 1)
            ..forward(from: 0);
        },
      ),
    );
  }
}
