import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/core/utils/geo/distance.dart';
import 'package:incacook/core/widgets/effects/frosted_surface.dart';
import 'package:incacook/core/constants/text_strings.dart' show AppTexts;
import 'package:incacook/features/delivery/controllers/delivery_route_controller.dart';
import 'package:incacook/features/delivery/data/issue_catalog.dart';
import 'package:incacook/features/delivery/presentation/widgets/issue_report_sheet.dart';
import 'package:incacook/features/delivery/presentation/widgets/qr_handoff_sheet.dart';
import 'package:incacook/features/orders/domain/order_detail.dart';
import 'package:incacook/features/orders/domain/order_stage.dart';

/// State-aware card that walks the driver through the active job. Reads
/// [DeliveryRouteController.currentJob] / [DeliveryRouteController.currentStage]
/// reactively; renders nothing when there's no active job.
class JobLifecycleCard extends StatelessWidget {
  const JobLifecycleCard({super.key});

  @override
  Widget build(BuildContext context) {
    final route = DeliveryRouteController.instance;
    return Obx(() {
      final job = route.currentJob.value;
      final stage = route.currentStage.value;
      if (job == null || stage == null) return const SizedBox.shrink();
      return _Card(job: job, stage: stage, route: route);
    });
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.job, required this.stage, required this.route});

  final OrderDetail job;
  final OrderStage stage;
  final DeliveryRouteController route;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final spec = _StageSpec.forStage(stage);
    //? distance to whatever the driver is currently navigating to (pickup or
    //? dropoff). Stays static within a stage; recomputed on stage change via
    //? the parent Obx rebuild.
    final destination = route.currentDestination;
    final origin = route.currentDriverPosition;
    final distanceKm = (destination != null && origin != null)
        ? greatCircleDistance(origin, destination) / 1000
        : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
      child: Container(
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: scheme.shadow.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(spec: spec, distanceKm: distanceKm),
              const Gap(AppSizes.lg),
              _DestinationBlock(spec: spec, job: job),
              if (spec.showInstructions &&
                  (job.deliveryDetails?.instructions ?? '').isNotEmpty) ...[
                const Gap(AppSizes.md),
                _InstructionsBlock(text: job.deliveryDetails!.instructions),
              ],
              const Gap(AppSizes.md),
              _OrderMeta(job: job),
              const Gap(AppSizes.lg),
              _PrimaryCta(
                spec: spec,
                onPressed: () => _onCtaPressed(context),
              ),
              if (!spec.isTerminal) ...[
                const Gap(AppSizes.xs),
                _ReportIssueButton(
                  onPressed: () => _onReportPressed(context),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onCtaPressed(BuildContext context) async {
    final spec = _StageSpec.forStage(stage);
    if (spec.isTerminal) {
      route.clearJob();
      return;
    }
    final next = spec.nextStage;
    if (next == null) return;
    if (spec.requiresQrHandoff) {
      final confirmed = await showQrHandoffModal(context);
      if (confirmed != true) return;
    }
    await route.advanceStage(next);
  }

  Future<void> _onReportPressed(BuildContext context) async {
    final result = await showIssueReportModal(context, stage: stage);
    if (result == null || !context.mounted) return;
    if (result.option.severity == IssueSeverity.abort) {
      await route.advanceStage(OrderStage.failed);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppTexts.issueSheetReportedToast),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

/// Display + behavior for a single lifecycle stage.
class _StageSpec {
  const _StageSpec({
    required this.title,
    required this.icon,
    required this.target,
    required this.cta,
    required this.nextStage,
    required this.isTerminal,
    required this.showInstructions,
    this.requiresQrHandoff = false,
  });

  final String title;
  final IconData icon;
  final _Target target;
  final String cta;
  final OrderStage? nextStage;
  final bool isTerminal;
  final bool showInstructions;

  /// True for handoff stages — the seller / customer scans a QR before the
  /// driver advances. Mocked via [showQrHandoffModal].
  final bool requiresQrHandoff;

  static _StageSpec forStage(OrderStage stage) {
    switch (stage) {
      case OrderStage.prepared:
        return const _StageSpec(
          title: AppTexts.jobStageGoingToPickup,
          icon: Iconsax.shop,
          target: _Target.pickup,
          cta: AppTexts.jobCtaArrivedPickup,
          nextStage: OrderStage.arrivedPickup,
          isTerminal: false,
          showInstructions: false,
        );
      case OrderStage.arrivedPickup:
        return const _StageSpec(
          title: AppTexts.jobStageAtPickup,
          icon: Iconsax.shop,
          target: _Target.pickup,
          cta: AppTexts.jobCtaPickedUp,
          nextStage: OrderStage.onTheWay,
          isTerminal: false,
          showInstructions: false,
          requiresQrHandoff: true,
        );
      case OrderStage.onTheWay:
        return const _StageSpec(
          title: AppTexts.jobStageGoingToDropoff,
          icon: Iconsax.location,
          target: _Target.dropoff,
          cta: AppTexts.jobCtaArrivedDropoff,
          nextStage: OrderStage.arrivedDropoff,
          isTerminal: false,
          showInstructions: false,
        );
      case OrderStage.arrivedDropoff:
        return const _StageSpec(
          title: AppTexts.jobStageAtDropoff,
          icon: Iconsax.location,
          target: _Target.dropoff,
          cta: AppTexts.jobCtaConfirmDelivery,
          nextStage: OrderStage.delivered,
          isTerminal: false,
          showInstructions: true,
          requiresQrHandoff: true,
        );
      case OrderStage.delivered:
        return const _StageSpec(
          title: AppTexts.jobStageDelivered,
          icon: Iconsax.tick_circle,
          target: _Target.dropoff,
          cta: AppTexts.jobCtaFinish,
          nextStage: null,
          isTerminal: true,
          showInstructions: false,
        );
      case OrderStage.failed:
        return const _StageSpec(
          title: AppTexts.jobStageFailed,
          icon: Iconsax.warning_2,
          target: _Target.dropoff,
          cta: AppTexts.jobCtaFinish,
          nextStage: null,
          isTerminal: true,
          showInstructions: false,
        );
    }
  }
}

enum _Target { pickup, dropoff }

class _Header extends StatelessWidget {
  const _Header({required this.spec, required this.distanceKm});

  final _StageSpec spec;
  final double? distanceKm;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        Expanded(
          child: Text(
            spec.title,
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: scheme.onSurface,
              height: 1.1,
            ),
          ),
        ),
        if (distanceKm != null) ...[
          const Gap(AppSizes.sm),
          FrostedSurface(
            borderRadius: BorderRadius.circular(999),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.sm + 4,
              vertical: AppSizes.xs + 2,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Iconsax.location5, size: 14, color: scheme.onSurface),
                const Gap(6),
                Text(
                  '${NumberFormat('0.0', 'fr_FR').format(distanceKm!)} km',
                  style: textTheme.labelMedium?.copyWith(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _DestinationBlock extends StatelessWidget {
  const _DestinationBlock({required this.spec, required this.job});

  final _StageSpec spec;
  final OrderDetail job;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final (title, subtitle) = switch (spec.target) {
      _Target.pickup => (job.seller.name, job.seller.neighborhood),
      _Target.dropoff => (
        job.deliveryDetails?.address.line1 ?? '',
        job.deliveryDetails?.address.line2 ?? '',
      ),
    };

    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(spec.icon, color: scheme.primary, size: 20),
          ),
          const Gap(AppSizes.sm + 2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleSmall?.copyWith(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (subtitle.isNotEmpty) ...[
                  const Gap(2),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InstructionsBlock extends StatelessWidget {
  const _InstructionsBlock({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.sm + 2,
      ),
      decoration: BoxDecoration(
        color: scheme.outline.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppTexts.jobInstructionsLabel.toUpperCase(),
            style: textTheme.labelSmall?.copyWith(
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const Gap(2),
          Text(
            text,
            style: textTheme.bodyMedium?.copyWith(
              color: scheme.onSurface,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderMeta extends StatelessWidget {
  const _OrderMeta({required this.job});

  final OrderDetail job;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final itemsLabel = job.itemCount > 1
        ? AppTexts.incomingOrderItemsSuffix
        : AppTexts.incomingOrderItemSuffix;
    //? same mock formula as the incoming modal — keep the two views consistent.
    final payout = job.deliveryFee + 4.0;
    final currency = NumberFormat.currency(locale: 'fr_FR', symbol: '€');
    return Text(
      '${AppTexts.jobOrderNumberPrefix} #${job.orderNumber} · '
      '${job.itemCount} $itemsLabel · ${currency.format(payout)}',
      style: textTheme.bodySmall?.copyWith(
        color: scheme.onSurfaceVariant,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _PrimaryCta extends StatelessWidget {
  const _PrimaryCta({required this.spec, required this.onPressed});

  final _StageSpec spec;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        icon: const Icon(Iconsax.arrow_right_3, size: 18),
        label: Text(spec.cta),
      ),
    );
  }
}

class _ReportIssueButton extends StatelessWidget {
  const _ReportIssueButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: scheme.onSurfaceVariant,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.md,
            vertical: AppSizes.xs,
          ),
        ),
        child: const Text(AppTexts.jobReportIssue),
      ),
    );
  }
}
