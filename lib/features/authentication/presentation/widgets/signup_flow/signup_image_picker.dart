import 'dart:io';

import 'package:flutter/material.dart';
import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/core/utils/popups/blurred_modal_sheet.dart';

/// Image picker tile used for profile photos and KYC document uploads.
/// Tap opens a frosted modal sheet with camera / gallery / remove options.
///
/// External integrations are stubbed: `path` is set to a deterministic
/// fake path (`stub://camera/<ts>` or `stub://gallery/<ts>`) so the rest
/// of the flow can validate "has a path" without a real plugin.
enum SignupImagePickerVariant { circular, rectangular }

class SignupImagePicker extends StatelessWidget {
  const SignupImagePicker({
    super.key,
    required this.path,
    required this.onChanged,
    this.label,
    this.helper,
    this.variant = SignupImagePickerVariant.circular,
    this.size = 96,
    this.cameraOnly = false,
  });

  final String path;
  final ValueChanged<String> onChanged;
  final String? label;
  final String? helper;
  final SignupImagePickerVariant variant;
  final double size;

  /// When true, the action sheet hides the gallery option (live capture
  /// only) — used for the selfie page.
  final bool cameraOnly;

  bool get _hasImage => path.isNotEmpty;
  bool get _isLocalFile => _hasImage && !path.startsWith('stub://');

  Future<void> _open(BuildContext context) async {
    await showBlurredModalBottomSheet<void>(
      context: context,
      builder: (ctx) {
        final scheme = Theme.of(ctx).colorScheme;
        return SafeArea(
          top: false,
          child: Container(
            margin: const EdgeInsets.all(AppSizes.sm + 4),
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg + 4),
            ),
            padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _SheetTile(
                  icon: Icons.photo_camera_outlined,
                  label: AppTexts.signupImagePickerCamera,
                  onTap: () {
                    Navigator.of(ctx).pop();
                    onChanged(
                      'stub://camera/${DateTime.now().millisecondsSinceEpoch}',
                    );
                  },
                ),
                if (!cameraOnly)
                  _SheetTile(
                    icon: Icons.photo_library_outlined,
                    label: AppTexts.signupImagePickerGallery,
                    onTap: () {
                      Navigator.of(ctx).pop();
                      onChanged(
                        'stub://gallery/${DateTime.now().millisecondsSinceEpoch}',
                      );
                    },
                  ),
                if (_hasImage)
                  _SheetTile(
                    icon: Icons.delete_outline,
                    label: AppTexts.signupImagePickerRemove,
                    destructive: true,
                    onTap: () {
                      Navigator.of(ctx).pop();
                      onChanged('');
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isCircular = variant == SignupImagePickerVariant.circular;
    final radius = isCircular ? size / 2 : 12.0;

    final placeholder = Container(
      width: isCircular ? size : double.infinity,
      height: size,
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.06),
        shape: isCircular ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: isCircular ? null : BorderRadius.circular(radius),
        border: Border.all(
          color: scheme.primary.withValues(alpha: 0.45),
          width: 1.4,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_a_photo_outlined,
            size: 24,
            color: scheme.primary,
          ),
        ],
      ),
    );

    Widget body;
    if (_hasImage) {
      final image = _isLocalFile
          ? Image.file(File(path), fit: BoxFit.cover)
          : Container(
              color: scheme.primary.withValues(alpha: 0.12),
              alignment: Alignment.center,
              child: Icon(Icons.check_circle, color: scheme.primary, size: 32),
            );
      body = SizedBox(
        width: isCircular ? size : double.infinity,
        height: size,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: image,
        ),
      );
    } else {
      body = placeholder;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: AppSizes.sm),
        ],
        Stack(
          children: [
            InkWell(
              onTap: () => _open(context),
              borderRadius: BorderRadius.circular(radius),
              child: body,
            ),
            if (_hasImage)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: scheme.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: scheme.outlineVariant),
                  ),
                  child: Icon(Icons.edit, size: 14, color: scheme.onSurface),
                ),
              ),
          ],
        ),
        if (helper != null) ...[
          const SizedBox(height: AppSizes.sm),
          Text(
            helper!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
          ),
        ],
      ],
    );
  }
}

class _SheetTile extends StatelessWidget {
  const _SheetTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.destructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = destructive ? scheme.error : scheme.onSurface;
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label, style: TextStyle(color: color)),
      onTap: onTap,
    );
  }
}
