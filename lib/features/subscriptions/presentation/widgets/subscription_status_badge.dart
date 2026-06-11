import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import 'package:incacook/core/utils/theme/brand_colors.dart';

/// Small pill showing whether the seller's platform subscription is active.
/// Green when active, muted/red otherwise. Reusable on the dashboard,
/// profile header, etc.
class SubscriptionStatusBadge extends StatelessWidget {
  const SubscriptionStatusBadge({required this.active, super.key});

  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = active ? BrandColors.success : BrandColors.warning;
    final label = active ? 'Abonnement actif' : 'Abonnement inactif';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(active ? Iconsax.tick_circle : Iconsax.info_circle,
              size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
