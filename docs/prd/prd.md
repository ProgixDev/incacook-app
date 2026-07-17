# Product Requirements Document — IncaCook

> Source of intent: **what** we are building and **why**, before how.
>
> Companion docs: feature inventory (`docs/features/features_overview.md`),
> code-vs-intent assessment (`docs/FEATURE-ASSESSMENT.md`), per-feature
> specs (`docs/specs/`), and the build-task board (`docs/tasks/board.md`).

**Client:** IncaCook

**Product / Project:** IncaCook — anti-food-waste local food marketplace

**Owner / PM:** PROGIX delivery team

**Status:** draft

**Updated:** 2026-06-30

**Version:** 0.1

---

## Project Description

IncaCook is a French-market, mobile-first food marketplace that lets home
cooks, traiteurs (caterers), and restaurants sell surplus or made-to-order
meals to nearby buyers, with independent drivers handling delivery. It
fights food waste by giving sellers a low-friction channel to sell
home-made dishes ("plats faits maison") at very low prices, and gives
buyers affordable, geolocated access to local cooking.

The product is a **Flutter** app (GetX, Mapbox, Stripe, RevenueCat,
Firebase, Supabase auth deep-links) talking to a **NestJS 11 / Prisma 6**
backend ("incacook-server") on Railway, backed by Supabase Postgres +
PostGIS. The mobile app talks **only** to the IncaCook backend — never to
Supabase directly (the single exception is the signed-URL `PUT` leg of the
two-step file upload). See `docs/backend-communication.md` for the wire
contract.

There are three seller archetypes, each with its own subscription offering:

| Archetype | French brand | Seller category enum | Notes |
|---|---|---|---|
| Home cook | Le Bon Fait Maison | `FAIT_MAISON` | KYC auto-approved; **€4.50 price cap**; no storefront/business info |
| Caterer | L'Atelier Traiteur | `TRAITEUR` | Full KYC + business (SIRET, opening hours) |
| Restaurant | Sauve Ton Panier | `RESTAURANT` | Full KYC + business; surplus-basket model |

---

## Problem & Opportunity

### Problem

Home cooks and small food businesses routinely waste edible surplus and
have no compliant, trust-backed, geolocated channel to sell single
portions to neighbours. Buyers lack an affordable way to discover
home-made local food near them.

### Opportunity

Convert a daily food-waste pain into a trusted local marketplace: verified
sellers, allergen-declared dishes, in-app payment with platform commission,
independent-driver or pickup fulfillment, ratings, and seller
subscriptions. The backend is already ~95% built across the full
marketplace, delivery, payments, and admin surface; the near-term
opportunity is finishing the **mobile wiring** so the buyer→order→deliver
loop runs end-to-end on real data.

---

## Goals & Non-Goals

> The end-to-end transaction loop is **already wired** in the app
> (seller publish → geolocated feed → order → pay → track → review all hit
> real endpoints; see `docs/FEATURE-ASSESSMENT.md`). The MVP work below is
> therefore **hardening, closing mock leaks, and enforcing compliance** —
> not building the loop from scratch.

### Goals

- Close the remaining **mock/hardcoded leaks**: public seller-profile view
  fed `SellerMockData`, seller dashboard KPIs (`today_snapshot_card`), driver
  stats/`_hydrateMock` filler, and the `OrderMockData` order template.
- Enforce regulatory + client business rules in the UI, not just
  server-side: fait-maison €4.50 **hard input block**, mandatory allergen
  declaration, minimum dish descriptions.
- Fix the pickup-vs-delivery tracking copy and verify empty-filter behaviour
  on the live feed.
- Resolve auth UX: remove/finish the Facebook button; friendly error copy;
  re-enable phone OTP when SMS is live (`skipPhoneVerification` flag).
- Finish seller subscriptions (RevenueCat) **store-side**: App Store Connect
  agreement, fix swapped products, set the webhook auth token.
- Delete dead modules (`lib/features/home/`, `checkout` stub, orphan mocks).

### Business Goals

- Launch a testable MVP in the French market that validates real
  cook-to-buyer sales with platform commission (30% standard / 25%
  premium, €1 floor) and a working payout rail (Stripe Connect).
- Validate the three subscription offerings as the seller revenue model.

### User Goals

- **Buyer:** find cheap home-made food nearby, order and pay safely, track
  pickup or delivery, rate the cook.
- **Seller:** list dishes fast, stay compliant (KYC, allergens, price cap),
  get paid, manage a subscription.
- **Driver:** come online, claim nearby deliveries, complete handoffs with
  QR proof, get paid (wallet, withdrawals).

### Non-Goals (current slice)

- Buyer-side subscriptions, "Mise à la Une" featured-listing boosts, and
  dish-photo background enhancement are **requested but unscoped** (see
  `docs/client-feedback.md` §5) — out of the wiring MVP.
- Replacing Flutter/GetX or the NestJS/Prisma backend.
- A standalone admin app — admin endpoints exist on the backend; the admin
  console lives in the separate `incacook-admin` repo.
- Real SMS OTP — temporarily replaced by an **email-OTP bypass** until the
  SMS provider is live (see `docs/signup-flow.md`).

---

## Users & Jobs

| User | What they are trying to do | Success looks like |
|---|---|---|
| Buyer (`BUYER`) | Find affordable home-made food nearby and receive it safely | Discovers a dish on the geolocated feed, pays in-app, tracks pickup/delivery, rates |
| Seller (`SELLER`) | Sell surplus/made-to-order meals compliantly and get paid | Publishes a listing with photos, passes KYC, receives orders, gets payouts, manages a subscription |
| Driver (`DRIVER`) | Earn by delivering nearby orders | Comes online, claims a delivery, completes QR-verified pickup + dropoff, withdraws wallet balance |
| Admin (`ADMIN`) | Keep the marketplace safe and solvent | Reviews KYC, resolves disputes/claims, issues strikes/suspensions, reads dashboards (via backend + admin repo) |

---

## MVP Scope

The non-negotiables for a testable launch, ranked. Each becomes one or more
specs in `docs/specs/`.

All items below are **wired**; MVP scope is to harden them and close the
named gap:

1. **Auth & signup wizard** *(Done)* — remove/finish Facebook button;
   friendly error copy; re-enable phone OTP when SMS is live.
2. **Listings** *(Done)* — add the fait-maison €4.50 **hard input block**,
   mandatory allergen confirmation, and minimum description length to
   `AddProductSheet`.
3. **Dish detail / extras** *(Partial)* — replace `SellerMockData` seller
   info + demo extras with real seller-declared extras (needs a small
   backend `sellers/me/extras` addition).
4. **Discovery feed + map** *(Done)* — close the public-seller-profile mock
   leak; verify empty-filter shows everything.
5. **Orders** *(Done)* — fix pickup-vs-delivery tracking copy; replace the
   `OrderMockData` order template with fully real data.
6. **Deliveries** *(Partial)* — wire the driver stats card and incoming-order
   filler to real data.
7. **Seller dashboard** *(Partial)* — wire `today_snapshot_card` KPIs.
8. **Wallet, reviews, messaging, moderation, supply catalog** *(Done)* —
   regression-verify on real data.
9. **Seller subscriptions** *(Partial)* — finish RevenueCat store/dashboard
   config + webhook auth token.

### Excluded from MVP

- Buyer subscriptions, featured-listing boosts ("Mise à la Une"),
  dish-photo enhancement, countdown-timer UI polish, seller-extras pantry
  redesign (these are net-new from client feedback — scope separately).
- Realtime chat polish beyond the existing messaging endpoints.

---

## User Journey

```text
Buyer
  installs IncaCook → signs up (email/Google) → completes buyer profile
  (address, dietary prefs) → browses geolocated feed of nearby dishes →
  opens a dish, adds extras → orders & pays (Stripe) → tracks pickup or
  delivery → receives food → rates the cook.

Seller
  signs up → picks category (fait-maison / traiteur / restaurant) →
  completes profile + KYC + charters → (non-fait-maison) business info →
  subscribes (RevenueCat) → sets up Stripe Connect payout → publishes
  listings with photos → receives & prepares orders → hands off (QR) →
  gets paid.

Driver
  signs up → KYC + vehicle + zones → Stripe Connect → comes online →
  claims a nearby delivery → confirms pickup (QR) → delivers (QR/absent
  proof) → wallet credited → withdraws.
```

---

## Constraints

### Delivery / Platform

- **Platforms:** iOS-first (App Store products + RevenueCat configured for
  `com.incacook.app`); Android wiring exists but RevenueCat Android key not
  set. Flutter + GetX.
- **Backend hosting:** Railway (`https://incacook-api-production-146b.up.railway.app`),
  Supabase Postgres + PostGIS (project ref `eoxrrofpdtrwjbhywcvz`), Redis +
  BullMQ workers for durable order/wallet timers.
- **Payments:** Stripe Connect for orders/wallet/payouts; **RevenueCat for
  seller subscriptions only** (Apple IAP compliance — never Stripe for
  digital subscriptions on iOS).

### Compliance & Legal (France/EU)

- GDPR/RGPD; allergen law (EU-14, French names) — allergen declaration must
  be enforced per `docs/client-feedback.md` §2.2.
- Fait-maison statutory price cap **€4.50** — must be a hard client-side
  block, not just a hint (client blocker §1.2).
- CGU/CGV + role charters (HYGIENE, FAIT_MAISON, PUNCTUALITY, CARE) served
  by `GET /v1/charters/active`; versioned acceptance.
- KYC required for traiteur/restaurant sellers and all drivers
  (fait-maison auto-approved).
- Service-role Supabase key lives **only** on the backend.

### Language

- French primary. The product brand strings and onboarding value-prop copy
  ("plats faits maison à prix très bas") need a client-supplied rewrite
  (feedback §4).

---

## Success Metrics

### Product

- Signup→profile-complete conversion by role (resume cursor:
  `GET /v1/users/me/onboarding`).
- Listing-publish rate per active seller; share of listings with photos.
- Order placement → paid → fulfilled completion rate.
- Pickup vs delivery split; delivery claim time.

### Business

- GMV and platform commission collected; seller payout volume.
- Active subscriptions per offering; trial→paid conversion.

### Technical

- Crash-free sessions; backend API success rate/latency.
- Stripe + RevenueCat webhook reconciliation accuracy (no orphaned
  entitlements/payments).

---

## Risks

| Risk | Mitigation |
|---|---|
| Residual mock leaks ship to users (seller profile, dashboard KPIs, driver stats, order template) | Each `docs/tasks/` task removes a named mock file; track via `grep MockData` going to zero |
| Fait-maison price cap / allergens bypassed in UI | Hard input block + mandatory allergen confirmation; backend already enforces `INCACOOK_PRICE_CAP_EXCEEDED` as belt-and-braces |
| RevenueCat store/dashboard misconfig blocks subscriptions | App code verified complete; remaining work is App Store Connect (Paid Apps Agreement) + dashboard product attachment + webhook token (`docs/qa/revenuecat-testing.md`) |
| `docs/backend-communication.md` is stale | Treat `docs/FEATURE-ASSESSMENT.md` (live code read) as authoritative; refresh the wire-snapshot doc |
| Phone OTP currently bypassed (`skipPhoneVerification = true`) | Re-enable when SMS provider is live; OTP UI is intact |
| Facebook login advertised but reportedly broken | `facebook_email_completion` screen exists; finish the flow or remove the button (feedback §1.5) |

---

## Open Questions

- [ ] Buyer subscription model — Uber-One-style? scope TBD (feedback §5.3).
- [ ] "Mise à la Une" featured boost — pricing, duration, ranking (§5.2).
- [ ] "Partage solitaire" client-home rubric — rename or remove? (§5.5).
- [ ] Pickup orders: does the backend skip `ON_THE_WAY`/`ARRIVED_DROPOFF`
      stages, or does every order traverse delivery stages? (§1.4).
- [ ] Android RevenueCat + Play Store product setup timeline.

---

## Decision Log

- 2026-06-30 — Mobile talks only to the IncaCook backend; no direct
  Supabase calls except the signed-URL upload `PUT`.
- 2026-06-30 — RevenueCat for seller subscriptions; Stripe Connect for all
  order/wallet/payout money movement.
- 2026-06-30 — Email-OTP bypass stands in for SMS phone verification until
  the SMS provider is live.
- 2026-06-30 — Project renamed `HomeMade → IncaCook` (commit `8bd8e01`);
  bundle/app id `com.incacook.app`.

---

## Recommended Phases

### Phase 1 — Transaction-loop MVP (current)

Auth hardening; listings end-to-end; map on real data; orders + payment;
deliveries; wallet/payouts; seller subscriptions; reviews. Honour the
client blockers in `docs/client-feedback.md` §1.

### Phase 2 — Compliance & trust hardening

CGU/CGV rewrite + charter version bump; mandatory allergen/ingredient
declaration; moderation/report surfacing; messaging polish; push delivery
hardening.

### Phase 3 — Growth / monetization

Buyer subscriptions, featured-listing boosts, dish-photo enhancement,
countdown-timer listings, seller-extras pantry, Android subscription
parity.

---

## MVP Definition of Done

- [ ] No buyer- or seller-facing screen depends on a mock data file for
      listings, orders, deliveries, or the map.
- [ ] A seller can publish a photographed listing and a buyer can find,
      order, and pay for it on real data.
- [ ] Fait-maison €4.50 cap and allergen declaration are enforced in the UI.
- [ ] Orders advance through their lifecycle with correct pickup-vs-delivery
      tracking copy and QR handoff.
- [ ] Drivers can claim and complete deliveries; wallet + withdrawal work.
- [ ] Seller subscription purchase + restore + backend reconciliation work
      on a real device (per `docs/qa/revenuecat-testing.md`).
- [ ] Security/compliance constraints satisfied (service-role key
      server-only; charters accepted at current version).
