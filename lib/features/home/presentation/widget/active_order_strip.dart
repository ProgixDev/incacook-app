import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import 'package:vinted_v2/core/common/widgets/custon_shapes/container/circular_image.dart';
import 'package:vinted_v2/core/constants/colors.dart';
import 'package:vinted_v2/core/constants/image_strings.dart';
import 'package:vinted_v2/core/constants/sizes.dart';
import 'package:vinted_v2/core/constants/text_strings.dart';

class ActiveOrderStrip extends StatelessWidget {
  const ActiveOrderStrip({
    super.key,
    required this.onTap,
    this.etaMinutes = 15,
    this.subtitle = AppTexts.homeActiveOrderSubtitle,
    this.avatarPath = AppImages.profilePic,
  });

  final VoidCallback onTap;
  final int etaMinutes;
  final String subtitle;
  final String avatarPath;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppColors.secondary,
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: AppColors.secondary.withValues(alpha: 0.2),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            //* avatar with live pulsing badge
            Stack(
              clipBehavior: Clip.none,
              children: [
                CustomCircularImage(
                  image: avatarPath,
                  width: 44,
                  height: 44,
                ),
                const Positioned(bottom: 0, right: 0, child: _LiveDot()),
              ],
            ),
            const Gap(AppSizes.sm + 2),

            //* ETA + subtitle
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${AppTexts.homeActiveOrderEtaPrefix} $etaMinutes ${AppTexts.homeActiveOrderEtaSuffix}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w700,
                      height: 1.1,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),

            //* chevron bubble
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Iconsax.arrow_right_3,
                color: AppColors.white,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LiveDot extends StatefulWidget {
  const _LiveDot();

  @override
  State<_LiveDot> createState() => _LiveDotState();
}

class _LiveDotState extends State<_LiveDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color live = Color(0xFF4CAF50);

    return AnimatedBuilder(
      animation: _c,
      builder: (_, _) {
        final t = _c.value;
        return SizedBox(
          width: 18,
          height: 18,
          child: Stack(
            alignment: Alignment.center,
            children: [
              //* expanding halo
              Container(
                width: 10 + 6 * t,
                height: 10 + 6 * t,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: live.withValues(alpha: 0.35 * (1 - t)),
                ),
              ),
              //* solid dot with white ring so it reads on the avatar edge
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: live,
                  border: Border.all(color: AppColors.secondary, width: 2),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
