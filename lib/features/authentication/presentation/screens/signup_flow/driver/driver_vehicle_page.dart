import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/core/utils/device/device_utility.dart';
import 'package:incacook/features/authentication/controllers/signup_flow_controller.dart';
import 'package:incacook/features/authentication/data/models/driver_vehicle_type.dart';
import 'package:incacook/features/authentication/presentation/widgets/signup_flow/signup_step_layout.dart';
import 'package:incacook/features/authentication/presentation/widgets/user_type_card.dart';

/// Vehicle picker. Same shape as [RoleSelectionPage]: 2-column grid of
/// frosted [UserTypeCard]s with the chosen vehicle's subtitle revealed
/// at the bottom of the page after a card is tapped. Three options
/// (bicycle / scooter / car) — electric was removed.
class DriverVehiclePage extends GetView<SignupFlowController> {
  const DriverVehiclePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SignupStepLayout(
      title: AppTexts.signupDriverVehicleTitle,
      scrollable: false,
      child: Obx(() {
        final selected = controller.vehicleType.value;
        return Column(
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  const gap = AppSizes.gridViewSpacing;
                  // Cards are taller than wide (cardHeight = cardWidth /
                  // aspect). Width is bounded by the more constrained
                  // axis so two rows × two columns fit cleanly.
                  const aspect = 0.78;
                  final widthLimited = (constraints.maxWidth - gap) / 2;
                  final heightLimited =
                      ((constraints.maxHeight - gap) / 2) * aspect;
                  final cardWidth = math.min(widthLimited, heightLimited);
                  final cardHeight = cardWidth / aspect;
                  return Center(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: gap,
                      runSpacing: gap,
                      children: [
                        for (final v in DriverVehicleType.values)
                          SizedBox(
                            width: cardWidth,
                            height: cardHeight,
                            child: UserTypeCard(
                              media: Image.asset(
                                v.iconPath,
                                fit: BoxFit.contain,
                              ),
                              title: v.title,
                              selected: selected == v,
                              onTap: () => controller.selectVehicle(v),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const Gap(AppSizes.spaceBtwItems),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: selected == null
                  ? SizedBox(
                      key: ValueKey('empty'),
                      height: DeviceUtils.getScreenHeight(context) * 0.02,
                      width: double.infinity,
                    )
                  : SizedBox(
                      height: DeviceUtils.getScreenHeight(context) * 0.02,
                      width: double.infinity,
                      child: Padding(
                        key: ValueKey(selected),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.sm,
                        ),
                        child: Text(
                          selected.subtitle,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ),
                    ),
            ),
          ],
        );
      }),
    );
  }
}
