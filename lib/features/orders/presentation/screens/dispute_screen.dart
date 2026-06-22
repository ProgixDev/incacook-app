import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/core/models/auth/upload_info.dart';
import 'package:incacook/core/network/api_response.dart';
import 'package:incacook/features/authentication/data/services/upload_picker.dart';
import 'package:incacook/features/orders/data/orders_repository.dart';

/// Backend dispute type codes + their French labels.
const _reasons = <(String, String)>[
  ('NEVER_RECEIVED', AppTexts.disputeReasonNeverReceived),
  ('WRONG_ORDER', AppTexts.disputeReasonWrongOrder),
  ('SPOILED_FOOD', AppTexts.disputeReasonSpoiled),
  ('FOOD_POISONING', AppTexts.disputeReasonPoisoning),
  ('SUBJECTIVE_DISSATISFACTION', AppTexts.disputeReasonSubjective),
];

/// Buyer post-delivery claim. Pick a reason, describe, optionally attach
/// photos / proof, submit. Pops with `true` once a dispute is created so the
/// history can refresh; shows the backend's result message.
class DisputeScreen extends StatefulWidget {
  const DisputeScreen({super.key, required this.orderId, required this.orderNumber});

  final String orderId;
  final String orderNumber;

  @override
  State<DisputeScreen> createState() => _DisputeScreenState();
}

class _DisputeScreenState extends State<DisputeScreen> {
  final TextEditingController _description = TextEditingController();

  String _type = 'NEVER_RECEIVED';
  final List<String> _photoPaths = [];
  final List<File> _photoFiles = [];
  bool _uploading = false;
  bool _submitting = false;
  String? _error;

  bool get _isPoisoning => _type == 'FOOD_POISONING';
  bool get _isSubjective => _type == 'SUBJECTIVE_DISSATISFACTION';

  @override
  void dispose() {
    _description.dispose();
    super.dispose();
  }

  Future<void> _addPhoto(ImageSource source) async {
    setState(() => _uploading = true);
    try {
      final result = await pickAndUploadImage(
        source: source,
        purpose: UploadPurpose.disputeProof,
      );
      if (result != null && mounted) {
        setState(() {
          _photoPaths.add(result.path);
          _photoFiles.add(result.file);
        });
      }
    } on ImageTooLargeException catch (e) {
      _snack(e.message);
    } on ApiFailure catch (e) {
      _snack(e.message);
    } catch (_) {
      _snack(AppTexts.disputePhotoFailed);
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _submit() async {
    if (_isPoisoning && _photoPaths.isEmpty) {
      setState(() => _error = AppTexts.disputeProofRequiredPoisoning);
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    final description = _description.text.trim();
    try {
      final message = await OrdersRepository.instance.createDispute(
        widget.orderId,
        type: _type,
        description: description.isEmpty ? null : description,
        // Food poisoning proof rides in proofFileUrls; other photos in photoUrls.
        photoUrls: !_isPoisoning && _photoPaths.isNotEmpty ? List.of(_photoPaths) : null,
        proofFileUrls: _isPoisoning && _photoPaths.isNotEmpty ? List.of(_photoPaths) : null,
      );
      if (!mounted) return;
      Get.back<bool>(result: true);
      Get.snackbar(AppTexts.disputeTitle, message,
          snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 4));
    } on ApiFailure catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = '$e');
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
    return Scaffold(
      appBar: AppBar(title: const Text(AppTexts.disputeTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSizes.lg),
          children: [
            Text('Commande #${widget.orderNumber}',
                style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
            const Gap(AppSizes.xs),
            Text(AppTexts.disputeIntro, style: textTheme.bodyMedium),
            const Gap(AppSizes.lg),

            Text(AppTexts.disputeReasonLabel,
                style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700)),
            const Gap(AppSizes.sm),
            Wrap(
              spacing: AppSizes.sm,
              runSpacing: AppSizes.sm,
              children: _reasons
                  .map((r) => ChoiceChip(
                        label: Text(r.$2),
                        selected: _type == r.$1,
                        onSelected: (_) => setState(() => _type = r.$1),
                      ))
                  .toList(),
            ),

            if (_isSubjective) ...[
              const Gap(AppSizes.md),
              Container(
                padding: const EdgeInsets.all(AppSizes.md),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(AppTexts.disputeSubjectiveNotice, style: textTheme.bodyMedium),
              ),
            ],

            const Gap(AppSizes.md),
            TextField(
              controller: _description,
              maxLines: 3,
              maxLength: 2000,
              decoration: const InputDecoration(
                hintText: AppTexts.disputeDescriptionHint,
                border: OutlineInputBorder(),
              ),
            ),

            // Photos / proof (hidden for subjective dissatisfaction).
            if (!_isSubjective) ...[
              const Gap(AppSizes.sm),
              if (_photoFiles.isNotEmpty) ...[
                SizedBox(
                  height: 84,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _photoFiles.length,
                    separatorBuilder: (_, _) => const Gap(AppSizes.sm),
                    itemBuilder: (_, i) => ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(_photoFiles[i], width: 84, height: 84, fit: BoxFit.cover),
                    ),
                  ),
                ),
                const Gap(AppSizes.sm),
              ],
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: _uploading ? null : () => _addPhoto(ImageSource.camera),
                    icon: _uploading
                        ? const SizedBox(
                            height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.photo_camera, size: 18),
                    label: Text(_isPoisoning ? AppTexts.disputeAddProof : AppTexts.disputeAddPhoto),
                  ),
                  const Gap(AppSizes.sm),
                  IconButton(
                    onPressed: _uploading ? null : () => _addPhoto(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library_outlined),
                    tooltip: 'Galerie',
                  ),
                ],
              ),
            ],

            if (_error != null) ...[
              const Gap(AppSizes.sm),
              Text(_error!, style: TextStyle(color: scheme.error)),
            ],

            const Gap(AppSizes.lg),
            FilledButton(
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox(
                      height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text(AppTexts.disputeSubmit),
            ),
          ],
        ),
      ),
    );
  }
}
