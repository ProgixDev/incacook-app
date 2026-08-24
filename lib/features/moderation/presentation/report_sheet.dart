import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/network/api_response.dart';
import 'package:incacook/features/moderation/data/reports_repository.dart';

class _ReportOption {
  const _ReportOption(this.label, this.value);
  final String label;
  final String value;
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md,
          vertical: AppSizes.md - 2,
        ),
        decoration: BoxDecoration(
          color: selected
              ? scheme.primary.withValues(alpha: 0.08)
              : scheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? scheme.primary
                : scheme.outline.withValues(alpha: 0.4),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              size: 20,
              color: selected ? scheme.primary : scheme.outline,
            ),
            const Gap(AppSizes.sm),
            Expanded(child: Text(label)),
          ],
        ),
      ),
    );
  }
}

/// What a report targets — drives the reason set offered and the request
/// payload's target field (#54 added [message] and [user] alongside the
/// original dish/seller reporting).
enum ReportTarget { listing, message, user }

/// Bottom sheet to report a dish, a chat message, or a user. The reason set
/// adapts to [target] — "Non fait maison" only for FAIT_MAISON listings (the
/// backend also enforces this). Submits to `POST /v1/reports`; pops `true`
/// on success.
class ReportSheet extends StatefulWidget {
  const ReportSheet({
    super.key,
    this.target = ReportTarget.listing,
    this.listingId,
    this.sellerId,
    this.messageId,
    this.userId,
    this.isFaitMaison = false,
  });

  final ReportTarget target;
  final String? listingId;
  final String? sellerId;
  final String? messageId;
  final String? userId;
  final bool isFaitMaison;

  /// Reports a dish listing. Preserved for existing call sites.
  static Future<bool?> show(
    BuildContext context, {
    required String listingId,
    required bool isFaitMaison,
  }) {
    return _showSheet(
      context,
      ReportSheet(
        listingId: listingId,
        isFaitMaison: isFaitMaison,
      ),
    );
  }

  /// Reports a single chat message (#54) — reachable via long-press.
  static Future<bool?> showForMessage(
    BuildContext context, {
    required String messageId,
  }) {
    return _showSheet(
      context,
      ReportSheet(target: ReportTarget.message, messageId: messageId),
    );
  }

  /// Reports a user directly (#54) — reachable from the chat header.
  static Future<bool?> showForUser(
    BuildContext context, {
    required String userId,
  }) {
    return _showSheet(
      context,
      ReportSheet(target: ReportTarget.user, userId: userId),
    );
  }

  static Future<bool?> _showSheet(BuildContext context, ReportSheet sheet) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => sheet,
    );
  }

  @override
  State<ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends State<ReportSheet> {
  String? _type;
  final TextEditingController _comment = TextEditingController();
  bool _submitting = false;
  String? _error;

  String get _title => switch (widget.target) {
    ReportTarget.listing => 'Signaler ce plat',
    ReportTarget.message => 'Signaler ce message',
    ReportTarget.user => 'Signaler cet utilisateur',
  };

  List<_ReportOption> get _options => switch (widget.target) {
    ReportTarget.listing => [
        if (widget.isFaitMaison)
          const _ReportOption('Non fait maison', 'NON_FAIT_MAISON'),
        const _ReportOption('Mauvaise hygiène', 'MAUVAISE_HYGIENE'),
        const _ReportOption('Autre', 'OTHER'),
      ],
    ReportTarget.message => const [
        _ReportOption('Spam', 'SPAM'),
        _ReportOption('Contenu inapproprié', 'INAPPROPRIATE'),
        _ReportOption('Contenu offensant', 'OFFENSIVE'),
        _ReportOption('Autre', 'OTHER'),
      ],
    ReportTarget.user => const [
        _ReportOption('Spam', 'SPAM'),
        _ReportOption('Comportement inapproprié', 'INAPPROPRIATE'),
        _ReportOption('Comportement offensant', 'OFFENSIVE'),
        _ReportOption('Faux profil', 'FAKE'),
        _ReportOption('Autre', 'OTHER'),
      ],
  };

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final type = _type;
    if (type == null) {
      setState(() => _error = 'Choisis un motif de signalement.');
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await ReportsRepository().submit(
        type: type,
        listingId: widget.listingId,
        sellerId: widget.sellerId,
        messageId: widget.messageId,
        userId: widget.userId,
        reason: _comment.text,
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on ApiFailure catch (e) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = e.message;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.lg,
          AppSizes.md,
          AppSizes.lg,
          AppSizes.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: scheme.onSurface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Gap(AppSizes.md),
            Text(
              _title,
              style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const Gap(AppSizes.lg),
            for (final o in _options) ...[
              _OptionTile(
                label: o.label,
                selected: _type == o.value,
                onTap: () => setState(() => _type = o.value),
              ),
              const Gap(AppSizes.sm),
            ],
            const Gap(AppSizes.sm),
            TextField(
              controller: _comment,
              maxLines: 3,
              maxLength: 1000,
              decoration: const InputDecoration(
                labelText: 'Commentaire (optionnel)',
                hintText: 'Détaille ton signalement…',
              ),
            ),
            if (_error != null) ...[
              const Gap(AppSizes.sm),
              Text(_error!, style: TextStyle(color: scheme.error)),
            ],
            const Gap(AppSizes.md),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitting ? null : _submit,
                child: _submitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Envoyer le signalement'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
