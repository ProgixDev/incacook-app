# IncaCook Documentation Index

IncaCook is an anti-food-waste local food marketplace: a **Flutter** app
(GetX, Google Maps, Stripe, RevenueCat, Firebase) talking to a **NestJS 11 /
Prisma 6** backend (`IncaCook-Server`, Railway + Supabase Postgres/PostGIS).
Roles: **buyer / seller / driver** (admin lives in the separate
`incacook-admin` repo).

Updated: 2026-06-30.

## Start here

1. **[Product Requirements](prd/prd.md)** — what we're building, for whom,
   scope, success metrics, phases, MVP Definition of Done.
2. **[Feature Assessment](FEATURE-ASSESSMENT.md)** — live code-vs-backend
   completion matrix (Done / Partial / Todo) and the exact remaining work.
3. **[Feature Overview](features/features_overview.md)** — feature inventory
   mapping each module to its backend endpoints and state.

> ⚠️ `backend-communication.md` is a **dated snapshot** (it predates the
> listings/feed/map/order wiring). Where it disagrees with
> `FEATURE-ASSESSMENT.md`, the assessment (a live code read) is authoritative.

## Ground-truth references (existing)

- **[backend-communication.md](backend-communication.md)** — the mobile↔backend
  wire contract: client, envelope, auth/refresh, idempotency, repositories.
- **[signup-flow.md](signup-flow.md)** — signup wizard + full endpoint reference
  + the onboarding completeness cursor.
- **[client-feedback.md](client-feedback.md)** — the client's blockers and
  requests (drives the task board).
- **[revenuecat-setup.md](revenuecat-setup.md)** + **[qa/revenuecat-testing.md](qa/revenuecat-testing.md)**
  — seller subscription store/dashboard setup + QA.
- **[qa/supabase-firebase-apple-auth-reset.md](qa/supabase-firebase-apple-auth-reset.md)**
  — Firebase project rewire, Supabase Google/Apple auth setup, and QA DB reset.
- **[local-testing.md](local-testing.md)** — running the backend locally.

## Specs (per-feature: current behavior + gaps)

| ID | Spec | Status |
|---|---|---|
| 001 | [Authentication & signup wizard](specs/001-auth-onboarding/spec.md) | Done (hardening) |
| 002 | [Profile, addresses, KYC, charters, uploads](specs/002-profile-kyc-charters/spec.md) | Done |
| 003 | [Listings — seller publish](specs/003-listings-publish/spec.md) | Done (compliance gaps) |
| 004 | [Discovery — feed, kitchens & map](specs/004-discovery-feed-map/spec.md) | Done (1 mock leak) |
| 005 | [Dish detail & seller extras](specs/005-catalog-dish-detail-extras/spec.md) | Partial |
| 006 | [Cart, checkout & order placement](specs/006-cart-checkout-orders/spec.md) | Done (template leak) |
| 007 | [Order lifecycle & tracking](specs/007-order-lifecycle-tracking/spec.md) | Done (copy bug) |
| 008 | [Deliveries (driver)](specs/008-deliveries-driver/spec.md) | Partial |
| 009 | [Wallet & payouts](specs/009-wallet-payouts/spec.md) | Done |
| 010 | [Seller subscriptions (RevenueCat)](specs/010-seller-subscriptions/spec.md) | Partial (config) |
| 011 | [Reviews, messaging, moderation, notifications](specs/011-reviews-messaging-moderation-notifications/spec.md) | Done |
| 012 | [Settings, legal & theming](specs/012-settings-legal-theming/spec.md) | Done |
| 013 | [Net-new client requests (Phase 3)](specs/013-net-new-requests/spec.md) | Todo (scoping) |
| 014 | [Driver app location mode](specs/014-driver-location-mode/spec.md) | Done |
| 015 | [Buyer self-cancel](specs/015-buyer-self-cancel/spec.md) | Draft (policy open) |

## Build tasks

- **[Task board](tasks/board.md)** — all 20 tasks, grouped by spec, with
  status (Ready / Backlog / Blocked) and priority.
- Individual tickets: `tasks/TASK-001.md` … `tasks/TASK-020.md`. Each is
  independently grabbable with acceptance criteria, files, edge cases, and
  verification.

### Priority snapshot

- **P0 (client blockers):** TASK-001 (€4.50 cap), TASK-002 (allergens),
  TASK-003 (pickup/delivery copy).
- **P1:** TASK-004/005 (seller mock leaks), TASK-006/007/008 (dashboard/driver/
  order mock data), TASK-009 (RevenueCat config), TASK-010 (Facebook),
  TASK-014 (CGU/CGV).
- **P2/P3:** filters, dead-code cleanup, extras pantry, onboarding copy, phone
  OTP, wallet minimum, and net-new features.

## Repositories

- Mobile: `/Users/macbookpro/Documents/progix/IncaCook` (this repo).
- Backend: `/Users/macbookpro/Documents/progix/IncaCook-Server`
  (GitHub `Feint517/IncaCook-Server`).
- Admin console: `Feint517/incacook-admin` (separate repo).
