import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:homemade/core/constants/sizes.dart';
import 'package:homemade/core/constants/text_strings.dart';
import 'package:homemade/core/utils/validators/validators.dart';
import 'package:homemade/features/authentication/controllers/forget_password_contorller.dart';

class ForgetPasswordScreen extends StatelessWidget {
  const ForgetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ForgetPasswordController());
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //* heading
              Text(
                AppTexts.forgetPasswordTitle,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const Gap(AppSizes.spaceBtwItems),
              Text(
                AppTexts.forgetPasswordSubTitle,
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const Gap(AppSizes.spaceBtwSections * 2),

              //* text field
              Form(
                key: controller.forgetPasswordFormKey,
                child: TextFormField(
                  controller: controller.email,
                  validator: CustomValidator.validateEmail,
                  decoration: const InputDecoration(
                    labelText: AppTexts.email,
                    prefixIcon: Icon(Iconsax.direct_right),
                  ),
                ),
              ),
              const Gap(AppSizes.spaceBtwSections),

              //* submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  child: const Text(AppTexts.submit),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
