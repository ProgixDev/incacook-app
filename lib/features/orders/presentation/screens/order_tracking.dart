import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:incacook/core/common/widgets/appbar/appbar.dart';
import 'package:incacook/core/enums/order_stage.dart';
import 'package:incacook/core/services/realtime/chat_message.dart';
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

  Widget _stageContent(OrderStage stage) {
    switch (stage) {
      case OrderStage.prepared:
      case OrderStage.arrivedPickup:
        return const PreparingStageView();
      case OrderStage.onTheWay:
      case OrderStage.arrivedDropoff:
        return const OnTheWayStageView();
      case OrderStage.delivered:
      case OrderStage.failed:
        return const DeliveredStageView();
    }
  }
}
