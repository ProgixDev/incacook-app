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
import 'package:incacook/features/authentication/presentation/widgets/login_form.dart';
import 'package:incacook/features/authentication/presentation/widgets/login_header.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
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

                  //* devider
                  FormDivider(dividerText: AppTexts.orSignInWith.capitalize!),
                  const Gap(AppSizes.spaceBtwSections),

                  //* footer
                  const SocialButtons(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
