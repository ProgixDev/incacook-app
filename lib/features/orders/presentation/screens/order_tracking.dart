import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:incacook/core/common/widgets/appbar/appbar.dart';
import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/core/enums/order_stage.dart';
import 'package:incacook/core/network/api_response.dart';
import 'package:incacook/core/services/realtime/chat_message.dart';
import 'package:incacook/core/widgets/qr/qr_display_sheet.dart';
import 'package:incacook/features/chat/presentation/chat_navigator.dart';
import 'package:incacook/features/orders/controllers/order_tracking_controller.dart';
import 'package:incacook/features/orders/data/orders_repository.dart';
import 'package:incacook/features/orders/presentation/widgets/delivered_stage_view.dart';
import 'package:incacook/features/orders/presentation/widgets/on_the_way_stage_view.dart';
import 'package:incacook/features/orders/presentation/widgets/order_bottom_sheet.dart';
import 'package:incacook/features/orders/presentation/widgets/preparing_stage_view.dart';
import 'package:incacook/features/orders/presentation/widgets/qr_confirm_card.dart';

class OrderTrackingScreen extends StatelessWidget {
  const OrderTrackingScreen({super.key, this.orderId});

  /// Real server-issued order id. When provided, the controller
  /// subscribes to the live driver-position + status socket for this
  /// order. Null falls back to demo mock + simulated movement.
  final String? orderId;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OrderTrackingController(orderId: orderId));

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(showBackArrow: true),
      body: Obx(
        () => Stack(
          children: [
            //* 1. stage-specific content fills the whole screen
            Positioned.fill(child: _stageContent(controller.stage.value)),

            //* 2. pickup-only handoff: QR + tappable fallback link.
            //*    Visible once the seller marks ready (status READY ->
            //*    stage onTheWay). The QR encodes the pickup-confirm
            //*    payload so the seller could scan it in a real-world
            //*    flow; the link below triggers the same backend call
            //*    directly, which is what we actually demo on emulator.
            if (controller.isPickup.value &&
                controller.stage.value == OrderStage.onTheWay &&
                orderId != null)
              Positioned(
                left: 0,
                right: 0,
                bottom: 200,
                child: QrConfirmCard(
                  title: 'Code de récupération',
                  subtitle: 'Montre ce code au vendeur ou clique en dessous.',
                  qrData: 'incacook://handoff?orderId=$orderId&action=pickup',
                  linkLabel: 'Confirmer la récupération',
                  onConfirm: () async {
                    try {
                      await OrdersRepository.instance.confirmPickup(orderId!);
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Impossible de confirmer: $e')),
                        );
                      }
                    }
                  },
                ),
              ),

            //* 2a. no-driver fallback: when no driver accepted the delivery
            //*     (status NO_DRIVER_AVAILABLE), prompt the buyer to switch to
            //*     pickup or cancel + refund.
            if (controller.noDriverDecisionPending.value && orderId != null)
              Positioned(
                left: 0,
                right: 0,
                bottom: 200,
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.lg),
                  child: _NoDriverCard(
                    onSwitchToPickup: () =>
                        _onNoDriverDecision(context, controller, 'SWITCH_TO_PICKUP'),
                    onCancelRefund: () =>
                        _onNoDriverDecision(context, controller, 'CANCEL_AND_REFUND'),
                  ),
                ),
              ),

            //* 2b. delivery-only reception QR. Visible once the driver has
            //*     confirmed pickup (phase enRoute → order IN_DELIVERY). The
            //*     buyer taps to display their QR; the assigned driver scans it
            //*     to confirm delivery.
            if (!controller.isPickup.value &&
                controller.phase.value == TrackingPhase.enRoute &&
                orderId != null)
              Positioned(
                left: 0,
                right: 0,
                bottom: 200,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
                  child: FilledButton.icon(
                    onPressed: () => _showReceptionQr(context, orderId!),
                    icon: const Icon(Icons.qr_code_2),
                    label: const Text(AppTexts.buyerDeliveryQrCta),
                  ),
                ),
              ),

            //* 3. bottom sheet with title, timeline and deliverer pill
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: OrderBottomSheet(
                stage: controller.stage.value,
                phase: controller.phase.value,
                etaMinutes: controller.etaMinutes.value,
                onStageTap: controller.setStage,
                // Real assigned driver (null until a driver claims the
                // delivery) — the sheet hides the deliverer pill until then.
                driver: controller.assignedDriver.value,
                // Dial the real driver's phone when present.
                onCallTap: () {
                  final phone = controller.assignedDriver.value?.phone;
                  if (phone != null && phone.isNotEmpty) {
                    launchUrl(Uri.parse('tel:$phone'));
                  }
                },
                // Chat with the assigned driver (buyer ↔ livreur),
                // scoped to this order. The server derives the driver
                // from the order and rejects the call until one is
                // assigned, so we always offer the button and surface
                // any "no driver yet" error as a SnackBar.
                onChatTap: () => ChatNavigator.openBuyerDelivery(
                  context: context,
                  peerName:
                      controller.assignedDriver.value?.fullName ?? 'Livreur',
                  orderId: orderId ?? '',
                  myRole: ParticipantRole.buyer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Sends the buyer's no-driver decision and refreshes the screen. On success
  /// the order moves to pickup (READY) or cancelled; failures surface a snack.
  Future<void> _onNoDriverDecision(
    BuildContext context,
    OrderTrackingController controller,
    String decision,
  ) async {
    final id = orderId;
    if (id == null) return;
    try {
      await OrdersRepository.instance.noDriverDecision(id, decision);
      controller.noDriverDecisionPending.value = false;
      await controller.refreshSnapshot();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            decision == 'SWITCH_TO_PICKUP'
                ? AppTexts.noDriverSwitchedMessage
                : AppTexts.noDriverCancelledMessage,
          ),
        ),
      );
    } on ApiFailure catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text(AppTexts.noDriverDecisionFailed)));
    }
  }

  /// Fetches the buyer's reception QR for [orderId] and shows it for the
  /// driver to scan. Surfaces the backend message (e.g. not in delivery yet)
  /// on failure.
  Future<void> _showReceptionQr(BuildContext context, String orderId) async {
    try {
      final qr = await OrdersRepository.instance.fetchDeliveryQr(orderId);
      if (!context.mounted) return;
      await showQrModal(
        context,
        title: AppTexts.deliveryQrSheetTitle,
        instruction: AppTexts.deliveryQrSheetInstruction,
        qrData: qr.qrData,
        closeLabel: AppTexts.deliveryQrSheetClose,
      );
    } on ApiFailure catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text(AppTexts.deliveryQrUnavailable)));
    }
  }

  Widget _stageContent(OrderStage stage) {
    switch (stage) {
      case OrderStage.prepared:
      case OrderStage.arrivedPickup:
        return const PreparingStageView();
      case OrderStage.onTheWay:
      case OrderStage.arrivedDropoff:
        return const OnTheWayStageView();
      case OrderStage.delivered:
        return const DeliveredStageView();
      case OrderStage.failed:
        return const _CancelledStageView();
    }
  }
}

/// Buyer-facing cancelled/refunded state. Tailors the message to the
/// cancellation reason (e.g. seller unavailable at pickup).
class _CancelledStageView extends StatelessWidget {
  const _CancelledStageView();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(AppSizes.lg),
      child: Obx(() {
        final reason = OrderTrackingController.instance.cancellationReason.value;
        final message = switch (reason) {
          'seller_unavailable' => AppTexts.buyerSellerUnavailableCancelled,
          'driver_disappeared' => AppTexts.buyerDriverDisappearedRefunded,
          _ => AppTexts.orderCancelledRefunded,
        };
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cancel_outlined, size: 56, color: scheme.error),
            const Gap(AppSizes.md),
            Text(
              message,
              textAlign: TextAlign.center,
              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        );
      }),
    );
  }
}

/// Buyer prompt shown when no driver accepted the delivery: switch to pickup
/// or cancel + refund.
class _NoDriverCard extends StatelessWidget {
  const _NoDriverCard({
    required this.onSwitchToPickup,
    required this.onCancelRefund,
  });

  final VoidCallback onSwitchToPickup;
  final VoidCallback onCancelRefund;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Material(
      elevation: 6,
      borderRadius: BorderRadius.circular(16),
      color: scheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.no_transfer_outlined, color: scheme.error),
                const SizedBox(width: AppSizes.sm),
                Expanded(
                  child: Text(
                    AppTexts.noDriverTitle,
                    style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.sm),
            Text(AppTexts.noDriverText, style: textTheme.bodyMedium),
            const SizedBox(height: AppSizes.md),
            FilledButton.icon(
              onPressed: onSwitchToPickup,
              icon: const Icon(Icons.storefront_outlined, size: 18),
              label: const Text(AppTexts.noDriverSwitchPickup),
            ),
            const SizedBox(height: AppSizes.sm),
            OutlinedButton.icon(
              onPressed: onCancelRefund,
              icon: const Icon(Icons.cancel_outlined, size: 18),
              label: const Text(AppTexts.noDriverCancelRefund),
            ),
          ],
        ),
      ),
    );
  }
}
