import 'package:flutter_test/flutter_test.dart';

import 'package:incacook/features/orders/data/order_summary.dart';

OrderSummary _order({
  required String status,
  String fulfillmentChoice = 'DELIVERY',
}) {
  return OrderSummary(
    id: 'order-1',
    orderNumber: '001',
    status: status,
    buyerTotalCents: 1000,
    placedAt: DateTime.utc(2026),
    fulfillmentChoice: fulfillmentChoice,
    itemCount: 1,
  );
}

void main() {
  test('picked-up and no-driver orders remain paid', () {
    expect(_order(status: 'PICKED_UP').isPaid, isTrue);
    expect(_order(status: 'NO_DRIVER_AVAILABLE').isPaid, isTrue);
  });

  test('reception QR is reachable only during a delivery handoff', () {
    expect(_order(status: 'IN_DELIVERY').canShowReceptionQr, isTrue);
    expect(
      _order(
        status: 'IN_DELIVERY',
        fulfillmentChoice: 'PICKUP',
      ).canShowReceptionQr,
      isFalse,
    );
    expect(_order(status: 'DELIVERED').canShowReceptionQr, isFalse);
  });
}
