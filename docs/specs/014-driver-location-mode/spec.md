# Feature Spec: Driver App Location Mode

**Feature ID**: `014-driver-location-mode`
**Created**: 2026-07-09
**Status**: Implemented (2026-07-10)
**Mobile module**: `lib/core/services/location`, `lib/features/delivery`
**Wire contract**: unchanged — `POST /v1/drivers/me/location` (existing);
no new endpoints
**Related**: ADR-0002 (presence & heartbeat), `docs/notes/driver-background-persistence.md`,
`docs/plans/driver-location-lifecycle/plan.mdx`

## Problem Statement

A Driver's phone streams their GPS for two different jobs: a coarse **Heartbeat**
that keeps them matchable while **Online** and idle, and a fast **Live tracking**
stream to the Buyer's map during an **Active delivery**. These two jobs run on
different clocks and want different platform behavior — the idle Heartbeat should
be battery-light and may pause when the app is backgrounded, while Live tracking
must survive backgrounding so the Driver never appears to "disappear" mid-delivery.

Today the choice of *which* stream mode is live is made implicitly and in three
different places (`DeliveryDriverController`, `DeliveryRouteController`,
`IncomingOrderController`), each calling `start()`/`stop()` on a single shared
`LocationService` at the moment its own state changes. Because no single place
owns "given the Driver's state, which mode should the GPS be in?", the modes drift
out of sync with reality:

- After an app relaunch **during** an Active delivery, the online-restore path
  re-started the stream in idle (foreground) mode, silently tearing down the
  background service that Live tracking depends on — the Driver could vanish from
  the Buyer's map while backgrounded.
- After completing a delivery while staying Online, the stream was stopped and
  never re-armed, so idle matching kept pushing a frozen drop-off position and
  the Driver's map marker stopped moving until they manually toggled Offline/Online.

Both were ordering bugs invisible to the type checker and the widget layer.

## Solution

Make the Driver's location mode a single, explicit state machine derived from two
facts the app already knows: **is the Driver Online**, and **do they hold an
Active delivery**. From those two booleans the app resolves exactly one desired
mode — **off**, **foreground** (idle-online Heartbeat), or **background** (Active
delivery Live tracking) — and applies it idempotently to the shared
`LocationService`. Every state change (go Online, accept, pick up, deliver,
relaunch, cancellation, go Offline) recomputes the desired mode and converges to
it, instead of each controller issuing its own `start`/`stop` and hoping the
ordering works out.

From the Buyer's and Driver's point of view: the Driver stays trackable exactly
when they should be, the battery is spared when they're merely idle-online, and no
relaunch, hand-off, or completed delivery can leave the GPS in the wrong mode.

## User Stories

1. As a Driver, I want my GPS to stop entirely when I go Offline, so that the app
   never drains my battery or reports my position when I'm not working.
2. As a Driver, I want a battery-light location stream while I'm Online and idle,
   so that waiting for an order doesn't cost me a full charge.
3. As a Driver, I want my location to keep streaming while I have an Active
   delivery even if I switch apps or my screen locks, so that the Buyer keeps
   seeing me move and I'm not penalised for "disappearing".
4. As a Driver, when I accept a delivery, I want the stream to upgrade to the
   background/foreground-service mode automatically, so that Live tracking is
   reliable without me doing anything.
5. As a Driver, when I finish a delivery but stay Online, I want the stream to
   drop back to the idle Heartbeat mode automatically, so that I keep getting
   matched from my *current* position, not the last drop-off.
6. As a Driver, when I force-quit and reopen the app mid-delivery, I want the
   background tracking to resume in the correct mode, so that a relaunch doesn't
   silently downgrade me and make me look offline to the Buyer.
7. As a Driver, when a seller/admin cancels my Active delivery, I want the stream
   to return to whatever my Online state warrants (idle Heartbeat if still Online,
   off if Offline), so that a cancellation leaves my GPS in a coherent mode.
8. As a Driver, when I report the seller unavailable or leave an absent-recipient
   drop-off (both of which clear the job), I want the same clean mode transition
   as a normal completion, so that fallback paths don't strand my GPS.
9. As a Driver, I want going Online and immediately being offered a job to not
   double-start or race the stream, so that acceptance is smooth and the marker
   doesn't flicker.
10. As a Driver, I want toggling Offline during an Active delivery (edge case) to
    resolve to a single well-defined mode, so that the app never sits in an
    ambiguous half-tracking state.
11. As a Buyer, I want the Driver's dot to keep moving smoothly for the whole
    delivery, including when the Driver's app is backgrounded, so that I trust the
    ETA and know food is on the way.
12. As a Buyer, I don't want the Driver to appear frozen right after they pick up
    or right after a relaunch, so that I'm not misled into thinking the delivery
    stalled.
13. As the matching system, I want an idle Online Driver's position to refresh on
    the Heartbeat cadence, so that nearest-first dispatch offers them jobs near
    where they actually are.
14. As the matching system, I want a Driver who just completed a delivery and
    stayed Online to immediately resume the Heartbeat, so that they're offered
    the next job from their new location, not the old drop-off.
15. As a Driver, I want the persistent "delivery in progress" notification to
    appear only while I actually have an Active delivery, so that I'm not shown a
    tracking notification when I'm idle.
16. As a Driver on iOS, I want the background-location indicator to show only
    during an Active delivery, so that the app's use of my location is honest and
    expected.
17. As a product engineer, I want one pure function that answers "what mode should
    the GPS be in?", so that I can reason about and test every transition without a
    device or platform mocks.
18. As a product engineer, I want the rule "only upgrade foreground→background
    restarts the stream; a downgrade goes through an explicit stop→start" captured
    in one place, so that no caller can accidentally downgrade a live background
    stream.
19. As a QA engineer, I want the full state matrix (Offline / idle-online /
    active-delivery, and every transition between them) covered by fast unit
    tests, so that regressions in this fragile area are caught in CI, not on a
    Buyer's map.
20. As a support agent, I want "Driver looks stuck on the map" to have a single
    documented cause-and-owner (the location-mode machine), so that I can triage
    it without guessing across three controllers.
21. As a Driver, I want the location mode to be independent of the *push cadence*,
    so that tuning how often my position is sent to the server never accidentally
    changes whether background tracking is on.
22. As a Driver with location permission denied, I want the app to degrade
    gracefully (no crash, matching falls back to my last-known point), so that a
    permission gap doesn't break the whole session.

## Implementation Decisions

- **Single source of truth: a pure mode resolver.** Introduce a pure function
  `desiredLocationMode({required bool online, required bool hasActiveJob})`
  returning a `LocationMode` enum with three cases. It is the *only* place that
  decides what the stream should be doing. The mapping:

  ```
  desiredLocationMode(online, hasActiveJob):
    !online              -> LocationMode.off          // Offline: no stream
    online && !hasJob    -> LocationMode.foreground    // idle-online Heartbeat
    online && hasJob     -> LocationMode.background     // Active-delivery Live tracking
  ```

  `hasActiveJob` reflects an **Active delivery** per the glossary (any non-terminal
  Delivery the Driver owns); a `SEARCHING`/offer-pending state is not an Active
  delivery and stays `foreground`.

- **Transition rule stays pure and separate.** Keep the existing
  `LocationService.shouldRestartStream({required currentBackground, required
  requestedBackground})` rule: only an **upgrade** (foreground→background)
  restarts a live stream; a foreground request over a live background stream is a
  no-op (never an implicit downgrade). An explicit downgrade is modelled as
  `stop()` then `start()`. This rule and `desiredLocationMode` together fully
  describe the machine.

- **Idempotent apply.** `LocationService` exposes a single `applyMode(LocationMode)`
  that maps `off → stop()`, `foreground → start(background: false)`,
  `background → start(background: true)`, using `shouldRestartStream` internally so
  repeated calls with the same desired mode are no-ops. `start()`/`stop()` remain,
  but ad-hoc callers migrate to `applyMode`.

- **One coordination point, driven reactively.** A single coordinator subscribes
  to the two reactive facts already in the app — `DeliveryDriverController.isOnline`
  and `DeliveryRouteController.currentJob` — and on any change calls
  `LocationService.applyMode(desiredLocationMode(online: …, hasActiveJob: …))`.
  The three controllers stop issuing their own `start`/`stop`; they only mutate
  their own state, and mode convergence is centralised. This removes the ordering
  hazard that produced both prior bugs (relaunch downgrade, post-delivery stall).

- **`stop()` resets mode flags synchronously.** `stop()` clears the streaming/mode
  flags before awaiting the platform-stream cancel, so a mode re-apply triggered
  in the same turn (e.g. a delivery clearing while Online) sees a clean,
  non-streaming state and cannot race the in-flight cancel.

- **Mode is orthogonal to push cadence.** The location *mode* (which platform
  stream is live) is decided here; the *Heartbeat / Live-tracking push cadence*
  (idle ~60s; active 3s-min / 10m-move / 15s-keepalive) remains owned by the
  controllers per ADR-0002 and is unchanged. Tuning cadence must never change mode.

- **Platform behavior per mode is unchanged.** `background` continues to use the
  Android LOCATION foreground service + persistent notification and iOS
  `allowBackgroundLocationUpdates` + background indicator; `foreground` uses a
  plain high-accuracy stream; `off` cancels. Only *when* each is selected changes.

- **No wire/schema changes.** Location mode is purely a client concern. The server
  still receives fixes via the existing `POST /v1/drivers/me/location` and remains
  server-authoritative for `isOnline` per ADR-0002. `/users/me` restore semantics
  are untouched.

## Testing Decisions

- **Test external behavior, not platform plumbing.** The valuable assertions are
  "given the Driver's state, the resolved mode is X" and "given a current+requested
  mode, the stream does/doesn't restart" — both expressible as pure functions over
  plain booleans/enums. Do **not** test against the real Geolocator platform
  channel or assert on private stream fields.

- **Modules under test.**
  - `desiredLocationMode` — the full 2×2 truth table plus the Active-delivery
    definition (offer-pending is still `foreground`): Offline→off, idle-online→
    foreground, active→background, Offline-with-job (edge)→off.
  - `shouldRestartStream` — the transition matrix: foreground→background restarts;
    background→foreground is a no-op; same-mode is a no-op. (Already covered by
    `test/core/location_stream_mode_test.dart`.)
  - The coordinator — with a fake/recording `LocationService`, assert that a
    sequence of state flips (go Online → accept → deliver-while-online → relaunch-
    mid-delivery → cancel → go Offline) produces the expected ordered sequence of
    `applyMode` calls. This is the highest behavioral seam and directly guards the
    two prior bugs.

- **Prior art.** `test/delivery/delivery_cancel_match_test.dart` (pure decision
  function tested with plain inputs) and `test/core/location_stream_mode_test.dart`
  (the transition rule) are the templates; the coordinator test mirrors the
  reactive `ever`-worker pattern used elsewhere in the delivery feature.

## Out of Scope

- Server-side presence expiry (the `isOnline` staleness cron, lazy `lastSeenAt`
  guard, and DB write throttle) and the push-cadence values — owned by ADR-0002
  and its backend tasks.
- The native foreground-service configuration and the on-device permission
  escalation to "Always" / background push — implemented already (see
  `docs/notes/driver-background-persistence.md`); real-device verification is
  tracked there, not here.
- The Buyer's Live-tracking map rendering, the nearest-first matching algorithm,
  and the incoming-order offer/claim flow (`docs/notes/driver-order-receiving-flow.md`).
- Persisting declines, one-at-a-time vs. queued offers, and any change to when the
  offer modal appears.

## Further Notes

- This spec formalises and generalises the two fixes already shipped on `dev`
  (`fix(delivery): keep driver GPS alive across relaunch + post-delivery`): the
  `shouldRestartStream` no-downgrade rule and the post-delivery re-arm. Those fixes
  addressed the two known failures point-wise; the pure resolver + single
  coordinator make the *whole* machine correct by construction, so future
  transitions (new fallback paths, new lifecycle stages) inherit correct mode
  behavior for free.
- Aligns with ADR-0002's **two-clocks** separation: idle Heartbeat vs. Active-
  delivery Live tracking are distinct clocks, and this machine is exactly the
  client-side selector between them. A committed Driver (Active delivery) is
  governed by Delivery watchdogs, never the idle clock — mirrored here by
  `background` mode being selected whenever `hasActiveJob` is true, regardless of
  the idle Heartbeat.
- The `LocationMode.off` case for an (Offline, hasActiveJob) combination is a
  defensive edge: the one-active-per-driver + Online-to-claim invariants mean a
  Driver shouldn't normally be Offline with an Active delivery, but resolving it to
  a single defined mode avoids an ambiguous half-tracking state.

## Verification Status

- The resolver, restart rule, and ordered coordinator transition sequence are
  covered by automated tests under `test/core/`.
- Core, delivery, seller, and order regression suites pass; `flutter analyze`
  reports no issues (43 Flutter tests as of 2026-07-11).
- The corresponding backend order/delivery guarantees pass the complete server
  suite (187 tests), TypeScript, ESLint, and Prettier checks.
- A debug iOS build was signed, installed, and launched on a physical iPhone on
  2026-07-10.
- Background indicators, force-quit/relaunch continuity, and the complete
  buyer→seller→driver production transaction remain manual multi-device QA
  checks; code/build verification cannot substitute for those observations.
