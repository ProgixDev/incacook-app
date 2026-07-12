import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/core/enums/order_stage.dart';
import 'package:incacook/core/network/api_response.dart';
import 'package:incacook/features/delivery/controllers/delivery_route_controller.dart';
import 'package:incacook/features/delivery/presentation/screens/qr_scan_screen.dart';

/// Shared stage presentation (title, icon, primary-CTA label) used by both the
/// full [JobLifecycleCard] and the compact [DeliveryActionBar], so the stage
/// copy stays identical across the two views.
typedef StageLabels = ({String title, IconData icon, String cta});

StageLabels stageLabels(OrderStage stage) => switch (stage) {
  OrderStage.prepared => (
    title: AppTexts.jobStageGoingToPickup,
    icon: Iconsax.shop,
    cta: AppTexts.jobCtaArrivedPickup,
  ),
  OrderStage.arrivedPickup => (
    title: AppTexts.jobStageAtPickup,
    icon: Iconsax.shop,
    cta: AppTexts.jobCtaPickedUp,
  ),
  OrderStage.onTheWay => (
    title: AppTexts.jobStageGoingToDropoff,
    icon: Iconsax.location,
    cta: AppTexts.jobCtaArrivedDropoff,
  ),
  OrderStage.arrivedDropoff => (
    title: AppTexts.jobStageAtDropoff,
    icon: Iconsax.location,
    cta: AppTexts.jobCtaConfirmDelivery,
  ),
  OrderStage.delivered => (
    title: AppTexts.jobStageDelivered,
    icon: Iconsax.tick_circle,
    cta: AppTexts.jobCtaFinish,
  ),
  OrderStage.failed => (
    title: AppTexts.jobStageFailed,
    icon: Iconsax.warning_2,
    cta: AppTexts.jobCtaFinish,
  ),
};

/// The primary-CTA action for a lifecycle stage, shared by the full
/// [JobLifecycleCard] and the compact persistent [DeliveryActionBar] so the two
/// can never diverge on the QR-handoff / advance flows (proof-of-pickup and
/// proof-of-delivery are money/penalty paths — a single source of truth).
///
/// - terminal stage → clears the job.
/// - pickup handoff (→ onTheWay) → scans the seller QR, confirms server-side.
/// - delivery handoff (→ delivered) → scans the buyer QR, confirms server-side.
/// - otherwise → advances to the next stage.
Future<void> runStageCta(
  BuildContext context,
  DeliveryRouteController route,
  OrderStage stage,
) async {
  if (stage.isTerminal) {
    route.clearJob();
    return;
  }
  final next = stage.nextStage;
  if (next == null) return;

  // Pickup: the driver SCANS the seller's QR (proof the dish was handed over).
  // The token is validated server-side; the stage only advances on a successful
  // scan — an invalid/duplicate QR surfaces the backend message.
  if (next == OrderStage.onTheWay) {
    final token = await Get.to<String>(
      () => const QrScanScreen(
        title: AppTexts.pickupScanTitle,
        instruction: AppTexts.pickupScanInstruction,
      ),
    );
    if (token == null || token.isEmpty) return;
    try {
      await route.confirmPickupScanned(token);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppTexts.pickupConfirmedMessage)),
        );
      }
    } on ApiFailure catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } on DemoJobException {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppTexts.deliveryDemoJobUnavailable)),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
    return;
  }

  // Delivery: the driver SCANS the buyer's reception QR (proof the order reached
  // the client). On success the job is DELIVERED and cleared; an
  // invalid/duplicate QR surfaces the backend message.
  if (next == OrderStage.delivered) {
    final token = await Get.to<String>(
      () => const QrScanScreen(
        title: AppTexts.deliveryScanTitle,
        instruction: AppTexts.deliveryScanInstruction,
      ),
    );
    if (token == null || token.isEmpty) return;
    try {
      await route.confirmDeliveryScanned(token);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppTexts.deliveryConfirmedMessage)),
        );
      }
    } on ApiFailure catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } on DemoJobException {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppTexts.deliveryDemoJobUnavailable)),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
    return;
  }

  await route.advanceStage(next);
}
