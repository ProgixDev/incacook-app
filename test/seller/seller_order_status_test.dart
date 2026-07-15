import 'package:flutter_test/flutter_test.dart';

import 'package:incacook/features/seller/domain/accepted_order.dart';
import 'package:incacook/features/seller/domain/seller_order_status.dart';

/// Pure status → bucket / status → badge maps behind the seller Commandes
/// screen. These lock the two shipped bugs: a fresh CONFIRMED order must NOT
/// land in Historique, and a cancelled/no-driver order must NEVER read as an
/// active "En préparation" badge. Every backend OrderStatus is asserted so a
/// future status can't silently regress into the wrong pane.
void main() {
  const active = ['PREPARING', 'READY', 'IN_DELIVERY', 'PICKED_UP'];
  const terminal = [
    'DELIVERED',
    'COMPLETED',
    'CANCELLED',
    'REFUNDED',
    'DISPUTED',
    'NO_DRIVER_AVAILABLE',
  ];

  group('sellerOrderBucket', () {
    test('CONFIRMED awaits acceptance (never history, never active)', () {
      expect(sellerOrderBucket('CONFIRMED'), SellerOrderBucket.toAccept);
    });

    test('unpaid PENDING orders are hidden from the seller', () {
      expect(sellerOrderBucket('PENDING'), SellerOrderBucket.hidden);
    });

    test('in-progress statuses are active', () {
      for (final s in active) {
        expect(sellerOrderBucket(s), SellerOrderBucket.active, reason: s);
      }
    });

    test('terminal + cancelled + no-driver are history', () {
      for (final s in terminal) {
        expect(sellerOrderBucket(s), SellerOrderBucket.history, reason: s);
      }
    });

    test('unknown status stays visible (active), never hidden in history', () {
      expect(sellerOrderBucket('SOME_FUTURE_STATUS'), SellerOrderBucket.active);
    });
  });

  group('sellerOrderBadge', () {
    test('CONFIRMED → awaitingAccept', () {
      expect(sellerOrderBadge('CONFIRMED'), AcceptedOrderStatus.awaitingAccept);
    });

    test(
      'cancelled / refunded / disputed / no-driver → cancelled (the bug)',
      () {
        for (final s in [
          'CANCELLED',
          'REFUNDED',
          'DISPUTED',
          'NO_DRIVER_AVAILABLE',
        ]) {
          expect(sellerOrderBadge(s), AcceptedOrderStatus.cancelled, reason: s);
        }
      },
    );

    test('active handoff states have truthful badges', () {
      expect(sellerOrderBadge('READY'), AcceptedOrderStatus.readyToPickup);
      expect(sellerOrderBadge('PICKED_UP'), AcceptedOrderStatus.pickedUp);
      expect(sellerOrderBadge('IN_DELIVERY'), AcceptedOrderStatus.inDelivery);
    });

    test('DELIVERED / COMPLETED → completed', () {
      expect(sellerOrderBadge('DELIVERED'), AcceptedOrderStatus.completed);
      expect(sellerOrderBadge('COMPLETED'), AcceptedOrderStatus.completed);
    });

    test('PENDING / PREPARING → preparing', () {
      expect(sellerOrderBadge('PENDING'), AcceptedOrderStatus.preparing);
      expect(sellerOrderBadge('PREPARING'), AcceptedOrderStatus.preparing);
    });

    test('a cancelled order never reads as an active badge', () {
      expect(
        sellerOrderBadge('CANCELLED'),
        isNot(AcceptedOrderStatus.preparing),
      );
      expect(
        sellerOrderBadge('NO_DRIVER_AVAILABLE'),
        isNot(AcceptedOrderStatus.readyToPickup),
      );
    });
  });

  group('sellerCancellationBanner', () {
    test('surfaces every supplied cancellation reason', () {
      expect(
        sellerCancellationBanner(
          status: 'CANCELLED',
          reason: 'driver_disappeared',
        ),
        SellerCancellationBanner.driverIncident,
      );
      expect(
        sellerCancellationBanner(
          status: 'REFUNDED',
          reason: 'a_future_backend_reason',
        ),
        SellerCancellationBanner.generic,
      );
    });

    test('does not invent a reason when none was supplied', () {
      expect(
        sellerCancellationBanner(status: 'CANCELLED', reason: null),
        isNull,
      );
      expect(
        sellerCancellationBanner(status: 'DELIVERED', reason: 'anything'),
        isNull,
      );
    });
  });

  group('sellerCanShowPickupQr', () {
    test('pickup proof is available only before the driver handoff', () {
      expect(sellerCanShowPickupQr('READY'), isTrue);
      expect(sellerCanShowPickupQr('IN_DELIVERY'), isFalse);
      expect(sellerCanShowPickupQr('DELIVERED'), isFalse);
      expect(sellerCanShowPickupQr('CANCELLED'), isFalse);
    });
  });

  group('sellerCanContactDriver', () {
    bool canContact(
      String status, {
      bool driverAssigned = true,
      String fulfillment = 'DELIVERY',
    }) => sellerCanContactDriver(
      backendStatus: status,
      fulfillmentChoice: fulfillment,
      driverAssigned: driverAssigned,
    );

    // The shipped bug: READY is entered by mark-ready, which creates the
    // delivery with driverId=NULL, so an order is READY-with-no-driver for the
    // whole dispatch window. Offering the chat there produced a 400 on every
    // tap — not a rare race, the common case.
    test('hidden while READY has no driver yet', () {
      expect(canContact('READY', driverAssigned: false), isFalse);
    });

    test('shown once a driver holds the order', () {
      expect(canContact('READY'), isTrue);
      expect(canContact('IN_DELIVERY'), isTrue);
    });

    test('hidden for pickup orders, which never get a driver', () {
      expect(canContact('READY', fulfillment: 'PICKUP'), isFalse);
    });

    test('hidden before dispatch and after the order ends', () {
      for (final status in ['CONFIRMED', 'PREPARING']) {
        expect(canContact(status), isFalse, reason: '$status is pre-dispatch');
      }
      for (final status in ['DELIVERED', 'COMPLETED', 'CANCELLED']) {
        expect(canContact(status), isFalse, reason: '$status is terminal');
      }
    });
  });
}
