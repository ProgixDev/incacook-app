import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:incacook/core/utils/device/device_utility.dart';
import 'package:iconsax/iconsax.dart';
import 'package:incacook/core/common/widgets/appbar/appbar.dart';
import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/core/utils/popups/blurred_modal_sheet.dart';
import 'package:incacook/core/utils/theme/theme_extensions.dart';
import 'package:incacook/features/orders/domain/delivery_details.dart';
import 'package:incacook/features/orders/domain/saved_address.dart';
import 'package:incacook/features/orders/presentation/widgets/address_card.dart';
import 'package:incacook/features/orders/presentation/widgets/address_search_sheet.dart';

class DeliveryAddressScreen extends StatefulWidget {
  const DeliveryAddressScreen({super.key});

  @override
  State<DeliveryAddressScreen> createState() => _DeliveryAddressScreenState();
}

class _DeliveryAddressScreenState extends State<DeliveryAddressScreen> {
  //? demo addresses — swap for CRUD against a real source later
  final List<SavedAddress> _addresses = [
    const SavedAddress(
      id: 'home',
      type: SavedAddressType.home,
      line1: '12 Rue de la Roquette',
      line2: '75011 Paris',
    ),
    const SavedAddress(
      id: 'work',
      type: SavedAddressType.work,
      line1: '45 Avenue de la République',
      line2: '75011 Paris',
    ),
    const SavedAddress(
      id: 'family',
      type: SavedAddressType.other,
      customLabel: 'Famille',
      line1: '50 Rue de Saint-Germain',
      line2: '92500 Rueil-Malmaison',
      inRange: false,
    ),
  ];

  late String? _selectedId = _addresses.isNotEmpty ? _addresses.first.id : null;
  final TextEditingController _instructionsController = TextEditingController();
  final DeliveryTiming _timing = DeliveryTiming.asap;
  final DateTime _scheduledAt = DateTime.now().add(const Duration(minutes: 45));

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

  Future<void> _openAddressSearch() async {
    final picked = await showBlurredModalBottomSheet<SavedAddress>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const AddressSearchSheet(),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _addresses.add(picked);
      _selectedId = picked.id;
    });
  }

  void _confirm() {
    final address = _selected;
    if (address == null) return;
    Get.back<DeliveryDetails>(
      result: DeliveryDetails(
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
      appBar: CustomAppBar(
        showBackArrow: true,
        title: Text(
          AppTexts.addressTitle,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
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
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        IconButton(
                          onPressed: _openAddressSearch,
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
    final scheme = Theme.of(context).colorScheme;
    final colors = context.appColors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHigh,
              shape: BoxShape.circle,
            ),
            child: Icon(Iconsax.location, size: 24, color: scheme.onSurface),
          ),
          const Gap(AppSizes.md),
          Text(
            AppTexts.addressNoSavedTitle,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const Gap(AppSizes.md),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
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
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSizes.md,
        AppSizes.sm,
        AppSizes.md,
        DeviceUtils.getBottomNavigationBarHeight(),
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: enabled ? onContinue : null,
          child: const Text(AppTexts.addressContinueCta),
        ),
      ),
    );
  }
}
