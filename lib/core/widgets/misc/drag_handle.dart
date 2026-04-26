import 'package:flutter/material.dart';
import 'package:homemade/core/constants/sizes.dart';

/// Bottom-sheet grabber bar. Default color follows
/// `Theme.of(context).colorScheme.outline` so it adapts to light/dark.
/// Pass [color] to override.
class DragHandle extends StatelessWidget {
  const DragHandle({super.key, this.color});

  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.sm + 2),
      child: Center(
        child: Container(
          width: 42,
          height: 4,
          decoration: BoxDecoration(
            color: color ?? Theme.of(context).colorScheme.outline,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}
