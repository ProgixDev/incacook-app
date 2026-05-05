import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';

import 'package:homemade/core/constants/sizes.dart';
import 'package:homemade/core/constants/text_strings.dart';
import 'package:homemade/core/widgets/effects/frosted_surface.dart';
import 'package:homemade/features/seller/data/order_request_mock_data.dart';
import 'package:homemade/features/seller/presentation/widgets/order_request_card.dart';

class OrderRequestsSection extends StatelessWidget {
  const OrderRequestsSection({super.key});

  static const double _cardHeight = 480;
  static const double _viewportFraction = 0.92;

  @override
  Widget build(BuildContext context) {
    final orders = OrderRequestMockData.demoRequests();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
          child: _SectionHeader(count: orders.length),
        ),
        const Gap(AppSizes.md),
        if (orders.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSizes.md),
            child: _EmptyState(),
          )
        else
          SizedBox(
            height: _cardHeight,
            child: PageView.builder(
              controller: PageController(viewportFraction: _viewportFraction),
              padEnds: false,
              itemCount: orders.length,
              itemBuilder: (context, i) => Padding(
                padding: EdgeInsets.only(
                  left: i == 0 ? AppSizes.md : AppSizes.sm,
                  right: AppSizes.sm,
                ),
                child: OrderRequestCard(order: orders[i]),
              ),
            ),
          ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        if (count > 0)
          _CountBadge(count: count)
        else
          //? empty-state header collapses the count badge to a slim accent
          //? bar — keeps the visual rhythm without claiming attention.
          Container(
            width: 4,
            height: 28,
            decoration: BoxDecoration(
              color: scheme.error,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        const Gap(AppSizes.md),
        Expanded(
          child: Text(
            AppTexts.sellerOrderRequestsTitle,
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Icon(Iconsax.more, color: scheme.onSurface),
      ],
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: scheme.primary,
        borderRadius: BorderRadius.circular(40),
      ),
      alignment: Alignment.center,
      child: Text(
        count.toString(),
        style: textTheme.titleMedium?.copyWith(
          color: scheme.onError,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final hint = scheme.onSurfaceVariant.withValues(alpha: 0.5);

    return FrostedSurface(
      borderRadius: BorderRadius.circular(20),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.lg,
        vertical: AppSizes.spaceBtwSections,
      ),
      child: Column(
        children: [
          Icon(Iconsax.emoji_sad, size: 64, color: hint),
          const Gap(AppSizes.lg),
          Text(
            AppTexts.sellerOrderEmptyMessage,
            textAlign: TextAlign.center,
            style: textTheme.titleMedium?.copyWith(color: hint),
          ),
        ],
      ),
    );
  }
}
