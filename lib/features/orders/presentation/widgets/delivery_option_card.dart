import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:vinted_v2/core/constants/colors.dart';
import 'package:vinted_v2/core/constants/sizes.dart';
import 'package:vinted_v2/core/utils/device/device_utility.dart';
import 'package:vinted_v2/core/widgets/images/responsive_image_asset.dart';

class DeliveryOptionCard extends StatelessWidget {
  const DeliveryOptionCard({
    super.key,
    required this.iconPath,
    required this.label,
    required this.subtitle,
    required this.tertiary,
    required this.selected,
    required this.enabled,
    required this.onTap,
    this.disabledMessage,
    this.tertiaryIsHighlight = false,
  });

  final String iconPath;
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
    return Opacity(
      opacity: enabled ? 1.0 : 0.55,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          padding: const EdgeInsets.all(AppSizes.md - 2),
          decoration: BoxDecoration(
            color: selected ? AppColors.secondary : AppColors.lightGrey,
            borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ResponsiveImageAsset(
                assetPath: iconPath,
                width: DeviceUtils.getScreenWidth(context) * 0.36,
                height: DeviceUtils.getScreenWidth(context) * 0.36,
              ),
              const Gap(AppSizes.md - 2),
              Text(
                label,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: selected ? AppColors.white : AppColors.black,
                ),
              ),
              const Gap(2),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: selected ? AppColors.white : AppColors.black,
                ),
              ),
              const Gap(2),
              Text(
                tertiary,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: tertiaryIsHighlight
                      ? const Color(0xFF2E7D32)
                      : selected
                      ? AppColors.white
                      : AppColors.black,
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
      ),
    );
  }
}
