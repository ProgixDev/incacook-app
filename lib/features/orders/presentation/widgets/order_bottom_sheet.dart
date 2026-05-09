import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/core/enums/order_stage.dart';
import 'package:incacook/features/orders/presentation/widgets/order_deliverer_pill.dart';
import 'package:incacook/features/orders/presentation/widgets/order_timeline.dart';

class OrderBottomSheet extends StatelessWidget {
  const OrderBottomSheet({
    super.key,
    required this.stage,
    required this.etaMinutes,
    required this.onStageTap,
    this.onCallTap,
    this.onChatTap,
  });

  final OrderStage stage;
  final int etaMinutes;
  final ValueChanged<OrderStage> onStageTap;
  final VoidCallback? onCallTap;
  final VoidCallback? onChatTap;

  @override
  Widget build(BuildContext context) {
    final bottomSafe = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSizes.lg,
        AppSizes.sm,
        AppSizes.lg,
        bottomSafe + AppSizes.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Gap(AppSizes.lg),

          //* title + subtitle (changes per stage)
          _StageHeader(stage: stage, etaMinutes: etaMinutes),
          const Gap(AppSizes.lg),

          //* timeline
          OrderTimeline(currentStage: stage, onStageTap: onStageTap),
          const Gap(AppSizes.lg),

          //* deliverer pill
          OrderDelivererPill(onCallTap: onCallTap, onChatTap: onChatTap),
        ],
      ),
    );
  }
}

class _StageHeader extends StatelessWidget {
  const _StageHeader({required this.stage, required this.etaMinutes});

  final OrderStage stage;
  final int etaMinutes;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final titleStyle = Theme.of(context).textTheme.headlineSmall?.copyWith(
      fontWeight: FontWeight.w800,
    );
    final subtitleStyle = Theme.of(
      context,
    ).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant, height: 1.35);

    late final String title;
    late final String subtitle;

    switch (stage) {
      case OrderStage.prepared:
      case OrderStage.arrivedPickup:
        title = AppTexts.trackingPreparingTitle;
        subtitle = AppTexts.trackingPreparingSubtitle;
        break;
      case OrderStage.onTheWay:
      case OrderStage.arrivedDropoff:
        title =
            '${AppTexts.trackingArrivingPrefix} $etaMinutes ${AppTexts.trackingMinutesSuffix}';
        subtitle = AppTexts.trackingArrivingSubtitle;
        break;
      case OrderStage.delivered:
      case OrderStage.failed:
        title = AppTexts.trackingDeliveredTitle;
        subtitle = AppTexts.trackingDeliveredSubtitle;
        break;
    }

    return Column(
      children: [
        Text(title, textAlign: TextAlign.center, style: titleStyle),
        const Gap(AppSizes.xs),
        Text(subtitle, textAlign: TextAlign.center, style: subtitleStyle),
      ],
    );
  }
}
