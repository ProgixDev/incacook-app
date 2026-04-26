import 'package:flutter/material.dart';
import 'package:homemade/core/enums/food_enums.dart';

class DietaryTagDot extends StatelessWidget {
  const DietaryTagDot({super.key, required this.tag});

  final DietaryTag tag;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: tag.color,
        border: Border.all(
          color: Theme.of(context).colorScheme.surface,
          width: 1.5,
        ),
      ),
    );
  }
}
