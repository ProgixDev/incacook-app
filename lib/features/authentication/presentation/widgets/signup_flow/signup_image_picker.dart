import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/core/models/auth/upload_info.dart';
import 'package:incacook/core/network/api_response.dart';
import 'package:incacook/core/utils/popups/blurred_modal_sheet.dart';
import 'package:incacook/features/authentication/data/models/requests/create_upload_request.dart';
import 'package:incacook/features/authentication/data/repositories/uploads_repository.dart';
import 'package:incacook/features/authentication/data/services/upload_picker.dart';

/// Image picker tile used for profile photos and KYC document uploads.
///
/// Performs the §3.19 two-step upload on every pick:
///   1. `POST /v1/uploads` returns a signed Supabase Storage URL.
///   2. The picked file's bytes are PUT directly to that URL.
///   3. The returned storage `path` is handed back to the parent via
///      [onChanged] — the controller then sends that path to whichever
///      resource endpoint owns the column (avatar on /sellers/me/profile,
///      fileUrl on /kyc/documents, etc.).
///
/// Local preview comes from the picked [File] for instant feedback; the
/// committed server `path` is what survives a screen rebuild.
enum SignupImagePickerVariant { circular, rectangular }

class SignupImagePicker extends StatefulWidget {
  const SignupImagePicker({
    super.key,
    required this.path,
    required this.onChanged,
    required this.purpose,
    this.label,
    this.helper,
    this.variant = SignupImagePickerVariant.circular,
    this.size = 96,
    this.cameraOnly = false,
  });

  /// Storage path returned from `/v1/uploads` (e.g. `avatars/<uid>/01K…`),
  /// or empty when nothing has been uploaded yet. NOT a filesystem path.
  final String path;

  /// Fired with the new storage path on successful upload, or with the
  /// empty string when the user clears the slot.
  final ValueChanged<String> onChanged;

  /// Which storage bucket / role gate this upload lands in. The backend
  /// rejects (403) mismatches between purpose and the caller's role
  /// — see §3.19 "Role gates".
  final UploadPurpose purpose;

  final String? label;
  final String? helper;
  final SignupImagePickerVariant variant;
  final double size;

  /// When true, the action sheet hides the gallery option (live capture
  /// only) — used for the selfie page.
  final bool cameraOnly;

  @override
  State<SignupImagePicker> createState() => _SignupImagePickerState();
}

class _SignupImagePickerState extends State<SignupImagePicker> {
  /// Local file held for preview during and after upload. Cleared when
  /// the user explicitly removes the image.
  File? _localFile;

  /// Uploading-in-flight flag — drives the overlay spinner.
  bool _uploading = false;

  /// Last upload error, if any. Tapping the retry chip re-uploads
  /// [_localFile] without re-prompting the user for a new file.
  String? _error;

  bool get _hasServerPath => widget.path.isNotEmpty;
  bool get _hasImage => _localFile != null || _hasServerPath;

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
            // Transparent Material so each ListTile paints its background and
            // ink ripple above the container's surface color instead of behind
            // it (the container's DecoratedBox would otherwise hide them).
            child: Material(
              type: MaterialType.transparency,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _SheetTile(
                    icon: Icons.photo_camera_outlined,
                    label: AppTexts.signupImagePickerCamera,
                    onTap: () {
                      Navigator.of(ctx).pop();
                      _pickAndUpload(ImageSource.camera);
                    },
                  ),
                  if (!widget.cameraOnly)
                    _SheetTile(
                      icon: Icons.photo_library_outlined,
                      label: AppTexts.signupImagePickerGallery,
                      onTap: () {
                        Navigator.of(ctx).pop();
                        _pickAndUpload(ImageSource.gallery);
                      },
                    ),
                  if (_hasImage)
                    _SheetTile(
                      icon: Icons.delete_outline,
                      label: AppTexts.signupImagePickerRemove,
                      destructive: true,
                      onTap: () {
                        Navigator.of(ctx).pop();
                        _clear();
                      },
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickAndUpload(ImageSource source) async {
    setState(() {
      _uploading = true;
      _error = null;
    });
    try {
      final result = await pickAndUploadImage(
        source: source,
        purpose: widget.purpose,
      );
      if (!mounted) return;
      if (result == null) {
        // User cancelled the system picker — drop back to whatever
        // previous state was on screen.
        setState(() => _uploading = false);
        return;
      }
      setState(() {
        _localFile = result.file;
        _uploading = false;
      });
      widget.onChanged(result.path);
    } on ApiFailure catch (e) {
      if (!mounted) return;
      setState(() {
        _uploading = false;
        _error = e.message;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _uploading = false;
        _error = e.toString();
      });
    }
  }

  /// Re-upload the already-picked [_localFile] without prompting the
  /// system picker again. Used by the "Réessayer" affordance after an
  /// upload error.
  Future<void> _retry() async {
    final file = _localFile;
    if (file == null) return;
    setState(() {
      _uploading = true;
      _error = null;
    });
    try {
      final bytes = await file.readAsBytes();
      final path = await UploadsRepository.instance.upload(
        req: CreateUploadRequest(purpose: widget.purpose),
        bytes: bytes,
      );
      if (!mounted) return;
      setState(() => _uploading = false);
      widget.onChanged(path);
    } on ApiFailure catch (e) {
      if (!mounted) return;
      setState(() {
        _uploading = false;
        _error = e.message;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _uploading = false;
        _error = e.toString();
      });
    }
  }

  void _clear() {
    setState(() {
      _localFile = null;
      _uploading = false;
      _error = null;
    });
    widget.onChanged('');
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isCircular = widget.variant == SignupImagePickerVariant.circular;
    final radius = isCircular ? widget.size / 2 : 12.0;

    final placeholder = Container(
      width: isCircular ? widget.size : double.infinity,
      height: widget.size,
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.06),
        shape: isCircular ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: isCircular ? null : BorderRadius.circular(radius),
        border: Border.all(
          color: scheme.primary.withValues(alpha: 0.45),
          width: 1.4,
        ),
      ),
      child: Icon(
        Icons.add_a_photo_outlined,
        size: 24,
        color: scheme.primary,
      ),
    );

    Widget body;
    if (_localFile != null) {
      body = SizedBox(
        width: isCircular ? widget.size : double.infinity,
        height: widget.size,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: Image.file(_localFile!, fit: BoxFit.cover),
        ),
      );
    } else if (_hasServerPath) {
      // Server path with no local preview — happens on a screen rebuild
      // after the local file was GC'd. Show a "uploaded" placeholder.
      body = SizedBox(
        width: isCircular ? widget.size : double.infinity,
        height: widget.size,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: Container(
            color: scheme.primary.withValues(alpha: 0.12),
            alignment: Alignment.center,
            child: Icon(Icons.check_circle, color: scheme.primary, size: 32),
          ),
        ),
      );
    } else {
      body = placeholder;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: AppSizes.sm),
        ],
        Stack(
          children: [
            InkWell(
              onTap: _uploading ? null : () => _open(context),
              borderRadius: BorderRadius.circular(radius),
              child: body,
            ),
            if (_uploading)
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(radius),
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.35),
                    alignment: Alignment.center,
                    child: const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            if (_hasImage && !_uploading)
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
        if (_error != null) ...[
          const SizedBox(height: AppSizes.sm),
          InkWell(
            onTap: _retry,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 14, color: scheme.error),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    _error!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.error,
                        ),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'Réessayer',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.primary,
                        decoration: TextDecoration.underline,
                      ),
                ),
              ],
            ),
          ),
        ] else if (widget.helper != null) ...[
          const SizedBox(height: AppSizes.sm),
          Text(
            widget.helper!,
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
