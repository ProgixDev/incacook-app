import 'package:flutter/material.dart';
import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/features/authentication/presentation/widgets/signup_flow/signup_kyc_id_form.dart';
import 'package:incacook/features/authentication/presentation/widgets/signup_flow/signup_step_layout.dart';

class DriverKycIdPage extends StatelessWidget {
  const DriverKycIdPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SignupStepLayout(
      title: AppTexts.signupKycIdTitle,
      description: AppTexts.signupKycIdSubtitle,
      child: SignupKycIdForm(),
    );
  }
}
