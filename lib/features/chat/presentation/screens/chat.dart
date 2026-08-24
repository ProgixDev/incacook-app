import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:incacook/core/common/widgets/appbar/appbar.dart';
import 'package:incacook/core/common/widgets/custon_shapes/container/circular_container.dart';
import 'package:incacook/core/widgets/images/user_avatar.dart';
import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/services/realtime/chat_message.dart';
import 'package:incacook/core/services/realtime/tracking_socket_client.dart';
import 'package:incacook/core/utils/device/device_utility.dart';
import 'package:incacook/core/widgets/decor/decor_blob.dart';
import 'package:incacook/core/widgets/effects/frosted_surface.dart';
import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/features/chat/data/conversations_repository.dart';
import 'package:incacook/features/chat/data/messages_repository.dart';
import 'package:incacook/features/chat/presentation/widgets/chat_input_field.dart';
import 'package:incacook/features/moderation/controllers/blocked_users_controller.dart';
import 'package:incacook/features/moderation/presentation/report_sheet.dart';

/// Persisted-conversation chat screen. The caller passes the
/// conversation id (returned by `POST /v1/conversations`) plus the
/// viewer's role on that conversation, used to align bubbles. History
/// loads from the backend on first build; new messages arrive via the
/// `conv:<id>` socket room.
class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    required this.conversationId,
    required this.myRole,
    this.title,
    this.avatarPath,
    this.peerUserId,
  });

  /// DB id of the conversation — same one used for the socket room
  /// (`conv:<id>`) and the REST endpoints.
  final String conversationId;

  /// Viewer's role on this conversation. Messages with the same role
  /// align right (sent by me), others align left.
  final ParticipantRole myRole;

  /// Optional pill title (peer display name). Defaults to "Conversation".
  final String? title;

  /// Optional peer photo (storage key or URL) shown in the header. Null
  /// when opened from an entry point that doesn't know it yet.
  final String? avatarPath;

  /// The other participant's user id (#54) — needed for "Signaler cet
  /// utilisateur" / "Bloquer cet utilisateur" in the header overflow menu.
  /// Null disables those actions (entry point didn't know it, e.g. some
  /// order-tracking pills).
  final String? peerUserId;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Message> _messages = [];
  final ScrollController _scrollController = ScrollController();
  StreamSubscription<Message>? _sub;
  bool _sending = false;
  bool _loadingHistory = true;
  String? _historyError;

  @override
  void initState() {
    super.initState();
    _loadHistory();
    _subscribe();
    // Reset our unread counter for this thread now that the screen
    // is visible. Fire-and-forget — the server-side guard is a 200 OK
    // even when already zero.
    unawaited(
      ConversationsRepository.instance.markRead(widget.conversationId).catchError(
        (_) {/* swallow — non-fatal */},
      ),
    );
  }

  Future<void> _loadHistory() async {
    try {
      final history = await MessagesRepository.instance
          .listMessages(widget.conversationId, limit: 50);
      if (!mounted) return;
      setState(() {
        // Backend returns newest-first; reverse to chronological for
        // the bottom-anchored list.
        _messages
          ..clear()
          ..addAll(history.reversed);
        _loadingHistory = false;
      });
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingHistory = false;
        _historyError = e.toString();
      });
    }
  }

  void _subscribe() {
    if (!Get.isRegistered<TrackingSocketClient>()) return;
    final stream = TrackingSocketClient.instance
        .subscribeToConversation(widget.conversationId);
    _sub = stream.listen(
      (msg) {
        if (!mounted) return;
        // Drop dupes: if the message was just optimistically appended
        // by our own send, skip the socket echo.
        if (_messages.any((m) => m.id == msg.id)) return;
        setState(() => _messages.add(msg));
        _scrollToBottom();
      },
      onError: (Object _) {
        // Subscribe rejected — input still works as best-effort send.
      },
      cancelOnError: false,
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    if (Get.isRegistered<TrackingSocketClient>()) {
      TrackingSocketClient.instance
          .unsubscribeFromConversation(widget.conversationId);
    }
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _send(String text) async {
    if (_sending) return;
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    setState(() => _sending = true);
    try {
      // Persist + optimistically render. The socket echo can beat the
      // HTTP response back (WebSocket push vs REST round-trip), so guard
      // the optimistic add by id — otherwise the echo appends the message
      // first and this line duplicates it. Both paths are now idempotent.
      final sent =
          await MessagesRepository.instance.send(widget.conversationId, trimmed);
      if (!mounted) return;
      setState(() {
        if (_messages.every((m) => m.id != sent.id)) _messages.add(sent);
      });
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Envoi impossible: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _reportUser() async {
    final peerId = widget.peerUserId;
    if (peerId == null) return;
    await ReportSheet.showForUser(context, userId: peerId);
  }

  Future<void> _reportMessage(Message msg) async {
    await ReportSheet.showForMessage(context, messageId: msg.id);
  }

  Future<void> _blockUser() async {
    final peerId = widget.peerUserId;
    if (peerId == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(AppTexts.chatBlockConfirmTitle),
        content: const Text(AppTexts.chatBlockConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text(AppTexts.chatBlockConfirmCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(dialogContext).colorScheme.error,
            ),
            child: const Text(AppTexts.chatBlockConfirmAction),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await BlockedUsersController.instance.block(peerId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppTexts.chatBlockSuccess)),
      );
      // The conversation with a blocked peer should disappear from the
      // list without waiting for a refetch — leaving the thread plus the
      // reactive blockedUserIds set (read by ConversationsListScreen)
      // achieves that immediately.
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppTexts.chatBlockError)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appBarHeight =
        MediaQuery.viewPaddingOf(context).top + AppSizes.appBarHeight;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(appBarHeight),
        child: CustomAppBar(
          showBackArrow: true,
          title: FrostedSurface(
            borderRadius: BorderRadius.circular(999),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.md,
              vertical: AppSizes.xs + 2,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  widget.title ?? 'Conversation',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CustomCircularContainer(
                      size: 8,
                      backgroundColor: Colors.green,
                    ),
                    const Gap(AppSizes.xs),
                    Text(
                      'En ligne',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            UserAvatar(path: widget.avatarPath, size: 40),
            if (widget.peerUserId != null)
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) {
                  switch (value) {
                    case 'report':
                      _reportUser();
                    case 'block':
                      _blockUser();
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'report',
                    child: Text(AppTexts.chatReportUserCta),
                  ),
                  PopupMenuItem(
                    value: 'block',
                    child: Text(AppTexts.chatBlockUserCta),
                  ),
                ],
              ),
          ],
        ),
      ),
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            const Positioned(
              top: -8,
              right: -16,
              child: IgnorePointer(child: DecorBlob()),
            ),
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.only(
                  top: appBarHeight + AppSizes.md,
                  left: AppSizes.md,
                  right: AppSizes.md,
                  bottom: DeviceUtils.getBottomNavigationBarHeight() + 96,
                ),
                child: _buildBody(scheme),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: DeviceUtils.getBottomNavigationBarHeight() / 2.4,
              child: ChatInputField(
                onSend: _send,
                onAttach: () {},
                onMic: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(ColorScheme scheme) {
    if (_loadingHistory) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_historyError != null && _messages.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.md),
          child: Text(
            'Impossible de charger l\'historique: $_historyError',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.error,
                ),
          ),
        ),
      );
    }
    if (_messages.isEmpty) {
      return Center(
        child: Text(
          'Aucun message pour l\'instant. Dis bonjour 👋',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
        ),
      );
    }
    return ListView.separated(
      controller: _scrollController,
      itemCount: _messages.length,
      separatorBuilder: (_, _) => const Gap(AppSizes.sm),
      itemBuilder: (context, i) {
        final msg = _messages[i];
        final isMine = msg.senderRole == widget.myRole;
        return Align(
          alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            // Reporting a message you sent yourself makes no sense — the
            // long-press action is only offered on the peer's messages (#54).
            child: GestureDetector(
              onLongPress: isMine ? null : () => _reportMessage(msg),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.md,
                  vertical: AppSizes.sm,
                ),
                decoration: BoxDecoration(
                  color: isMine
                      ? scheme.primary
                      : scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  msg.content,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isMine ? scheme.onPrimary : scheme.onSurface,
                      ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}