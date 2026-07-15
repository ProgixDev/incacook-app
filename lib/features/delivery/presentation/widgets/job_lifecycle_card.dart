import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:incacook/core/services/map/models/map_route.dart';

import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/core/services/realtime/chat_message.dart';
import 'package:incacook/core/utils/geo/distance.dart';
import 'package:incacook/core/widgets/effects/frosted_surface.dart';
import 'package:incacook/core/constants/text_strings.dart' show AppTexts;
import 'package:incacook/features/chat/presentation/chat_navigator.dart';
import 'package:incacook/features/delivery/controllers/delivery_route_controller.dart';
import 'package:incacook/features/delivery/data/issue_catalog.dart';
import 'package:incacook/features/delivery/presentation/screens/absent_dropoff_screen.dart';
import 'package:incacook/features/delivery/presentation/screens/seller_unavailable_screen.dart';
import 'package:incacook/features/delivery/presentation/widgets/issue_report_sheet.dart';
import 'package:incacook/features/delivery/presentation/widgets/job_stage_actions.dart';
import 'package:incacook/core/models/order_detail.dart';
import 'package:incacook/core/enums/order_stage.dart';

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
              // Chat with the client (livreur ↔ buyer) and the seller
              // (livreur ↔ vendeur), both scoped to this order. The server
              // derives the counterpart from the order id; hidden once the
              // job reaches a terminal stage.
              if (!stage.isTerminal) ...[
                const Gap(AppSizes.md),
                _ContactButton(
                  label: AppTexts.chatContactClientCta,
                  onPressed: () => ChatNavigator.openBuyerDelivery(
                    context: context,
                    peerName: 'Client',
                    orderId: job.id,
                    myRole: ParticipantRole.delivery,
                  ),
                ),
                const Gap(AppSizes.sm),
                _ContactButton(
                  label: AppTexts.chatContactSellerCta,
                  onPressed: () => ChatNavigator.openSellerDriver(
                    context: context,
                    peerName: job.seller.name,
                    orderId: job.id,
                    myRole: ParticipantRole.delivery,
                  ),
                ),
              ],
              const Gap(AppSizes.lg),
              _PrimaryCta(
                spec: spec,
                onPressed: () => _onCtaPressed(context),
              ),
              // Pickup fallback: seller absent / no food → report it (driver is
              // at the seller). Only at the pickup step, before confirmation.
              if (stage == OrderStage.arrivedPickup) ...[
                const Gap(AppSizes.xs),
                TextButton.icon(
                  onPressed: () => _onSellerUnavailablePressed(context),
                  icon: const Icon(Icons.storefront_outlined, size: 18),
                  label: const Text(AppTexts.sellerUnavailableCta),
                ),
              ],
              // Dropoff fallback: client absent → leave at the door with photo
              // + GPS proof. Only at the dropoff step (driver is at the door).
              if (stage == OrderStage.arrivedDropoff) ...[
                const Gap(AppSizes.xs),
                TextButton.icon(
                  onPressed: () => _onAbsentPressed(context),
                  icon: const Icon(Icons.report_gmailerrorred_outlined, size: 18),
                  label: const Text(AppTexts.absentDropoffCta),
                ),
              ],
              if (!stage.isTerminal) ...[
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

  /// Seller-unavailable fallback at the pickup step. Opens the report screen;
  /// on success the order is cancelled + refunded, the driver compensated, and
  /// the job cleared by the controller.
  Future<void> _onSellerUnavailablePressed(BuildContext context) async {
    final ok = await Get.to<bool>(() => const SellerUnavailableScreen());
    if (ok == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppTexts.sellerUnavailableSuccess)),
      );
    }
  }

  /// Client-absent fallback at the dropoff step. Opens the proof screen
  /// (photo + GPS); on success the job is already cleared by the controller, so
  /// we just confirm to the driver.
  Future<void> _onAbsentPressed(BuildContext context) async {
    final ok = await Get.to<bool>(() => const AbsentDropoffScreen());
    if (ok == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppTexts.absentDropoffSuccess)),
      );
    }
  }

  /// Delegates to the shared [runStageCta] so the full card and the compact
  /// persistent action bar drive the identical QR-handoff / advance flow.
  Future<void> _onCtaPressed(BuildContext context) => runStageCta(context, route, stage);

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

/// Display + behavior for a single lifecycle stage. Title / icon / CTA come
/// from the shared [stageLabels] (kept in sync with the compact action bar);
/// the flow (nextStage / isTerminal) lives on [OrderStageFlow]. This spec adds
/// only the card-specific layout bits (target, instructions, QR handoff).
class _StageSpec {
  const _StageSpec({
    required this.title,
    required this.icon,
    required this.target,
    required this.cta,
    required this.showInstructions,
    this.requiresQrHandoff = false,
  });

  final String title;
  final IconData icon;
  final _Target target;
  final String cta;
  final bool showInstructions;

  /// True for handoff stages — the seller / customer scans a QR before the
  /// driver advances.
  final bool requiresQrHandoff;

  static _StageSpec forStage(OrderStage stage) {
    final labels = stageLabels(stage);
    final (target, showInstructions, requiresQrHandoff) = switch (stage) {
      OrderStage.prepared => (_Target.pickup, false, false),
      OrderStage.arrivedPickup => (_Target.pickup, false, true),
      OrderStage.onTheWay => (_Target.dropoff, false, false),
      OrderStage.arrivedDropoff => (_Target.dropoff, true, true),
      OrderStage.delivered => (_Target.dropoff, false, false),
      OrderStage.failed => (_Target.dropoff, false, false),
    };
    return _StageSpec(
      title: labels.title,
      icon: labels.icon,
      cta: labels.cta,
      target: target,
      showInstructions: showInstructions,
      requiresQrHandoff: requiresQrHandoff,
    );
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

  /// The coordinate + text query for the current stage's destination.
  /// Pickup always has coordinates (seller location); the dropoff coordinate
  /// can be null when the client address hasn't been geocoded, in which case
  /// we fall back to the text address so Maps can still route to it.
  (MapPoint?, String) get _destination => switch (spec.target) {
        _Target.pickup => (
            job.seller.location,
            [job.seller.name, job.seller.neighborhood]
                .where((s) => s.isNotEmpty)
                .join(', '),
          ),
        _Target.dropoff => (
            job.deliveryDetails?.address.coordinate,
            [
              job.deliveryDetails?.address.line1 ?? '',
              job.deliveryDetails?.address.line2 ?? '',
            ].where((s) => s.isNotEmpty).join(', '),
          ),
      };

  /// Opens Google Maps with driving directions to this stage's destination.
  Future<void> _openDirections(BuildContext context) async {
    final (coord, query) = _destination;
    final String destParam;
    if (coord != null) {
      destParam = '${coord.lat},${coord.lng}';
    } else if (query.isNotEmpty) {
      destParam = Uri.encodeComponent(query);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Adresse indisponible pour l’itinéraire.'),
          ),
        );
      }
      return;
    }

    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$destParam',
    );
    final launched =
        await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible d’ouvrir Google Maps.')),
      );
    }
  }

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

    return GestureDetector(
      onTap: () => _openDirections(context),
      child: Container(
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
            //* Tappable directions affordance — the whole block routes to
            //* Google Maps, this icon signals it.
            const Gap(AppSizes.sm),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(Iconsax.direct_right, color: scheme.primary, size: 20),
            ),
          ],
        ),
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

class _ContactButton extends StatelessWidget {
  const _ContactButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        icon: const Icon(Iconsax.message, size: 18),
        label: Text(label),
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
