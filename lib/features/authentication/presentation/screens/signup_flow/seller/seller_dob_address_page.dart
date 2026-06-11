import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/core/utils/device/device_utility.dart';
import 'package:incacook/core/widgets/effects/frosted_surface.dart';
import 'package:incacook/core/models/auth/upload_info.dart';
import 'package:incacook/features/authentication/controllers/signup_flow_controller.dart';
import 'package:incacook/features/authentication/data/models/user_role.dart';
import 'package:incacook/features/authentication/presentation/widgets/signup_flow/signup_address_picker.dart';
import 'package:incacook/features/authentication/presentation/widgets/signup_flow/signup_image_picker.dart';
import 'package:incacook/features/authentication/presentation/widgets/signup_flow/signup_step_layout.dart';

class SellerDobAddressPage extends GetView<SignupFlowController> {
  const SellerDobAddressPage({super.key});

  Future<void> _pickDob(
    BuildContext context,
    SignupFlowController controller,
  ) async {
    final now = DateTime.now();
    final initial =
        controller.dateOfBirth.value ??
        DateTime(now.year - 25, now.month, now.day);
    // CupertinoDatePicker has no built-in commit action — track the
    // wheel's running value here and only commit when the user taps
    // "Terminé" so closing via the modal scrim doesn't auto-save.
    var pending = initial;
    final scheme = Theme.of(context).colorScheme;

    await showCupertinoModalPopup<void>(
      context: context,
      builder: (ctx) {
        return Container(
          height: DeviceUtils.getScreenHeight(context) * 0.4,
          color: scheme.surface,
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.xs),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: Text(
                          AppTexts.signupExitCancel,
                          style: TextStyle(color: scheme.onSurfaceVariant),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          controller.dateOfBirth.value = pending;
                          Navigator.of(ctx).pop();
                        },
                        child: Text(
                          AppTexts.sayDone,
                          style: TextStyle(
                            color: scheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(
                  height: 1,
                  color: scheme.outlineVariant.withValues(alpha: 0.5),
                ),
                Expanded(
                  child: CupertinoTheme(
                    data: CupertinoThemeData(
                      brightness: Theme.of(context).brightness,
                      textTheme: CupertinoTextThemeData(
                        dateTimePickerTextStyle: TextStyle(
                          fontSize: 18,
                          color: scheme.onSurface,
                        ),
                      ),
                    ),
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.date,
                      initialDateTime: initial,
                      minimumDate: DateTime(now.year - 100),
                      maximumDate: DateTime(now.year - 16, now.month, now.day),
                      onDateTimeChanged: (d) => pending = d,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SignupStepLayout(
      title: AppTexts.signupSellerDobAddressTitle,
      description: AppTexts.signupSellerDobAddressSubtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //* Driver-only profile photo (optional). This page is shared with
          //  the seller flow, but sellers upload their photo on the dedicated
          //  sellerProfile step — so the avatar slot only shows for drivers.
          if (controller.role.value == UserRole.driver) ...[
            Center(
              child: Obx(() => SignupImagePicker(
                    path: controller.avatarPath.value,
                    purpose: UploadPurpose.avatar,
                    helper: 'Photo de profil (optionnel)',
                    onChanged: (p) => controller.avatarPath.value = p,
                  )),
            ),
            const Gap(AppSizes.lg),
          ],
          Text(
            AppTexts.signupSellerDobLabel,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w500),
          ),
          const Gap(AppSizes.xs + 2),
          Obx(() {
            final dob = controller.dateOfBirth.value;
            final formatted = dob == null
                ? AppTexts.signupSellerDobPlaceholder
                : '${dob.day.toString().padLeft(2, '0')}/${dob.month.toString().padLeft(2, '0')}/${dob.year}';
            // Match the SignupTextField visual exactly: pill FrostedSurface
            // + theme content padding (16h / 14v from the global
            // InputDecorationTheme), brand-green leading icon, hint-style
            // grey for the placeholder.
            return GestureDetector(
              onTap: () => _pickDob(context, controller),
              behavior: HitTestBehavior.opaque,
              child: FrostedSurface(
                borderRadius: BorderRadius.circular(999),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.md,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    Icon(Iconsax.calendar, size: 20, color: scheme.primary),
                    const Gap(AppSizes.sm + 4),
                    Expanded(
                      child: Text(
                        formatted,
                        style: TextStyle(
                          color: dob == null
                              ? scheme.onSurfaceVariant
                              : scheme.onSurface,
                        ),
                      ),
                    ),
                    if (dob != null && !controller.isAdult)
                      Padding(
                        padding: const EdgeInsets.only(left: AppSizes.sm),
                        child: Text(
                          AppTexts.signupSellerDobAdultRequired,
                          style: TextStyle(color: scheme.error, fontSize: 12),
                        ),
                      ),
                  ],
                ),
              ),
            );
          }),
          const Gap(AppSizes.lg),
          Text(
            AppTexts.signupSellerPickupLabel,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w500),
          ),
          const Gap(AppSizes.xs + 2),
          Obx(
            () => SignupAddressPicker(
              value: controller.pickupAddress.value,
              onChanged: (a) => controller.pickupAddress.value = a,
              hint: AppTexts.signupSellerPickupHint,
            ),
          ),
          const Gap(AppSizes.sm),
          Text(
            AppTexts.signupSellerPickupHelper,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
