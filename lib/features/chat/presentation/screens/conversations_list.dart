import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:incacook/core/common/widgets/appbar/appbar.dart';
import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/services/realtime/chat_message.dart';
import 'package:incacook/core/widgets/images/user_avatar.dart';
import 'package:incacook/features/chat/data/conversations_repository.dart';
import 'package:incacook/features/chat/presentation/screens/chat.dart';

/// One reusable conversation list screen. Buyer's messages tab and
/// seller's messages tab both render this, parameterized by [filter]:
///   - buyer (no filter)  → every thread: BUYER_SELLER + BUYER_DELIVERY + SUPPORT
///   - seller (BUYER_SELLER filter) → only client threads
/// All data shapes are identical (one backend list endpoint), so the
/// UI doesn't need to know which role it's serving.
class ConversationsListScreen extends StatefulWidget {
  const ConversationsListScreen({
    super.key,
    this.filter,
    this.title = 'Messages',
    this.showBackArrow = true,
  });

  /// Optional server-side type filter. `null` lists everything the
  /// caller participates in.
  final ConversationType? filter;
  final String title;
  final bool showBackArrow;

  @override
  State<ConversationsListScreen> createState() =>
      _ConversationsListScreenState();
}

class _ConversationsListScreenState extends State<ConversationsListScreen> {
  late Future<List<ConversationListItem>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<ConversationListItem>> _load() =>
      ConversationsRepository.instance.list(type: widget.filter);

  Future<void> _refresh() async {
    final next = _load();
    setState(() {
      _future = next;
    });
    await next;
  }

  String _relativeTime(DateTime when) {
    final delta = DateTime.now().difference(when);
    if (delta.inMinutes < 1) return 'à l\'instant';
    if (delta.inMinutes < 60) return '${delta.inMinutes} min';
    if (delta.inHours < 24) return '${delta.inHours} h';
    if (delta.inDays == 1) return 'Hier';
    if (delta.inDays < 7) {
      return DateFormat('EEE', 'fr_FR').format(when);
    }
    return DateFormat('d MMM', 'fr_FR').format(when);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: CustomAppBar(
        showBackArrow: widget.showBackArrow,
        title: Text(
          widget.title,
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<ConversationListItem>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: 80),
                  Icon(Icons.error_outline, size: 48, color: scheme.error),
                  const Gap(AppSizes.md),
                  Center(child: Text('${snapshot.error}')),
                  const Gap(AppSizes.md),
                  Center(
                    child: OutlinedButton(
                      onPressed: _refresh,
                      child: const Text('Réessayer'),
                    ),
                  ),
                ],
              );
            }
            final items = snapshot.data ?? const <ConversationListItem>[];
            if (items.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: 100),
                  Center(
                    child: Text(
                      'Aucune discussion pour l\'instant.',
                      style: textTheme.titleMedium
                          ?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ),
                ],
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.md,
                vertical: AppSizes.md,
              ),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (_, _) => const Gap(AppSizes.sm),
              itemBuilder: (context, i) {
                final c = items[i];
                return _ConversationTile(
                  item: c,
                  trailing: c.lastMessageAt != null
                      ? _relativeTime(c.lastMessageAt!)
                      : null,
                  onTap: () async {
                    await Get.to<void>(
                      () => ChatScreen(
                        conversationId: c.id,
                        myRole: c.myRole,
                        title: c.peer.displayName,
                        avatarPath: c.peer.avatarPath,
                      ),
                    );
                    if (mounted) _refresh();
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({
    required this.item,
    required this.onTap,
    this.trailing,
  });

  final ConversationListItem item;
  final VoidCallback onTap;
  final String? trailing;

  String _subtitle() {
    if (item.lastMessage != null && item.lastMessage!.isNotEmpty) {
      return item.lastMessage!;
    }
    switch (item.type) {
      case ConversationType.buyerSeller:
        return 'Nouvelle discussion';
      case ConversationType.buyerDelivery:
        return 'Livraison en cours';
      case ConversationType.support:
        return 'Support';
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final unread = item.unreadCount;
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSizes.sm,
        vertical: 2,
      ),
      // Peer photo (seller profile photo / buyer-driver avatar), resolved
      // from the stored storage key to a public URL, with a generic
      // default avatar fallback.
      leading: UserAvatar(path: item.peer.avatarPath, size: 48),
      title: Text(
        item.peer.displayName,
        style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
      ),
      subtitle: Text(
        _subtitle(),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (trailing != null)
            Text(
              trailing!,
              style: textTheme.labelSmall
                  ?.copyWith(color: scheme.onSurfaceVariant),
            ),
          if (unread > 0) ...[
            const Gap(4),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: scheme.primary,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                unread > 99 ? '99+' : '$unread',
                style: textTheme.labelSmall?.copyWith(
                  color: scheme.onPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}