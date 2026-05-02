import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:homemade/core/common/widgets/appbar/appbar.dart';
import 'package:homemade/core/constants/animations.dart';
import 'package:homemade/core/constants/sizes.dart';
import 'package:homemade/core/constants/text_strings.dart';
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

    return Scaffold(
      appBar: const CustomAppBar(showBackArrow: true),
      body: SafeArea(
        child: Column(
          children: [
            //* heading
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.defaultSpace,
              ),
              child: Column(
                children: [
                  Text(
                    AppTexts.userTypeHeading,
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
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
                      final cardWidth = (constraints.maxWidth - gap) / 2;
                      final cardHeight = cardWidth / aspect;

                      return SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
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
                                  onTap: () => controller.selectUserType(type),
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
            Obx(
              () => controller.selectedUserType.value == null
                  ? const SizedBox.shrink()
                  : Text(
                      _options[controller.selectedUserType.value]!.subtitle,
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
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
    );
  }
}
