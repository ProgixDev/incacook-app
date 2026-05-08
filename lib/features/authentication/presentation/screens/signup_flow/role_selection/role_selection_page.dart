import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:incacook/core/constants/animations.dart';
import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/features/authentication/controllers/signup_flow_controller.dart';
import 'package:incacook/features/authentication/data/models/user_role.dart';
import 'package:incacook/features/authentication/presentation/widgets/signup_flow/signup_step_layout.dart';
import 'package:incacook/features/authentication/presentation/widgets/user_type_card.dart';

class RoleSelectionPage extends GetView<SignupFlowController> {
  const RoleSelectionPage({super.key});

  // Lottie + copy mapping reuses the original UserTypeSelectionScreen
  // strings so the two role pickers feel like the same component family
  // and we don't fork the brand voice.
  static const Map<
    UserRole,
    ({String animation, String title, String subtitle})
  >
  _options = {
    UserRole.buyer: (
      animation: AppAnimations.userTypeClient,
      title: AppTexts.userTypeClientTitle,
      subtitle: AppTexts.userTypeClientSubtitle,
    ),
    UserRole.seller: (
      animation: AppAnimations.userTypeSeller,
      title: AppTexts.userTypeSellerTitle,
      subtitle: AppTexts.userTypeSellerSubtitle,
    ),
    UserRole.driver: (
      animation: AppAnimations.userTypeDelivery,
      title: AppTexts.userTypeDeliveryTitle,
      subtitle: AppTexts.userTypeDeliverySubtitle,
    ),
  };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SignupStepLayout(
      title: AppTexts.userTypeHeading,
      scrollable: false,
      child: Obx(() {
        final selected = controller.role.value;
        return Column(
          children: [
            // Card grid sized to fit two columns × two rows in the
            // available space; with three options the bottom-right slot
            // stays empty and the cards remain large enough to read.
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  const gap = AppSizes.gridViewSpacing;
                  // Cards are taller than wide (cardHeight = cardWidth /
                  // aspect). For 2 rows to fit in `maxHeight`, the card
                  // width is bounded by ((maxH - gap) / 2) * aspect.
                  // Using `/ aspect` here would oversize the card height
                  // and bleed the bottom row into the subtitle below.
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
                        for (final entry in _options.entries)
                          SizedBox(
                            width: cardWidth,
                            height: cardHeight,
                            child: UserTypeCard(
                              media: Lottie.asset(
                                entry.value.animation,
                                fit: BoxFit.contain,
                              ),
                              title: entry.value.title,
                              selected: selected == entry.key,
                              onTap: () => controller.selectRole(entry.key),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Selected-role subtitle — appears once a card is picked,
            // gives extra context before the user commits via Continue.
            const Gap(AppSizes.spaceBtwItems),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: selected == null
                  ? const SizedBox(
                      key: ValueKey('empty'),
                      width: double.infinity,
                    )
                  : Padding(
                      key: ValueKey(selected),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.sm,
                      ),
                      child: Text(
                        _options[selected]!.subtitle,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
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
