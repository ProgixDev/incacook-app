import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:incacook/core/constants/sizes.dart';

/// Tappable checkbox row with a label. The whole row toggles when pressed.
class SignupCheckbox extends StatelessWidget {
  const SignupCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
    this.enabled = true,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final Widget label;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: enabled ? () => onChanged(!value) : null,
      borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 20,
              height: 20,
              margin: const EdgeInsets.only(top: 2),
              decoration: BoxDecoration(
                color: value
                    ? scheme.primary
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: value
                      ? scheme.primary
                      : (enabled
                          ? scheme.outline
                          : scheme.outlineVariant),
                  width: 1.5,
                ),
              ),
              alignment: Alignment.center,
              child: value
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
            const Gap(AppSizes.sm + 4),
            Expanded(
              child: DefaultTextStyle.merge(
                style: TextStyle(
                  color: enabled
                      ? scheme.onSurface
                      : scheme.onSurfaceVariant,
                  fontSize: 14,
                  height: 1.4,
                ),
                child: label,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
