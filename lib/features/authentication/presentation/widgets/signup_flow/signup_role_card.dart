import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:incacook/core/constants/sizes.dart';

/// Large tap-target card for role / sub-type / vehicle selection.
///
/// Hosts an emoji or icon on the left, a title + description in the
/// middle, and a chevron on the right. Tap → outline highlights and
/// the parent flow advances.
class SignupRoleCard extends StatelessWidget {
  const SignupRoleCard({
    super.key,
    required this.title,
    required this.description,
    required this.onTap,
    this.emoji,
    this.icon,
    this.note,
    this.selected = false,
  });

  final String title;
  final String description;
  final VoidCallback onTap;
  final String? emoji;
  final IconData? icon;
  final String? note;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        constraints: const BoxConstraints(minHeight: 88),
        padding: const EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
          border: Border.all(
            color: selected ? scheme.primary : scheme.outlineVariant,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: emoji != null
                  ? Text(emoji!, style: const TextStyle(fontSize: 20))
                  : Icon(icon, size: 20, color: scheme.primary),
            ),
            const Gap(AppSizes.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const Gap(2),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                  if (note != null) ...[
                    const Gap(AppSizes.xs + 2),
                    Text(
                      note!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Gap(AppSizes.sm),
            Icon(
              Icons.chevron_right_rounded,
              color: scheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
