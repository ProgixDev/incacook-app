import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// A handoff card that displays a QR code + a tappable confirmation
/// link below it. The QR encodes [qrData] (typically a short
/// `incacook://handoff?orderId=X&action=Y` URL the counterpart would
/// scan). The link triggers the same backend transition without
/// scanning — practical for emulator demos and a real-world fallback
/// when scanning fails.
///
/// [onConfirm] is awaited; while in-flight the card shows a loading
/// spinner and the link is disabled. Errors surface via the parent
/// (this widget just propagates the future).
class QrConfirmCard extends StatefulWidget {
  const QrConfirmCard({
    super.key,
    required this.title,
    required this.qrData,
    required this.linkLabel,
    required this.onConfirm,
    this.subtitle,
  });

  /// Section heading, e.g. "Code de récupération".
  final String title;

  /// Optional helper line under the title, e.g. "Montre ce code au livreur".
  final String? subtitle;

  /// Payload encoded in the QR image. Stable per handoff.
  final String qrData;

  /// Label of the tappable fallback link, e.g. "Confirmer la récupération".
  final String linkLabel;

  /// Triggered by the link tap. While pending, the link is disabled.
  final Future<void> Function() onConfirm;

  @override
  State<QrConfirmCard> createState() => _QrConfirmCardState();
}

class _QrConfirmCardState extends State<QrConfirmCard> {
  bool _submitting = false;

  Future<void> _tap() async {
    if (_submitting) return;
    setState(() => _submitting = true);
    try {
      await widget.onConfirm();
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              widget.title,
              textAlign: TextAlign.center,
              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            if (widget.subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                widget.subtitle!,
                textAlign: TextAlign.center,
                style: textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: 14),
            DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: scheme.outlineVariant),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: QrImageView(
                  data: widget.qrData,
                  version: QrVersions.auto,
                  size: 168,
                  backgroundColor: Colors.white,
                  // Eye + dot colors hard-coded to black for max scanner
                  // contrast — readability matters more than theme fit.
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
            const SizedBox(height: 12),
            // Fallback link: same action, no scanner needed. Practical
            // for emulator demos where another phone can't see the QR.
            InkWell(
              onTap: _submitting ? null : _tap,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                child: _submitting
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        widget.linkLabel,
                        style: textTheme.titleSmall?.copyWith(
                          color: scheme.primary,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                          decorationColor: scheme.primary,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}