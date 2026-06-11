import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

import 'package:incacook/core/common/widgets/appbar/appbar.dart';
import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/constants/text_strings.dart';

/// Read-only CGU/CGV screen. Reuses the existing legal text constants so the
/// same source backs signup, publication and purchase. Versioning + "notify on
/// change" live server-side (ACTIVE_CHARTER_VERSIONS); this is the reader only.
class LegalTermsScreen extends StatelessWidget {
  const LegalTermsScreen({super.key});

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Text(
          '${AppTexts.signupCguText}\n\n────────\n\n${AppTexts.signupCgvText}',
          style: textTheme.bodyMedium?.copyWith(height: 1.45),
        ),
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
