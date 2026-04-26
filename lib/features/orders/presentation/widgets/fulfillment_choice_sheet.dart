import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:homemade/core/constants/colors.dart';
import 'package:homemade/core/constants/image_strings.dart';
import 'package:homemade/core/constants/sizes.dart';
import 'package:homemade/core/constants/text_strings.dart';
import 'package:homemade/core/utils/popups/blurred_modal_sheet.dart';
import 'package:homemade/core/widgets/misc/drag_handle.dart';
import 'package:homemade/features/orders/domain/fulfillment_options.dart';
import 'package:homemade/features/orders/presentation/widgets/delivery_option_card.dart';

class FulfillmentChoiceSheet extends StatefulWidget {
  const FulfillmentChoiceSheet({super.key, required this.options});

  final FulfillmentOptions options;

  /// Unconditionally shows the sheet. Use [resolve] instead if you want the
  /// "skip when only one option is available" smart default.
  static Future<FulfillmentSelection?> show(
    BuildContext context, {
    required FulfillmentOptions options,
  }) {
    return showBlurredModalBottomSheet<FulfillmentSelection>(
      context: context,
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
    Navigator.of(
      context,
    ).pop(FulfillmentSelection(choice: _selected!, fee: fee));
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
              const DragHandle(),
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

              Row(
                children: [
                  if (opts.deliveryAvailable)
                    DeliveryOptionCard(
                      iconPath: AppImages.delivery,
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
                      onTap: () => setState(
                        () => _selected = FulfillmentChoice.delivery,
                      ),
                    ),
                  if (opts.deliveryAvailable && opts.pickupAvailable)
                    const Gap(AppSizes.sm + 2),
                  if (opts.pickupAvailable)
                    DeliveryOptionCard(
                      iconPath: AppImages.pickup,
                      label: AppTexts.fulfillmentPickupLabel,
                      subtitle: opts.pickupNeighborhood,
                      tertiary: AppTexts.fulfillmentPickupFree,
                      tertiaryIsHighlight: true,
                      selected: _selected == FulfillmentChoice.pickup,
                      enabled: true,
                      onTap: () =>
                          setState(() => _selected = FulfillmentChoice.pickup),
                    ),
                ],
              ),
              const Gap(AppSizes.lg),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selected == null ? null : _confirm,
                  child: Text(AppTexts.fulfillmentContinueCta),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
