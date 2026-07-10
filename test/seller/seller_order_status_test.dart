import 'package:flutter_test/flutter_test.dart';

import 'package:incacook/features/seller/domain/accepted_order.dart';
import 'package:incacook/features/seller/domain/seller_order_status.dart';

/// Pure status → bucket / status → badge maps behind the seller Commandes
/// screen. These lock the two shipped bugs: a fresh CONFIRMED order must NOT
/// land in Historique, and a cancelled/no-driver order must NEVER read as an
/// active "En préparation" badge. Every backend OrderStatus is asserted so a
/// future status can't silently regress into the wrong pane.
void main() {
  const active = [
    'PENDING',
    'PREPARING',
    'READY',
    'IN_DELIVERY',
    'PICKED_UP',
  ];
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

    test('cancelled / refunded / disputed / no-driver → cancelled (the bug)', () {
      for (final s in ['CANCELLED', 'REFUNDED', 'DISPUTED', 'NO_DRIVER_AVAILABLE']) {
        expect(sellerOrderBadge(s), AcceptedOrderStatus.cancelled, reason: s);
      }
    });

    test('READY / IN_DELIVERY → readyToPickup', () {
      expect(sellerOrderBadge('READY'), AcceptedOrderStatus.readyToPickup);
      expect(sellerOrderBadge('IN_DELIVERY'), AcceptedOrderStatus.readyToPickup);
    });

    test('DELIVERED / COMPLETED → completed', () {
      expect(sellerOrderBadge('DELIVERED'), AcceptedOrderStatus.completed);
      expect(sellerOrderBadge('COMPLETED'), AcceptedOrderStatus.completed);
    });

    test('PENDING / PREPARING / PICKED_UP → preparing', () {
      expect(sellerOrderBadge('PENDING'), AcceptedOrderStatus.preparing);
      expect(sellerOrderBadge('PREPARING'), AcceptedOrderStatus.preparing);
      expect(sellerOrderBadge('PICKED_UP'), AcceptedOrderStatus.preparing);
    });

    test('a cancelled order never reads as an active badge', () {
      expect(sellerOrderBadge('CANCELLED'), isNot(AcceptedOrderStatus.preparing));
      expect(
        sellerOrderBadge('NO_DRIVER_AVAILABLE'),
        isNot(AcceptedOrderStatus.readyToPickup),
      );
    });
  });
}
