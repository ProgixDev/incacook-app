import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/features/authentication/controllers/signup_flow_controller.dart';
import 'package:incacook/features/authentication/presentation/widgets/signup_flow/signup_image_picker.dart';

/// Shared selfie capture used by both seller and driver KYC pages. The
/// underlying picker is forced to camera-only so this can never accept a
/// gallery upload — important for fraud prevention in production.
class SignupKycSelfieForm extends StatelessWidget {
  const SignupKycSelfieForm({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SignupFlowController>();
    final scheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Container(
          width: 200,
          height: 240,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            borderRadius: const BorderRadius.all(Radius.elliptical(140, 180)),
            color: scheme.primary.withValues(alpha: 0.06),
            border: Border.all(
              color: scheme.primary.withValues(alpha: 0.45),
              width: 1.5,
            ),
          ),
          child: Obx(() {
            if (controller.selfiePath.value.isNotEmpty) {
              return Icon(
                Icons.check_circle,
                color: scheme.primary,
                size: 64,
              );
            }
            return Icon(
              Icons.face_outlined,
              size: 96,
              color: scheme.primary.withValues(alpha: 0.7),
            );
          }),
        ),
        const Gap(AppSizes.lg),
        Obx(() {
          final has = controller.selfiePath.value.isNotEmpty;
          return SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () => _SelfiePicker.open(controller),
              icon: const Icon(Icons.photo_camera_outlined),
              label: Text(
                has
                    ? AppTexts.signupKycSelfieRetakeCta
                    : AppTexts.signupKycSelfieCta,
              ),
            ),
          );
        }),
        const Gap(AppSizes.sm),
        Offstage(
          offstage: true,
          child: SignupImagePicker(
            path: controller.selfiePath.value,
            onChanged: (p) => controller.selfiePath.value = p,
            cameraOnly: true,
          ),
        ),
        Text(
          AppTexts.signupKycSelfieFooter,
          style: TextStyle(
            color: scheme.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

/// Stub camera trigger — production camera plugin would replace this.
class _SelfiePicker {
  static void open(SignupFlowController controller) {
    controller.selfiePath.value =
        'stub://camera/${DateTime.now().millisecondsSinceEpoch}';
  }
}
