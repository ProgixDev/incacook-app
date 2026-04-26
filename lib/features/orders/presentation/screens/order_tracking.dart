import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homemade/core/common/widgets/appbar/appbar.dart';
import 'package:homemade/features/chat/presentation/screens/chat.dart';
import 'package:homemade/features/orders/controllers/order_tracking_controller.dart';
import 'package:homemade/features/orders/domain/order_stage.dart';
import 'package:homemade/features/orders/presentation/widgets/delivered_stage_view.dart';
import 'package:homemade/features/orders/presentation/widgets/on_the_way_stage_view.dart';
import 'package:homemade/features/orders/presentation/widgets/order_bottom_sheet.dart';
import 'package:homemade/features/orders/presentation/widgets/preparing_stage_view.dart';

class OrderTrackingScreen extends StatelessWidget {
  const OrderTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OrderTrackingController());

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(showBackArrow: true),
      body: Obx(
        () => Stack(
          children: [
            //* 1. stage-specific content fills the whole screen
            Positioned.fill(child: _stageContent(controller.stage.value)),

            //* 2. bottom sheet with title, timeline and deliverer pill
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: OrderBottomSheet(
                stage: controller.stage.value,
                etaMinutes: controller.etaMinutes.value,
                onStageTap: controller.setStage,
                onCallTap: () {},
                onChatTap: () => Get.to(() => const ChatScreen()),
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
        return const PreparingStageView();
      case OrderStage.onTheWay:
        return const OnTheWayStageView();
      case OrderStage.delivered:
        return const DeliveredStageView();
    }
  }
}
