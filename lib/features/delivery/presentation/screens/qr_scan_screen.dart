import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'package:incacook/core/constants/sizes.dart';
import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/core/widgets/qr/qr_token.dart';

/// Driver-side camera scanner for a handoff QR (seller pickup or buyer
/// reception). Pops with the extracted token (or null if the driver backs
/// out). The QR encodes `incacook://...&token=XXX`; a bare token is also
/// accepted so the manual-entry fallback (emulators / damaged QR) works.
class QrScanScreen extends StatefulWidget {
  const QrScanScreen({
    super.key,
    required this.title,
    required this.instruction,
  });

  /// App-bar title, e.g. "Scanner le QR vendeur" / "Scanner le QR client".
  final String title;

  /// Helper line under the camera, e.g. what to scan.
  final String instruction;

  @override
  State<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends State<QrScanScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  bool _handled = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handled) return;
    for (final barcode in capture.barcodes) {
      final raw = barcode.rawValue;
      if (raw == null) continue;
      final token = handoffTokenFromPayload(raw, acceptBare: true);
      if (token != null) {
        _handled = true;
        Get.back<String>(result: token);
        return;
      }
    }
  }

  Future<void> _manualEntry() async {
    final controller = TextEditingController();
    final token = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppTexts.qrScanManualTitle),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: AppTexts.qrScanManualHint,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(AppTexts.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
            child: const Text(AppTexts.commonValidate),
          ),
        ],
      ),
    );
    final parsed = (token == null || token.isEmpty)
        ? null
        : handoffTokenFromPayload(token, acceptBare: true);
    if (parsed != null && !_handled && mounted) {
      _handled = true;
      Get.back<String>(result: parsed);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(widget.title),
      ),
      body: Stack(
        children: [
          MobileScanner(controller: _controller, onDetect: _onDetect),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.instruction,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Gap(AppSizes.sm),
                    TextButton(
                      onPressed: _manualEntry,
                      child: const Text(
                        AppTexts.qrScanManualCta,
                        style: TextStyle(
                          color: Colors.white,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
