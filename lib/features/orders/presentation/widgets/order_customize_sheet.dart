import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:incacook/core/widgets/misc/drag_handle.dart';
import 'package:iconsax/iconsax.dart';
import 'package:incacook/core/common/widgets/misc/price_display.dart';
import 'package:incacook/core/constants/image_strings.dart';
import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/core/utils/popups/blurred_modal_sheet.dart';
import 'package:incacook/core/utils/theme/theme_extensions.dart';
import 'package:incacook/core/widgets/effects/frosted_surface.dart';
import 'package:incacook/core/models/cart_item.dart';
import 'package:incacook/core/models/food_listing.dart';
import 'package:incacook/core/models/product_add_on.dart';

class OrderCustomizeSheet extends StatefulWidget {
  const OrderCustomizeSheet({
    super.key,
    required this.listing,
    this.addOns = const [],
  });

  final FoodListing listing;
  final List<ProductAddOn> addOns;

  static Future<CartItem?> show(
    BuildContext context, {
    required FoodListing listing,
    List<ProductAddOn> addOns = const [],
  }) {
    return showBlurredModalBottomSheet<CartItem>(
      context: context,
      builder: (_) => OrderCustomizeSheet(listing: listing, addOns: addOns),
    );
  }

  @override
  State<OrderCustomizeSheet> createState() => _OrderCustomizeSheetState();
}

class _OrderCustomizeSheetState extends State<OrderCustomizeSheet> {
  static const int _noteMaxLength = 200;

  int _quantity = 1;
  late final Set<String> _selectedAddOnIds = {
    for (final a in widget.addOns)
      if (a.isSelectedByDefault) a.id,
  };
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _noteController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  double get _addOnsDelta => widget.addOns
      .where((a) => _selectedAddOnIds.contains(a.id))
      .fold(0.0, (sum, a) => sum + a.priceDelta);

  double get _total => (widget.listing.price + _addOnsDelta) * _quantity;

  bool get _canIncrease => _quantity < widget.listing.portionsLeft;
  bool get _canDecrease => _quantity > 1;

  void _increase() {
    if (!_canIncrease) return;
    setState(() => _quantity++);
  }

  void _decrease() {
    if (!_canDecrease) return;
    setState(() => _quantity--);
  }

  void _toggleAddOn(String id) {
    setState(() {
      if (_selectedAddOnIds.contains(id)) {
        _selectedAddOnIds.remove(id);
      } else {
        _selectedAddOnIds.add(id);
      }
    });
  }

  void _confirmAddToCart() {
    final selectedAddOns = widget.addOns
        .where((a) => _selectedAddOnIds.contains(a.id))
        .toList(growable: false);
    // Empty id — CartController assigns the sequence-based id on insert.
    Navigator.of(context).pop(
      CartItem(
        id: '',
        listing: widget.listing,
        quantity: _quantity,
        selectedAddOns: selectedAddOns,
        note: _noteController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.72,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const DragHandle(),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(
                    AppSizes.md,
                    AppSizes.sm,
                    AppSizes.md,
                    AppSizes.md,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Header(listing: widget.listing),
                      // const HorizontalSeparator(),
                      const Gap(AppSizes.spaceBtwItems),
                      _QuantitySection(
                        quantity: _quantity,
                        portionsAvailable: widget.listing.portionsLeft,
                        canDecrease: _canDecrease,
                        canIncrease: _canIncrease,
                        onDecrease: _decrease,
                        onIncrease: _increase,
                      ),
                      if (widget.addOns.isNotEmpty) ...[
                        // const HorizontalSeparator(),
                        const Gap(AppSizes.spaceBtwItems),
                        _OptionsSection(
                          addOns: widget.addOns,
                          selectedIds: _selectedAddOnIds,
                          onToggle: _toggleAddOn,
                        ),
                      ],
                      // const HorizontalSeparator(),
                      const Gap(AppSizes.spaceBtwItems),
                      _NoteSection(
                        controller: _noteController,
                        maxLength: _noteMaxLength,
                      ),
                    ],
                  ),
                ),
              ),
              _TotalAndCta(total: _total, onAddToCart: _confirmAddToCart),
            ],
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.listing});

  final FoodListing listing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSizes.cardRadiusMd),
          child: listing.imageUrl.startsWith('http')
              ? Image.network(
                  listing.imageUrl,
                  width: 64,
                  height: 64,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Image.asset(
                    AppImages.foodTest,
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                  ),
                )
              : Image.asset(
                  listing.imageUrl,
                  width: 64,
                  height: 64,
                  fit: BoxFit.cover,
                ),
        ),
        const Gap(AppSizes.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                listing.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                ),
              ),
              const Gap(4),
              _SellerRow(listing: listing),
              const Gap(6),
              PriceDisplay(price: listing.price, priceSize: 15),
            ],
          ),
        ),
      ],
    );
  }
}

class _SellerRow extends StatelessWidget {
  const _SellerRow({required this.listing});

  final FoodListing listing;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Flexible(
          child: Text(
            listing.sellerName,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const Gap(12),

        SizedBox(
          width: 14,
          height: 14,
          child: Image.asset(listing.category.imagePath, fit: BoxFit.contain),
        ),
      ],
    );
  }
}

class _QuantitySection extends StatelessWidget {
  const _QuantitySection({
    required this.quantity,
    required this.portionsAvailable,
    required this.canDecrease,
    required this.canIncrease,
    required this.onDecrease,
    required this.onIncrease,
  });

  final int quantity;
  final int portionsAvailable;
  final bool canDecrease;
  final bool canIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppTexts.orderSheetQuantityLabel,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const Gap(AppSizes.sm + 2),
        FrostedSurface(
          borderRadius: BorderRadius.circular(999),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            children: [
              _QtyButton(
                icon: Iconsax.minus,
                enabled: canDecrease,
                onTap: onDecrease,
              ),
              Expanded(
                child: Center(
                  child: Text(
                    '$quantity',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              _QtyButton(
                icon: Iconsax.add,
                enabled: canIncrease,
                onTap: onIncrease,
              ),
            ],
          ),
        ),
        const Gap(AppSizes.sm),
        Text(
          '$portionsAvailable ${portionsAvailable == 1 ? AppTexts.orderSheetPortionAvailableSuffix : AppTexts.orderSheetPortionsAvailableSuffix}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: canIncrease
                ? scheme.onSurfaceVariant
                : const Color(0xFFC05D3B),
            fontWeight: canIncrease ? FontWeight.w500 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _QtyButton extends StatelessWidget {
  const _QtyButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = context.appColors;
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: enabled ? colors.selectedSurface : scheme.surfaceContainerHigh,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 18,
          color: enabled ? colors.selectedOnSurface : scheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _OptionsSection extends StatelessWidget {
  const _OptionsSection({
    required this.addOns,
    required this.selectedIds,
    required this.onToggle,
  });

  final List<ProductAddOn> addOns;
  final Set<String> selectedIds;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppTexts.orderSheetOptionsLabel,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const Gap(AppSizes.sm),
        for (final addOn in addOns)
          _AddOnRow(
            addOn: addOn,
            selected: selectedIds.contains(addOn.id),
            onTap: () => onToggle(addOn.id),
          ),
      ],
    );
  }
}

class _AddOnRow extends StatelessWidget {
  const _AddOnRow({
    required this.addOn,
    required this.selected,
    required this.onTap,
  });

  final ProductAddOn addOn;
  final bool selected;
  final VoidCallback onTap;

  String _formatDelta() {
    final sign = addOn.priceDelta >= 0 ? '+' : '−';
    return '$sign€${addOn.priceDelta.abs().toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final deltaColor = addOn.priceDelta >= 0
        ? scheme.onSurface
        : const Color(0xFF2E7D32);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.cardRadiusSm),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            _Checkbox(selected: selected),
            const Gap(AppSizes.sm + 2),
            Expanded(
              child: Text(
                addOn.label,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
            ),
            Text(
              _formatDelta(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: deltaColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Checkbox extends StatelessWidget {
  const _Checkbox({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: selected
            ? context.appColors.selectedSurface
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: selected
              ? context.appColors.selectedSurface
              : Theme.of(context).colorScheme.outline,
          width: 1.5,
        ),
      ),
      child: selected
          ? Icon(
              Icons.check,
              size: 14,
              color: context.appColors.selectedOnSurface,
            )
          : null,
    );
  }
}

class _NoteSection extends StatelessWidget {
  const _NoteSection({required this.controller, required this.maxLength});

  final TextEditingController controller;
  final int maxLength;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppTexts.orderSheetNoteLabel,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const Gap(AppSizes.sm + 2),
        FrostedSurface(
          borderRadius: BorderRadius.circular(20),
          child: TextField(
            controller: controller,
            maxLength: maxLength,
            maxLines: 3,
            minLines: 2,
            inputFormatters: [LengthLimitingTextInputFormatter(maxLength)],
            style: Theme.of(context).textTheme.bodyMedium,
            decoration: InputDecoration(
              hintText: AppTexts.orderSheetNoteHint,
              hintStyle: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
              filled: false,
              counterText: '',
              contentPadding: const EdgeInsets.all(AppSizes.md - 2),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}

class _TotalAndCta extends StatelessWidget {
  const _TotalAndCta({required this.total, required this.onAddToCart});

  final double total;
  final VoidCallback onAddToCart;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '${AppTexts.orderSheetTotalLabel} : ',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                PriceDisplay(price: total, priceSize: 18, currencySize: 18),
              ],
            ),
            const Gap(AppSizes.sm + 2),
            //* Frosted CTA tinted with selectedSurface — keeps the brown
            //* pill brand identity but joins the rest of the sheet's glass
            //* aesthetic. Inner Material+InkWell preserves Flutter's tap
            //* ripple/feedback now that we're not using ElevatedButton.
            FrostedSurface(
              borderRadius: BorderRadius.circular(999),
              tint: colors.selectedSurface,
              child: Material(
                color: Colors.transparent,
                shape: const StadiumBorder(),
                child: InkWell(
                  onTap: onAddToCart,
                  customBorder: const StadiumBorder(),
                  child: Container(
                    width: double.infinity,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      '${AppTexts.orderSheetAddToCartCta} — €${total.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: colors.selectedOnSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
