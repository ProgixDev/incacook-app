import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:incacook/core/widgets/qr/qr_display_sheet.dart';

void main() {
  testWidgets('handoff sheet renders the raw token as selectable text', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => showQrModal(
              context,
              title: 'QR',
              instruction: 'Présentez le code',
              qrData: 'incacook://delivery?token=manual-123',
            ),
            child: const Text('Open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    final selectable = tester.widget<SelectableText>(
      find.byType(SelectableText),
    );
    expect(selectable.data, 'manual-123');
  });
}
