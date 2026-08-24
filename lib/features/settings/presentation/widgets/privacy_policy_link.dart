import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:incacook/core/constants/text_strings.dart';

/// Small reusable "Lire la politique de confidentialité" link — opens
/// [AppTexts.privacyPolicyUrl] externally. Used wherever a consent flow
/// (KYC selfie, CGU/CGV) needs to reference the privacy policy inline.
class PrivacyPolicyLink extends StatelessWidget {
  const PrivacyPolicyLink({super.key, this.label = AppTexts.kycConsentReadPrivacyLink});

  final String label;

  Future<void> _open(BuildContext context) async {
    final uri = Uri.tryParse(AppTexts.privacyPolicyUrl);
    final opened =
        uri != null && await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppTexts.supportUnavailable)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return TextButton(
      onPressed: () => _open(context),
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: scheme.primary,
              fontWeight: FontWeight.w700,
              decoration: TextDecoration.underline,
              decorationColor: scheme.primary,
            ),
      ),
    );
  }
}
