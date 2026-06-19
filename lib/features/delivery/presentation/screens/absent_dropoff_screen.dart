import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/core/models/auth/upload_info.dart';
import 'package:incacook/core/network/api_response.dart';
import 'package:incacook/core/services/location/location_service.dart';
import 'package:incacook/features/authentication/data/services/upload_picker.dart';
import 'package:incacook/features/delivery/controllers/delivery_route_controller.dart';

/// Driver fallback when the buyer is absent: capture a mandatory proof photo +
/// current GPS (+ optional note) and confirm the dropoff. Pops with `true` on
/// success (the active job is cleared by the controller). The buyer is not
/// refunded — this completes the delivery.
class AbsentDropoffScreen extends StatefulWidget {
  const AbsentDropoffScreen({super.key});

  @override
  State<AbsentDropoffScreen> createState() => _AbsentDropoffScreenState();
}

class _AbsentDropoffScreenState extends State<AbsentDropoffScreen> {
  final DeliveryRouteController _route = DeliveryRouteController.instance;
  final TextEditingController _noteController = TextEditingController();

  Position? _gps;
  bool _gpsLoading = true;

  File? _photo;
  String? _photoPath; // storage path returned by the upload flow
  bool _uploading = false;

  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _captureGps();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _captureGps() async {
    setState(() => _gpsLoading = true);
    Position? fix;
    try {
      fix = await LocationService.instance.getCurrent();
    } catch (_) {
      fix = null;
    }
    // Fall back to the last live tracking fix if a fresh one isn't available.
    fix ??= LocationService.instance.currentPosition.value;
    if (!mounted) return;
    setState(() {
      _gps = fix;
      _gpsLoading = false;
    });
  }

  Future<void> _takePhoto() async {
    setState(() => _uploading = true);
    try {
      final result = await pickAndUploadImage(
        source: ImageSource.camera,
        purpose: UploadPurpose.deliveryProof,
      );
      if (result != null && mounted) {
        setState(() {
          _photo = result.file;
          _photoPath = result.path;
        });
      }
    } on ImageTooLargeException catch (e) {
      _snack(e.message);
    } on ApiFailure catch (e) {
      _snack(e.message);
    } catch (_) {
      _snack(AppTexts.absentDropoffUploadFailed);
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _submit() async {
    if (_photoPath == null) {
      _snack(AppTexts.absentDropoffPhotoRequired);
      return;
    }
    final gps = _gps;
    if (gps == null) {
      _snack(AppTexts.absentDropoffGpsMissing);
      return;
    }
    setState(() => _submitting = true);
    final note = _noteController.text.trim();
    try {
      await _route.confirmAbsentDropoff(
        photoUrl: _photoPath!,
        lat: gps.latitude,
        lng: gps.longitude,
        note: note.isEmpty ? null : note,
      );
      Get.back<bool>(result: true);
    } on ApiFailure catch (e) {
      _snack(e.message);
    } catch (e) {
      _snack('$e');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final canSubmit = _photoPath != null && _gps != null && !_submitting;

    return Scaffold(
      appBar: AppBar(title: const Text(AppTexts.absentDropoffTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSizes.lg),
          children: [
            Text(AppTexts.absentDropoffIntro, style: textTheme.bodyMedium),
            const Gap(AppSizes.lg),

            // Photo capture + preview.
            AspectRatio(
              aspectRatio: 4 / 3,
              child: Container(
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                  image: _photo != null
                      ? DecorationImage(image: FileImage(_photo!), fit: BoxFit.cover)
                      : null,
                ),
                child: _photo == null
                    ? Center(
                        child: Icon(Icons.photo_camera_outlined,
                            size: 48, color: scheme.onSurfaceVariant),
                      )
                    : null,
              ),
            ),
            const Gap(AppSizes.sm),
            OutlinedButton.icon(
              onPressed: _uploading ? null : _takePhoto,
              icon: _uploading
                  ? const SizedBox(
                      height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.photo_camera, size: 18),
              label: Text(_photo == null
                  ? AppTexts.absentDropoffTakePhoto
                  : AppTexts.absentDropoffRetakePhoto),
            ),
            const Gap(AppSizes.md),

            // GPS status.
            Row(
              children: [
                Icon(
                  _gps != null ? Icons.location_on : Icons.location_off,
                  size: 18,
                  color: _gps != null ? scheme.primary : scheme.error,
                ),
                const Gap(AppSizes.sm),
                Expanded(
                  child: Text(
                    _gpsLoading
                        ? AppTexts.absentDropoffGpsCapturing
                        : _gps != null
                            ? AppTexts.absentDropoffGpsReady
                            : AppTexts.absentDropoffGpsMissing,
                    style: textTheme.bodySmall,
                  ),
                ),
                if (!_gpsLoading && _gps == null)
                  TextButton(onPressed: _captureGps, child: const Text(AppTexts.commonValidate)),
              ],
            ),
            const Gap(AppSizes.md),

            // Optional note.
            TextField(
              controller: _noteController,
              maxLines: 2,
              maxLength: 500,
              decoration: const InputDecoration(
                hintText: AppTexts.absentDropoffNoteHint,
                border: OutlineInputBorder(),
              ),
            ),
            const Gap(AppSizes.md),

            FilledButton(
              onPressed: canSubmit ? _submit : null,
              child: _submitting
                  ? const SizedBox(
                      height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text(AppTexts.absentDropoffSubmit),
            ),
          ],
        ),
      ),
    );
  }
}
