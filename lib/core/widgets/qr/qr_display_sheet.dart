import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/core/utils/popups/blurred_modal_sheet.dart';
import 'package:incacook/core/widgets/qr/qr_token.dart';

/// Bottom sheet that renders [qrData] as a QR for the other party to scan.
/// Used by the seller (pickup proof) and the buyer (reception proof).
Future<void> showQrModal(
  BuildContext context, {
  required String title,
  required String instruction,
  required String qrData,
  String closeLabel = AppTexts.pickupQrSheetClose,
}) {
  return showBlurredModalBottomSheet<void>(
    context: context,
    builder: (_) => _QrDisplaySheet(
      title: title,
      instruction: instruction,
      qrData: qrData,
      closeLabel: closeLabel,
    ),
  );
}

class _QrDisplaySheet extends StatelessWidget {
  const _QrDisplaySheet({
    required this.title,
    required this.instruction,
    required this.qrData,
    required this.closeLabel,
  });

  final String title;
  final String instruction;
  final String qrData;
  final String closeLabel;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    // The raw proof token, pulled from the `incacook://…?token=…` payload. Shown
    // as selectable text so the handoff still works when the camera can't read
    // the QR (glare, cracked screen, one phone scanning another) — the driver's
    // scanner has a manual-entry fallback that was useless without this.
    final token = handoffTokenFromPayload(qrData);
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const Gap(AppSizes.md),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.all(20),
              child: QrImageView(
                data: qrData,
                version: QrVersions.auto,
                size: 240,
                backgroundColor: Colors.white,
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: Colors.black,
                ),
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: Colors.black,
                ),
              ),
            ),
            const Gap(AppSizes.md),
            Text(
              instruction,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            if (token != null && token.isNotEmpty) ...[
              const Gap(AppSizes.md),
              Text(
                AppTexts.qrTokenFallbackLabel,
                textAlign: TextAlign.center,
                style: textTheme.labelMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const Gap(AppSizes.xs),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.md,
                  vertical: AppSizes.sm,
                ),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SelectableText(
                  token,
                  textAlign: TextAlign.center,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ],
            const Gap(AppSizes.lg),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(closeLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
