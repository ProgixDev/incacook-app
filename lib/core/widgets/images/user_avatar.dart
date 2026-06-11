import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import 'package:incacook/core/constants/api_constants.dart';

/// Round avatar for a user/peer. Renders the stored photo — a Supabase
/// storage object key (resolved to a public URL) or an already-absolute
/// URL — and falls back to a generic person silhouette when there's no
/// photo or it fails to load.
///
/// Used by the conversations inbox, the chat header, and anywhere a peer's
/// photo + neutral default is needed.
class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, required this.path, this.size = 48});

  /// Stored avatar value: a storage object key, a full URL, or null/empty.
  final String? path;
  final double size;

  String? get _url {
    final v = path;
    if (v == null || v.isEmpty) return null;
    if (v.startsWith('http')) return v;
    return ApiConstants.publicImageUrl(v);
  }

  @override
  Widget build(BuildContext context) {
    final url = _url;
    if (url == null) return _DefaultAvatar(size: size);
    return ClipOval(
      child: Image.network(
        url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _DefaultAvatar(size: size),
      ),
    );
  }
}

class _DefaultAvatar extends StatelessWidget {
  const _DefaultAvatar({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: scheme.primary.withValues(alpha: 0.10),
      ),
      alignment: Alignment.center,
      child: Icon(
        Iconsax.user,
        size: size * 0.5,
        color: scheme.primary.withValues(alpha: 0.65),
      ),
    );
  }
}
