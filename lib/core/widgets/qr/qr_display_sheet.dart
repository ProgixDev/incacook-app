import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/core/utils/popups/blurred_modal_sheet.dart';

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
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
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
              style: textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
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
