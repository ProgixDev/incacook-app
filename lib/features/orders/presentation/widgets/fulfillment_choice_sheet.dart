import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import 'package:vinted_v2/core/constants/colors.dart';
import 'package:vinted_v2/core/constants/sizes.dart';
import 'package:vinted_v2/core/constants/text_strings.dart';
import 'package:vinted_v2/features/orders/domain/fulfillment_options.dart';

class FulfillmentChoiceSheet extends StatefulWidget {
  const FulfillmentChoiceSheet({super.key, required this.options});

  final FulfillmentOptions options;

  /// Unconditionally shows the sheet. Use [resolve] instead if you want the
  /// "skip when only one option is available" smart default.
  static Future<FulfillmentSelection?> show(
    BuildContext context, {
    required FulfillmentOptions options,
  }) {
    return showModalBottomSheet<FulfillmentSelection>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FulfillmentChoiceSheet(options: options),
    );
  }

  /// Applies the "smart default" rules:
  /// - Only one option → return it immediately without showing the sheet.
  /// - Neither → returns null.
  /// - Both → shows the sheet.
  static Future<FulfillmentSelection?> resolve(
    BuildContext context, {
    required FulfillmentOptions options,
  }) async {
    final delivery = options.deliverySelectable;
    final pickup = options.pickupAvailable;

    if (delivery && !pickup) {
      return FulfillmentSelection(
        choice: FulfillmentChoice.delivery,
        fee: options.deliveryFee,
      );
    }
    if (pickup && !delivery) {
      return const FulfillmentSelection(
        choice: FulfillmentChoice.pickup,
        fee: 0,
      );
    }
    if (!pickup && !delivery) return null;
    return show(context, options: options);
  }

  @override
  State<FulfillmentChoiceSheet> createState() => _FulfillmentChoiceSheetState();
}

class _FulfillmentChoiceSheetState extends State<FulfillmentChoiceSheet> {
  FulfillmentChoice? _selected;

  @override
  void initState() {
    super.initState();
    //? default selection favours delivery when it's selectable
    if (widget.options.deliverySelectable) {
      _selected = FulfillmentChoice.delivery;
    } else if (widget.options.pickupAvailable) {
      _selected = FulfillmentChoice.pickup;
    }
  }

  void _confirm() {
    if (_selected == null) return;
    final fee = _selected == FulfillmentChoice.delivery
        ? widget.options.deliveryFee
        : 0.0;
    Navigator.of(context).pop(
      FulfillmentSelection(choice: _selected!, fee: fee),
    );
  }

  @override
  Widget build(BuildContext context) {
    final opts = widget.options;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.lightBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSizes.md,
            AppSizes.sm,
            AppSizes.md,
            AppSizes.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _DragHandle(),
              const Gap(AppSizes.md),
              Text(
                AppTexts.fulfillmentTitle,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  height: 1.25,
                ),
              ),
              const Gap(AppSizes.md),
              if (opts.deliveryAvailable)
                _OptionCard(
                  icon: Iconsax.truck_fast,
                  label: AppTexts.fulfillmentDeliveryLabel,
                  subtitle: AppTexts.fulfillmentDeliveryWindow(
                    opts.deliveryMinMinutes,
                    opts.deliveryMaxMinutes,
                  ),
                  tertiary:
                      '${AppTexts.fulfillmentDeliveryFeePrefix} €${opts.deliveryFee.toStringAsFixed(2)}',
                  selected: _selected == FulfillmentChoice.delivery,
                  enabled: opts.deliverySelectable,
                  disabledMessage: opts.userHasAddress
                      ? null
                      : AppTexts.fulfillmentNoAddress,
                  onTap: () =>
                      setState(() => _selected = FulfillmentChoice.delivery),
                ),
              if (opts.deliveryAvailable && opts.pickupAvailable)
                const Gap(AppSizes.sm + 2),
              if (opts.pickupAvailable)
                _OptionCard(
                  icon: Iconsax.shop,
                  label: AppTexts.fulfillmentPickupLabel,
                  subtitle: opts.pickupNeighborhood,
                  tertiary: AppTexts.fulfillmentPickupFree,
                  tertiaryIsHighlight: true,
                  selected: _selected == FulfillmentChoice.pickup,
                  enabled: true,
                  onTap: () =>
                      setState(() => _selected = FulfillmentChoice.pickup),
                ),
              const Gap(AppSizes.lg),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selected == null ? null : _confirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: AppColors.white,
                    disabledBackgroundColor: AppColors.buttonDisabled,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                    textStyle: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  child: const Text(AppTexts.fulfillmentContinueCta),
                ),
              ),
            ],
          ),
        ),
      ),
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

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.tertiary,
    required this.selected,
    required this.enabled,
    required this.onTap,
    this.disabledMessage,
    this.tertiaryIsHighlight = false,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final String tertiary;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;
  final String? disabledMessage;
  final bool tertiaryIsHighlight;

  @override
  Widget build(BuildContext context) {
    final borderColor = selected
        ? AppColors.primary
        : AppColors.lightGrey;
    final iconBg = selected
        ? AppColors.primary.withValues(alpha: 0.12)
        : AppColors.lightGrey;

    return Opacity(
      opacity: enabled ? 1.0 : 0.55,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          padding: const EdgeInsets.all(AppSizes.md - 2),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
            border: Border.all(
              color: borderColor,
              width: selected ? 1.8 : 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
                child: Icon(
                  icon,
                  size: 20,
                  color: selected ? AppColors.primary : AppColors.secondary,
                ),
              ),
              const Gap(AppSizes.md - 2),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Gap(2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.grey,
                      ),
                    ),
                    const Gap(2),
                    Text(
                      tertiary,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: tertiaryIsHighlight
                            ? const Color(0xFF2E7D32)
                            : AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (disabledMessage != null) ...[
                      const Gap(4),
                      Text(
                        disabledMessage!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(0xFFC05D3B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Gap(AppSizes.sm),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 150),
                opacity: selected ? 1 : 0,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Iconsax.tick_square,
                    size: 14,
                    color: AppColors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
