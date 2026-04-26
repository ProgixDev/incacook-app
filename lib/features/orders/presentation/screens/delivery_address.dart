import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import 'package:homemade/core/common/widgets/appbar/appbar.dart';
import 'package:homemade/core/constants/colors.dart';
import 'package:homemade/core/constants/sizes.dart';
import 'package:homemade/core/constants/text_strings.dart';
import 'package:homemade/features/orders/domain/delivery_details.dart';
import 'package:homemade/features/orders/domain/saved_address.dart';
import 'package:homemade/features/orders/presentation/widgets/address_card.dart';

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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppTexts.addressDeliverTo,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.add),
                        ),
                      ],
                    ),
                    const Gap(AppSizes.sm + 2),
                    for (final address in _addresses) ...[
                      AddressCard(
                        address: address,
                        selected: _selectedId == address.id,
                        onTap: () => setState(() => _selectedId = address.id),
                        onEdit: () {},
                      ),
                      const Gap(AppSizes.sm + 2),
                    ],
                    // const _AddAddressLink(),
                    if (showOutOfRangeWarning) ...[
                      const Gap(AppSizes.sm + 2),
                      const _OutOfRangeWarning(),
                    ],
                  ],
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
                textStyle: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
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
    return SizedBox(
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

class _Footer extends StatelessWidget {
  const _Footer({required this.enabled, required this.onContinue});

  final bool enabled;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.lightBackground,
        border: Border(top: BorderSide(color: Colors.transparent)),
      ),
      padding: const EdgeInsets.all(AppSizes.md),
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
              textStyle: Theme.of(context).textTheme.titleMedium,
            ),
            child: const Text(AppTexts.addressContinueCta),
          ),
        ),
      ),
    );
  }
}
