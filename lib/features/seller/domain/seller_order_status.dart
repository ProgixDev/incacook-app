import 'package:incacook/features/seller/domain/accepted_order.dart';

/// Which pane of the seller Commandes screen an order belongs in, derived
/// purely from its backend `OrderStatus`. Kept exhaustive and Flutter-free so
/// no status can silently fall into the wrong bucket — that "not-active ⇒
/// history" gap is what put fresh `CONFIRMED` orders in Historique and made
/// cancelled orders read as "En préparation".
enum SellerOrderBucket {
  /// Awaiting the seller's accept/reject decision (`CONFIRMED`).
  toAccept,

  /// Accepted and in progress — being prepared, ready, or out for delivery.
  active,

  /// Terminal — delivered/completed, or cancelled/refunded/disputed/no-driver.
  history,
}

// Backend OrderStatus strings (mirror the server `OrderStatus` enum).
const _confirmed = 'CONFIRMED';
const _pending = 'PENDING';
const _preparing = 'PREPARING';
const _ready = 'READY';
const _inDelivery = 'IN_DELIVERY';
const _pickedUp = 'PICKED_UP';
const _delivered = 'DELIVERED';
const _completed = 'COMPLETED';
const _cancelled = 'CANCELLED';
const _refunded = 'REFUNDED';
const _disputed = 'DISPUTED';
const _noDriver = 'NO_DRIVER_AVAILABLE';

/// The seller tab an order belongs in, from its backend status.
SellerOrderBucket sellerOrderBucket(String backendStatus) {
  switch (backendStatus) {
    case _confirmed:
      return SellerOrderBucket.toAccept;
    case _pending:
    case _preparing:
    case _ready:
    case _inDelivery:
    case _pickedUp:
      return SellerOrderBucket.active;
    case _delivered:
    case _completed:
    case _cancelled:
    case _refunded:
    case _disputed:
    case _noDriver:
      return SellerOrderBucket.history;
    default:
      // Unknown/future status: keep it visible in the in-progress pane rather
      // than hiding it in history — a seller-actionable order must never vanish.
      return SellerOrderBucket.active;
  }
}

/// The display badge for an order, from its backend status. Every real
/// `OrderStatus` is handled explicitly so a terminal state can never render as
/// an active one (the "cancelled shows as En préparation" bug).
AcceptedOrderStatus sellerOrderBadge(String backendStatus) {
  switch (backendStatus) {
    case _confirmed:
      return AcceptedOrderStatus.awaitingAccept;
    case _ready:
    case _inDelivery:
      return AcceptedOrderStatus.readyToPickup;
    case _delivered:
    case _completed:
      return AcceptedOrderStatus.completed;
    case _cancelled:
    case _refunded:
    case _disputed:
    case _noDriver:
      return AcceptedOrderStatus.cancelled;
    case _pending:
    case _preparing:
    case _pickedUp:
      return AcceptedOrderStatus.preparing;
    default:
      return AcceptedOrderStatus.preparing;
  }
}
