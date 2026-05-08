import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:incacook/core/constants/animations.dart';
import 'package:incacook/core/utils/device/device_utility.dart';
import 'package:incacook/features/orders/presentation/widgets/order_tracking_layout.dart';

class PreparingStageView extends StatelessWidget {
  const PreparingStageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.only(bottom: kOrderSheetApproxHeight),
      alignment: Alignment.center,
      child: Lottie.asset(
        AppAnimations.orderPreparing,
        width: DeviceUtils.getScreenWidth(context) * 0.7,
        fit: BoxFit.contain,
      ),
    );
  }
}
