import 'package:flutter_test/flutter_test.dart';

import 'package:incacook/core/widgets/qr/qr_token.dart';

void main() {
  group('handoffTokenFromPayload', () {
    test('extracts the proof token from pickup and delivery QR payloads', () {
      expect(
        handoffTokenFromPayload(
          'incacook://pickup?deliveryId=delivery-1&token=pick%2Bup',
        ),
        'pick+up',
      );
      expect(
        handoffTokenFromPayload(
          'incacook://delivery?deliveryId=delivery-1&token=drop-off',
        ),
        'drop-off',
      );
    });

    test('accepts a bare manual code only when explicitly allowed', () {
      expect(handoffTokenFromPayload('  manual-code  '), isNull);
      expect(
        handoffTokenFromPayload('  manual-code  ', acceptBare: true),
        'manual-code',
      );
    });

    test('rejects empty or tokenless QR payloads', () {
      expect(handoffTokenFromPayload(''), isNull);
      expect(handoffTokenFromPayload('incacook://handoff?orderId=1'), isNull);
    });
  });
}
