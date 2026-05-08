import 'package:flutter/material.dart';
import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/utils/theme/theme_extensions.dart';

class QuickChoiceChips extends StatefulWidget {
  const QuickChoiceChips({
    super.key,
    this.choices = const ['Small', 'Medium', 'Large', 'Extra large'],
    this.initialIndex = 0,
    this.onChanged,
  });

  final List<String> choices;
  final int initialIndex;
  final ValueChanged<int>? onChanged;

  @override
  State<QuickChoiceChips> createState() => _QuickChoiceChipsState();
}

class _QuickChoiceChipsState extends State<QuickChoiceChips> {
  late int _selected = widget.initialIndex;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: widget.choices.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSizes.sm),
        itemBuilder: (context, index) {
          final selected = index == _selected;
          return GestureDetector(
            onTap: () {
              setState(() => _selected = index);
              widget.onChanged?.call(index);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.md + 2,
                vertical: AppSizes.sm,
              ),
              decoration: BoxDecoration(
                color: selected ? colors.selectedSurface : Colors.transparent,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: selected ? colors.selectedSurface : scheme.outline,
                  width: 1.2,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                widget.choices[index],
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: selected ? colors.selectedOnSurface : scheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
