import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:incacook/core/common/widgets/custon_shapes/container/circular_image.dart';
import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/core/widgets/effects/frosted_surface.dart';
import 'package:incacook/features/chat/domain/chat_preview.dart';

class ChatListTile extends StatelessWidget {
  const ChatListTile({super.key, required this.chat, this.onTap});

  final ChatPreview chat;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: FrostedSurface(
        borderRadius: BorderRadius.circular(40),
        padding: const EdgeInsets.all(AppSizes.sm + 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            //* avatar
            CustomCircularImage(image: chat.avatarPath),
            const Gap(AppSizes.md),

            //* name + preview
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    chat.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      height: 1.15,
                    ),
                  ),
                  const Gap(2),
                  _Preview(chat: chat),
                ],
              ),
            ),

            //* right rail — last-message time + optional unread badge
            const Gap(AppSizes.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatLastMessageTime(chat.lastMessageAt),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: chat.unreadCount > 0
                        ? scheme.primary
                        : scheme.onSurfaceVariant,
                    fontWeight: chat.unreadCount > 0
                        ? FontWeight.w700
                        : FontWeight.w500,
                    height: 1.15,
                  ),
                ),
                if (chat.unreadCount > 0) ...[
                  const Gap(4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: scheme.primary,
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Text(
                      '${chat.unreadCount}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Preview extends StatelessWidget {
  const _Preview({required this.chat});

  final ChatPreview chat;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final style = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: chat.isTyping ? scheme.primary : scheme.onSurfaceVariant,
      fontWeight: chat.isTyping ? FontWeight.w600 : FontWeight.w500,
      fontStyle: chat.isTyping ? FontStyle.italic : FontStyle.normal,
      height: 1.3,
    );

    final text = chat.isTyping
        ? '${chat.name.split(' ').first} ${AppTexts.chatTypingSuffix}'
        : chat.lastMessage;

    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: style,
    );
  }
}

//* Compact French relative-time label for chat list rows.
//*   < 1 min  → "À l'instant"
//*   < 1 h    → "12 min"
//*   < 1 day  → "3 h"
//*   yesterday→ "Hier"
//*   < 7 days → weekday short ("Lun.", "Mar.", ...)
//*   else     → "DD/MM"
String _formatLastMessageTime(DateTime when, {DateTime? now}) {
  final ref = now ?? DateTime.now();
  final diff = ref.difference(when);

  if (diff.inMinutes < 1) return "À l'instant";
  if (diff.inHours < 1) return '${diff.inMinutes} min';
  if (diff.inHours < 24) return '${diff.inHours} h';

  final whenDay = DateTime(when.year, when.month, when.day);
  final today = DateTime(ref.year, ref.month, ref.day);
  final dayDiff = today.difference(whenDay).inDays;

  if (dayDiff == 1) return 'Hier';
  if (dayDiff < 7) {
    const names = ['Lun.', 'Mar.', 'Mer.', 'Jeu.', 'Ven.', 'Sam.', 'Dim.'];
    return names[when.weekday - 1];
  }

  final dd = when.day.toString().padLeft(2, '0');
  final mm = when.month.toString().padLeft(2, '0');
  return '$dd/$mm';
}
