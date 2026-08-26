import 'package:flutter_test/flutter_test.dart';

import 'package:incacook/core/constants/text_strings.dart';
import 'package:incacook/features/delivery/controllers/incoming_order_controller.dart';
import 'package:incacook/features/delivery/data/deliveries_repository.dart';
import 'package:incacook/features/orders/data/order_mock_data.dart';

DeliverySummary _summary({
  String orderNumber = 'B0042',
  String dropoffCity = 'Lyon',
  String dropoffPostalCode = '69001',
  String? dropoffFullAddress = '5 rue de la République',
  int? itemCount = 4,
}) {
  return DeliverySummary(
    id: 'delivery-1',
    orderId: 'order-1',
    orderNumber: orderNumber,
    feeCents: 350,
    dropoffCity: dropoffCity,
    dropoffPostalCode: dropoffPostalCode,
    sellerName: 'Real Seller',
    sellerNeighborhood: 'Real Neighborhood',
    recipientName: 'Real Recipient',
    pickupLat: 45.75,
    pickupLng: 4.85,
    dropoffLat: 45.76,
    dropoffLng: 4.86,
    dropoffFullAddress: dropoffFullAddress,
    orderTotalCents: 2500,
    itemCount: itemCount,
  );
}

void main() {
  final mock = OrderMockData.demoOrder();

  test('a complete backend summary renders only real values, never the mock', () {
    final summary = _summary();
    final order = IncomingOrderController.hydrateFromSummary(summary);

    expect(order.orderNumber, 'B0042');
    expect(order.orderNumber, isNot(mock.orderNumber));
    expect(order.deliveryDetails!.address.fullAddress, '5 rue de la République');
    expect(order.deliveryDetails!.address.fullAddress, isNot(mock.deliveryDetails!.address.fullAddress));
    expect(order.deliveryDetails!.address.city, 'Lyon');
    expect(order.deliveryDetails!.address.postalCode, '69001');
    expect(order.itemCount, 4);
    expect(order.itemCount, isNot(mock.itemCount));
  });

  test('a missing dropoff address renders a neutral placeholder, not the mock address', () {
    final summary = _summary(dropoffFullAddress: null);
    final order = IncomingOrderController.hydrateFromSummary(summary);

    expect(
      order.deliveryDetails!.address.fullAddress,
      AppTexts.incomingOrderAddressUnavailable,
    );
    expect(
      order.deliveryDetails!.address.fullAddress,
      isNot(mock.deliveryDetails!.address.fullAddress),
    );
  });

  test('a missing item count falls back to 1, not the mock template count', () {
    final summary = _summary(itemCount: null);
    final order = IncomingOrderController.hydrateFromSummary(summary);

    expect(order.itemCount, 1);
    expect(order.itemCount, isNot(mock.itemCount));
  });

  test('a missing order number renders a neutral placeholder, not the mock number', () {
    final summary = _summary(orderNumber: '');
    final order = IncomingOrderController.hydrateFromSummary(summary);

    expect(order.orderNumber, AppTexts.incomingOrderNumberUnavailable);
    expect(order.orderNumber, isNot(mock.orderNumber));
  });

  test('seller identity still uses the generic fallback, never mock data', () {
    final summary = _summary().copyWithSeller();
    final order = IncomingOrderController.hydrateFromSummary(summary);

    expect(order.seller.name, isNot(mock.seller.name));
  });
}

extension on DeliverySummary {
  // Small helper so the seller-fallback regression test doesn't repeat the
  // full summary constructor above.
  DeliverySummary copyWithSeller() => DeliverySummary(
        id: id,
        orderId: orderId,
        orderNumber: orderNumber,
        feeCents: feeCents,
        dropoffCity: dropoffCity,
        dropoffPostalCode: dropoffPostalCode,
        sellerName: null,
        sellerNeighborhood: null,
        recipientName: recipientName,
        pickupLat: pickupLat,
        pickupLng: pickupLng,
        dropoffLat: dropoffLat,
        dropoffLng: dropoffLng,
        dropoffFullAddress: dropoffFullAddress,
        orderTotalCents: orderTotalCents,
        itemCount: itemCount,
      );
}
