# Feature Spec: Order Lifecycle & Tracking (seller + buyer)

**Feature ID**: `007-order-lifecycle-tracking`
**Created**: 2026-06-30
**Status**: Implemented — copy bug
**Mobile module**: `lib/features/orders`, `lib/features/seller`
**Wire contract**: order lifecycle + QR + tracking endpoints (`/v1/orders/*`,
`/v1/sellers/me/orders/*`), `docs/client-feedback.md` §1.4

## User Story

As a seller I want to accept/prepare/hand off orders; as a buyer I want to
track my order accurately whether it's pickup or delivery.

## Current Behavior

- Seller side (`seller_orders_repository.dart`): list incoming, `cancel`,
  `cannot-provide`, `start-preparing`, `mark-ready`, `pickup-qr`. Screens
  `order_requests`, `seller_home` wired.
- Buyer side: `order_tracking_controller.dart` reads `GET /v1/orders/:id/tracking`;
  `orders_history_screen → dispute_screen` for disputes; QR handoff via
  `qr_flutter` / `mobile_scanner`; live updates via `tracking_socket_client`.
- Full backend lifecycle exists: `OrderStatus` / `DeliveryStatus` enums,
  no-driver-decision, delivery-proof, disputes.
- Seller lists exclude unpaid `PENDING` checkout rows. The mobile seller bucket
  also hides them defensively if an older server returns one.
- Pickup proof is exposed only while an order is `READY`; reception proof is
  exposed only while it is `IN_DELIVERY`.
- A no-driver timeout atomically moves the order to `NO_DRIVER_AVAILABLE` and
  retires its `SEARCHING` delivery. Available-job and claim queries independently
  require the parent order to remain `READY`, closing stale-list claim races.
- QR and absent-recipient completion finalize the idempotent order/wallet side
  before marking the delivery `DELIVERED`, so a failure leaves a retryable driver
  action instead of a split terminal state.

## Gaps (`docs/client-feedback.md` §1.4)

- **Tracking copy bug:** `order_bottom_sheet.dart` uses the same subtitle
  (`trackingArrivingSubtitle`) for pickup and delivery. The data exists
  (`order_detail.dart` exposes `isDelivery` / `isPickup`). Branch the
  title/subtitle:
  - Delivery → "Votre nourriture est en route."
  - Pickup → "Votre commande vous attend chez le cuisinier." *(confirm wording)*
- **Confirm with backend:** pickup orders should follow
  `PREPARED → ARRIVED_PICKUP → DELIVERED` and skip `ON_THE_WAY` /
  `ARRIVED_DROPOFF`. If every order traverses `ON_THE_WAY`, file a backend bug.

## Acceptance Criteria

1. **Given** a pickup order, **When** the buyer tracks it, **Then** the copy
   reflects pickup, never "en route" delivery phrasing.
2. **Given** a seller, **When** they progress an order, **Then**
   `start-preparing` / `mark-ready` / `pickup-qr` advance server state.
3. **Given** a QR handoff, **When** scanned, **Then** the matching
   confirm-pickup / confirm-delivery endpoint fires.
4. **Given** an unpaid checkout row, **When** the seller lists orders, **Then**
   that `PENDING` row is not returned or rendered.
5. **Given** a no-driver timeout racing a driver claim, **When** either write
   wins, **Then** the order and delivery remain mutually consistent and a timed-
   out order cannot be claimed.
6. **Given** order/wallet finalization fails during delivery confirmation,
   **When** the driver retries, **Then** the proof action remains retryable and
   cannot double-credit funds.

## Minimal Data Contract

`Order`, `OrderStatus`, `Delivery`, `DeliveryStatus`, QR proof payloads,
`OrderDispute`, `OrderIssue`.

## Execution Tasks

- [x] Wire seller lifecycle + buyer tracking + QR + disputes.
- [x] Enforce seller paid-order visibility and status-gated QR reachability.
- [x] Close no-driver list/claim/decision races at the server write boundary.
- [x] Make QR and absent-proof completion retry-safe.
- [ ] Branch pickup-vs-delivery tracking title/subtitle; add new strings.
- [ ] Confirm/repair the pickup stage path with backend.

## Risks

- Stage-machine mismatch between client copy and server transitions.
