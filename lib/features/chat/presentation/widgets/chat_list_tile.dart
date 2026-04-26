import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:homemade/core/constants/colors.dart';
import 'package:homemade/core/constants/sizes.dart';
import 'package:homemade/core/constants/text_strings.dart';
import 'package:homemade/features/chat/domain/chat_preview.dart';

class ChatListTile extends StatelessWidget {
  const ChatListTile({super.key, required this.chat, this.onTap});

  final ChatPreview chat;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(AppSizes.sm + 2),
        decoration: BoxDecoration(
          color: AppColors.accent,
          borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg * 1.2),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            //* colored avatar
            Container(
              width: 52,
              height: 52,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: chat.avatarBackground.withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: Image.asset(chat.avatarPath, fit: BoxFit.cover),
              ),
            ),
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
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      height: 1.15,
                    ),
                  ),
                  const Gap(2),
                  _Preview(chat: chat),
                ],
              ),
            ),

            //* optional unread badge
            if (chat.unreadCount > 0) ...[
              const Gap(AppSizes.sm),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${chat.unreadCount}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
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
    final style = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: chat.isTyping ? AppColors.primary : AppColors.grey,
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
