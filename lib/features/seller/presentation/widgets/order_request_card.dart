import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/core/widgets/effects/frosted_surface.dart';
import 'package:incacook/features/seller/domain/order_request.dart';

class OrderRequestCard extends StatelessWidget {
  const OrderRequestCard({
    super.key,
    required this.order,
    this.onAccept,
    this.onReject,
    this.onSeeMore,
  });

  final OrderRequest order;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final VoidCallback? onSeeMore;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final dateLabel = DateFormat('d MMM y', 'fr_FR').format(order.placedAt);
    final timeLabel = DateFormat.jm('fr_FR').format(order.placedAt);

    return FrostedSurface(
      borderRadius: BorderRadius.circular(20),
      padding: const EdgeInsets.all(AppSizes.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _Header(
            id: order.id,
            dateLabel: dateLabel,
            timeLabel: timeLabel,
            onAccept: onAccept,
            onReject: onReject,
          ),
          const Gap(AppSizes.md),
          for (final item in order.items) ...[
            _ItemRow(item: item),
            Divider(
              color: scheme.outlineVariant.withValues(alpha: 0.5),
              height: 1,
            ),
          ],
          const Gap(AppSizes.sm),
          Center(
            child: GestureDetector(
              onTap: onSeeMore,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSizes.xs),
                child: Text(
                  AppTexts.sellerOrderSeeMore,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface,
                  ),
                ),
              ),
            ),
          ),
          const Gap(AppSizes.sm),
          _NoteBlock(note: order.note),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.id,
    required this.dateLabel,
    required this.timeLabel,
    required this.onAccept,
    required this.onReject,
  });

  final String id;
  final String dateLabel;
  final String timeLabel;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.sm,
        vertical: AppSizes.xs,
      ),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '#$id',
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Gap(AppSizes.xs),
              Text(
                '$dateLabel, $timeLabel',
                style: textTheme.labelSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const Spacer(),
          _DecisionToggle(onAccept: onAccept, onReject: onReject),
        ],
      ),
    );
  }
}

enum _Decision { reject, accept }

/// Two-segment selector for accepting / rejecting an order. Starts with
/// neither selected; tapping a segment fills it with [ColorScheme.error]
/// and dims the other to a transparent label, then fires the callback.
class _DecisionToggle extends StatefulWidget {
  const _DecisionToggle({required this.onAccept, required this.onReject});

  final VoidCallback? onAccept;
  final VoidCallback? onReject;

  @override
  State<_DecisionToggle> createState() => _DecisionToggleState();
}

class _DecisionToggleState extends State<_DecisionToggle> {
  _Decision? _selected;

  void _select(_Decision decision) {
    setState(() => _selected = decision);
    switch (decision) {
      case _Decision.accept:
        widget.onAccept?.call();
      case _Decision.reject:
        widget.onReject?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _DecisionSegment(
          icon: Icons.close,
          tooltip: AppTexts.sellerOrderActionReject,
          selected: _selected == _Decision.reject,
          onTap: () => _select(_Decision.reject),
        ),
        const Gap(AppSizes.xs),
        _DecisionSegment(
          icon: Icons.check,
          tooltip: AppTexts.sellerOrderActionAccept,
          selected: _selected == _Decision.accept,
          onTap: () => _select(_Decision.accept),
        ),
      ],
    );
  }
}

class _DecisionSegment extends StatelessWidget {
  const _DecisionSegment({
    required this.icon,
    required this.tooltip,
    required this.selected,
    required this.onTap,
  });

  static const double _size = 36;

  final IconData icon;
  final String tooltip;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    //? Unselected sits on the parent chip's surfaceContainerHigh background,
    //? so transparent reads cleanly without a second flat tile competing.
    final bg = selected ? scheme.secondary : Colors.transparent;
    final fg = selected ? scheme.onSecondary : scheme.onSurfaceVariant;

    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          width: _size,
          height: _size,
          decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
          child: TweenAnimationBuilder<Color?>(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            tween: ColorTween(end: fg),
            builder: (context, color, _) => Icon(icon, color: color, size: 20),
          ),
        ),
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({required this.item});

  final OrderRequestItem item;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          //? thin red accent matches the section's brand red — semantic
          //? "needs attention" treatment for actionable rows.
          Container(
            width: 3,
            height: 36,
            decoration: BoxDecoration(
              color: scheme.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Gap(AppSizes.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const Gap(AppSizes.xs),
                Row(
                  children: [
                    Text(
                      '\$${item.price.toStringAsFixed(0)}',
                      style: textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Gap(AppSizes.sm),
          _QuantityPill(quantity: item.quantity, isVeg: item.isVeg),
        ],
      ),
    );
  }
}

class _QuantityPill extends StatelessWidget {
  const _QuantityPill({required this.quantity, required this.isVeg});

  final int quantity;
  final bool isVeg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(
            context,
          ).colorScheme.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      child: Center(
        child: Text(
          'x$quantity',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _NoteBlock extends StatelessWidget {
  const _NoteBlock({required this.note});

  final String note;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(8),
      ),
      child: RichText(
        text: TextSpan(
          style: textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
          children: [
            TextSpan(
              text: '${AppTexts.sellerOrderNotePrefix} ',
              style: textTheme.bodySmall?.copyWith(
                color: scheme.onSurface,
                fontWeight: FontWeight.w800,
              ),
            ),
            TextSpan(text: note),
          ],
        ),
      ),
    );
  }
}
