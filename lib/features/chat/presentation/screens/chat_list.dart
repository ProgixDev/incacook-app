import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:homemade/core/common/widgets/appbar/appbar.dart';
import 'package:homemade/core/constants/colors.dart';
import 'package:homemade/core/constants/image_strings.dart';
import 'package:homemade/core/constants/sizes.dart';
import 'package:homemade/core/constants/text_strings.dart';
import 'package:homemade/features/chat/domain/chat_preview.dart';
import 'package:homemade/features/chat/presentation/screens/chat.dart';
import 'package:homemade/features/chat/presentation/widgets/chat_list_tile.dart';
import 'package:homemade/features/chat/presentation/widgets/chat_search_bar.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  //? placeholder chats — swap for a real data source once the chat
  //? backend is wired
  static const List<ChatPreview> _chats = [
    ChatPreview(
      id: 'fresh-mart',
      name: AppTexts.chatSample1Name,
      lastMessage: AppTexts.chatSample1Msg,
      avatarPath: AppImages.foodTest,
      avatarBackground: Color(0xFFE8823B),
      unreadCount: 2,
    ),
    ChatPreview(
      id: 'daily-grocery',
      name: AppTexts.chatSample2Name,
      lastMessage: AppTexts.chatSample2Msg,
      avatarPath: AppImages.foodTest,
      avatarBackground: Color(0xFF4CAF50),
    ),
    ChatPreview(
      id: 'green-cart',
      name: AppTexts.chatSample3Name,
      lastMessage: AppTexts.chatSample3Msg,
      avatarPath: AppImages.foodTest,
      avatarBackground: Color(0xFF2E81E6),
    ),
    ChatPreview(
      id: 'duck-support-1',
      name: AppTexts.chatSample4Name,
      lastMessage: AppTexts.chatSample4Msg,
      avatarPath: AppImages.foodTest,
      avatarBackground: Color(0xFFFFC107),
      unreadCount: 1,
    ),
    ChatPreview(
      id: 'pharmacy-care',
      name: AppTexts.chatSample5Name,
      lastMessage: AppTexts.chatSample5Msg,
      avatarPath: AppImages.foodTest,
      avatarBackground: Color(0xFFE53935),
    ),
    ChatPreview(
      id: 'shopnest',
      name: AppTexts.chatSample6Name,
      lastMessage: '',
      avatarPath: AppImages.foodTest,
      avatarBackground: Color(0xFFF06292),
      isTyping: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: CustomAppBar(
        showBackArrow: false,
        title: Text(
          AppTexts.chatListTitle,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Column(
        children: [
          //* search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.md,
              AppSizes.md,
              AppSizes.md,
              AppSizes.md,
            ),
            child: ChatSearchBar(onChanged: (_) {}),
          ),

          //* chats list
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.md,
                0,
                AppSizes.md,
                AppSizes.spaceBtwSections,
              ),
              itemCount: _chats.length,
              separatorBuilder: (_, _) => const Gap(AppSizes.sm + 2),
              itemBuilder: (context, index) {
                final chat = _chats[index];
                return ChatListTile(
                  chat: chat,
                  onTap: () => Get.to(() => const ChatScreen()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
