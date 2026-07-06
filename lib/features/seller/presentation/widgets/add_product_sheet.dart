import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';

import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/core/enums/food_enums.dart';
import 'package:incacook/core/models/listing.dart';
import 'package:incacook/core/utils/popups/blurred_modal_sheet.dart';
import 'package:incacook/core/utils/theme/brand_colors.dart';
import 'package:incacook/core/utils/theme/theme_extensions.dart';
import 'package:incacook/core/widgets/effects/frosted_surface.dart';
import 'package:incacook/core/widgets/misc/drag_handle.dart';
import 'package:incacook/features/legal/presentation/legal_terms_screen.dart';
import 'package:incacook/features/seller/controllers/add_product_controller.dart';

/// Bottom sheet for creating a new product. State lives in
/// [AddProductController]; this widget is just the shell that wires it up
/// and renders the section widgets.
class AddProductSheet extends StatefulWidget {
  const AddProductSheet({super.key, this.sellerCategory, this.existing});

  /// Optional explicit override. Normally left null so the controller
  /// resolves the category from the connected seller's profile — the
  /// Add Product page never picks a category by hand.
  final SellerCategory? sellerCategory;

  /// When non-null the sheet opens in **edit mode**: the form is pre-filled
  /// from this listing and Save sends `PATCH /v1/listings/:id` instead of
  /// creating a new one. Returns `true` from `show()` on a successful save
  /// so callers (e.g. the detail screen) can refresh.
  final Listing? existing;

  /// GetX tag — sheet-scoped so we can `Get.delete` the controller on close
  /// without colliding with any other instance that might be live.
  static const _tag = 'add-product-sheet';

  static Future<bool?> show(
    BuildContext context, {
    SellerCategory? sellerCategory,
    Listing? existing,
  }) {
    return showBlurredModalBottomSheet<bool>(
      context: context,
      builder: (_) =>
          AddProductSheet(sellerCategory: sellerCategory, existing: existing),
    );
  }

  @override
  State<AddProductSheet> createState() => _AddProductSheetState();
}

class _AddProductSheetState extends State<AddProductSheet> {
  late final AddProductController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(
      AddProductController(
        sellerCategory: widget.sellerCategory,
        existing: widget.existing,
      ),
      tag: AddProductSheet._tag,
    );
  }

  @override
  void dispose() {
    Get.delete<AddProductController>(tag: AddProductSheet._tag);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.only(bottom: keyboardInset),
      child: DraggableScrollableSheet(
        initialChildSize: 0.92,
        minChildSize: 0.6,
        maxChildSize: 0.96,
        expand: false,
        builder: (context, scrollCtrl) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DragHandle(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.35),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSizes.md),
                child: Text(
                  AppTexts.addProductSheetTitle,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () => FocusScope.of(context).unfocus(),
                  child: ListView(
                    controller: scrollCtrl,
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.fromLTRB(
                      AppSizes.md,
                      AppSizes.lg,
                      AppSizes.md,
                      AppSizes.md + _SaveBar.height,
                    ),
                    children: [
                      PhotosSection(controller: _controller),
                      const Gap(AppSizes.spaceBtwSections),
                      BaseInfoSection(controller: _controller),
                      const Gap(AppSizes.spaceBtwSections),
                      ClassificationSection(controller: _controller),
                      const Gap(AppSizes.spaceBtwSections),
                      AllergensSection(controller: _controller),
                      const Gap(AppSizes.spaceBtwSections),
                      AvailabilitySection(controller: _controller),
                      const Gap(AppSizes.spaceBtwSections),
                      PickupModeSection(controller: _controller),
                      const Gap(AppSizes.spaceBtwSections),
                      // CGU/CGV consent — required to publish a NEW dish (the
                      // publish button is gated on it). Hidden when editing.
                      if (!_controller.isEditing) ...[
                        Obx(
                          () => TermsConsentTile(
                            value: _controller.termsAccepted.value,
                            onChanged: (v) =>
                                _controller.termsAccepted.value = v,
                          ),
                        ),
                        const Gap(AppSizes.spaceBtwSections),
                      ],
                    ],
                  ),
                ),
              ),
              Obx(
                () => _SaveBar(
                  enabled:
                      _controller.canSubmit && !_controller.isSubmitting.value,
                  loading: _controller.isSubmitting.value,
                  ctaLabel: _controller.isEditing
                      ? AppTexts.addProductEditCta
                      : AppTexts.addProductSaveCta,
                  onSave: () async {
                    FocusScope.of(context).unfocus();
                    final ok = await _controller.submit();
                    if (ok && context.mounted) Navigator.of(context).pop(true);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//? ─────────────────────────────────────────────────────────────────────
//? SECTIONS — one stateless widget per logical group, each takes the
//? controller and reads/writes through it.
//? ─────────────────────────────────────────────────────────────────────

class PhotosSection extends StatelessWidget {
  const PhotosSection({super.key, required this.controller});

  final AddProductController controller;

  Future<void> _onPick(BuildContext context, int index) async {
    final source = await _showPhotoSourceSheet(context);
    if (source == null) return;
    await controller.pickPhoto(index, source);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(
          icon: Iconsax.gallery,
          title: AppTexts.addProductSectionPhotos,
        ),
        const Gap(AppSizes.md),
        Obx(
          () => _PhotoGrid(
            photos: controller.photos.toList(),
            onPick: (i) => _onPick(context, i),
            onRemove: controller.removePhoto,
          ),
        ),
        const Gap(AppSizes.sm),
        const _HelperNote(text: AppTexts.addProductPhotosHint),
      ],
    );
  }
}

class BaseInfoSection extends StatelessWidget {
  const BaseInfoSection({super.key, required this.controller});

  final AddProductController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(
          icon: Iconsax.note_text,
          title: AppTexts.addProductSectionBasic,
        ),
        const Gap(AppSizes.md),
        _FrostedField(
          controller: controller.titleController,
          label: AppTexts.addProductFieldTitle,
        ),
        const Gap(AppSizes.sm + 2),
        _FrostedField(
          controller: controller.descriptionController,
          label: AppTexts.addProductFieldDescription,
          maxLines: 4,
        ),
        const Gap(AppSizes.sm + 2),
        Row(
          children: [
            Expanded(
              child: _FrostedField(
                controller: controller.priceController,
                icon: Iconsax.money,
                label: AppTexts.addProductFieldPrice,
                suffixText: '€',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                ],
              ),
            ),
            const Gap(AppSizes.sm + 2),
            Expanded(
              child: _FrostedField(
                controller: controller.portionsController,
                icon: Iconsax.box_1,
                label: AppTexts.addProductFieldPortions,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ),
          ],
        ),
        const Gap(AppSizes.sm + 2),
        _FrostedField(
          controller: controller.prepMinutesController,
          icon: Iconsax.clock,
          label: AppTexts.addProductFieldPrepMinutes,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        if (controller.sellerCategory != null) ...[
          const Gap(AppSizes.sm),
          if (controller.isFaitMaison)
            //? Reactive: once the price crosses the €4.50 fait-maison cap we
            //? swap the neutral hint for a red error so the rule is explained
            //? rather than silently blocking the publish button.
            Obx(
              () => controller.priceCapExceeded
                  ? const _ErrorNote(text: AppTexts.addProductPriceCapError)
                  : _HelperNote(text: controller.priceCapNote),
            )
          else
            //? Traiteur / Restaurant have no price cap.
            _HelperNote(text: controller.priceCapNote),
        ],
      ],
    );
  }
}

class ClassificationSection extends StatelessWidget {
  const ClassificationSection({super.key, required this.controller});

  final AddProductController controller;

  @override
  Widget build(BuildContext context) {
    final dishOptions = controller.dishOptions;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(
          icon: Iconsax.category,
          title: AppTexts.addProductSectionClassification,
        ),
        const Gap(AppSizes.md),
        const _SubLabel(text: AppTexts.addProductFieldCategory),
        const Gap(AppSizes.sm),
        _CategoryReadonlyChip(category: controller.sellerCategory),
        const Gap(AppSizes.xs),
        const _HelperNote(text: AppTexts.addProductCategoryAutoNote),
        const Gap(AppSizes.md),
        const _SubLabel(text: AppTexts.addProductFieldCuisine),
        const Gap(AppSizes.sm),
        Obx(
          () => _ChipWrap(
            children: [
              for (final c in CuisineType.values)
                _SelectableChip(
                  label: c.label,
                  selected: controller.cuisines.contains(c),
                  onTap: () => controller.toggleCuisine(c),
                ),
            ],
          ),
        ),
        const Gap(AppSizes.md),
        const _SubLabel(text: AppTexts.addProductFieldDiets),
        const Gap(AppSizes.sm),
        Obx(
          () => _ChipWrap(
            children: [
              for (final d in DietaryTag.values)
                _SelectableChip(
                  label: d.label,
                  tint: d.color,
                  selected: controller.diets.contains(d),
                  onTap: () => controller.toggleDiet(d),
                ),
            ],
          ),
        ),
        if (dishOptions.isNotEmpty) ...[
          const Gap(AppSizes.md),
          const _SubLabel(text: AppTexts.addProductFieldDishType),
          const Gap(AppSizes.sm),
          Obx(
            () => _ChipWrap(
              children: [
                for (final d in dishOptions)
                  _SelectableChip(
                    label: d.label,
                    selected: controller.dishTypes.contains(d),
                    onTap: () => controller.toggleDishType(d),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class AllergensSection extends StatelessWidget {
  const AllergensSection({super.key, required this.controller});

  final AddProductController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(
          icon: Iconsax.warning_2,
          title: AppTexts.addProductSectionAllergens,
          required: true,
        ),
        const Gap(AppSizes.sm),
        const _HelperNote(text: AppTexts.addProductAllergensRequiredHint),
        const Gap(AppSizes.sm + 2),
        Obx(
          () => _ChipWrap(
            children: [
              for (final a in Allergen.values)
                _SelectableChip(
                  label: a.label,
                  selected: controller.allergens.contains(a),
                  onTap: () => controller.toggleAllergen(a),
                ),
              //* "Autres" — reveals a required free-text field.
              _SelectableChip(
                label: AppTexts.allergenOther,
                selected: controller.otherSelected.value,
                onTap: controller.toggleOtherAllergen,
              ),
              //* "Aucun" — explicit "no allergens"; clears all others.
              _SelectableChip(
                label: AppTexts.allergenNone,
                selected: controller.noAllergens.value,
                onTap: controller.toggleNoAllergens,
              ),
            ],
          ),
        ),
        //* The free-text precision is only shown (and required) once
        //* "Autres" is selected.
        Obx(() {
          if (!controller.otherSelected.value) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.only(top: AppSizes.sm + 2),
            child: _FrostedField(
              controller: controller.otherAllergenController,
              icon: Iconsax.edit,
              label: AppTexts.addProductAllergenOtherHint,
            ),
          );
        }),
      ],
    );
  }
}

class AvailabilitySection extends StatelessWidget {
  const AvailabilitySection({super.key, required this.controller});

  final AddProductController controller;

  Future<void> _pick(BuildContext context, {required bool isStart}) async {
    final initial =
        (isStart ? controller.pickupStart.value : controller.pickupEnd.value) ??
        TimeOfDay.now();
    final picked = await _showCupertinoTimePicker(context, initial);
    if (picked == null) return;
    if (isStart) {
      controller.setPickupStart(picked);
    } else {
      controller.setPickupEnd(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(
          icon: Iconsax.clock,
          title: AppTexts.addProductSectionAvailability,
        ),
        const Gap(AppSizes.md),
        Row(
          children: [
            Expanded(
              child: Obx(
                () => _TimePickerField(
                  icon: Iconsax.timer_start,
                  label: AppTexts.addProductFieldPickupStart,
                  value: controller.pickupStart.value,
                  onTap: () => _pick(context, isStart: true),
                ),
              ),
            ),
            const Gap(AppSizes.sm + 2),
            Expanded(
              child: Obx(
                () => _TimePickerField(
                  icon: Iconsax.timer_pause,
                  label: AppTexts.addProductFieldPickupEnd,
                  value: controller.pickupEnd.value,
                  onTap: () => _pick(context, isStart: false),
                ),
              ),
            ),
          ],
        ),
        const Gap(AppSizes.sm),
        const _HelperNote(text: AppTexts.addProductPickupTimeNote),
      ],
    );
  }
}

class PickupModeSection extends StatelessWidget {
  const PickupModeSection({super.key, required this.controller});

  final AddProductController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(
          icon: Iconsax.routing_2,
          title: AppTexts.addProductSectionPickup,
        ),
        const Gap(AppSizes.md),
        Obx(
          () => _PickupOption(
            icon: Iconsax.shop,
            label: AppTexts.addProductPickupOnSite,
            hint: AppTexts.addProductPickupOnSiteHint,
            selected: controller.onSite.value,
            onChanged: controller.setOnSite,
          ),
        ),
        const Gap(AppSizes.sm),
        Obx(
          () => _PickupOption(
            icon: Iconsax.truck,
            label: AppTexts.addProductPickupDelivery,
            hint: AppTexts.addProductPickupDeliveryHint,
            selected: controller.delivery.value,
            onChanged: controller.setDelivery,
          ),
        ),
      ],
    );
  }
}

//? ─────────────────────────────────────────────────────────────────────
//? Internal building blocks — kept private to this file.
//? ─────────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.title,
    this.required = false,
  });

  final IconData icon;
  final String title;
  final bool required;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        Icon(icon, color: scheme.onSurface, size: 20),
        const Gap(AppSizes.sm + 2),
        Text(
          title,
          style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        if (required)
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              '*',
              style: textTheme.titleSmall?.copyWith(
                color: BrandColors.error,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        const Gap(AppSizes.sm + 2),
        Expanded(
          child: Container(
            height: 1,
            color: scheme.onSurface.withValues(alpha: 0.15),
          ),
        ),
      ],
    );
  }
}

class _SubLabel extends StatelessWidget {
  const _SubLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(
        context,
      ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}

class _HelperNote extends StatelessWidget {
  const _HelperNote({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Text(
      text,
      style: Theme.of(
        context,
      ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
    );
  }
}

class _ErrorNote extends StatelessWidget {
  const _ErrorNote({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Iconsax.warning_2, size: 14, color: BrandColors.error),
        const Gap(AppSizes.xs),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: BrandColors.error,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _ChipWrap extends StatelessWidget {
  const _ChipWrap({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSizes.sm,
      runSpacing: AppSizes.sm,
      children: children,
    );
  }
}

class _SelectableChip extends StatelessWidget {
  const _SelectableChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.tint,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = context.appColors;
    final accent = tint ?? colors.selectedSurface;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md,
          vertical: AppSizes.sm + 2,
        ),
        decoration: BoxDecoration(
          color: selected ? accent : scheme.surface,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: selected ? colors.selectedOnSurface : accent,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _CategoryReadonlyChip extends StatelessWidget {
  const _CategoryReadonlyChip({required this.category});

  /// Null when the connected seller's category couldn't be resolved — the
  /// chip then shows an "unavailable" warning state instead of a category.
  final SellerCategory? category;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final unavailable = category == null;

    // Warning (amber) styling when the category is missing; the normal
    // "selected" green pill when it's resolved from the seller profile.
    final bg = unavailable
        ? BrandColors.warning.withValues(alpha: 0.12)
        : colors.selectedSurface;
    final fg = unavailable ? BrandColors.warning : colors.selectedOnSurface;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.sm + 2,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            unavailable ? Iconsax.info_circle : Iconsax.tick_circle,
            size: 16,
            color: fg,
          ),
          const Gap(AppSizes.sm),
          Text(
            category?.label ?? AppTexts.addProductCategoryUnavailable,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: fg,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _FrostedField extends StatelessWidget {
  const _FrostedField({
    required this.controller,
    this.icon,
    required this.label,
    this.maxLines = 1,
    this.keyboardType,
    this.inputFormatters,
    this.suffixText,
  });

  final TextEditingController controller;
  final IconData? icon;
  final String label;
  final int maxLines;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? suffixText;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return FrostedSurface(
      borderRadius: BorderRadius.circular(20),
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: 4),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        textInputAction: maxLines == 1
            ? TextInputAction.done
            : TextInputAction.newline,
        inputFormatters: inputFormatters,
        onEditingComplete: () => FocusScope.of(context).unfocus(),
        onTapOutside: (_) => FocusScope.of(context).unfocus(),
        decoration: InputDecoration(
          //? suppress every state-specific underline/outline so the
          //? FrostedSurface remains the only visible chrome.
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          isDense: true,
          icon: icon != null
              ? Icon(icon, color: scheme.onSurfaceVariant, size: 20)
              : null,
          hintText: label,
          hintStyle: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
          suffixText: suffixText,
        ),
      ),
    );
  }
}

class _TimePickerField extends StatelessWidget {
  const _TimePickerField({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final TimeOfDay? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final hasValue = value != null;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: FrostedSurface(
        borderRadius: BorderRadius.circular(20),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md,
          vertical: AppSizes.md,
        ),
        child: Row(
          children: [
            Icon(icon, color: scheme.onSurfaceVariant, size: 20),
            const Gap(AppSizes.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: textTheme.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const Gap(2),
                  Text(
                    hasValue ? value!.format(context) : '—',
                    style: textTheme.titleSmall?.copyWith(
                      color: hasValue
                          ? scheme.onSurface
                          : scheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PickupOption extends StatelessWidget {
  const _PickupOption({
    required this.icon,
    required this.label,
    required this.hint,
    required this.selected,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final String hint;
  final bool selected;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: () => onChanged(!selected),
      behavior: HitTestBehavior.opaque,
      child: FrostedSurface(
        borderRadius: BorderRadius.circular(20),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md,
          vertical: AppSizes.md,
        ),
        child: Row(
          children: [
            Icon(icon, color: scheme.onSurface, size: 22),
            const Gap(AppSizes.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Gap(2),
                  Text(
                    hint,
                    style: textTheme.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Switch.adaptive(
              value: selected,
              onChanged: onChanged,
              activeTrackColor: scheme.primary,
              activeThumbColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoGrid extends StatelessWidget {
  const _PhotoGrid({
    required this.photos,
    required this.onPick,
    required this.onRemove,
  });

  final List<ProductPhoto> photos;
  final ValueChanged<int> onPick;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = AppSizes.sm + 2;
        const cols = 4;
        final tile = (constraints.maxWidth - gap * (cols - 1)) / cols;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (int i = 0; i < photos.length; i++)
              _PhotoTile(
                size: tile,
                photo: photos[i],
                onPick: () => onPick(i),
                onRemove: () => onRemove(i),
              ),
          ],
        );
      },
    );
  }
}

class _PhotoTile extends StatelessWidget {
  const _PhotoTile({
    required this.size,
    required this.photo,
    required this.onPick,
    required this.onRemove,
  });

  final double size;
  final ProductPhoto photo;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final height = size * 1.2;
    final radius = BorderRadius.circular(16);

    // Filled slot — show the local preview with a remove affordance.
    if (photo.file != null) {
      return SizedBox(
        width: size,
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: radius,
              child: Image.file(photo.file!, fit: BoxFit.cover),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: onRemove,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Iconsax.close_circle,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Edit-mode "kept" slot — we have a committed Supabase path but no local
    // file. Real network display isn't wired yet, so show an "uploaded"
    // placeholder with the same remove affordance; the path is still
    // included in `uploadedImagePaths` until the seller removes it.
    if (photo.path != null) {
      return SizedBox(
        width: size,
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            FrostedSurface(
              borderRadius: radius,
              tint: scheme.primary.withValues(alpha: 0.12),
              border: Border.all(
                color: scheme.primary.withValues(alpha: 0.5),
                width: 1,
              ),
              child: Center(
                child: Icon(
                  Iconsax.gallery_tick,
                  color: scheme.primary,
                  size: 26,
                ),
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: onRemove,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Iconsax.close_circle,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Empty / uploading / error — a tappable frosted placeholder.
    final isError = photo.error != null;
    return GestureDetector(
      onTap: photo.uploading ? null : onPick,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: size,
        height: height,
        child: FrostedSurface(
          borderRadius: radius,
          //? sheet sits on top of a blurred app screenshot, but the sheet
          //? itself is flat — bump the tint so the tile reads as a glass
          //? surface even without varied content directly behind it.
          tint: scheme.onSurface.withValues(alpha: 0.06),
          border: Border.all(
            color: isError
                ? BrandColors.error.withValues(alpha: 0.6)
                : scheme.outlineVariant.withValues(alpha: 0.6),
            width: 1,
          ),
          child: Center(
            child: photo.uploading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(
                    isError ? Iconsax.refresh : Iconsax.add,
                    color: isError
                        ? BrandColors.error
                        : scheme.onSurfaceVariant,
                    size: 26,
                  ),
          ),
        ),
      ),
    );
  }
}

/// Camera-or-gallery chooser for an add-product photo slot. Returns the
/// selected [ImageSource], or null if dismissed.
Future<ImageSource?> _showPhotoSourceSheet(BuildContext context) {
  return showBlurredModalBottomSheet<ImageSource>(
    context: context,
    builder: (ctx) {
      final scheme = Theme.of(ctx).colorScheme;
      return SafeArea(
        top: false,
        // Transparent Material so the ListTiles paint their ink ripple above
        // the sheet surface instead of behind it.
        child: Material(
          type: MaterialType.transparency,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Iconsax.camera, color: scheme.onSurface),
                title: const Text(AppTexts.signupImagePickerCamera),
                onTap: () => Navigator.of(ctx).pop(ImageSource.camera),
              ),
              ListTile(
                leading: Icon(Iconsax.gallery, color: scheme.onSurface),
                title: const Text(AppTexts.signupImagePickerGallery),
                onTap: () => Navigator.of(ctx).pop(ImageSource.gallery),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _SaveBar extends StatelessWidget {
  const _SaveBar({
    required this.enabled,
    required this.onSave,
    required this.ctaLabel,
    this.loading = false,
  });

  final bool enabled;
  final bool loading;
  final String ctaLabel;
  final VoidCallback onSave;

  static const double height = 84;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.md,
          AppSizes.sm,
          AppSizes.md,
          AppSizes.sm,
        ),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: enabled ? onSave : null,
            child: loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(ctaLabel),
          ),
        ),
      ),
    );
  }
}

//? ─────────────────────────────────────────────────────────────────────
//? Top-level helpers
//? ─────────────────────────────────────────────────────────────────────

/// iOS-style wheel time picker presented from the bottom. Returns the
/// selected [TimeOfDay] or `null` if the user cancels / dismisses.
Future<TimeOfDay?> _showCupertinoTimePicker(
  BuildContext context,
  TimeOfDay initial,
) {
  final scheme = Theme.of(context).colorScheme;
  var tempPicked = initial;
  return showCupertinoModalPopup<TimeOfDay>(
    context: context,
    builder: (ctx) => Container(
      height: 280,
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: Text(
                      'Annuler',
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                  ),
                  CupertinoButton(
                    onPressed: () => Navigator.of(ctx).pop(tempPicked),
                    child: Text(
                      AppTexts.sayDone,
                      style: TextStyle(
                        color: scheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoTheme(
                data: CupertinoThemeData(
                  brightness: Theme.of(context).brightness,
                ),
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  use24hFormat: true,
                  initialDateTime: DateTime(
                    2020,
                    1,
                    1,
                    initial.hour,
                    initial.minute,
                  ),
                  onDateTimeChanged: (dt) {
                    tempPicked = TimeOfDay(hour: dt.hour, minute: dt.minute);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
