import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import 'package:vinted_v2/core/constants/colors.dart';
import 'package:vinted_v2/core/constants/sizes.dart';
import 'package:vinted_v2/core/constants/text_strings.dart';
import 'package:vinted_v2/features/home/domain/food_listing.dart';
import 'package:vinted_v2/features/orders/domain/order_customization.dart';
import 'package:vinted_v2/features/orders/domain/product_add_on.dart';

class OrderCustomizeSheet extends StatefulWidget {
  const OrderCustomizeSheet({
    super.key,
    required this.listing,
    this.addOns = const [],
  });

  final FoodListing listing;
  final List<ProductAddOn> addOns;

  static Future<OrderCustomization?> show(
    BuildContext context, {
    required FoodListing listing,
    List<ProductAddOn> addOns = const [],
  }) {
    return showModalBottomSheet<OrderCustomization>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
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
    Navigator.of(context).pop(
      OrderCustomization(
        listing: widget.listing,
        quantity: _quantity,
        selectedAddOns: selectedAddOns,
        note: _noteController.text.trim(),
        totalPrice: _total,
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
          decoration: const BoxDecoration(
            color: AppColors.lightBackground,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const _DragHandle(),
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
                      const _SectionDivider(),
                      _QuantitySection(
                        quantity: _quantity,
                        portionsAvailable: widget.listing.portionsLeft,
                        canDecrease: _canDecrease,
                        canIncrease: _canIncrease,
                        onDecrease: _decrease,
                        onIncrease: _increase,
                      ),
                      if (widget.addOns.isNotEmpty) ...[
                        const _SectionDivider(),
                        _OptionsSection(
                          addOns: widget.addOns,
                          selectedIds: _selectedAddOnIds,
                          onToggle: _toggleAddOn,
                        ),
                      ],
                      const _SectionDivider(),
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

class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.sm + 2),
      child: Center(
        child: Container(
          width: 42,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.secondary,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
      child: Container(
        height: 1,
        color: AppColors.secondary.withValues(alpha: 0.3),
      ),
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
          child: Image.asset(
            listing.imagePath,
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
                  color: AppColors.textPrimary,
                  height: 1.15,
                ),
              ),
              const Gap(4),
              _SellerRow(listing: listing),
              const Gap(6),
              _PriceRow(
                price: listing.price,
                originalPrice: listing.originalPrice,
              ),
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
    final style = Theme.of(
      context,
    ).textTheme.bodySmall?.copyWith(color: AppColors.grey);

    return Row(
      children: [
        Flexible(
          child: Text(
            listing.sellerName,
            overflow: TextOverflow.ellipsis,
            style: style?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        const Gap(6),
        Text('·', style: style),
        const Gap(6),
        SizedBox(
          width: 14,
          height: 14,
          child: Image.asset(listing.category.imagePath, fit: BoxFit.contain),
        ),
        const Gap(4),
        Flexible(child: Text(listing.category.label, style: style)),
      ],
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({required this.price, this.originalPrice});

  final double price;
  final double? originalPrice;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        if (originalPrice != null) ...[
          Text(
            '€${originalPrice!.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.grey,
              decoration: TextDecoration.lineThrough,
              decorationColor: AppColors.grey,
            ),
          ),
          const Gap(6),
          const Icon(Iconsax.arrow_right_3, size: 12, color: AppColors.grey),
          const Gap(6),
        ],
        Text(
          '€${price.toStringAsFixed(2)}',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w800,
          ),
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

  String _portionsLabel() {
    final word = portionsAvailable == 1
        ? AppTexts.orderSheetPortionAvailableSuffix
        : AppTexts.orderSheetPortionsAvailableSuffix;
    return '$portionsAvailable $word';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppTexts.orderSheetQuantityLabel,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const Gap(AppSizes.sm + 2),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppColors.lightGrey),
          ),
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
                      color: AppColors.textPrimary,
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
          _portionsLabel(),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: canIncrease ? AppColors.grey : const Color(0xFFC05D3B),
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
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: enabled ? AppColors.secondary : AppColors.lightGrey,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 18,
          color: enabled ? AppColors.white : AppColors.grey,
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
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
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
    final deltaColor = addOn.priceDelta >= 0
        ? AppColors.textPrimary
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
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
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
        color: selected ? AppColors.secondary : AppColors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: selected ? AppColors.secondary : AppColors.lightGrey,
          width: 1.5,
        ),
      ),
      child: selected
          ? const Icon(Iconsax.tick_square, size: 14, color: AppColors.white)
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppTexts.orderSheetNoteLabel,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const Gap(AppSizes.sm + 2),
        TextField(
          controller: controller,
          maxLength: maxLength,
          maxLines: 3,
          minLines: 2,
          inputFormatters: [LengthLimitingTextInputFormatter(maxLength)],
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: AppTexts.orderSheetNoteHint,
            hintStyle: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.grey),
            filled: true,
            fillColor: AppColors.accent,
            counterText: '',
            contentPadding: const EdgeInsets.all(AppSizes.md - 2),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.cardRadiusMd),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.cardRadiusMd),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.cardRadiusMd),
              borderSide: const BorderSide(
                color: AppColors.secondary,
                width: 1,
              ),
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
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.lightBackground,
        border: Border(top: BorderSide(color: AppColors.lightGrey, width: 1)),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSizes.md,
        AppSizes.md,
        AppSizes.md,
        AppSizes.md,
      ),
      child: SafeArea(
        top: false,
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
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '€${total.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
              ],
            ),
            const Gap(AppSizes.sm + 2),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onAddToCart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: AppColors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                  textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: Text(
                  '${AppTexts.orderSheetAddToCartCta} — €${total.toStringAsFixed(2)}',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
