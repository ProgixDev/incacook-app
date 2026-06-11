import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/core/utils/geo/distance.dart';
import 'package:incacook/core/utils/popups/blurred_modal_sheet.dart';
import 'package:incacook/core/widgets/effects/frosted_surface.dart';
import 'package:incacook/core/models/order_detail.dart';

const Duration _kCountdown = Duration(seconds: 25);
const Duration _kHapticInterval = Duration(seconds: 4);

/// Presents the incoming-order modal for [order]. Resolves to:
/// - `true`  → driver tapped Accept
/// - `false` → driver tapped Decline OR the 25-second timer expired
/// - `null`  → barrier-tap / system dismissal (treated as decline by callers).
Future<bool?> showIncomingOrderModal(
  BuildContext context, {
  required OrderDetail order,
}) {
  return showBlurredModalBottomSheet<bool>(
    context: context,
    //? non-dismissible: declining must be an explicit choice or a timeout.
    isDismissible: false,
    enableDrag: false,
    builder: (_) => IncomingOrderSheet(order: order),
  );
}

class IncomingOrderSheet extends StatefulWidget {
  const IncomingOrderSheet({super.key, required this.order});

  final OrderDetail order;

  @override
  State<IncomingOrderSheet> createState() => _IncomingOrderSheetState();
}

class _IncomingOrderSheetState extends State<IncomingOrderSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _countdown;
  Timer? _hapticPulse;

  @override
  void initState() {
    super.initState();
    _countdown = AnimationController(vsync: this, duration: _kCountdown)
      ..addStatusListener(_onCountdownStatus)
      ..forward();

    //? attention-grabbing ping: a single system sound + heavy haptic on show,
    //? then a soft pulse every few seconds while waiting for a response.
    SystemSound.play(SystemSoundType.alert);
    HapticFeedback.heavyImpact();
    _hapticPulse = Timer.periodic(
      _kHapticInterval,
      (_) => HapticFeedback.lightImpact(),
    );
  }

  void _onCountdownStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && mounted) {
      Navigator.of(context).pop(false);
    }
  }

  @override
  void dispose() {
    _hapticPulse?.cancel();
    _countdown.removeStatusListener(_onCountdownStatus);
    _countdown.dispose();
    super.dispose();
  }

  void _accept() => Navigator.of(context).pop(true);
  void _decline() => Navigator.of(context).pop(false);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final order = widget.order;

    final pickup = order.seller.location;
    final dropoff = order.deliveryDetails?.address.coordinate;
    final distanceKm = dropoff == null
        ? 0.0
        : greatCircleDistance(pickup, dropoff) / 1000;
    //? city pace ~15 km/h → 4 min/km.
    final etaMin = (distanceKm * 4).round().clamp(1, 99);
    //? Real driver payout: backend's `driverPayoutCents` (which equals
    //? the order's `fulfillmentFeeCents`) is surfaced via
    //? `OrderDetail.deliveryFee` from the hydrated DeliverySummary.
    //? Was previously `+ 4.0` placeholder.
    final payout = order.deliveryFee;

    // Dropoff display: lead with the recipient (client) name when the
    // backend resolved it, with the address underneath. Falls back to
    // the plain address-only layout when the name isn't available.
    final dropoffDetails = order.deliveryDetails;
    final recipient = dropoffDetails?.recipientName;
    final hasRecipient = recipient != null && recipient.isNotEmpty;
    final addrLine1 = dropoffDetails?.address.line1 ?? '';
    final addrLine2 = dropoffDetails?.address.line2 ?? '';
    final fullAddress =
        [addrLine1, addrLine2].where((s) => s.isNotEmpty).join(' · ');

    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: FrostedSurface(
          borderRadius: BorderRadius.circular(28),
          tint: scheme.surface.withValues(alpha: 0.92),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.lg,
                AppSizes.md,
                AppSizes.lg,
                AppSizes.lg,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CountdownBar(controller: _countdown),
                  const Gap(AppSizes.md),
                  _Header(order: order),
                  const Gap(AppSizes.lg),
                  _PayoutBlock(
                    payout: payout,
                    itemCount: order.itemCount,
                    distanceKm: distanceKm,
                    etaMin: etaMin,
                  ),
                  const Gap(AppSizes.lg + 4),
                  _AddressBlock(
                    label: AppTexts.incomingOrderPickupLabel,
                    icon: Iconsax.shop,
                    title: order.seller.name,
                    subtitle: order.seller.neighborhood,
                  ),
                  const Gap(AppSizes.md),
                  _AddressBlock(
                    label: AppTexts.incomingOrderDropoffLabel,
                    icon: Iconsax.location,
                    title: hasRecipient ? recipient : addrLine1,
                    subtitle: hasRecipient ? fullAddress : addrLine2,
                  ),
                  const Gap(AppSizes.lg + 4),
                  _Actions(onAccept: _accept, onDecline: _decline),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CountdownBar extends StatelessWidget {
  const _CountdownBar({required this.controller});

  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: controller,
      builder: (_, _) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            //? value goes 0 → 1 over 25s; flip so the bar shrinks.
            value: 1 - controller.value,
            minHeight: 6,
            backgroundColor: scheme.outline.withValues(alpha: 0.18),
            valueColor: AlwaysStoppedAnimation<Color>(scheme.primary),
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.order});

  final OrderDetail order;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.sm + 2,
            vertical: AppSizes.xs,
          ),
          decoration: BoxDecoration(
            color: scheme.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            AppTexts.incomingOrderTitle.toUpperCase(),
            style: textTheme.labelSmall?.copyWith(
              color: scheme.primary,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.4,
            ),
          ),
        ),
        const Spacer(),
        Text(
          '#${order.orderNumber}',
          style: textTheme.labelMedium?.copyWith(
            color: scheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _PayoutBlock extends StatelessWidget {
  const _PayoutBlock({
    required this.payout,
    required this.itemCount,
    required this.distanceKm,
    required this.etaMin,
  });

  final double payout;
  final int itemCount;
  final double distanceKm;
  final int etaMin;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final currency = NumberFormat.currency(locale: 'fr_FR', symbol: '€');
    final dist = NumberFormat('0.0', 'fr_FR').format(distanceKm);
    final itemsLabel = itemCount > 1
        ? AppTexts.incomingOrderItemsSuffix
        : AppTexts.incomingOrderItemSuffix;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          currency.format(payout),
          style: textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: scheme.onSurface,
            height: 1.0,
          ),
        ),
        const Gap(AppSizes.xs + 2),
        Text(
          '$itemCount $itemsLabel · $dist ${AppTexts.incomingOrderDistanceSuffix} · $etaMin ${AppTexts.incomingOrderEtaSuffix}',
          style: textTheme.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _AddressBlock extends StatelessWidget {
  const _AddressBlock({
    required this.label,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final String label;
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: scheme.primary.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(icon, color: scheme.primary, size: 18),
        ),
        const Gap(AppSizes.sm + 2),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: textTheme.labelSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
              const Gap(2),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.titleSmall?.copyWith(
                  color: scheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (subtitle.isNotEmpty) ...[
                const Gap(1),
                Text(
                  subtitle,
                  maxLines: 1,
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
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions({required this.onAccept, required this.onDecline});

  final VoidCallback onAccept;
  final VoidCallback onDecline;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: OutlinedButton(
            onPressed: onDecline,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: AppSizes.md - 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
              textStyle: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            child: const Text(AppTexts.incomingOrderDeclineCta),
          ),
        ),
        const Gap(AppSizes.sm),
        Expanded(
          flex: 3,
          child: FilledButton(
            onPressed: onAccept,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: AppSizes.md - 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
              textStyle: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            child: const Text(AppTexts.incomingOrderAcceptCta),
          ),
        ),
      ],
    );
  }
}
