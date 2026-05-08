import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/core/utils/theme/theme_extensions.dart';
import 'package:incacook/features/authentication/controllers/signup_flow_controller.dart';
import 'package:incacook/features/authentication/presentation/widgets/signup_flow/signup_step_layout.dart';
import 'package:incacook/features/authentication/presentation/widgets/signup_flow/signup_text_field.dart';

class DriverZonePage extends StatefulWidget {
  const DriverZonePage({super.key});

  @override
  State<DriverZonePage> createState() => _DriverZonePageState();
}

class _DriverZonePageState extends State<DriverZonePage> {
  final _query = TextEditingController();
  late List<String> _suggestions;

  static const _knownZones = [
    'Paris 1er',
    'Paris 4e — Le Marais',
    'Paris 11e',
    'Lyon Centre',
    'Marseille Vieux-Port',
    'Bordeaux Centre',
    'Toulouse Capitole',
    'Lille Vieux-Lille',
    'Nantes Centre',
    'Strasbourg Petite France',
  ];

  @override
  void initState() {
    super.initState();
    _suggestions = _knownZones;
  }

  void _onQueryChanged(String q) {
    setState(() {
      if (q.trim().isEmpty) {
        _suggestions = _knownZones;
        return;
      }
      _suggestions = _knownZones
          .where((z) => z.toLowerCase().contains(q.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SignupFlowController>();
    final colors = context.appColors;
    final scheme = Theme.of(context).colorScheme;

    return SignupStepLayout(
      title: AppTexts.signupDriverZoneTitle,
      description: AppTexts.signupDriverZoneSubtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SignupTextField(
            controller: _query,
            hint: AppTexts.signupDriverZoneSearchHint,
            leadingIcon: Iconsax.search_normal,
            onChanged: _onQueryChanged,
          ),
          const Gap(AppSizes.sm + 4),
          Obx(() {
            if (controller.operatingZones.isEmpty) {
              return const SizedBox.shrink();
            }
            return Wrap(
              spacing: AppSizes.sm,
              runSpacing: AppSizes.sm,
              children: controller.operatingZones.map((zone) {
                return InputChip(
                  label: Text(zone),
                  onDeleted: () => controller.operatingZones.remove(zone),
                  backgroundColor: colors.selectedSurface,
                  labelStyle: TextStyle(color: colors.selectedOnSurface),
                  deleteIconColor: colors.selectedOnSurface,
                  // Pill shape so the chips match the frosted text-field
                  // and chip-group radii used elsewhere in the flow.
                  shape: const StadiumBorder(),
                  side: BorderSide.none,
                );
              }).toList(),
            );
          }),
          const Gap(AppSizes.md),
          Container(
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg),
              border: Border.all(color: scheme.outlineVariant),
            ),
            constraints: const BoxConstraints(maxHeight: 240),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: _suggestions.length,
              separatorBuilder: (_, _) => Divider(
                height: 1,
                color: scheme.outlineVariant.withValues(alpha: 0.5),
              ),
              itemBuilder: (_, i) {
                final zone = _suggestions[i];
                return Obx(() {
                  final selected = controller.operatingZones.contains(zone);
                  return ListTile(
                    dense: true,
                    leading: Icon(
                      Iconsax.location,
                      size: 18,
                      color: scheme.onSurfaceVariant,
                    ),
                    title: Text(zone),
                    trailing: selected
                        ? Icon(Icons.check, color: scheme.primary)
                        : null,
                    onTap: () {
                      if (selected) {
                        controller.operatingZones.remove(zone);
                      } else {
                        controller.operatingZones.add(zone);
                      }
                    },
                  );
                });
              },
            ),
          ),
          const Gap(AppSizes.md),
          Container(
            height: 140,
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg),
              border: Border.all(color: scheme.outlineVariant),
            ),
            alignment: Alignment.center,
            child: Obx(
              () => Text(
                controller.operatingZones.isEmpty
                    ? AppTexts.signupDriverZoneEmpty
                    : AppTexts.signupDriverZoneCount(
                        controller.operatingZones.length,
                      ),
                style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
