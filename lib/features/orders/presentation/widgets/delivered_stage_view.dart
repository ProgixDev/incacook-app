import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lottie/lottie.dart';
import 'package:incacook/core/constants/animations.dart';
import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/utils/device/device_utility.dart';
import 'package:incacook/features/orders/presentation/widgets/order_tracking_layout.dart';

class DeliveredStageView extends StatelessWidget {
  const DeliveredStageView({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final width = DeviceUtils.getScreenWidth(context);

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.only(bottom: kOrderSheetApproxHeight),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
                child: Icon(
                  Icons.star_rounded,
                  color: Color(0xFFFFC107),
                  size: 28,
                ),
              );
            }),
          ),
          const Gap(AppSizes.xs),
          Text(
            'Tap a star to rate',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
