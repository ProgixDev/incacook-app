import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';

import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/core/models/auth/address_record.dart';
import 'package:incacook/core/network/api_response.dart';
import 'package:incacook/core/utils/popups/blurred_modal_sheet.dart';
import 'package:incacook/core/utils/theme/theme_extensions.dart';
import 'package:incacook/core/widgets/effects/frosted_surface.dart';
import 'package:incacook/core/widgets/misc/drag_handle.dart';
import 'package:incacook/features/authentication/data/models/requests/upsert_address_request.dart';
import 'package:incacook/features/authentication/data/repositories/users_repository.dart';

IconData _iconForType(AddressType? type) {
  switch (type) {
    case AddressType.home:
      return Iconsax.home_2;
    case AddressType.work:
      return Iconsax.briefcase;
    case AddressType.other:
    case null:
      return Iconsax.location;
  }
}

String _typeLabel(AddressType? type) {
  switch (type) {
    case AddressType.home:
      return AppTexts.addressTypeHome;
    case AddressType.work:
      return AppTexts.addressTypeWork;
    case AddressType.other:
    case null:
      return AppTexts.addressTypeOther;
  }
}

String _displayLabel(AddressRecord r) {
  if (r.customLabel != null && r.customLabel!.isNotEmpty) return r.customLabel!;
  if (r.type != null) return _typeLabel(r.type);
  return r.fullAddress;
}

/// Bottom sheet listing the user's saved addresses with full CRUD — add,
/// edit, delete. Each user only ever sees their own addresses (the backend
/// scopes every query to the JWT). Loads live from
/// `GET /v1/users/me/addresses`.
class SavedAddressesSheet extends StatefulWidget {
  const SavedAddressesSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showBlurredModalBottomSheet<void>(
      context: context,
      builder: (_) => const SavedAddressesSheet(),
    );
  }

  @override
  State<SavedAddressesSheet> createState() => _SavedAddressesSheetState();
}

class _SavedAddressesSheetState extends State<SavedAddressesSheet> {
  late Future<List<AddressRecord>> _future;

  @override
  void initState() {
    super.initState();
    _future = UsersRepository.instance.listAddresses();
  }

  void _reload() {
    setState(() => _future = UsersRepository.instance.listAddresses());
  }

  Future<void> _add() async {
    final saved = await _AddressEditorSheet.show(context, existing: null);
    if (saved == true) _reload();
  }

  Future<void> _edit(AddressRecord record) async {
    final saved = await _AddressEditorSheet.show(context, existing: record);
    if (saved == true) _reload();
  }

  Future<void> _delete(AddressRecord record) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer l\'adresse ?'),
        content: Text(record.fullAddress),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await UsersRepository.instance.deleteAddress(record.id);
      _reload();
    } on ApiFailure catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.45,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollCtrl) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const DragHandle(),
            _Header(onAdd: _add),
            Expanded(
              child: FutureBuilder<List<AddressRecord>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return _ErrorState(onRetry: _reload, error: '${snapshot.error}');
                  }
                  final items = snapshot.data ?? const <AddressRecord>[];
                  if (items.isEmpty) return const _EmptyState();
                  return ListView.separated(
                    controller: scrollCtrl,
                    padding: const EdgeInsets.all(AppSizes.md),
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const Gap(AppSizes.sm + 2),
                    itemBuilder: (_, index) => _AddressTile(
                      record: items[index],
                      onEdit: () => _edit(items[index]),
                      onDelete: () => _delete(items[index]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.all(AppSizes.md),
      child: Row(
        children: [
          Expanded(
            child: Text(
              AppTexts.addressesSheetTitle,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          Material(
            color: colors.selectedSurface,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onAdd,
              child: Tooltip(
                message: AppTexts.addressesAddNew,
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: Icon(Iconsax.add, color: colors.selectedOnSurface, size: 20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddressTile extends StatelessWidget {
  const _AddressTile({
    required this.record,
    required this.onEdit,
    required this.onDelete,
  });

  final AddressRecord record;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return FrostedSurface(
      borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
      padding: const EdgeInsets.all(AppSizes.md - 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 44,
            height: 44,
            child: Icon(_iconForType(record.type), size: 20, color: scheme.onSurface),
          ),
          const Gap(AppSizes.md - 2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _displayLabel(record),
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const Gap(2),
                Text(
                  record.fullAddress,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: scheme.onSurfaceVariant),
                ),
                Text(
                  '${record.postalCode} ${record.city}'.trim(),
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onEdit,
            icon: Icon(Iconsax.edit_2, size: 18, color: scheme.onSurface),
          ),
          IconButton(
            onPressed: onDelete,
            icon: Icon(Iconsax.trash, size: 18, color: scheme.error),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Text(
          AppTexts.addressesEmpty,
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry, required this.error});

  final VoidCallback onRetry;
  final String error;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: scheme.error, size: 40),
            const Gap(AppSizes.sm),
            Text(error, textAlign: TextAlign.center),
            const Gap(AppSizes.md),
            OutlinedButton(onPressed: onRetry, child: const Text('Réessayer')),
          ],
        ),
      ),
    );
  }
}

/// Add / edit form for one address. Pops `true` after a successful save so
/// the list refreshes. Self-contained (text fields only) so it doesn't
/// depend on the signup-only address autocomplete.
class _AddressEditorSheet extends StatefulWidget {
  const _AddressEditorSheet({this.existing});

  final AddressRecord? existing;

  static Future<bool?> show(BuildContext context, {AddressRecord? existing}) {
    return showBlurredModalBottomSheet<bool>(
      context: context,
      isDismissible: true,
      builder: (_) => _AddressEditorSheet(existing: existing),
    );
  }

  @override
  State<_AddressEditorSheet> createState() => _AddressEditorSheetState();
}

class _AddressEditorSheetState extends State<_AddressEditorSheet> {
  late final TextEditingController _fullAddress;
  late final TextEditingController _postalCode;
  late final TextEditingController _city;
  late final TextEditingController _label;
  AddressType _type = AddressType.home;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _fullAddress = TextEditingController(text: e?.fullAddress ?? '');
    _postalCode = TextEditingController(text: e?.postalCode ?? '');
    _city = TextEditingController(text: e?.city ?? '');
    _label = TextEditingController(text: e?.customLabel ?? '');
    _type = e?.type ?? AddressType.home;
  }

  @override
  void dispose() {
    _fullAddress.dispose();
    _postalCode.dispose();
    _city.dispose();
    _label.dispose();
    super.dispose();
  }

  bool get _valid =>
      _fullAddress.text.trim().isNotEmpty &&
      _postalCode.text.trim().isNotEmpty &&
      _city.text.trim().isNotEmpty;

  Future<void> _save() async {
    if (_saving || !_valid) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    final req = UpsertAddressRequest(
      fullAddress: _fullAddress.text.trim(),
      city: _city.text.trim(),
      postalCode: _postalCode.text.trim(),
      type: _type,
      customLabel: _label.text.trim().isEmpty ? null : _label.text.trim(),
    );
    try {
      final repo = UsersRepository.instance;
      if (widget.existing == null) {
        await repo.createAddress(req);
      } else {
        await repo.updateAddress(widget.existing!.id, req);
      }
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on ApiFailure catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: EdgeInsets.only(
        left: AppSizes.lg,
        right: AppSizes.lg,
        top: AppSizes.md,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSizes.lg,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const DragHandle(),
            Text(
              widget.existing == null ? 'Nouvelle adresse' : 'Modifier l\'adresse',
              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const Gap(AppSizes.md),
            Wrap(
              spacing: AppSizes.sm,
              children: AddressType.values.map((t) {
                final selected = t == _type;
                return ChoiceChip(
                  label: Text(_typeLabel(t)),
                  avatar: Icon(_iconForType(t), size: 16),
                  selected: selected,
                  onSelected: (_) => setState(() => _type = t),
                );
              }).toList(),
            ),
            const Gap(AppSizes.md),
            TextField(
              controller: _fullAddress,
              decoration: const InputDecoration(
                labelText: 'Adresse',
                hintText: '12 rue Saint-Sabin',
              ),
              onChanged: (_) => setState(() {}),
            ),
            const Gap(AppSizes.sm),
            Row(
              children: [
                SizedBox(
                  width: 120,
                  child: TextField(
                    controller: _postalCode,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Code postal'),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const Gap(AppSizes.sm),
                Expanded(
                  child: TextField(
                    controller: _city,
                    decoration: const InputDecoration(labelText: 'Ville'),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
            const Gap(AppSizes.sm),
            TextField(
              controller: _label,
              decoration: const InputDecoration(
                labelText: 'Libellé (optionnel)',
                hintText: 'Chez ma sœur',
              ),
            ),
            if (_error != null) ...[
              const Gap(AppSizes.sm),
              Text(_error!, style: textTheme.bodySmall?.copyWith(color: scheme.error)),
            ],
            const Gap(AppSizes.lg),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_saving || !_valid) ? null : _save,
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
    );
  }
}
