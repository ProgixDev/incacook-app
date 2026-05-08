import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/features/authentication/controllers/signup_flow_controller.dart';
import 'package:incacook/features/authentication/presentation/widgets/signup_flow/signup_step_layout.dart';

/// Biometric activation. Production wiring would call `local_auth` —
/// stubbed here as a 600ms simulated prompt that always succeeds.
class BiometricSetupPage extends StatelessWidget {
  const BiometricSetupPage({super.key});

  IconData get _icon => Platform.isIOS ? Icons.face : Icons.fingerprint;

  Future<void> _activate(BuildContext context) async {
    final controller = Get.find<SignupFlowController>();
    final messenger = ScaffoldMessenger.of(context);
    await Future<void>.delayed(const Duration(milliseconds: 600));
    controller.biometricEnabled.value = true;
    messenger.showSnackBar(
      const SnackBar(content: Text(AppTexts.signupBiometricEnabledToast)),
    );
    controller.nextPage();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SignupStepLayout(
      title: AppTexts.signupBiometricTitle,
      description: AppTexts.signupBiometricSubtitle,
      child: Column(
        children: [
          const Gap(AppSizes.lg),
          _PulsingIcon(icon: _icon),
          const Gap(AppSizes.xl),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () => _activate(context),
              icon: Icon(_icon, color: Colors.white),
              label: const Text(AppTexts.signupBiometricCta),
            ),
          ),
          const Gap(AppSizes.md),
          Text(
            AppTexts.signupBiometricFooter,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: scheme.onSurfaceVariant,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _PulsingIcon extends StatefulWidget {
  const _PulsingIcon({required this.icon});

  final IconData icon;

  @override
  State<_PulsingIcon> createState() => _PulsingIconState();
}

class _PulsingIconState extends State<_PulsingIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, _) {
        final t = Curves.easeInOut.transform(_ctrl.value);
        return Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: scheme.primary.withValues(alpha: 0.10 + 0.04 * t),
            boxShadow: [
              BoxShadow(
                color: scheme.primary.withValues(alpha: 0.18 * (1 - t)),
                blurRadius: 30,
                spreadRadius: 14 * t,
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Icon(widget.icon, size: 56, color: scheme.primary),
        );
      },
    );
  }
}
