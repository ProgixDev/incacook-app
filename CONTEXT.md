# IncaCook — Domain Glossary

A shared vocabulary for the IncaCook food-delivery domain. Glossary only — no
implementation details. When a term here conflicts with how code or
conversation uses a word, the glossary wins until deliberately changed.

## Delivery & Driver

- **Delivery** — the fulfilment of one Order by one Driver, from seller pickup
  to buyer dropoff. Progresses through a lifecycle of statuses.

- **Active delivery** — a Delivery in any non-terminal status: `ASSIGNED`,
  `EN_ROUTE_TO_PICKUP`, `AT_PICKUP`, `PICKED_UP`, `EN_ROUTE_TO_DROPOFF`,
  `AT_DROPOFF`. Excludes the pre-claim states (`UNASSIGNED`, `SEARCHING`) and
  the terminal ones (`DELIVERED`, `CANCELLED`, `FAILED`).

- **One-active-per-driver** — a Driver holds **at most one** Active delivery at
  a time. This is a hard domain invariant, enforced server-side at claim time,
  not merely a client-side convenience. (No stacked / batched deliveries.)

- **Claim** — a Driver taking ownership of a `SEARCHING` Delivery. First-writer-
  wins; a lost race is a conflict, not an error.

- **Online** — a Driver has declared themselves available to be offered and
  claim deliveries. A per-session availability state. NOT the same as
  "activated" — an Online driver may still be idle (no Active delivery).

- **Suspended** — a Driver (or any User) barred from acting by the strike
  engine. This is the true meaning of "deactivated": an account-level penalty,
  distinct from simply being Offline. A driver who "quit the app and came back
  deactivated" was **Offline**, not Suspended — avoid the word "deactivated"
  for the offline case.

## Presence & tracking

These two concepts both involve the driver's location but serve different
purposes and run on different clocks. Do not conflate them.

- **Heartbeat** — a periodic signal that an Online driver's session is still
  alive, carrying a *coarse* position for nearest-first matching. Slow by
  design. Its staleness is what expires an idle Online driver, but backgrounding
  is legitimate (a driver waits for an order push while backgrounded), so
  availability ultimately rests on **FCM-token reachability**, not a tight
  heartbeat.

- **Live tracking** — the fast, near-real-time stream of a driver's position to
  the buyer's map **during an Active delivery only**. Broadcast over the
  realtime socket; it does not need to be persisted at the same rate.

- **Delivery watchdog** — a per-Delivery timer that detects a stalled Active
  delivery. Distinct from the Heartbeat: one Delivery-progress clock
  (pre-pickup ETA-based; post-pickup a long backstop) vs. one availability
  clock. A committed Driver (has an Active delivery) is governed by watchdogs,
  never by the idle Heartbeat expiry.

## Payments & Subscriptions

- **Seller subscription entitlement** — whether a Seller's platform
  subscription is active, gating Accueil/Commandes/Mes plats. **RevenueCat is
  the sole source of truth** (DEC-8, resolved `#11`): the RevenueCat webhook
  is the only writer of `SellerProfile.subscriptionStatus` /
  `subscriptionCurrentPeriodEnd`. A parallel Stripe Checkout/Billing-Portal
  path existed but was never reachable from the app and has been removed —
  do not reintroduce a second writer of these fields without revisiting this
  decision.
- **Payout readiness** (Stripe Connect) is a **separate concept** from
  subscription entitlement — see DEC-2/DEC-3 precedent in
  `.agent-board/map.md`: Stripe governs payout/withdrawal readiness only,
  never app access or subscription state.

## Sanctions

- **Strike** — one penalty point in a single system that spans all three actors
  (Seller, Driver, Buyer). The canonical taxonomy (source of truth):
  - *Infraction légère* (seller absent, lateness/**retard**, late cancellation)
    → **1 strike**.
  - *Infraction grave* (false absence claim, confirmed dangerous dish,
    fraudulent chargeback, false allergen claim) → **2 strikes**.
  - *Theft / non-delivery after pickup* ("disparition après le retrait") →
    **immediate exclusion** (not a point-count — an instant ban).
  - **3 strikes within 90 days → exclusion.**
  - Seller mean rating below 3.5/5 (≥10 reviews) → suspension; buyer serial
    chargebacks / false "never received" → report then ban.
  - A Driver who claims but never reaches pickup (pre-pickup no-show) is a
    **retard → 1 strike**; a Driver who vanishes after pickup is immediate
    exclusion.
