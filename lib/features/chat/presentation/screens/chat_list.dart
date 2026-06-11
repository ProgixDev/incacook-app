import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gap/gap.dart';
import 'package:incacook/core/common/widgets/appbar/appbar.dart';
import 'package:incacook/core/constants/image_strings.dart';
import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/core/widgets/decor/decor_blob.dart';
import 'package:incacook/features/chat/domain/chat_preview.dart';
import 'package:incacook/features/chat/presentation/widgets/chat_list_tile.dart';
import 'package:incacook/features/chat/presentation/widgets/chat_search_bar.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  //? placeholder chats — swap for a real data source once the chat
  //? backend is wired. Times are computed at first access (relative to
  //? the moment the user opens the screen) so the labels look "live".
  static final List<ChatPreview> _chats = _buildMockChats();

  static List<ChatPreview> _buildMockChats() {
    final now = DateTime.now();
    return [
      ChatPreview(
        id: 'fresh-mart',
        name: AppTexts.chatSample1Name,
        lastMessage: AppTexts.chatSample1Msg,
        avatarUrl: AppImages.foodTest,
        unreadCount: 2,
        lastMessageAt: now.subtract(const Duration(minutes: 3)),
      ),
      ChatPreview(
        id: 'daily-grocery',
        name: AppTexts.chatSample2Name,
        lastMessage: AppTexts.chatSample2Msg,
        avatarUrl: AppImages.foodTest,
        lastMessageAt: now.subtract(const Duration(minutes: 42)),
      ),
      ChatPreview(
        id: 'green-cart',
        name: AppTexts.chatSample3Name,
        lastMessage: AppTexts.chatSample3Msg,
        avatarUrl: AppImages.foodTest,
        lastMessageAt: now.subtract(const Duration(hours: 5)),
      ),
      ChatPreview(
        id: 'duck-support-1',
        name: AppTexts.chatSample4Name,
        lastMessage: AppTexts.chatSample4Msg,
        avatarUrl: AppImages.foodTest,
        unreadCount: 1,
        lastMessageAt: now.subtract(const Duration(days: 1, hours: 2)),
      ),
      ChatPreview(
        id: 'pharmacy-care',
        name: AppTexts.chatSample5Name,
        lastMessage: AppTexts.chatSample5Msg,
        avatarUrl: AppImages.foodTest,
        lastMessageAt: now.subtract(const Duration(days: 3)),
      ),
      ChatPreview(
        id: 'shopnest',
        name: AppTexts.chatSample6Name,
        lastMessage: '',
        avatarUrl: AppImages.foodTest,
        isTyping: true,
        lastMessageAt: now.subtract(const Duration(days: 12)),
      ),
    ];
  }

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _appBarVisible = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
  }

  void _handleScroll() {
    final direction = _scrollController.position.userScrollDirection;
    if (direction == ScrollDirection.reverse && _appBarVisible) {
      setState(() => _appBarVisible = false);
    } else if (direction == ScrollDirection.forward && !_appBarVisible) {
      setState(() => _appBarVisible = true);
    }
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appBarHeight =
        MediaQuery.viewPaddingOf(context).top + AppSizes.appBarHeight;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(appBarHeight),
        child: AnimatedSlide(
          offset: _appBarVisible ? Offset.zero : const Offset(0, -1),
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          child: CustomAppBar(
            showBackArrow: false,
            title: Text(
              AppTexts.chatListTitle,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          //* decorative top-right blob (purely cosmetic, no input).
          const Positioned(
            top: -8,
            right: -16,
            child: IgnorePointer(child: DecorBlob()),
          ),
          Column(
            children: [
              //* search bar — top padding compensates for the (now overlaid) appbar.
              Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSizes.md,
                  appBarHeight + AppSizes.md,
                  AppSizes.md,
                  AppSizes.md,
                ),
                child: ChatSearchBar(onChanged: (_) {}),
              ),

              //* chats list
              Expanded(
                child: ListView.separated(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(
                    AppSizes.md,
                    0,
                    AppSizes.md,
                    AppSizes.spaceBtwSections,
                  ),
                  itemCount: ChatListScreen._chats.length,
                  separatorBuilder: (_, _) => const Gap(AppSizes.sm + 2),
                  itemBuilder: (context, index) {
                    final chat = ChatListScreen._chats[index];
                    return ChatListTile(
                      chat: chat,
                      // Mock chat-list tile — real entry points (buyer
                      // tracking pill, seller conversations screen)
                      // pass a real orderId or peerUserId. Tapping
                      // the mock list is a no-op until wired to real
                      // ConversationSummary rows.
                      onTap: () {},
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
