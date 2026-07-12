# Feature Spec: Deliveries (Driver)

**Feature ID**: `008-deliveries-driver`
**Created**: 2026-06-30
**Status**: Partial
**Mobile module**: `lib/features/delivery`
**Wire contract**: `/v1/drivers/me/{online,location}`,
`/v1/drivers/me/deliveries/*`

## User Story

As a driver, I want to come online, claim nearby deliveries, navigate, and
complete QR-verified handoffs (including absent-recipient and
seller-unavailable cases), so I get paid.

## Current Behavior

- `delivery_driver_controller.dart` + `deliveries_repository.dart` are wired:
  `setOnline`, location ping, available feed, `claim`, `arrive-pickup`,
  `confirm-pickup`, `confirm-delivery`, `confirm-absent-dropoff`,
  `report-seller-unavailable`, `report-issue`.
- `delivery_route_controller.dart` does Mapbox routing; screens `delivery_home`,
  `qr_scan_screen`, `absent_dropoff_screen`, `seller_unavailable_screen` +
  job-lifecycle / QR-handoff / issue-report sheets.
- `DriverLocationModeCoordinator` is the single owner of GPS mode. It derives
  `off`, `foreground`, or `background` from online + active-job state and
  serializes rapid restore/claim/completion/cancellation transitions.
- The available feed and atomic claim both require a `SEARCHING` delivery whose
  parent order is still `READY`. No-driver timeout retires that delivery in the
  same transaction that prompts the buyer.
- Delivery and absent-dropoff proof remain retryable when order/wallet
  finalization fails; server-side idempotency prevents duplicate credits.

## Gaps

- **Mock leaks:**
  - `widgets/today_stats_card.dart` reads `delivery_driver_mock_data.dart`
    (driver earnings/stats hardcoded).
  - `incoming_order_controller.dart` `_hydrateMock()` overlays real backend
    fields onto `OrderMockData.demoOrder()`, leaving cart-line specifics /
    payment method as filler.

## Acceptance Criteria

1. **Given** an online driver, **When** an order needs delivery, **Then** it
   appears in the available feed and can be claimed.
2. **Given** a claimed delivery, **When** the driver scans pickup/dropoff QR,
   **Then** the matching confirm endpoint fires; absent-dropoff and
   seller-unavailable paths work.
3. **Given** the driver home, **When** stats render, **Then** they come from
   real wallet/delivery data, not `delivery_driver_mock_data`.
4. **Given** any online/job state transition, **When** state settles, **Then**
   exactly one coordinator converges the shared location stream to the expected
   mode.
5. **Given** a no-driver timeout races a claim, **When** either wins, **Then** a
   driver never receives an order already awaiting the buyer's decision.

## Minimal Data Contract

`Delivery`, `DeliveryStatus`, driver online/location, proof payloads,
`OrderIssue`, `WalletEntry` (earnings).

## Execution Tasks

- [x] Wire driver online/location/claim/QR/incident lifecycle.
- [x] Centralize driver location mode and cover the full transition matrix.
- [x] Guard available/claim against resolved parent orders.
- [x] Keep QR and absent-proof completion retry-safe.
- [ ] Wire `today_stats_card` to real earnings/delivery data.
- [ ] Remove `_hydrateMock` filler; populate the order fully from the backend.
- [ ] Delete `delivery_driver_mock_data.dart` once unused.

## Risks

- Location-permission + background-update reliability for live tracking.
