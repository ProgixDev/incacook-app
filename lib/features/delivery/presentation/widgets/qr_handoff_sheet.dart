import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/core/utils/popups/blurred_modal_sheet.dart';

/// QR-handoff confirmation modal shown by the driver before they
/// advance through pickup / dropoff. The seller (at pickup) or buyer
/// (at dropoff) would scan the rendered QR in production; on emulator
/// the driver taps Continue to advance. Resolves `true` on confirm
/// and `null` if dismissed.
///
/// [qrData] is the payload encoded in the QR — typically a short
/// `incacook://handoff?orderId=...&action=...` URL. Defaults to a
/// neutral placeholder so callers that haven't passed real ids yet
/// still render a scannable image.
Future<bool?> showQrHandoffModal(
  BuildContext context, {
  String qrData = 'incacook://handoff',
  String? title,
}) {
  return showBlurredModalBottomSheet<bool>(
    context: context,
    builder: (_) => QrHandoffSheet(qrData: qrData, title: title),
  );
}

class QrHandoffSheet extends StatelessWidget {
  const QrHandoffSheet({super.key, required this.qrData, this.title});

  final String qrData;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    //? full screen height so the QR can sit at true vertical center while
    //? the Continue button anchors to the bottom safe-area. The dark tint
    //? sits on top of the helper's BackdropFilter to deepen contrast.
    return Container(
      height: MediaQuery.of(context).size.height,
      color: Colors.black.withValues(alpha: 0.25),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.lg),
          child: Column(
            children: [
              if (title != null) ...[
                const SizedBox(height: AppSizes.md),
                Text(
                  title!,
                  textAlign: TextAlign.center,
                  style: textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
              Expanded(
                child: Center(
                  child: Container(
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
                ),
              ),
              // Tap-instead-of-scan path: always shown under the QR
              // as a clearly clickable underlined link. Same effect as
              // a successful scan — parent advances the stage, which
              // fires the backend transition and broadcasts the new
              // order status to the buyer.
              const SizedBox(height: AppSizes.md),
              InkWell(
                onTap: () => Navigator.of(context).pop(true),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.md,
                    vertical: AppSizes.sm,
                  ),
                  child: Text(
                    AppTexts.qrHandoffContinueCta,
                    style: textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}