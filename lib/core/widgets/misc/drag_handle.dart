import 'package:flutter/material.dart';
import 'package:vinted_v2/core/constants/sizes.dart';

class DragHandle extends StatelessWidget {
  const DragHandle({super.key, this.color = Colors.grey});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.sm + 2),
      child: Center(
        child: Container(
          width: 42,
          height: 4,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}
