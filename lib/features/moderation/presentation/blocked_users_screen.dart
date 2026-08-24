import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import 'package:incacook/core/common/widgets/appbar/appbar.dart';
import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/core/network/api_response.dart';
import 'package:incacook/core/widgets/images/user_avatar.dart';
import 'package:incacook/features/moderation/controllers/blocked_users_controller.dart';
import 'package:incacook/features/moderation/data/blocked_user.dart';
import 'package:incacook/features/moderation/data/blocks_repository.dart';

/// Settings → "Utilisateurs bloqués" (#54). Lists everyone the caller has
/// blocked, with an inline unblock action — reversibility is what Apple's
/// moderation review checks for.
class BlockedUsersScreen extends StatefulWidget {
  const BlockedUsersScreen({super.key});

  @override
  State<BlockedUsersScreen> createState() => _BlockedUsersScreenState();
}

class _BlockedUsersScreenState extends State<BlockedUsersScreen> {
  late Future<List<BlockedUser>> _future;
  final Set<String> _unblocking = {};

  @override
  void initState() {
    super.initState();
    _future = BlocksRepository.instance.list();
  }

  Future<void> _refresh() async {
    final next = BlocksRepository.instance.list();
    setState(() => _future = next);
    await next;
  }

  Future<void> _unblock(BlockedUser user) async {
    setState(() => _unblocking.add(user.userId));
    try {
      await BlockedUsersController.instance.unblock(user.userId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppTexts.blockedUsersUnblockSuccess)),
      );
      await _refresh();
    } on ApiFailure catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppTexts.chatUnblockError)),
      );
    } finally {
      if (mounted) setState(() => _unblocking.remove(user.userId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: const CustomAppBar(
        showBackArrow: true,
        title: Text(AppTexts.blockedUsersTitle),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<BlockedUser>>(
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
                  Center(
                    child: Text(
                      AppTexts.blockedUsersLoadError,
                      style: textTheme.bodyMedium?.copyWith(color: scheme.error),
                    ),
                  ),
                ],
              );
            }
            final items = snapshot.data ?? const <BlockedUser>[];
            if (items.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: 100),
                  Center(
                    child: Text(
                      AppTexts.blockedUsersEmpty,
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
                final u = items[i];
                final busy = _unblocking.contains(u.userId);
                return ListTile(
                  leading: UserAvatar(path: u.avatarPath, size: 44),
                  title: Text(u.displayName),
                  trailing: TextButton(
                    onPressed: busy ? null : () => _unblock(u),
                    child: busy
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(AppTexts.blockedUsersUnblockCta),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
