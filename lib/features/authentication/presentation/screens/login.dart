import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:vinted_v2/core/common/styles/spacing_styles.dart';
import 'package:vinted_v2/core/common/widgets/login_signup/form_divider.dart';
import 'package:vinted_v2/core/common/widgets/login_signup/social_buttons.dart';
import 'package:vinted_v2/core/constants/colors.dart';
import 'package:vinted_v2/core/constants/sizes.dart';
import 'package:vinted_v2/core/constants/text_strings.dart';
import 'package:vinted_v2/features/authentication/presentation/widgets/login_form.dart';
import 'package:vinted_v2/features/authentication/presentation/widgets/login_header.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SingleChildScrollView(
        child: Padding(
          padding: AppSpacingStyle.paddingWithAppBarHeight,
          child: Column(
            children: [
              const Gap(AppSizes.spaceBtwSections),
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
    );
  }
}
