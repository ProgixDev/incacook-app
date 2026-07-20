import 'package:flutter_test/flutter_test.dart';

import 'package:incacook/features/wallet/data/wallet_models.dart';

WalletEntry _entry(String type) {
  return WalletEntry(
    id: 'entry-1',
    type: type,
    amountCents: -500,
    status: 'AVAILABLE',
    createdAt: DateTime.utc(2026),
  );
}

void main() {
  test('every backend WalletEntryType has a non-fallback French label', () {
    // Mirrors the Prisma WalletEntryType enum exactly (schema.prisma) —
    // a type falling through to the `default: return type` branch means the
    // user sees the raw backend enum string instead of a label.
    const backendTypes = [
      'ORDER_EARNING',
      'DELIVERY_EARNING',
      'COMMISSION',
      'REFUND',
      'WITHDRAWAL',
      'DRIVER_DEBT',
      'SELLER_DEBT',
      'PLATFORM_FEE',
    ];

    for (final type in backendTypes) {
      expect(
        _entry(type).label,
        isNot(equals(type)),
        reason: '$type fell through to the default case and rendered as '
            'the raw enum string',
      );
    }
  });

  test('SELLER_DEBT mirrors DRIVER_DEBT\'s label', () {
    expect(_entry('SELLER_DEBT').label, _entry('DRIVER_DEBT').label);
  });
}
