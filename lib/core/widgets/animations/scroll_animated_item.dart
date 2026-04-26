import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

class ScrollAnimatedItem extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double offsetY;

  const ScrollAnimatedItem({
    required this.child,
    this.duration = const Duration(milliseconds: 500),
    this.offsetY = 50.0,
    super.key,
  });

  @override
  State<ScrollAnimatedItem> createState() => _ScrollAnimatedItemState();
}

class _ScrollAnimatedItemState extends State<ScrollAnimatedItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  bool _visible = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: widget.duration);

    _fade = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _slide = Tween<Offset>(
      begin: Offset(0, widget.offsetY / 100),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  void _trigger() {
    if (!_visible) {
      _controller.forward();
      _visible = true;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: ValueKey(widget.child.hashCode.toString()),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.1) _trigger();
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder:
            (_, _) => Opacity(
              opacity: _fade.value,
              child: Transform.translate(
                offset: _slide.value * 100,
                child: widget.child,
              ),
            ),
      ),
    );
  }
}
