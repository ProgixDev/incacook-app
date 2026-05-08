import 'package:flutter/material.dart';
import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/features/authentication/presentation/widgets/signup_flow/signup_kyc_selfie_form.dart';
import 'package:incacook/features/authentication/presentation/widgets/signup_flow/signup_step_layout.dart';

class DriverKycSelfiePage extends StatelessWidget {
  const DriverKycSelfiePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SignupStepLayout(
      title: AppTexts.signupKycSelfieTitle,
      description: AppTexts.signupKycSelfieSubtitle,
      child: Center(child: SignupKycSelfieForm()),
    );
  }
}
