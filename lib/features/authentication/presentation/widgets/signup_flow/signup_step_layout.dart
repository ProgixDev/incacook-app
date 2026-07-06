import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:incacook/core/constants/sizes.dart';

/// Reusable step layout. Every page in the flow renders inside this so
/// titles, descriptions, and content padding stay consistent.
///
/// The bottom action bar is a sibling footer in the shell's column, so it
/// occupies its own space and content never hides behind it — this layout
/// only owns the page's own padding.
class SignupStepLayout extends StatelessWidget {
  const SignupStepLayout({
    super.key,
    required this.title,
    this.description,
    required this.child,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppSizes.lg,
      vertical: AppSizes.md,
    ),
    this.scrollable = true,
  });

  final String title;
  final String? description;
  final Widget child;
  final EdgeInsets padding;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final header = <Widget>[
      Text(
        title,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 24,
        ),
      ),
      if (description != null) ...[
        const Gap(AppSizes.sm),
        Text(
          description!,
          maxLines: 3,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
      const Gap(AppSizes.lg),
    ];

    if (!scrollable) {
      // Wrap [child] in [Expanded] so it gets *bounded* height equal to
      // the leftover space after the header. Without this, the outer
      // Column passes unbounded main-axis constraints to non-flex kids,
      // which breaks any inner [Expanded] (e.g. the legal page's
      // charter viewer flexing between header and checkboxes).
      return Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...header,
            Expanded(child: child),
          ],
        ),
      );
    }
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [...header, child],
      ),
    );
  }
}
