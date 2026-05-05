import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:homemade/core/common/widgets/appbar/appbar.dart';
import 'package:homemade/core/constants/animations.dart';
import 'package:homemade/core/constants/sizes.dart';
import 'package:homemade/core/constants/text_strings.dart';
import 'package:homemade/core/utils/device/device_utility.dart';
import 'package:homemade/core/widgets/decor/decor_blob.dart';
import 'package:homemade/features/authentication/controllers/user_type_selection_controller.dart';
import 'package:homemade/features/authentication/domain/user_type.dart';
import 'package:homemade/features/authentication/presentation/widgets/user_type_card.dart';

class UserTypeSelectionScreen extends StatelessWidget {
  const UserTypeSelectionScreen({super.key});

  static const Map<
    UserType,
    ({String animation, String title, String subtitle})
  >
  _options = {
    UserType.client: (
      animation: AppAnimations.userTypeClient,
      title: AppTexts.userTypeClientTitle,
      subtitle: AppTexts.userTypeClientSubtitle,
    ),
    UserType.seller: (
      animation: AppAnimations.userTypeSeller,
      title: AppTexts.userTypeSellerTitle,
      subtitle: AppTexts.userTypeSellerSubtitle,
    ),
    UserType.delivery: (
      animation: AppAnimations.userTypeDelivery,
      title: AppTexts.userTypeDeliveryTitle,
      subtitle: AppTexts.userTypeDeliverySubtitle,
    ),
  };

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UserTypeSelectionController());
    final scheme = Theme.of(context).colorScheme;
    final appBarHeight = DeviceUtils.getAppBarHeight();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const CustomAppBar(showBackArrow: true),
      body: Stack(
        children: [
          //* decorative top-right blob — gives the frosted cards something
          //* to blur over so the glass effect actually reads.
          const Positioned(
            top: -8,
            right: -16,
            child: IgnorePointer(child: DecorBlob()),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.only(top: appBarHeight),
              child: Column(
                children: [
                  //* heading
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.defaultSpace,
                    ),
                    child: Text(
                      AppTexts.userTypeHeading,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const Gap(AppSizes.spaceBtwSections),

                  //* user type grid
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.defaultSpace,
                      ),
                      child: Obx(() {
                        final selected = controller.selectedUserType.value;
                        return LayoutBuilder(
                          builder: (context, constraints) {
                            const gap = AppSizes.gridViewSpacing;
                            const aspect = 0.78;
                            //* size cards so 2 columns × 2 rows fit without
                            //* scrolling — pick the more constrained axis.
                            final widthLimited =
                                (constraints.maxWidth - gap) / 2;
                            final heightLimited =
                                ((constraints.maxHeight - gap) / 2) * aspect;
                            final cardWidth = math.min(
                              widthLimited,
                              heightLimited,
                            );
                            final cardHeight = cardWidth / aspect;

                            return Center(
                              child: Wrap(
                                alignment: WrapAlignment.center,
                                spacing: gap,
                                runSpacing: gap,
                                children: [
                                  for (final type
                                      in UserTypeSelectionController.userTypes)
                                    SizedBox(
                                      width: cardWidth,
                                      height: cardHeight,
                                      child: UserTypeCard(
                                        animation: _options[type]!.animation,
                                        title: _options[type]!.title,
                                        selected: selected == type,
                                        onTap: () =>
                                            controller.selectUserType(type),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        );
                      }),
                    ),
                  ),

                  const Gap(AppSizes.spaceBtwItems),

                  //* selected-type subtitle (muted for hierarchy under the
                  //* heading, becomes visible only after a selection).
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.defaultSpace,
                    ),
                    child: Obx(
                      () => controller.selectedUserType.value == null
                          ? const SizedBox.shrink()
                          : Text(
                              _options[controller.selectedUserType.value]!
                                  .subtitle,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: scheme.onSurfaceVariant),
                              textAlign: TextAlign.center,
                            ),
                    ),
                  ),

                  //* continue button
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSizes.defaultSpace,
                      AppSizes.spaceBtwItems,
                      AppSizes.defaultSpace,
                      AppSizes.defaultSpace,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: Obx(
                        () => ElevatedButton(
                          onPressed: controller.selectedUserType.value == null
                              ? null
                              : controller.continueToSignup,
                          child: const Text(AppTexts.sayContinue),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
