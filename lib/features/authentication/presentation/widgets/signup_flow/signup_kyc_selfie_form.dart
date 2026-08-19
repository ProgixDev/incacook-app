import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/features/authentication/controllers/signup_flow_controller.dart';
import 'package:incacook/features/authentication/data/services/face_photo_validator.dart';
import 'package:incacook/features/authentication/data/services/selfie_capture_service.dart';

/// Shared selfie capture used by both seller and driver KYC pages.
///
/// Camera-only, front-facing — never accepts a gallery upload (fraud
/// prevention). [SelfieCaptureService] validates the capture on-device
/// (face presence/framing/pose/lighting — see `face_photo_validator.dart`)
/// before uploading; a rejected photo is never uploaded and never reaches
/// `controller.selfieUrl`. This widget keeps the locally-picked `File` for
/// preview and surfaces the retry/error message inline.
class SignupKycSelfieForm extends StatefulWidget {
  const SignupKycSelfieForm({super.key});

  @override
  State<SignupKycSelfieForm> createState() => _SignupKycSelfieFormState();
}

class _SignupKycSelfieFormState extends State<SignupKycSelfieForm> {
  final SignupFlowController _controller = Get.find();

  File? _localFile;
  bool _uploading = false;
  String? _error;

  Future<void> _takeSelfie() async {
    setState(() {
      _uploading = true;
      _error = null;
    });
    try {
      // A KYC selfie must be a live, on-device-validated capture — the
      // service is camera-only/front-facing and never uploads (or lets
      // `selfieUrl` get populated for) a rejected photo.
      final outcome = await SelfieCaptureService().captureValidateAndUpload();
      if (!mounted) return;
      switch (outcome) {
        case SelfieCaptureCancelled():
          setState(() => _uploading = false);
        case SelfieCaptureRejected(:final reason):
          setState(() {
            _uploading = false;
            _error = reason.message;
          });
        case SelfieCaptureFailed(:final message):
          setState(() {
            _uploading = false;
            _error = message;
          });
        case SelfieCaptureUploaded(:final file, :final path):
          setState(() {
            _localFile = file;
            _uploading = false;
          });
          _controller.selfieUrl.value = path;
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _uploading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Container(
          width: 200,
          height: 240,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            borderRadius: const BorderRadius.all(Radius.elliptical(140, 180)),
            color: scheme.primary.withValues(alpha: 0.06),
            border: Border.all(
              color: scheme.primary.withValues(alpha: 0.45),
              width: 1.5,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (_localFile != null)
                Positioned.fill(
                  child: Image.file(_localFile!, fit: BoxFit.cover),
                )
              else
                Obx(() {
                  if (_controller.selfieUrl.value.isNotEmpty) {
                    // Server path with no local preview — happens on a
                    // form rebuild after the local file was lost (e.g.
                    // navigated away and back).
                    return Icon(
                      Icons.check_circle,
                      color: scheme.primary,
                      size: 64,
                    );
                  }
                  return Icon(
                    Icons.face_outlined,
                    size: 96,
                    color: scheme.primary.withValues(alpha: 0.7),
                  );
                }),
              if (_uploading)
                Container(
                  color: Colors.black.withValues(alpha: 0.35),
                  alignment: Alignment.center,
                  child: const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const Gap(AppSizes.lg),
        Obx(() {
          final has =
              _localFile != null || _controller.selfieUrl.value.isNotEmpty;
          return SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _uploading ? null : _takeSelfie,
              icon: const Icon(Icons.photo_camera_outlined),
              label: Text(
                has
                    ? AppTexts.signupKycSelfieRetakeCta
                    : AppTexts.signupKycSelfieCta,
              ),
            ),
          );
        }),
        if (_error != null) ...[
          const Gap(AppSizes.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 14, color: scheme.error),
              const Gap(AppSizes.xs),
              Flexible(
                child: Text(
                  _error!,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: scheme.error),
                ),
              ),
            ],
          ),
        ],
        const Gap(AppSizes.sm),
        Text(
          AppTexts.signupKycSelfieFooter,
          style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12),
        ),
      ],
    );
  }
}
