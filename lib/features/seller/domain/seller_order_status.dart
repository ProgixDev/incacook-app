import 'package:incacook/features/seller/domain/accepted_order.dart';

/// Which pane of the seller Commandes screen an order belongs in, derived
/// purely from its backend `OrderStatus`. Kept exhaustive and Flutter-free so
/// no status can silently fall into the wrong bucket — that "not-active ⇒
/// history" gap is what put fresh `CONFIRMED` orders in Historique and made
/// cancelled orders read as "En préparation".
enum SellerOrderBucket {
  /// Unpaid checkout rows are not actionable seller orders.
  hidden,

  /// Awaiting the seller's accept/reject decision (`CONFIRMED`).
  toAccept,

  /// Accepted and in progress — being prepared, ready, or out for delivery.
  active,

  /// Terminal — delivered/completed, or cancelled/refunded/disputed/no-driver.
  history,
}

enum SellerCancellationBanner {
  noFood,
  noDriver,
  driverIncident,
  sellerCannotProvide,
  generic,
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
    case _pending:
      return SellerOrderBucket.hidden;
    case _confirmed:
      return SellerOrderBucket.toAccept;
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

/// Pickup proof is meaningful only while the order is waiting for pickup.
bool sellerCanShowPickupQr(String backendStatus) => backendStatus == _ready;

/// Whether to offer the seller↔driver chat.
///
/// [driverAssigned] is load-bearing, not belt-and-braces: `READY` begins when
/// the seller marks the food ready — which spawns the delivery with no driver —
/// and stays `READY` after a driver claims it. Gating on status alone therefore
/// offered a chat for the whole dispatch window, where it could only fail. The
/// backend still rejects an unassigned open, so the error path remains the
/// fallback for the claim-between-fetch-and-tap race.
bool sellerCanContactDriver({
  required String backendStatus,
  required String fulfillmentChoice,
  required bool driverAssigned,
}) =>
    fulfillmentChoice == 'DELIVERY' &&
    driverAssigned &&
    (backendStatus == _ready || backendStatus == _inDelivery);

/// The display badge for an order, from its backend status. Every real
/// `OrderStatus` is handled explicitly so a terminal state can never render as
/// an active one (the "cancelled shows as En préparation" bug).
AcceptedOrderStatus sellerOrderBadge(String backendStatus) {
  switch (backendStatus) {
    case _confirmed:
      return AcceptedOrderStatus.awaitingAccept;
    case _ready:
      return AcceptedOrderStatus.readyToPickup;
    case _pickedUp:
      return AcceptedOrderStatus.pickedUp;
    case _inDelivery:
      return AcceptedOrderStatus.inDelivery;
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
      return AcceptedOrderStatus.preparing;
    default:
      return AcceptedOrderStatus.preparing;
  }
}

SellerCancellationBanner? sellerCancellationBanner({
  required String status,
  required String? reason,
}) {
  if (status != _cancelled && status != _refunded) return null;
  final normalized = reason?.trim();
  if (normalized == null || normalized.isEmpty) return null;
  return switch (normalized) {
    'seller_unavailable' => SellerCancellationBanner.noFood,
    'driver_disappeared' => SellerCancellationBanner.driverIncident,
    'seller_cannot_provide' => SellerCancellationBanner.sellerCannotProvide,
    'buyer_no_response_after_no_driver' ||
    'no_driver_buyer_cancelled' => SellerCancellationBanner.noDriver,
    _ => SellerCancellationBanner.generic,
  };
}
