import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/core/enums/food_enums.dart';
import 'package:incacook/core/models/auth/upload_info.dart';
import 'package:incacook/features/authentication/controllers/signup_flow_controller.dart';
import 'package:incacook/features/authentication/data/models/day_of_week.dart';
import 'package:incacook/features/authentication/data/models/time_range.dart';
import 'package:incacook/features/authentication/presentation/widgets/signup_flow/signup_image_picker.dart';
import 'package:incacook/features/authentication/presentation/widgets/signup_flow/signup_step_layout.dart';
import 'package:incacook/features/authentication/presentation/widgets/signup_flow/signup_text_field.dart';

class SellerBusinessInfoPage extends GetView<SignupFlowController> {
  const SellerBusinessInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isRestaurant =
        controller.sellerCategory.value == SellerCategory.restaurant;

    return SignupStepLayout(
      title: AppTexts.signupSellerBusinessTitle,
      description: AppTexts.signupSellerBusinessSubtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SignupTextField(
            label: AppTexts.signupSellerBusinessNameLabel,
            hint: AppTexts.signupSellerBusinessNameHint,
            initialValue: controller.businessName.value,
            onChanged: (v) => controller.businessName.value = v,
            leadingIcon: Iconsax.shop,
            textInputAction: TextInputAction.next,
          ),
          const Gap(AppSizes.md),
          Obx(() => SignupTextField(
                label: AppTexts.signupSellerSiretLabel,
                hint: AppTexts.signupSellerSiretHint,
                initialValue: controller.siret.value,
                leadingIcon: Iconsax.card,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d\s]')),
                  _SiretFormatter(),
                  LengthLimitingTextInputFormatter(17),
                ],
                onChanged: (v) => controller.siret.value = v,
                errorText: controller.siret.value.isEmpty ||
                        controller.isSiretValid
                    ? null
                    : AppTexts.signupSellerSiretError,
              )),
          if (isRestaurant) ...[
            const Gap(AppSizes.lg),
            Text(
              AppTexts.signupSellerFacadeLabel,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const Gap(AppSizes.sm),
            Obx(() => SignupImagePicker(
                  path: controller.restaurantFacadeUrl.value,
                  onChanged: (p) =>
                      controller.restaurantFacadeUrl.value = p,
                  purpose: UploadPurpose.sellerFacade,
                  variant: SignupImagePickerVariant.rectangular,
                  size: 160,
                )),
            const Gap(AppSizes.lg),
            Text(
              AppTexts.signupSellerHoursLabel,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const Gap(AppSizes.sm),
            const _OpeningHoursEditor(),
          ],
        ],
      ),
    );
  }
}

class _SiretFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\s'), '');
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i == 3 || i == 6 || i == 9) buffer.write(' ');
      buffer.write(digits[i]);
    }
    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class _OpeningHoursEditor extends StatelessWidget {
  const _OpeningHoursEditor();

  Future<TimeOfDay?> _pickTime(BuildContext context, TimeOfDay initial) async {
    final scheme = Theme.of(context).colorScheme;
    var selected = initial;
    final confirmed = await showCupertinoModalPopup<bool>(
      context: context,
      builder: (ctx) => Container(
        color: scheme.surface,
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 280,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: Text(
                        'Annuler',
                        style: TextStyle(color: scheme.onSurfaceVariant),
                      ),
                    ),
                    CupertinoButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: Text(
                        'Confirmer',
                        style: TextStyle(
                          color: scheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  // Match the app's light/dark mode so the wheel's text isn't
                  // unreadable in dark mode.
                  child: CupertinoTheme(
                    data: CupertinoThemeData(
                      brightness: Theme.of(context).brightness,
                    ),
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.time,
                      use24hFormat: true,
                      initialDateTime: DateTime(
                        2000,
                        1,
                        1,
                        initial.hour,
                        initial.minute,
                      ),
                      onDateTimeChanged: (dt) =>
                          selected = TimeOfDay(hour: dt.hour, minute: dt.minute),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    return confirmed == true ? selected : null;
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SignupFlowController>();
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: DayOfWeek.values.map((day) {
        return Obx(() {
          final range = controller.openingHours[day];
          final isOpen = range != null;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSizes.xs),
            child: Row(
              children: [
                SizedBox(
                  width: 90,
                  child: Text(
                    day.label,
                    style: TextStyle(
                      color: scheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Switch.adaptive(
                  value: isOpen,
                  onChanged: (v) {
                    if (v) {
                      controller.openingHours[day] = const DailyTimeRange(
                        start: TimeOfDay(hour: 9, minute: 0),
                        end: TimeOfDay(hour: 22, minute: 0),
                      );
                    } else {
                      controller.openingHours.remove(day);
                    }
                  },
                ),
                const Gap(AppSizes.sm),
                Expanded(
                  child: !isOpen
                      ? Text(
                          AppTexts.signupSellerHoursClosed,
                          style: TextStyle(
                            color: scheme.onSurfaceVariant,
                            fontSize: 13,
                          ),
                        )
                      : Row(
                          children: [
                            Expanded(
                              child: _TimeChip(
                                time: range.start,
                                onTap: () async {
                                  final picked =
                                      await _pickTime(context, range.start);
                                  if (picked != null) {
                                    controller.openingHours[day] =
                                        range.copyWith(start: picked);
                                  }
                                },
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4),
                              child: Text('—'),
                            ),
                            Expanded(
                              child: _TimeChip(
                                time: range.end,
                                onTap: () async {
                                  final picked =
                                      await _pickTime(context, range.end);
                                  if (picked != null) {
                                    controller.openingHours[day] =
                                        range.copyWith(end: picked);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          );
        });
      }).toList(),
    );
  }
}

class _TimeChip extends StatelessWidget {
  const _TimeChip({required this.time, required this.onTap});

  final TimeOfDay time;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
      child: Container(
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
        ),
        child: Text(
          time.format(context),
          style: TextStyle(color: scheme.onSurface),
        ),
      ),
    );
  }
}
