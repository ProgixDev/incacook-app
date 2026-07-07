---
status: accepted
date: 2026-07-06
---

# Pre-pickup timeout uses a PostGIS straight-line ETA, not real routing

## Context

A Driver who claims a Delivery but never reaches the seller for pickup (the
`ASSIGNED → AT_PICKUP` gap) currently has no watchdog — the food can sit at the
restaurant indefinitely. We want a pre-pickup timeout whose budget is
ETA-based: `ETA(driver → seller) + remaining prep time + grace`, and if
`AT_PICKUP` isn't reached in time the Delivery is re-offered / unassigned.

The blocker: the backend has **no routing capability**. It only geocodes
(address → lat/lng); all route/ETA computation lives client-side in the driver
app (Google Directions). There is no server-side Directions integration.

## Decision

Compute the pre-pickup deadline with a **PostGIS straight-line approximation**,
not a real route:

`budget = (haversine(driver.lastKnownPoint, seller.location) / assumedSpeed)
          × detourFactor + remainingPrepTime + grace`

with a conservative urban speed (~18–20 km/h), a detour factor (~1.3), and a
generous grace margin. Pair it with a **movement check**: only trip the timeout
when the driver's live position is stationary or receding from the seller over
successive heartbeats — never when they are demonstrably getting closer.

A timeout *budget* needs a defensible "this driver is clearly not moving toward
pickup," not routing precision — so accuracy is deliberately traded for having
zero external dependency and zero per-claim API cost.

### Budget simplification (prep is already done at claim)

A `Delivery` row is only created at `markReady` (the order is already `READY`),
so by the time a Driver claims it, **prep is complete**. The budget therefore
collapses to roughly `ETA(driver → seller) + grace` — there is no meaningful
"remaining prep time" term to add.

### Movement check — data source (chosen: claim-time distance snapshot)

The backend stores only the *latest* `lastKnownPoint` (no position history), so
"is the driver getting closer over successive heartbeats?" has no data source
out of the box. Decision: **snapshot the straight-line distance
`distance(driver, seller)` at claim time** (a single stored value). At the
deadline, compare it to the current distance:

- current distance **meaningfully smaller** than the snapshot → the Driver is
  progressing → do **not** trip (optionally re-arm a shorter extension).
- current distance **not smaller** (stationary/receding) → non-progress → trip:
  unassign + re-offer + 1 strike.

Cheapest option (one value, no history table, no extra reads). Rejected: storing
the previous point on every `recordLocation`, and a rolling-history table —
both add write cost/schema for accuracy the budget doesn't need.

## On timeout (what happens when the deadline trips)

Reuses existing machinery; no new severity invented — mapped onto the canonical
strike taxonomy (see `CONTEXT.md` → Strike):

- **Delivery** → unassign (`driverId = null`, status back to `SEARCHING`),
  **excluding the failing driver** from re-offer, then **re-arm the no-driver
  timeout**. Re-dispatches silently if another driver is near; otherwise flows
  into the existing no-driver → buyer switch/cancel path.
- **Driver** → a pre-pickup no-show is a *retard* = **infraction légère =
  1 strike** (`strikes.addStrike`, not `immediateExclude`), issued **only when
  the movement check confirms non-progress** (stationary/receding) so a driver
  genuinely en route through slow traffic is never struck.
- **Contrast — post-pickup disappearance** is a *different* case ("disparition
  après le retrait" → **exclusion immédiate**) and is **already implemented**
  correctly: `handleDriverDeliveryTimeout` → `resolveDriverDisappeared` →
  `strikes.immediateExclude('DRIVER_DISAPPEARED_AFTER_PICKUP')`.

## Considered options

- **(A) Server-side Google Directions call at claim** — accurate ETA, but adds
  a paid API call per claim and a new server-side Google integration we don't
  have. Rejected for now: over-engineered for a timeout budget.
- **(B) PostGIS straight-line + movement check** — **chosen.** Cheap, no
  external dependency; the data (driver `lastKnownPoint`, seller `location`) is
  already in PostGIS. Errs toward patience.
- **(C) Client-reported ETA** — the driver app already has `durationSeconds`
  from its own Directions call and could POST it. Zero new server integration,
  but trusts a number the driver's device controls (a bad actor could report a
  huge ETA to dodge the timeout). Rejected: untrusted input on a penalty path.

## Revisit if

- False positives appear (drivers penalised while legitimately en route through
  slow/complex routes the straight-line model underestimates) → escalate to
  **(A)** server-side Directions, or **(C)** client ETA cross-checked against
  the server approximation as an upper bound.
- We add server-side routing for another reason (e.g. dispatch optimisation),
  at which point (A) becomes nearly free.

This decision is intended to be superseded, not treated as permanent.
