import 'package:flutter/material.dart';

import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/core/utils/popups/blurred_modal_sheet.dart';

/// Mock QR-handoff confirmation. Shown before pickup and dropoff handoffs;
/// the seller / customer would scan the rendered QR in production. Resolves
/// to `true` if the driver tapped Continue, `null` if dismissed.
Future<bool?> showQrHandoffModal(BuildContext context) {
  return showBlurredModalBottomSheet<bool>(
    context: context,
    builder: (_) => const QrHandoffSheet(),
  );
}

class QrHandoffSheet extends StatelessWidget {
  const QrHandoffSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
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
              Expanded(
                child: Center(
                  child: Icon(
                    Icons.qr_code_2,
                    size: 240,
                    color: scheme.onSurface,
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text(AppTexts.qrHandoffContinueCta),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
