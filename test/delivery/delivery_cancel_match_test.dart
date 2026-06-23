import 'package:flutter_test/flutter_test.dart';

import 'package:incacook/core/services/realtime/delivery_cancelled_event.dart';
import 'package:incacook/features/delivery/controllers/delivery_route_controller.dart';

/// Pure decision behind the driver active-job auto-clear: a realtime
/// `delivery:cancelled` event only clears the job when it targets the active
/// delivery/order — an unrelated event is ignored.
void main() {
  DeliveryCancelledEvent event({
    String deliveryId = 'd1',
    String orderId = 'o1',
    String message = 'Cette livraison a été annulée.',
  }) =>
      DeliveryCancelledEvent(
        deliveryId: deliveryId,
        orderId: orderId,
        status: 'CANCELLED',
        reason: 'seller_cannot_provide',
        message: message,
      );

  test('parses the realtime payload', () {
    final ev = DeliveryCancelledEvent.fromJson({
      'deliveryId': 'd1',
      'orderId': 'o1',
      'status': 'CANCELLED',
      'reason': 'seller_cannot_provide',
      'message': 'La commande a été annulée par le vendeur.',
    });
    expect(ev.deliveryId, 'd1');
    expect(ev.message, 'La commande a été annulée par le vendeur.');
  });

  test('matches the active job by deliveryId', () {
    expect(
      DeliveryRouteController.cancelMatchesJob(event(), activeDeliveryId: 'd1', activeOrderId: null),
      isTrue,
    );
  });

  test('matches the active job by orderId', () {
    expect(
      DeliveryRouteController.cancelMatchesJob(event(), activeDeliveryId: null, activeOrderId: 'o1'),
      isTrue,
    );
  });

  test('does not match an unrelated delivery/order', () {
    expect(
      DeliveryRouteController.cancelMatchesJob(
        event(deliveryId: 'OTHER', orderId: 'OTHER'),
        activeDeliveryId: 'd1',
        activeOrderId: 'o1',
      ),
      isFalse,
    );
  });

  test('does not match when there is no active job', () {
    expect(
      DeliveryRouteController.cancelMatchesJob(event(), activeDeliveryId: null, activeOrderId: null),
      isFalse,
    );
  });
}
