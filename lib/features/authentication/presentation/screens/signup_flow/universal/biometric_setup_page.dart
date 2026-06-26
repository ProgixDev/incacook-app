import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/core/services/biometric_auth_service.dart';
import 'package:incacook/core/services/biometric_preference.dart';
import 'package:incacook/features/authentication/controllers/signup_flow_controller.dart';
import 'package:incacook/features/authentication/presentation/widgets/signup_flow/signup_step_layout.dart';

/// Biometric activation — enables the OS-level "Connexion biométrique" via
/// `local_auth` (Face ID / Touch ID / fingerprint). This does NOT open the
/// camera and is separate from the signup KYC selfie ("Vérification du visage").
///
/// The user can always continue without enabling it (so signup is never blocked
/// on a device with no biometrics). Never logs biometric data.
class BiometricSetupPage extends StatefulWidget {
  const BiometricSetupPage({super.key});

  @override
  State<BiometricSetupPage> createState() => _BiometricSetupPageState();
}

class _BiometricSetupPageState extends State<BiometricSetupPage> {
  final BiometricAuthService _biometric = BiometricAuthService();
  bool _busy = false;
  bool? _supported; // null = still checking

  IconData get _icon => Platform.isIOS ? Icons.face : Icons.fingerprint;

  @override
  void initState() {
    super.initState();
    _checkSupport();
  }

  Future<void> _checkSupport() async {
    final supported = await _biometric.isSupported();
    if (mounted) setState(() => _supported = supported);
  }

  /// Runs a real biometric prompt; only on success do we mark the account as
  /// biometric-enabled (persisted so the login screen can offer the button).
  Future<void> _activate() async {
    if (_busy) return;
    final controller = Get.find<SignupFlowController>();
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    try {
      final ok = await _biometric.authenticate(reason: AppTexts.biometricSetupReason);
      if (!ok) {
        messenger.showSnackBar(
          const SnackBar(content: Text(AppTexts.biometricFailed)),
        );
        return;
      }
      controller.biometricEnabled.value = true;
      await BiometricPreference.setEnabled(true);
      messenger.showSnackBar(
        const SnackBar(content: Text(AppTexts.signupBiometricEnabledToast)),
      );
      controller.nextPage();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Continue without enabling biometrics (or when the device has none).
  void _skip() {
    final controller = Get.find<SignupFlowController>();
    controller.biometricEnabled.value = false;
    controller.nextPage();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final supported = _supported;
    return SignupStepLayout(
      title: AppTexts.signupBiometricTitle,
      description: AppTexts.signupBiometricSubtitle,
      child: Column(
        children: [
          const Gap(AppSizes.lg),
          _PulsingIcon(icon: _icon),
          const Gap(AppSizes.xl),
          if (supported == false) ...[
            // No enrolled biometrics on this device — let the user continue.
            Text(
              AppTexts.biometricUnavailable,
              textAlign: TextAlign.center,
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
            const Gap(AppSizes.md),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _skip,
                child: const Text(AppTexts.biometricContinueCta),
              ),
            ),
          ] else ...[
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: (supported == null || _busy) ? null : _activate,
                icon: _busy
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(_icon, color: Colors.white),
                label: const Text(AppTexts.signupBiometricCta),
              ),
            ),
            const Gap(AppSizes.sm),
            TextButton(
              onPressed: _busy ? null : _skip,
              child: const Text(AppTexts.biometricLaterCta),
            ),
          ],
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
