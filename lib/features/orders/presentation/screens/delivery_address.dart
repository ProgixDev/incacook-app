import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import 'package:vinted_v2/core/common/widgets/appbar/appbar.dart';
import 'package:vinted_v2/core/constants/colors.dart';
import 'package:vinted_v2/core/constants/sizes.dart';
import 'package:vinted_v2/core/constants/text_strings.dart';
import 'package:vinted_v2/features/orders/domain/delivery_details.dart';
import 'package:vinted_v2/features/orders/domain/saved_address.dart';

class DeliveryAddressScreen extends StatefulWidget {
  const DeliveryAddressScreen({super.key});

  @override
  State<DeliveryAddressScreen> createState() => _DeliveryAddressScreenState();
}

class _DeliveryAddressScreenState extends State<DeliveryAddressScreen> {
  //? demo addresses — swap for CRUD against a real source later
  static const List<SavedAddress> _addresses = [
    SavedAddress(
      id: 'home',
      type: SavedAddressType.home,
      line1: '12 Rue de la Roquette',
      line2: '75011 Paris',
    ),
    SavedAddress(
      id: 'work',
      type: SavedAddressType.work,
      line1: '45 Avenue de la République',
      line2: '75011 Paris',
    ),
    SavedAddress(
      id: 'family',
      type: SavedAddressType.other,
      customLabel: 'Famille',
      line1: '50 Rue de Saint-Germain',
      line2: '92500 Rueil-Malmaison',
      inRange: false,
    ),
  ];

  static const int _instructionsMaxLength = 200;

  String? _selectedId = _addresses.isNotEmpty ? _addresses.first.id : null;
  final TextEditingController _instructionsController = TextEditingController();
  DeliveryTiming _timing = DeliveryTiming.asap;
  DateTime _scheduledAt = DateTime.now().add(const Duration(minutes: 45));

  @override
  void initState() {
    super.initState();
    _instructionsController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _instructionsController.dispose();
    super.dispose();
  }

  SavedAddress? get _selected =>
      _addresses.where((a) => a.id == _selectedId).firstOrNull;

  bool get _canContinue {
    final sel = _selected;
    if (sel == null) return false;
    if (!sel.inRange) return false;
    return true;
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _scheduledAt,
      firstDate: now,
      lastDate: now.add(const Duration(days: 14)),
    );
    if (picked == null) return;
    setState(() {
      _scheduledAt = DateTime(
        picked.year,
        picked.month,
        picked.day,
        _scheduledAt.hour,
        _scheduledAt.minute,
      );
    });
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_scheduledAt),
    );
    if (picked == null) return;
    setState(() {
      _scheduledAt = DateTime(
        _scheduledAt.year,
        _scheduledAt.month,
        _scheduledAt.day,
        picked.hour,
        picked.minute,
      );
    });
  }

  void _confirm() {
    final address = _selected;
    if (address == null) return;
    Navigator.of(context).pop(
      DeliveryDetails(
        address: address,
        instructions: _instructionsController.text.trim(),
        timing: _timing,
        scheduledAt: _timing == DeliveryTiming.scheduled ? _scheduledAt : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final showOutOfRangeWarning = _selected != null && !_selected!.inRange;

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: CustomAppBar(
        showBackArrow: true,
        title: Text(
          AppTexts.addressTitle,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.md,
                AppSizes.md,
                AppSizes.md,
                AppSizes.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_addresses.isEmpty)
                    const _EmptyAddressState()
                  else ...[
                    _SectionLabel(text: AppTexts.addressDeliverTo),
                    const Gap(AppSizes.sm + 2),
                    for (final address in _addresses) ...[
                      _AddressCard(
                        address: address,
                        selected: _selectedId == address.id,
                        onTap: () =>
                            setState(() => _selectedId = address.id),
                        onEdit: () {},
                      ),
                      const Gap(AppSizes.sm + 2),
                    ],
                    const _AddAddressLink(),
                    if (showOutOfRangeWarning) ...[
                      const Gap(AppSizes.sm + 2),
                      const _OutOfRangeWarning(),
                    ],
                  ],
                  const _Divider(),
                  _SectionLabel(text: AppTexts.addressInstructionsLabel),
                  const Gap(AppSizes.sm + 2),
                  _InstructionsField(
                    controller: _instructionsController,
                    maxLength: _instructionsMaxLength,
                  ),
                  const _Divider(),
                  _SectionLabel(text: AppTexts.addressWhenLabel),
                  const Gap(AppSizes.sm + 2),
                  _SchedulePicker(
                    timing: _timing,
                    scheduledAt: _scheduledAt,
                    onTimingChanged: (t) => setState(() => _timing = t),
                    onPickDate: _pickDate,
                    onPickTime: _pickTime,
                  ),
                  const Gap(AppSizes.md),
                ],
              ),
            ),
          ),
          _Footer(enabled: _canContinue, onContinue: _confirm),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
      child: Container(height: 1, color: AppColors.lightGrey),
    );
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({
    required this.address,
    required this.selected,
    required this.onTap,
    required this.onEdit,
  });

  final SavedAddress address;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(AppSizes.md - 2),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.lightGrey,
            width: selected ? 1.8 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primary.withValues(alpha: 0.12)
                    : AppColors.lightGrey,
                shape: BoxShape.circle,
              ),
              child: Icon(
                address.type.icon,
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
                    address.label,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Gap(2),
                  Text(
                    address.line1,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppColors.grey),
                  ),
                  Text(
                    address.line2,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppColors.grey),
                  ),
                ],
              ),
            ),
            const Gap(AppSizes.sm),
            GestureDetector(
              onTap: onEdit,
              behavior: HitTestBehavior.opaque,
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(
                  Iconsax.edit_2,
                  size: 16,
                  color: AppColors.grey,
                ),
              ),
            ),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 150),
              opacity: selected ? 1 : 0,
              child: Padding(
                padding: const EdgeInsets.only(left: AppSizes.sm - 2),
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
            ),
          ],
        ),
      ),
    );
  }
}

class _AddAddressLink extends StatelessWidget {
  const _AddAddressLink();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.sm + 2),
        child: Row(
          children: [
            const Icon(Iconsax.add, size: 18, color: AppColors.secondary),
            const Gap(AppSizes.sm),
            Text(
              AppTexts.addressAdd,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyAddressState extends StatelessWidget {
  const _EmptyAddressState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: AppColors.accent,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Iconsax.location,
              size: 24,
              color: AppColors.secondary,
            ),
          ),
          const Gap(AppSizes.md),
          Text(
            AppTexts.addressNoSavedTitle,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const Gap(AppSizes.md),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: AppColors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
                textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: const Text(AppTexts.addressAddFirst),
            ),
          ),
        ],
      ),
    );
  }
}

class _OutOfRangeWarning extends StatelessWidget {
  const _OutOfRangeWarning();

  @override
  Widget build(BuildContext context) {
    const bannerColor = Color(0xFFE53935);
    return Container(
      padding: const EdgeInsets.all(AppSizes.sm + 2),
      decoration: BoxDecoration(
        color: bannerColor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppSizes.cardRadiusMd),
        border: Border.all(color: bannerColor.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Iconsax.warning_2, size: 16, color: bannerColor),
          const Gap(AppSizes.sm),
          Expanded(
            child: Text(
              AppTexts.addressOutOfRange,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: bannerColor,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InstructionsField extends StatelessWidget {
  const _InstructionsField({required this.controller, required this.maxLength});

  final TextEditingController controller;
  final int maxLength;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLength: maxLength,
      maxLines: 3,
      minLines: 2,
      inputFormatters: [LengthLimitingTextInputFormatter(maxLength)],
      style: Theme.of(
        context,
      ).textTheme.bodyMedium?.copyWith(color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: AppTexts.addressInstructionsHint,
        hintStyle: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: AppColors.grey),
        filled: true,
        fillColor: AppColors.white,
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
          borderSide: const BorderSide(color: AppColors.secondary, width: 1),
        ),
      ),
    );
  }
}

class _SchedulePicker extends StatelessWidget {
  const _SchedulePicker({
    required this.timing,
    required this.scheduledAt,
    required this.onTimingChanged,
    required this.onPickDate,
    required this.onPickTime,
  });

  final DeliveryTiming timing;
  final DateTime scheduledAt;
  final ValueChanged<DeliveryTiming> onTimingChanged;
  final VoidCallback onPickDate;
  final VoidCallback onPickTime;

  String _dateLabel() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(
      scheduledAt.year,
      scheduledAt.month,
      scheduledAt.day,
    );
    final diff = target.difference(today).inDays;
    if (diff == 0) return AppTexts.addressToday;
    if (diff == 1) return AppTexts.addressTomorrow;
    return '${scheduledAt.day.toString().padLeft(2, '0')}/'
        '${scheduledAt.month.toString().padLeft(2, '0')}';
  }

  String _timeLabel() {
    return '${scheduledAt.hour.toString().padLeft(2, '0')}:'
        '${scheduledAt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _RadioRow(
          selected: timing == DeliveryTiming.asap,
          label: AppTexts.addressWhenAsap,
          onTap: () => onTimingChanged(DeliveryTiming.asap),
        ),
        const Gap(AppSizes.sm),
        _RadioRow(
          selected: timing == DeliveryTiming.scheduled,
          label: AppTexts.addressWhenLater,
          onTap: () => onTimingChanged(DeliveryTiming.scheduled),
        ),
        if (timing == DeliveryTiming.scheduled) ...[
          const Gap(AppSizes.sm + 2),
          Padding(
            padding: const EdgeInsets.only(left: 32),
            child: Row(
              children: [
                _PickerChip(label: _dateLabel(), onTap: onPickDate),
                const Gap(AppSizes.sm),
                _PickerChip(label: _timeLabel(), onTap: onPickTime),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _RadioRow extends StatelessWidget {
  const _RadioRow({
    required this.selected,
    required this.label,
    required this.onTap,
  });

  final bool selected;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selected ? AppColors.primary : AppColors.white,
              border: Border.all(
                color: selected ? AppColors.primary : AppColors.lightGrey,
                width: 1.5,
              ),
            ),
            child: selected
                ? Center(
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  )
                : null,
          ),
          const Gap(AppSizes.sm + 2),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _PickerChip extends StatelessWidget {
  const _PickerChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md - 2,
          vertical: AppSizes.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.lightGrey),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const Gap(6),
            const Icon(
              Iconsax.arrow_down_1,
              size: 14,
              color: AppColors.grey,
            ),
          ],
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.enabled, required this.onContinue});

  final bool enabled;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.lightBackground,
        border: Border(top: BorderSide(color: AppColors.lightGrey)),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSizes.md,
        AppSizes.md,
        AppSizes.md,
        AppSizes.md,
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: enabled ? onContinue : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: AppColors.white,
              disabledBackgroundColor: AppColors.buttonDisabled,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
              textStyle: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            child: const Text(AppTexts.addressContinueCta),
          ),
        ),
      ),
    );
  }
}
