import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/core/models/zone.dart';
import 'package:incacook/core/utils/theme/theme_extensions.dart';
import 'package:incacook/features/authentication/controllers/signup_flow_controller.dart';
import 'package:incacook/features/authentication/data/repositories/zones_repository.dart';
import 'package:incacook/features/authentication/presentation/widgets/signup_flow/signup_step_layout.dart';
import 'package:incacook/features/authentication/presentation/widgets/signup_flow/signup_text_field.dart';

class DriverZonePage extends StatefulWidget {
  const DriverZonePage({super.key});

  @override
  State<DriverZonePage> createState() => _DriverZonePageState();
}

class _DriverZonePageState extends State<DriverZonePage> {
  final _query = TextEditingController();

  List<Zone> _zones = const [];
  List<Zone> _suggestions = const [];
  bool _loading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadZones();
  }

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  Future<void> _loadZones() async {
    setState(() {
      _loading = true;
      _hasError = false;
    });
    try {
      final zones = await ZonesRepository.instance.getActiveZones();
      if (!mounted) return;
      setState(() {
        _zones = zones;
        _suggestions = _filtered(_query.text, zones);
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _hasError = true;
      });
    }
  }

  List<Zone> _filtered(String q, List<Zone> source) {
    final query = q.trim().toLowerCase();
    if (query.isEmpty) return source;
    return source.where((z) => z.name.toLowerCase().contains(query)).toList();
  }

  void _onQueryChanged(String q) {
    setState(() => _suggestions = _filtered(q, _zones));
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
            child: _buildZoneList(context, controller, scheme),
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

  Widget _buildZoneList(
    BuildContext context,
    SignupFlowController controller,
    ColorScheme scheme,
  ) {
    if (_loading) {
      return const SizedBox(
        height: 120,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_hasError) {
      return Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Iconsax.cloud_cross, color: scheme.onSurfaceVariant, size: 28),
            const Gap(AppSizes.sm),
            Text(
              AppTexts.signupDriverZoneLoadError,
              textAlign: TextAlign.center,
              style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13),
            ),
            const Gap(AppSizes.sm),
            TextButton(
              onPressed: _loadZones,
              child: const Text(AppTexts.signupDriverZoneRetry),
            ),
          ],
        ),
      );
    }

    if (_suggestions.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Center(
          child: Text(
            AppTexts.signupDriverZoneNoResults,
            style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      itemCount: _suggestions.length,
      separatorBuilder: (_, _) => Divider(
        height: 1,
        color: scheme.outlineVariant.withValues(alpha: 0.5),
      ),
      itemBuilder: (_, i) {
        final zone = _suggestions[i];
        return Obx(() {
          final selected = controller.operatingZones.contains(zone.name);
          return ListTile(
            dense: true,
            leading: Icon(
              Iconsax.location,
              size: 18,
              color: scheme.onSurfaceVariant,
            ),
            title: Text(zone.name),
            subtitle: zone.city != null && zone.city != zone.name
                ? Text(zone.city!)
                : null,
            trailing: selected
                ? Icon(Icons.check, color: scheme.primary)
                : null,
            onTap: () {
              if (selected) {
                controller.operatingZones.remove(zone.name);
              } else {
                controller.operatingZones.add(zone.name);
              }
            },
          );
        });
      },
    );
  }
}
