import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import 'package:homemade/core/constants/sizes.dart';
import 'package:homemade/core/constants/text_strings.dart';
import 'package:homemade/core/utils/popups/blurred_modal_sheet.dart';
import 'package:homemade/core/utils/theme/theme_extensions.dart';
import 'package:homemade/core/widgets/effects/frosted_surface.dart';
import 'package:homemade/core/widgets/misc/drag_handle.dart';
import 'package:homemade/features/orders/domain/saved_address.dart';

/// Bottom sheet showing the user's saved addresses. Opens with a frosted
/// blur via [showBlurredModalBottomSheet].
class SavedAddressesSheet extends StatelessWidget {
  const SavedAddressesSheet({super.key, required this.addresses});

  final List<SavedAddress> addresses;

  static Future<void> show(
    BuildContext context, {
    required List<SavedAddress> addresses,
  }) {
    return showBlurredModalBottomSheet<void>(
      context: context,
      builder: (_) => SavedAddressesSheet(addresses: addresses),
    );
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
            _Header(onAdd: () {}),
            Expanded(
              child: addresses.isEmpty
                  ? const _EmptyState()
                  : ListView.separated(
                      controller: scrollCtrl,
                      padding: const EdgeInsets.all(AppSizes.md),
                      itemCount: addresses.length,
                      separatorBuilder: (_, _) => const Gap(AppSizes.sm + 2),
                      itemBuilder: (_, index) =>
                          _AddressTile(address: addresses[index]),
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
      padding: const EdgeInsets.fromLTRB(
        AppSizes.md,
        AppSizes.md,
        AppSizes.md,
        AppSizes.md,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              AppTexts.addressesSheetTitle,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
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
                  child: Icon(
                    Iconsax.add,
                    color: colors.selectedOnSurface,
                    size: 20,
                  ),
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
  const _AddressTile({required this.address});

  final SavedAddress address;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return FrostedSurface(
      borderRadius: BorderRadius.circular(300),
      padding: const EdgeInsets.all(AppSizes.md - 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //* type icon (home / work / other)
          SizedBox(
            width: 44,
            height: 44,
            child: Icon(address.type.icon, size: 20, color: scheme.onSurface),
          ),
          const Gap(AppSizes.md - 2),

          //* label + lines
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  address.label,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
                const Gap(2),
                Text(
                  address.line1,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                ),
                Text(
                  address.line2,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const Gap(AppSizes.sm),
          IconButton(
            onPressed: () {},
            icon: Icon(Iconsax.edit_2, size: 18, color: scheme.onSurface),
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
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
