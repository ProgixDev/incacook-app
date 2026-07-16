import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:incacook/core/constants/api_constants.dart';
import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/core/controllers/user_controller.dart';
import 'package:incacook/core/widgets/effects/frosted_surface.dart';

class ProfileUserCard extends StatelessWidget {
  const ProfileUserCard({
    super.key,
    this.onEditProfile,
    this.onPreferences,
    this.onPayment,
  });

  final VoidCallback? onEditProfile;
  final VoidCallback? onPreferences;
  final VoidCallback? onPayment;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final userController = UserController.instance;

    return FrostedSurface(
      borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg * 1.5),
      padding: const EdgeInsets.fromLTRB(
        AppSizes.md,
        AppSizes.lg,
        AppSizes.md,
        AppSizes.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          //* avatar — shows the photo the user registered with (buyer/driver
          //  via `avatarPath`, seller via `sellerProfile.profilePhotoUrl`),
          //  resolved to a public URL. Falls back to a generic default
          //  avatar when no photo was provided (or it fails to load).
          Obx(() {
            final u = userController.user.value;
            final initials = userController.initials;
            final url = _resolveAvatarUrl(
              u?.avatarPath ?? u?.sellerAccount?.profilePhotoUrl,
            );
            if (url == null) {
              return _DefaultAvatar(size: 88, initials: initials);
            }
            return ClipOval(
              child: Image.network(
                url,
                width: 88,
                height: 88,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) =>
                    _DefaultAvatar(size: 88, initials: initials),
              ),
            );
          }),
          const Gap(AppSizes.md),

          //* name + email — bound to UserController. Empty string while
          //  the post-auth flow is still hydrating so we don't flash
          //  placeholder copy.
          Obx(
            () => Text(
              userController.displayName,
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const Gap(AppSizes.xs),
          Obx(
            () => Text(
              userController.email,
              style: textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Gap(AppSizes.lg),

          //* quick-action tiles
          Row(
            children: [
              Expanded(
                child: _ProfileActionTile(
                  icon: Iconsax.user_edit,
                  label: AppTexts.profileActionEditProfile,
                  onTap: onEditProfile,
                ),
              ),
              const Gap(AppSizes.sm),
              Expanded(
                child: _ProfileActionTile(
                  icon: Iconsax.heart,
                  label: AppTexts.profileActionPreferences,
                  onTap: onPreferences,
                ),
              ),
              const Gap(AppSizes.sm),
              Expanded(
                child: _ProfileActionTile(
                  icon: Iconsax.card,
                  label: AppTexts.profileActionPayment,
                  onTap: onPayment,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Resolves a stored avatar value to a fetchable URL. Storage object keys
/// go through [ApiConstants.publicImageUrl]; already-absolute URLs pass
/// through untouched. Returns null for empty/missing values.
String? _resolveAvatarUrl(String? value) {
  if (value == null || value.isEmpty) return null;
  if (value.startsWith('http')) return value;
  return ApiConstants.publicImageUrl(value);
}

/// Placeholder shown when a user has no profile photo (or it fails to load):
/// their initials (e.g. "GD") on a soft tinted circle. Falls back to a person
/// silhouette only when no initials are available.
class _DefaultAvatar extends StatelessWidget {
  const _DefaultAvatar({required this.size, this.initials = ''});

  final double size;
  final String initials;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hasInitials = initials.isNotEmpty && initials != '?';
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: scheme.primary.withValues(alpha: 0.10),
      ),
      alignment: Alignment.center,
      child: hasInitials
          ? Text(
              initials,
              style: TextStyle(
                fontSize: size * 0.36,
                fontWeight: FontWeight.w700,
                color: scheme.primary,
              ),
            )
          : Icon(
              Iconsax.user,
              size: size * 0.5,
              color: scheme.primary.withValues(alpha: 0.65),
            ),
    );
  }
}

class _ProfileActionTile extends StatelessWidget {
  const _ProfileActionTile({
    required this.icon,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final radius = BorderRadius.circular(AppSizes.cardRadiusMd);

    // A null onTap means the action isn't available for this user (e.g. a seller
    // hasn't finished payout setup, or a buyer has no Stripe dashboard). Dim it
    // so it reads as disabled instead of tappable-but-dead.
    final enabled = onTap != null;

    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: FrostedSurface(
        borderRadius: radius,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: radius,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AppSizes.md,
                horizontal: AppSizes.sm,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 22, color: scheme.onSurface),
                  const Gap(AppSizes.sm),
                  Text(
                    label,
                    style: textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
