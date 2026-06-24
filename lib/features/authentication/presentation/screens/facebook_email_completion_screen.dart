import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';

import 'package:incacook/core/common/styles/loaders.dart';
import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/core/network/api_response.dart';
import 'package:incacook/features/authentication/data/repositories/auth_repository.dart';

/// Fallback for a Facebook login whose provider returned **no email** and for
/// which no Supabase session was created. Two steps, both via the PUBLIC
/// `/v1/auth/social/email/*` endpoints (no bearer needed):
///
///   1. Email — the user enters an address; we send a 6-digit OTP by e-mail.
///   2. OTP — the user enters the code; on success the backend returns a fresh
///      (email-verified) session which the repository persists, and the screen
///      pops `true` so [WelcomeController] continues to the same destination as
///      a normal social login (onboarding if no profile, home if complete).
///
/// Cancel/back returns to the login screen (`false`). Never logs the e-mail,
/// the OTP code, or tokens.
class FacebookEmailCompletionScreen extends StatefulWidget {
  const FacebookEmailCompletionScreen({super.key});

  @override
  State<FacebookEmailCompletionScreen> createState() =>
      _FacebookEmailCompletionScreenState();
}

class _FacebookEmailCompletionScreenState
    extends State<FacebookEmailCompletionScreen> {
  final AuthRepository _auth = AuthRepository.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  bool _codeSent = false;
  bool _busy = false;
  bool _verified = false; // guards against double-completion
  String _email = '';

  static final RegExp _emailRe = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  // --------------------------------------------------------------------------
  // Step 1 — send the code
  // --------------------------------------------------------------------------
  Future<void> _sendCode() async {
    if (_busy) return;
    final email = _emailController.text.trim();
    debugPrint('[Auth][Facebook] manual email submitted');
    if (!_emailRe.hasMatch(email)) {
      CustomLoaders.warningSnackBar(
        title: AppTexts.fbEmailStepTitle,
        message: AppTexts.fbEmailInvalid,
      );
      return;
    }
    setState(() => _busy = true);
    try {
      await _auth.requestSocialEmailOtp(email);
      debugPrint('[Auth][Facebook] verification code requested');
      if (!mounted) return;
      setState(() {
        _email = email;
        _codeSent = true;
        _otpController.clear();
      });
      CustomLoaders.successSnackBar(
        title: AppTexts.fbOtpStepTitle,
        message: AppTexts.fbEmailCodeSent,
      );
    } on ApiFailure catch (e) {
      // Surfaces the backend message verbatim, incl. the 409 conflict
      // "Cette adresse e-mail est déjà utilisée par un autre compte."
      CustomLoaders.errorSnackBar(
        title: AppTexts.fbEmailStepTitle,
        message: e.message.isNotEmpty ? e.message : AppTexts.fbEmailGenericError,
      );
    } catch (_) {
      CustomLoaders.errorSnackBar(
        title: AppTexts.fbEmailStepTitle,
        message: AppTexts.fbEmailGenericError,
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  // --------------------------------------------------------------------------
  // Step 2 — verify the code
  // --------------------------------------------------------------------------
  Future<void> _verifyCode() async {
    if (_busy || _verified) return;
    final code = _otpController.text.trim();
    if (code.length < 6) return;
    setState(() => _busy = true);
    try {
      // On success the repository persists the new (email-verified) session.
      await _auth.verifySocialEmailOtp(email: _email, code: code);
      _verified = true;
      debugPrint('[Auth][Facebook] manual email verified');
      if (!mounted) return;
      CustomLoaders.successSnackBar(
        title: AppTexts.fbOtpStepTitle,
        message: AppTexts.fbEmailVerifiedSuccess,
      );
      Get.back<bool>(result: true);
    } on ApiFailure catch (e) {
      debugPrint('[Auth][Facebook] manual email verification failed');
      CustomLoaders.errorSnackBar(
        title: AppTexts.fbOtpStepTitle,
        message: e.message.isNotEmpty ? e.message : AppTexts.fbEmailInvalidCode,
      );
    } catch (_) {
      debugPrint('[Auth][Facebook] manual email verification failed');
      CustomLoaders.errorSnackBar(
        title: AppTexts.fbOtpStepTitle,
        message: AppTexts.fbEmailGenericError,
      );
    } finally {
      if (mounted && !_verified) setState(() => _busy = false);
    }
  }

  // --------------------------------------------------------------------------
  // UI
  // --------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_codeSent ? AppTexts.fbOtpStepTitle : AppTexts.fbEmailStepTitle),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.lg,
            vertical: AppSizes.md,
          ),
          child: _codeSent ? _buildOtpStep(context) : _buildEmailStep(context),
        ),
      ),
    );
  }

  Widget _buildEmailStep(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppTexts.fbEmailStepMessage, style: textTheme.bodyMedium),
        const Gap(AppSizes.lg),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          autocorrect: false,
          enabled: !_busy,
          decoration: const InputDecoration(labelText: AppTexts.fbEmailLabel),
          onSubmitted: (_) => _sendCode(),
        ),
        const Gap(AppSizes.lg),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _busy ? null : _sendCode,
            child: _busy
                ? const _ButtonSpinner()
                : const Text(AppTexts.fbEmailSendCodeCta),
          ),
        ),
        const Gap(AppSizes.xs),
        Center(
          child: TextButton(
            onPressed: _busy ? null : () => Get.back<bool>(result: false),
            child: const Text(AppTexts.fbEmailCancelCta),
          ),
        ),
      ],
    );
  }

  Widget _buildOtpStep(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppTexts.fbOtpStepMessage, style: textTheme.bodyMedium),
        const Gap(AppSizes.md),
        Pinput(
          length: 6,
          controller: _otpController,
          enabled: !_busy,
          onCompleted: (_) => _verifyCode(),
        ),
        const Gap(AppSizes.lg),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _busy ? null : _verifyCode,
            child: _busy
                ? const _ButtonSpinner()
                : const Text(AppTexts.fbOtpVerifyCta),
          ),
        ),
        const Gap(AppSizes.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: _busy
                  ? null
                  : () => setState(() => _codeSent = false),
              child: const Text(AppTexts.fbEmailChangeCta),
            ),
            TextButton(
              onPressed: _busy ? null : _sendCode,
              child: const Text(AppTexts.fbOtpResendCta),
            ),
          ],
        ),
      ],
    );
  }
}

class _ButtonSpinner extends StatelessWidget {
  const _ButtonSpinner();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
    );
  }
}
