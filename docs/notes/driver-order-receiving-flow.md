# Reference — Driver order-receiving flow (current behavior + tuning knobs)

How a driver learns about, is offered, and accepts a delivery — as built today.
Written so the values can be **tuned later** without re-deriving the flow.
See also `CONTEXT.md` (glossary) and `docs/adr/0002` (presence & heartbeat).

## Mental model — two channels, different jobs

1. **FCM push** = the *alert / wake* ("there's an order"). Draws a tray
   notification. It does **not** itself open the offer modal.
2. **Polling** = the *actual offer*. A client timer asks the server what's
   available; that is what pops the accept/decline modal.

**The poll is the source of truth; the push is only a nudge.** They are
redundant on purpose.

## Server flow (IncaCook-Server)

1. Buyer pays → order `CONFIRMED`.
2. Seller marks ready → `markReady` (`orders.service.ts`) creates a **`Delivery`
   row, status `SEARCHING`** + mints a pickup QR token.
3. `notifyDeliveryAvailable(orderId, deliveryId)` (`notifications.service.ts`)
   → FCM push to every `isOnline: true` driver: *"Nouvelle livraison
   disponible"*, `data: {type:'delivery_available', orderId, deliveryId}`.
4. Arms `scheduleNoDriverTimeout` (no-driver fallback).

**Open dispatch:** a `SEARCHING` delivery is offered to **every** online driver
at once (not pinned to one), ordered nearest-first (PostGIS driver
`lastKnownPoint` → seller `location`), FIFO tiebreak. First to claim wins.

**Claim = atomic first-writer-wins:** `UPDATE Delivery SET driverId=…,
status='ASSIGNED' WHERE id=? AND status='SEARCHING' AND driverId IS NULL`.
0 rows → **409** (someone beat them to it). Gated on KYC; Stripe payout NOT
required to claim.

## Client flow (`IncomingOrderController`)

Runs only while **Online with no active job**:

1. On going/restoring online, `_startPolling()` fires `_pollOnce()` **immediately**
   (not after one interval), then every `_pollInterval`.
2. `_pollOnce`: (throttled) push location → `GET /drivers/me/deliveries/available`.
3. Picks the **first** delivery that is not in `_dismissed` (declined this
   session) and has geocoded pickup coords → hydrates → sets `pendingOrder`.
4. `delivery_home.dart` shows the **incoming-order modal** (`IncomingOrderSheet`):
   non-dismissible, with an auto-decline countdown.
5. Accept → `claim` → `DeliveryRouteController.acceptJob` (job, stage `prepared`,
   route bootstrap). Decline/timeout → `resolve(accepted:false)` → id added to
   `_dismissed` → immediate re-poll.

Even when foreground, the modal comes from the **poll**, not the push.

## Pending / unclaimed orders on app entry

- **Unclaimed (`SEARCHING`) orders are NOT tracked client-side.** They live on
  the server; the first poll after going online re-derives and surfaces them
  (one at a time, nearest-first). A driver opening the app to 3 waiting orders
  gets offered them sequentially — nothing was stored locally.
- **Gate:** this only happens if the driver is **Online**. If the (planned)
  staleness expiry flipped them offline while away, they enter offline and see
  nothing until they tap Go Online — then the poll surfaces them.
- **Transient in-flight offer** (modal shown, not yet decided) is **in-memory
  only** (`pendingOrder` / countdown / `_dismissed`). Killed app → lost, and
  correctly so: the delivery is still `SEARCHING`, so the next poll re-surfaces
  it fresh. Persisting it would risk showing an offer since claimed by someone
  else.
- **Active (claimed) job** on entry IS restored — via `activeMine()` +
  `restoreJob` (a driver with an active delivery is never offered new ones,
  because `_pollOnce` returns early when `route.order != null`).

## Known behaviors / gaps (candidates for tuning)

- **Declines don't survive a restart.** `_dismissed` is in-memory and wiped on
  restart; declines aren't persisted server-side either (a decline isn't a state
  change — the delivery stays `SEARCHING`). So a declined-then-reopened order is
  re-offered. To change: persist `_dismissed` locally, or add a server-side
  per-driver decline record.
- **One-at-a-time offers.** The UI shows only the first claimable delivery as a
  modal, even though `listAvailable` returns up to 10. No list/queue/badge of
  waiting orders. Product decision if a list view is wanted.
- **Poll is foreground-only.** The Dart timer pauses when the OS suspends the
  app, so a backgrounded driver depends entirely on the FCM push (tap → app
  foregrounds → poll resumes → modal). Tied to the foreground-service work in
  `docs/notes/driver-background-persistence.md`.
- **Matching targets `isOnline: true` with no freshness filter** today — the
  reason for the presence work in `docs/adr/0002`.

## Tuning knobs

| Knob | Where | Current | Effect of changing |
|---|---|---|---|
| Available-orders poll interval | `IncomingOrderController._pollInterval` | 5s | Lower = faster offer surfacing, more `listAvailable` reads. FCM push covers the gap, so it can be relaxed (e.g. 10s). |
| Idle location-push throttle | `IncomingOrderController._minLocationPushInterval` | 60s | Higher = fewer server writes, coarser matching position. |
| Offer auto-decline countdown | `IncomingOrderSheet` (`_kCountdown`) | ~25s | Time a driver has to accept before it auto-passes. |
| Available list size | `listAvailable(limit:)` call | 10 | How many candidates are fetched (only the first is shown today). |
| Active-delivery push throttle | `DeliveryRouteController._minPushIntervalMs` / `_minPushDistanceM` / `_keepaliveMs` | 3s / 10m / 15s | Live-tracking cadence to the buyer. Faster = smoother tracking, more writes. |
| Off-route reroute | `DeliveryRouteController._offRouteThresholdMeters` / `_offRouteHitsBeforeReroute` | 50m / 3 hits | How aggressively the route re-fetches on deviation. |
| No-driver fallback | server `NO_DRIVER_TIMEOUT_MINUTES` | 15 min | How long a `SEARCHING` order waits before prompting the buyer to switch/cancel. |
| Post-pickup disappearance | server `DRIVER_DELIVERY_TIMEOUT_MINUTES` | 60 min | Backstop before a picked-up-but-undelivered order is force-resolved (→ immediate exclusion). |

### Planned knobs (not yet built — see Task #1 / ADRs)

| Knob | Source | Proposed |
|---|---|---|
| `isOnline` staleness threshold | ADR-0002 | ~10 min (no active delivery) |
| `isOnline` expiry cron interval | ADR-0002 | ~30–60s |
| Server `lastKnownPoint` write throttle | ADR-0002 | ≤ every 20–30s |
| Pre-pickup ETA model | ADR-0001 | straight-line ÷ ~18–20 km/h × ~1.3 + prep + grace |
