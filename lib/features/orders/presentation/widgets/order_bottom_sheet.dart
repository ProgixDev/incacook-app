import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:incacook/core/constants/api_constants.dart';
import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/core/enums/order_stage.dart';
import 'package:incacook/features/orders/controllers/order_tracking_controller.dart';
import 'package:incacook/features/orders/data/orders_repository.dart';
import 'package:incacook/features/orders/presentation/widgets/order_deliverer_pill.dart';
import 'package:incacook/features/orders/presentation/widgets/order_timeline.dart';

class OrderBottomSheet extends StatelessWidget {
  const OrderBottomSheet({
    super.key,
    required this.stage,
    required this.etaMinutes,
    required this.onStageTap,
    this.phase = TrackingPhase.enRoute,
    this.driver,
    this.onCallTap,
    this.onChatTap,
  });

  final OrderStage stage;

  /// Real assigned driver, or null before assignment. The deliverer pill is
  /// only rendered once this is non-null — the buyer never sees a driver
  /// (no placeholder) during preparation.
  final TrackingDriver? driver;

  /// Which leg of the trip the buyer is watching. Lets the header
  /// distinguish "driver going to the seller" from "driver coming to
  /// you" while [stage] stays on `onTheWay` for both. Defaults to
  /// `enRoute` so existing demo paths keep the old wording.
  final TrackingPhase phase;

  /// Estimated minutes to arrival, or null when unknown — the header then
  /// shows a generic "en route" message instead of a fabricated number.
  final int? etaMinutes;
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

          //* title + subtitle (changes per stage and per leg)
          _StageHeader(stage: stage, etaMinutes: etaMinutes, phase: phase),
          const Gap(AppSizes.lg),

          //* timeline
          OrderTimeline(currentStage: stage, onStageTap: onStageTap),

          //* deliverer pill — only once a real driver is assigned. Before
          //* that the buyer sees the timeline/"en préparation" with no driver.
          if (driver != null) ...[
            const Gap(AppSizes.lg),
            OrderDelivererPill(
              name: driver!.fullName,
              totalDeliveries: driver!.totalDeliveries,
              avatarUrl: ApiConstants.publicImageUrl(driver!.avatarPath),
              onCallTap: onCallTap,
              onChatTap: onChatTap,
            ),
          ],
        ],
      ),
    );
  }
}

class _StageHeader extends StatelessWidget {
  const _StageHeader({
    required this.stage,
    required this.etaMinutes,
    required this.phase,
  });

  final OrderStage stage;
  final int? etaMinutes;
  final TrackingPhase phase;

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
        // While the same stage label ("En route") shows on the
        // stepper, the bottom sheet differentiates the two legs so
        // the buyer knows whether the polyline on the map is the
        // driver heading to the seller (leg 1) or to them (leg 2).
        if (phase == TrackingPhase.awaitingPickup) {
          title = AppTexts.trackingAwaitingPickupTitle;
          subtitle = AppTexts.trackingAwaitingPickupSubtitle;
        } else {
          // Show a real ETA only when known; otherwise a generic en-route
          // title (no fabricated number).
          title = etaMinutes != null
              ? '${AppTexts.trackingArrivingPrefix} $etaMinutes ${AppTexts.trackingMinutesSuffix}'
              : AppTexts.trackingEnRouteSubtitle;
          subtitle = AppTexts.trackingEnRouteSubtitle;
        }
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
