import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

import 'package:incacook/core/common/widgets/appbar/appbar.dart';
import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/features/legal/data/legal_document.dart';
import 'package:incacook/features/legal/data/legal_documents_repository.dart';

/// Read-only CGU/CGV screen. Fetches the active CGU/CGV documents the admin
/// published (`GET /v1/legal-documents/active`) and falls back to the bundled
/// local text per-kind when the API is unreachable or a kind has no published
/// document yet — so the screen always renders. Versioning + "notify on change"
/// live server-side; this is the reader only.
class LegalTermsScreen extends StatefulWidget {
  const LegalTermsScreen({super.key});

  @override
  State<LegalTermsScreen> createState() => _LegalTermsScreenState();
}

class _LegalTermsScreenState extends State<LegalTermsScreen> {
  late final Future<List<LegalDocument>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<LegalDocument>> _load() async {
    try {
      return await LegalDocumentsRepository().fetchActive();
    } catch (_) {
      // Offline / server error → render the bundled local text instead.
      return const <LegalDocument>[];
    }
  }

  /// Combines the active CGU + CGV content with the existing divider, falling
  /// back to the bundled local text for any kind missing from [docs].
  String _compose(List<LegalDocument> docs) {
    final cgu = _contentOr(docs, (d) => d.isCgu, AppTexts.signupCguText);
    final cgv = _contentOr(docs, (d) => d.isCgv, AppTexts.signupCgvText);
    return '$cgu\n\n────────\n\n$cgv';
  }

  String _contentOr(
    List<LegalDocument> docs,
    bool Function(LegalDocument) test,
    String fallback,
  ) {
    for (final d in docs) {
      if (test(d) && d.content.trim().isNotEmpty) return d.content.trim();
    }
    return fallback;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: CustomAppBar(
        showBackArrow: true,
        title: Text(
          AppTexts.legalTermsTitle,
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      body: FutureBuilder<List<LegalDocument>>(
        future: _future,
        builder: (context, snapshot) {
          // Before the request resolves, snapshot.data is null → the compose
          // helper yields the full local fallback, so there's never a blank
          // screen or spinner flash.
          final text = _compose(snapshot.data ?? const <LegalDocument>[]);
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.lg),
            child: Text(
              text,
              style: textTheme.bodyMedium?.copyWith(height: 1.45),
            ),
          );
        },
      ),
    );
  }
}

/// Required CGU/CGV consent row: a checkbox ("J'accepte les CGU/CGV") plus a
/// "Lire les CGU/CGV" link opening [LegalTermsScreen]. Shared by the order
/// purchase + dish publication flows so the wording + behaviour stay identical.
class TermsConsentTile extends StatelessWidget {
  const TermsConsentTile({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 28,
          height: 28,
          child: Checkbox(
            value: value,
            onChanged: (v) => onChanged(v ?? false),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        const Gap(AppSizes.sm),
        Expanded(
          child: GestureDetector(
            onTap: () => onChanged(!value),
            child: Text(
              AppTexts.termsAcceptCheckbox,
              style: textTheme.bodyMedium,
            ),
          ),
        ),
        TextButton(
          onPressed: () => Get.to<void>(() => const LegalTermsScreen()),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            AppTexts.termsReadLink,
            style: textTheme.bodySmall?.copyWith(
              color: scheme.primary,
              fontWeight: FontWeight.w700,
              decoration: TextDecoration.underline,
              decorationColor: scheme.primary,
            ),
          ),
        ),
      ],
    );
  }
}
