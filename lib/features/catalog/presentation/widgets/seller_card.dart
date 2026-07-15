import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';
import 'package:incacook/core/common/widgets/custon_shapes/container/circular_container.dart';
import 'package:incacook/core/utils/theme/theme_extensions.dart';
import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/core/services/realtime/chat_message.dart';
import 'package:incacook/features/chat/presentation/chat_navigator.dart';

class SellerCard extends StatelessWidget {
  const SellerCard({
    super.key,
    this.name = AppTexts.productSellerFallbackName,
    this.avatarUrl,
    this.initials = '',
    this.rating = 0,
    this.ordersCompleted = 0,
    this.sellerUserId,
    this.onCallTap,
    this.onCardTap,
    this.showContact = true,
  });

  final String name;

  /// Resolved network URL of the seller's profile photo, or null when the
  /// seller has none — the card then falls back to [initials] (or a person
  /// icon). Never a mock asset.
  final String? avatarUrl;

  /// Up-to-2-letter initials shown when [avatarUrl] is null / fails to load.
  final String initials;

  final double rating;
  final int ordersCompleted;

  /// Internal user id of the seller — passed to ChatScreen so the
  /// pair-chat thread is keyed correctly. Null disables the chat
  /// button (covers cases where the surrounding screen hasn't
  /// resolved a real seller yet, e.g. in mock/demo flows).
  final String? sellerUserId;

  final VoidCallback? onCallTap;
  final VoidCallback? onCardTap;

  /// Whether to offer the chat action. False on the seller's own product
  /// detail, where the card is an identity block rather than a way to reach
  /// someone — a seller can't message themselves, and the disabled-but-visible
  /// button reads as broken.
  final bool showContact;

  String get _formattedOrders {
    final s = ordersCompleted.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buffer.write(',');
      buffer.write(s[i]);
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = context.appColors;
    final hasStats = rating > 0 || ordersCompleted > 0;
    return GestureDetector(
      onTap: onCardTap,
      child: Container(
        padding: const EdgeInsets.all(AppSizes.sm),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg * 1.5),
        ),
        child: Row(
          children: [
            _SellerAvatar(avatarUrl: avatarUrl, initials: initials, size: 48),
            const Gap(AppSizes.sm),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (hasStats)
                    Row(
                      children: [
                        if (rating > 0) ...[
                          const Icon(
                            Iconsax.star1,
                            size: 14,
                            color: Color(0xFFFFC107),
                          ),
                          const Gap(4),
                          Text(
                            rating.toStringAsFixed(1),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ],
                        if (rating > 0 && ordersCompleted > 0) ...[
                          const Gap(6),
                          Container(
                            width: 3,
                            height: 3,
                            decoration: BoxDecoration(
                              color: scheme.onSurfaceVariant,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const Gap(6),
                        ],
                        if (ordersCompleted > 0)
                          Flexible(
                            child: Text(
                              '$_formattedOrders ${AppTexts.productSellerOrdersSuffix}',
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: scheme.onSurfaceVariant),
                            ),
                          ),
                      ],
                    )
                  else
                    Text(
                      'Aucun avis pour le moment.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            if (showContact)
              GestureDetector(
                onTap: sellerUserId == null
                    ? null
                    : () => ChatNavigator.openBuyerSeller(
                        context: context,
                        peerUserId: sellerUserId!,
                        peerName: name,
                        myRole: ParticipantRole.buyer,
                      ),
                child: Opacity(
                  opacity: sellerUserId == null ? 0.5 : 1.0,
                  child: CustomCircularContainer(
                    size: 40,
                    backgroundColor: colors.selectedSurface,
                    child: Icon(
                      Iconsax.message,
                      color: colors.selectedOnSurface,
                      size: 18,
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

/// Seller profile photo for the product-detail seller block. Shows the real
/// network photo when [avatarUrl] is set; otherwise the seller's [initials]
/// on a tinted circle (a person icon when even those are unavailable). Never
/// renders a mock asset.
class _SellerAvatar extends StatelessWidget {
  const _SellerAvatar({
    required this.avatarUrl,
    required this.initials,
    required this.size,
  });

  final String? avatarUrl;
  final String initials;
  final double size;

  @override
  Widget build(BuildContext context) {
    final url = avatarUrl;
    if (url == null || url.isEmpty) {
      return _InitialsAvatar(initials: initials, size: size);
    }
    return ClipOval(
      child: Image.network(
        url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) =>
            _InitialsAvatar(initials: initials, size: size),
      ),
    );
  }
}

class _InitialsAvatar extends StatelessWidget {
  const _InitialsAvatar({required this.initials, required this.size});

  final String initials;
  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hasInitials = initials.trim().isNotEmpty;
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
