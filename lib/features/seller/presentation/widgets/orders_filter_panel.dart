import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';

import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/core/widgets/effects/frosted_surface.dart';
import 'package:incacook/features/seller/domain/accepted_order.dart';

enum OrdersSortBy { acceptedTime, totalPrice }

/// Status filter — null means "all", else narrows to that status.
typedef OrdersStatusFilter = AcceptedOrderStatus?;

class OrdersFilterPanel extends StatefulWidget {
  const OrdersFilterPanel({
    super.key,
    required this.statusFilter,
    required this.sortBy,
    required this.onStatusChanged,
    required this.onSortChanged,
  });

  final OrdersStatusFilter statusFilter;
  final OrdersSortBy sortBy;
  final ValueChanged<OrdersStatusFilter> onStatusChanged;
  final ValueChanged<OrdersSortBy> onSortChanged;

  @override
  State<OrdersFilterPanel> createState() => _OrdersFilterPanelState();
}

class _OrdersFilterPanelState extends State<OrdersFilterPanel> {
  bool _expanded = false;

  String _statusLabel(OrdersStatusFilter status) => switch (status) {
    null => AppTexts.sellerOrdersFilterAll,
    AcceptedOrderStatus.awaitingAccept => AppTexts.sellerOrdersBadgeToAccept,
    AcceptedOrderStatus.readyToPickup =>
      AppTexts.sellerOrdersFilterReadyToPickup,
    AcceptedOrderStatus.pickedUp => AppTexts.sellerOrdersBadgePickedUp,
    AcceptedOrderStatus.inDelivery => AppTexts.sellerOrdersBadgeInDelivery,
    AcceptedOrderStatus.preparing => AppTexts.sellerOrdersFilterPreparing,
    AcceptedOrderStatus.completed => AppTexts.sellerOrdersFilterCompleted,
    AcceptedOrderStatus.cancelled => AppTexts.sellerOrdersBadgeCancelled,
  };

  void _toggleExpanded() => setState(() => _expanded = !_expanded);

  @override
  Widget build(BuildContext context) {
    return FrostedSurface(
      borderRadius: BorderRadius.circular(40),
      padding: const EdgeInsets.all(AppSizes.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CategoryHeader(
            label: _statusLabel(widget.statusFilter),
            expanded: _expanded,
            onToggle: _toggleExpanded,
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            child: _expanded
                ? _ExpandedBody(
                    statusFilter: widget.statusFilter,
                    sortBy: widget.sortBy,
                    onStatusChanged: (s) {
                      widget.onStatusChanged(s);
                      setState(() => _expanded = false);
                    },
                    onSortChanged: widget.onSortChanged,
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

class _CategoryHeader extends StatelessWidget {
  const _CategoryHeader({
    required this.label,
    required this.expanded,
    required this.onToggle,
  });

  final String label;
  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onToggle,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Container(
            width: 3,
            height: 22,
            decoration: BoxDecoration(
              color: scheme.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Gap(AppSizes.sm),
          Expanded(
            child: Text(
              label,
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          AnimatedRotation(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            turns: expanded ? 0.5 : 0,
            child: Icon(Iconsax.candle, color: scheme.onSurface, size: 22),
          ),
        ],
      ),
    );
  }
}

class _ExpandedBody extends StatelessWidget {
  const _ExpandedBody({
    required this.statusFilter,
    required this.sortBy,
    required this.onStatusChanged,
    required this.onSortChanged,
  });

  final OrdersStatusFilter statusFilter;
  final OrdersSortBy sortBy;
  final ValueChanged<OrdersStatusFilter> onStatusChanged;
  final ValueChanged<OrdersSortBy> onSortChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Gap(AppSizes.sm),
        _StatusOption(
          label: AppTexts.sellerOrdersFilterReadyToPickup,
          selected: statusFilter == AcceptedOrderStatus.readyToPickup,
          onTap: () => onStatusChanged(AcceptedOrderStatus.readyToPickup),
        ),
        _StatusOption(
          label: AppTexts.sellerOrdersFilterPreparing,
          selected: statusFilter == AcceptedOrderStatus.preparing,
          onTap: () => onStatusChanged(AcceptedOrderStatus.preparing),
        ),
        const Gap(AppSizes.md),
        Divider(color: scheme.outlineVariant.withValues(alpha: 0.5), height: 1),
        const Gap(AppSizes.md),
        Row(
          children: [
            Container(
              width: 3,
              height: 22,
              decoration: BoxDecoration(
                color: scheme.error,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Gap(AppSizes.sm),
            Text(
              AppTexts.sellerOrdersSortByLabel,
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const Gap(AppSizes.sm),
        _SortToggle(selected: sortBy, onChanged: onSortChanged),
      ],
    );
  }
}

class _StatusOption extends StatelessWidget {
  const _StatusOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.only(left: 11, top: 6, bottom: 6),
        child: Text(
          label,
          style: textTheme.bodyMedium?.copyWith(
            color: selected ? scheme.primary : scheme.onSurfaceVariant,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _SortToggle extends StatelessWidget {
  const _SortToggle({required this.selected, required this.onChanged});

  final OrdersSortBy selected;
  final ValueChanged<OrdersSortBy> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SortSegment(
              label: AppTexts.sellerOrdersSortAcceptedTime,
              selected: selected == OrdersSortBy.acceptedTime,
              onTap: () => onChanged(OrdersSortBy.acceptedTime),
            ),
          ),
          Expanded(
            child: _SortSegment(
              label: AppTexts.sellerOrdersSortTotalPrice,
              selected: selected == OrdersSortBy.totalPrice,
              onTap: () => onChanged(OrdersSortBy.totalPrice),
            ),
          ),
        ],
      ),
    );
  }
}

class _SortSegment extends StatelessWidget {
  const _SortSegment({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? scheme.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          style: textTheme.labelMedium!.copyWith(
            color: selected ? scheme.onSurface : scheme.onSurfaceVariant,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
          child: Text(label),
        ),
      ),
    );
  }
}
