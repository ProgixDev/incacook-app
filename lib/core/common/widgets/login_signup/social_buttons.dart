import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:homemade/core/constants/colors.dart';
import 'package:homemade/core/constants/image_strings.dart';
import 'package:homemade/core/constants/sizes.dart';

class SocialButtons extends StatelessWidget {
  const SocialButtons({super.key});

  @override
  Widget build(BuildContext context) {
    // final controller = Get.put(LoginController());
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.grey),
            borderRadius: BorderRadius.circular(100),
          ),
          child: IconButton(
            // onPressed: () => controller.googleSignIn(),
            onPressed: () {},
            icon: const Image(
              image: AssetImage(AppImages.googleLogo),
              height: AppSizes.iconMd,
              width: AppSizes.iconMd,
            ),
          ),
        ),
        const Gap(AppSizes.spaceBtwItems),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.grey),
            borderRadius: BorderRadius.circular(100),
          ),
          child: IconButton(
            onPressed: () {},
            icon: const Image(
              image: AssetImage(AppImages.facebookLogo),
              height: AppSizes.iconMd,
              width: AppSizes.iconMd,
            ),
          ),
        ),
      ],
    );
  }
}
