import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

import 'package:incacook/core/common/widgets/appbar/appbar.dart';
import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/controllers/user_controller.dart';
import 'package:incacook/core/models/auth/upload_info.dart';
import 'package:incacook/core/network/api_response.dart';
import 'package:incacook/features/authentication/data/repositories/users_repository.dart';
import 'package:incacook/features/authentication/presentation/widgets/signup_flow/signup_image_picker.dart';

/// Lets any signed-in user (buyer / seller / driver) edit their profile
/// basics — display name + avatar. Avatar uses the same two-step upload
/// as signup (`UploadPurpose.avatar`); the storage path + names are saved
/// via `PATCH /v1/users/me`, then the global [UserController] is refreshed
/// so the settings card updates immediately.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _firstName;
  late final TextEditingController _lastName;
  late final TextEditingController _phone;

  /// Storage object key for the avatar (empty = none). Seeded from the
  /// current user; updated by the image picker on a successful upload.
  String _avatarPath = '';
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final user = UserController.instance.user.value;
    _firstName = TextEditingController(text: user?.firstName ?? '');
    _lastName = TextEditingController(text: user?.lastName ?? '');
    _phone = TextEditingController(text: user?.phone ?? '');
    _avatarPath = user?.avatarPath ?? '';
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _phone.dispose();
    super.dispose();
  }

  bool get _isValid =>
      _firstName.text.trim().length >= 2 && _lastName.text.trim().length >= 2;

  Future<void> _save() async {
    if (_saving || !_isValid) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final updated = await UsersRepository.instance.updateMe(
        firstName: _firstName.text.trim(),
        lastName: _lastName.text.trim(),
        phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
        avatarPath: _avatarPath.isEmpty ? null : _avatarPath,
      );
      UserController.instance.setUser(updated);
      if (!mounted) return;
      Get.back<void>();
      Get.snackbar('Profil', 'Profil mis à jour',
          snackPosition: SnackPosition.BOTTOM);
    } on ApiFailure catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Échec de la mise à jour: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: CustomAppBar(
        showBackArrow: true,
        title: Text(
          'Modifier le profil',
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: SignupImagePicker(
                  path: _avatarPath,
                  purpose: UploadPurpose.avatar,
                  helper: 'Photo de profil',
                  onChanged: (path) => setState(() => _avatarPath = path),
                ),
              ),
              const Gap(AppSizes.lg),
              Text('Prénom', style: textTheme.labelLarge),
              const Gap(AppSizes.xs),
              TextField(
                controller: _firstName,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(hintText: 'Prénom'),
                onChanged: (_) => setState(() {}),
              ),
              const Gap(AppSizes.md),
              Text('Nom', style: textTheme.labelLarge),
              const Gap(AppSizes.xs),
              TextField(
                controller: _lastName,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(hintText: 'Nom'),
                onChanged: (_) => setState(() {}),
              ),
              const Gap(AppSizes.md),
              Text('Téléphone', style: textTheme.labelLarge),
              const Gap(AppSizes.xs),
              TextField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(hintText: '+33 6 12 34 56 78'),
              ),
              if (_error != null) ...[
                const Gap(AppSizes.md),
                Text(
                  _error!,
                  style: textTheme.bodySmall?.copyWith(color: scheme.error),
                ),
              ],
              const Gap(AppSizes.xl),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (_saving || !_isValid) ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Enregistrer'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
