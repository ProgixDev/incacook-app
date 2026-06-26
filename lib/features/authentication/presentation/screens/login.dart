import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:incacook/core/common/styles/spacing_styles.dart';
import 'package:incacook/core/common/widgets/appbar/appbar.dart';
import 'package:incacook/core/common/widgets/login_signup/form_divider.dart';
import 'package:incacook/core/common/widgets/login_signup/social_buttons.dart';
import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/core/widgets/decor/decor_blob.dart';
import 'package:incacook/features/authentication/controllers/biometric_login_controller.dart';
import 'package:incacook/features/authentication/controllers/welcome_controller.dart';
import 'package:incacook/features/authentication/presentation/widgets/login_form.dart';
import 'package:incacook/features/authentication/presentation/widgets/login_header.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Reuse the shared social-auth controller (Google + Facebook). Same
    // instance the welcome screen uses; the controller guards against
    // re-entrant taps, so the icon buttons need no per-button spinner.
    final social = Get.put(WelcomeController());
    // Optional OS-level biometric unlock — only offered when a valid session is
    // still stored AND the user opted in (see BiometricLoginController).
    final biometric = Get.put(BiometricLoginController());
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(showBackArrow: true),
      body: Stack(
        children: [
          //* decorative top-right blob — gives the frosted fields something
          //* to blur over so the glass effect actually reads.
          const Positioned(
            top: -8,
            right: -16,
            child: IgnorePointer(child: DecorBlob()),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: AppSpacingStyle.paddingWithAppBarHeight,
              child: Column(
                children: [
                  //* logo, title, subtitle
                  const LoginHeader(),

                  //* form
                  const LoginForm(),

                  //* optional biometric unlock (hidden unless a valid stored
                  //* session + opt-in + device support all hold)
                  Obx(() {
                    if (!biometric.canOffer.value) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: AppSizes.spaceBtwItems),
                      child: SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton.icon(
                          onPressed: biometric.isAuthenticating.value
                              ? null
                              : biometric.authenticate,
                          icon: biometric.isAuthenticating.value
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.fingerprint),
                          label: const Text(AppTexts.biometricLoginCta),
                        ),
                      ),
                    );
                  }),

                  //* devider
                  FormDivider(dividerText: AppTexts.orSignInWith.capitalize!),
                  const Gap(AppSizes.spaceBtwSections),

                  //* footer — disabled while any social login is in flight
                  Obx(
                    () => SocialButtons(
                      onGoogle: social.isAnySocialLoading
                          ? null
                          : social.signInWithGoogle,
                      onFacebook: social.isAnySocialLoading
                          ? null
                          : social.signInWithFacebook,
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
