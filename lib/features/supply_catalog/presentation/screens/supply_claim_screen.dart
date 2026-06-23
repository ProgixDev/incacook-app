import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/models/auth/upload_info.dart';
import 'package:incacook/core/network/api_response.dart';
import 'package:incacook/features/authentication/data/services/upload_picker.dart';
import 'package:incacook/features/supply_catalog/data/supply_catalog_repository.dart';

/// Catalog SAV claim reasons + their French labels.
const _reasons = <(String, String)>[
  ('NEVER_RECEIVED', 'Article jamais reçu'),
  ('DEFECTIVE', 'Article défectueux'),
  ('WRONG_ITEM', 'Mauvais article reçu'),
];

/// Seller after-sales claim on a kitchen catalog order. Pick a reason,
/// describe the issue, optionally attach photos, submit. Pops with `true`
/// once the claim is created so the orders list can refresh.
class SupplyClaimScreen extends StatefulWidget {
  const SupplyClaimScreen({super.key, required this.order});

  final CatalogOrder order;

  @override
  State<SupplyClaimScreen> createState() => _SupplyClaimScreenState();
}

class _SupplyClaimScreenState extends State<SupplyClaimScreen> {
  final SupplyCatalogRepository _repo = const SupplyCatalogRepository();
  final TextEditingController _description = TextEditingController();

  String _type = 'NEVER_RECEIVED';
  final List<String> _photoPaths = [];
  final List<File> _photoFiles = [];
  bool _uploading = false;
  bool _submitting = false;
  String? _error;

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
      _snack("Échec de l'envoi de la photo.");
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _submit() async {
    final description = _description.text.trim();
    if (description.isEmpty) {
      setState(() => _error = 'Veuillez décrire le problème.');
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await _repo.createClaim(
        widget.order.id,
        type: _type,
        description: description,
        photoUrls: _photoPaths.isNotEmpty ? List.of(_photoPaths) : null,
      );
      if (!mounted) return;
      Get.back<bool>(result: true);
      Get.snackbar(
        'Réclamation envoyée',
        'Votre réclamation a été transmise à notre équipe.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );
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
      appBar: AppBar(title: const Text('Signaler un problème')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSizes.lg),
          children: [
            Text(
              'Commande catalogue',
              style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const Gap(AppSizes.xs),
            Text(
              'Vous pouvez signaler un problème dans les 14 jours suivant votre achat.',
              style: textTheme.bodyMedium,
            ),
            const Gap(AppSizes.lg),

            Text(
              'Motif',
              style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
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

            const Gap(AppSizes.md),
            TextField(
              controller: _description,
              maxLines: 3,
              maxLength: 2000,
              decoration: const InputDecoration(
                hintText: 'Décrivez le problème…',
                border: OutlineInputBorder(),
              ),
            ),

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
                  label: const Text('Ajouter une photo'),
                ),
                const Gap(AppSizes.sm),
                IconButton(
                  onPressed: _uploading ? null : () => _addPhoto(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library_outlined),
                  tooltip: 'Galerie',
                ),
              ],
            ),

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
                  : const Text('Envoyer la réclamation'),
            ),
          ],
        ),
      ),
    );
  }
}
