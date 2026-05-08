import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:incacook/core/common/widgets/appbar/appbar.dart';
import 'package:incacook/core/common/widgets/login_signup/form_divider.dart';
import 'package:incacook/core/common/widgets/login_signup/social_buttons.dart';
import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/core/utils/device/device_utility.dart';
import 'package:incacook/core/widgets/decor/decor_blob.dart';
import 'package:incacook/features/authentication/domain/user_type.dart';
import 'package:incacook/features/authentication/presentation/widgets/signup_form.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key, required this.userType});

  final UserType userType;

  @override
  Widget build(BuildContext context) {
    final appBarHeight = DeviceUtils.getAppBarHeight();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const CustomAppBar(showBackArrow: true),
      body: Stack(
        children: [
          //* decorative top-right blob — gives the frosted fields something
          //* to blur over so the glass effect actually reads.
          const Positioned(
            top: -8,
            right: -16,
            child: IgnorePointer(child: DecorBlob()),
          ),
          SafeArea(
            //* SingleChildScrollView only kicks in when the keyboard reduces
            //* the viewport — when everything fits, there's nothing to scroll
            //* and the page visually behaves as a non-scrolling screen.
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                AppSizes.defaultSpace,
                appBarHeight + AppSizes.sm,
                AppSizes.defaultSpace,
                AppSizes.defaultSpace,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //* title
                  Text(
                    AppTexts.signUpTitile,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Gap(AppSizes.md),

                  //* form
                  SignupForm(userType: userType),
                  const Gap(AppSizes.md),

                  //* divider
                  FormDivider(dividerText: AppTexts.orSignUpWith.capitalize!),
                  const Gap(AppSizes.md),

                  //* social buttons
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
