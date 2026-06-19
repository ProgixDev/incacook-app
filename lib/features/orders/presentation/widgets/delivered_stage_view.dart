import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

import 'package:incacook/core/constants/animations.dart';
import 'package:incacook/core/constants/api_constants.dart';
import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/core/utils/device/device_utility.dart';
import 'package:incacook/features/orders/controllers/order_tracking_controller.dart';
import 'package:incacook/features/orders/data/orders_repository.dart';
import 'package:incacook/features/orders/presentation/widgets/order_tracking_layout.dart';

class DeliveredStageView extends StatefulWidget {
  const DeliveredStageView({super.key});

  @override
  State<DeliveredStageView> createState() => _DeliveredStageViewState();
}

class _DeliveredStageViewState extends State<DeliveredStageView> {
  DeliveryProof? _proof;

  @override
  void initState() {
    super.initState();
    _loadProof();
  }

  Future<void> _loadProof() async {
    final orderId = OrderTrackingController.instance.orderId;
    if (orderId == null) return;
    try {
      final proof = await OrdersRepository.instance.fetchDeliveryProof(orderId);
      if (mounted && proof.hasAbsentPhoto) setState(() => _proof = proof);
    } catch (_) {
      // No proof / not permitted / pickup order — just show the standard view.
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final width = DeviceUtils.getScreenWidth(context);

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.only(bottom: kOrderSheetApproxHeight),
      alignment: Alignment.center,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_proof != null) ...[
              _AbsentProofCard(proof: _proof!),
              const Gap(AppSizes.lg),
            ],
            Lottie.asset(
              AppAnimations.orderDelivered,
              width: width * 0.55,
              repeat: false,
              fit: BoxFit.contain,
            ),
            const Gap(AppSizes.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2),
                  child: Icon(Icons.star_rounded, color: Color(0xFFFFC107), size: 28),
                );
              }),
            ),
            const Gap(AppSizes.xs),
            Text(
              'Tap a star to rate',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shown on a delivered order that was left at the door (client absent): the
/// proof photo, the delivered timestamp, and an explanatory line.
class _AbsentProofCard extends StatelessWidget {
  const _AbsentProofCard({required this.proof});

  final DeliveryProof proof;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final photoUrl = ApiConstants.publicImageUrl(proof.photoUrl);
    final when = proof.deliveredAt ?? proof.takenAt;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(AppSizes.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppTexts.absentProofCardTitle,
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const Gap(AppSizes.sm),
          if (photoUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: 4 / 3,
                child: Image.network(
                  photoUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    color: scheme.surface,
                    alignment: Alignment.center,
                    child: Icon(Icons.broken_image_outlined, color: scheme.onSurfaceVariant),
                  ),
                ),
              ),
            ),
          const Gap(AppSizes.sm),
          Text(AppTexts.absentProofCardText, style: textTheme.bodyMedium),
          if (when != null) ...[
            const Gap(AppSizes.xs),
            Text(
              '${AppTexts.absentProofDeliveredAtLabel} ${DateFormat('dd/MM/yyyy HH:mm').format(when.toLocal())}',
              style: textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
          if (proof.note != null && proof.note!.isNotEmpty) ...[
            const Gap(AppSizes.xs),
            Text('« ${proof.note!} »',
                style: textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic)),
          ],
        ],
      ),
    );
  }
}
