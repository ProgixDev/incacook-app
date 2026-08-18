# IncaCook Admin Dashboard — QA Testing Guide

Manual test checklist for `incacook-admin` (Next.js, separate repo from the
Flutter app). Companion to [comprehensive-qa-guide.md](comprehensive-qa-guide.md)
(mobile) — see [end-to-end-qa-master-checklist.md](end-to-end-qa-master-checklist.md)
for how the two fit together, and
[payments-orders-subscriptions-deep-dive.md](payments-orders-subscriptions-deep-dive.md)
for the money-flow scenarios that touch both apps.

Last written: 2026-07-26.

## 0. Why this doc exists

The dashboard's own `e2e/` Playwright suite (`authed.spec.ts`) only asserts
each page **renders without an error** — it does not exercise a single
approve/reject/refund/publish action. Every mutation listed below is
currently unverified by automation, so this is where a human needs to look
hardest.

## 1. Login & role gate

- ☐ Visiting any dashboard route while signed out redirects to `/login`.
- ☐ Valid admin/moderator credentials → lands on Overview (`/`).
- ☐ Valid credentials for a **BUYER/SELLER/DRIVER** account are rejected: the
  login page signs them back out immediately and shows the inline French
  "Ce compte n'est pas autorisé…" error (don't just trust the token — the app
  fetches `/v1/users/me` after `/v1/auth/signin` and gates on `role`).
- ☐ Already-authenticated admin visiting `/login` bounces straight to `/`.
- ☐ A session that fails token refresh (expired refresh token) drops back to
  `unauthenticated` cleanly, no crash loop.
- ☐ **ADMIN** and **MODERATOR** roles currently get *identical* access (no nav
  item or button is role-conditional anywhere in the app) — confirm this is
  still true, since it's easy for a future PR to add a MODERATOR-only
  restriction without a matching e2e test to catch a regression the other way.

## 2. Overview (`/`)

- ☐ Period selector (Aujourd'hui / 7 jours / 30 jours / Tout) re-fetches all
  widgets (users/orders/revenue/listings KPIs, role breakdown, revenue detail,
  category/city charts) — numbers actually change between periods.
- ☐ Loading skeleton shows before data arrives; each widget has its own error
  state with a retry button (kill network mid-load to check).

## 3. Users (`/users`)

- ☐ Search by name / email / phone / id (debounced) narrows results.
- ☐ Pagination: next-page / no-more-pages boundary (no total count shown —
  verify it doesn't loop or dead-end early).
- ☐ Row click opens the profile drawer: suspension banner, seller rating
  block where applicable.
- ☐ **Add strike**: role + severity (LIGHT/SERIOUS/CRITICAL) + source + points
  (1–3) + reason/notes dialog → `POST /admin/users/:id/strikes`. Confirm the
  new strike shows in the strike-history list immediately after.
- ☐ **Suspend** (role + reason) → `POST …/suspend`; confirm the account can no
  longer sign in / place orders / accept deliveries from the mobile app side.
- ☐ **Unsuspend** → `POST …/unsuspend`; confirm mobile-side access returns.
- ☐ Cross-check the **90-day / 3-point auto-suspend** rule from the server
  (`STRIKE_WINDOW_DAYS=90`, `SUSPENSION_THRESHOLD_POINTS=3` —
  `IncaCook-Server/src/modules/strikes/strikes.service.ts:14-16`): add two
  LIGHT strikes then a third and confirm the account auto-suspends without a
  manual "Suspend" click; a CRITICAL strike should suspend immediately on its
  own.

## 4. Orders (`/orders`)

- ☐ Status filter covers all 12 states; search by order #/id/buyer.
- ☐ Drawer is **read-only** by design — no action buttons here. Don't go
  looking for a cancel/refund button on this page; that's not a bug, it's
  intentional (refunds happen via Disputes).
- ☐ Status timeline differs correctly for delivery vs pickup orders.
- ☐ **Financial reconciliation panel** (`GET /admin/orders/:id/financials`):
  for a normal completed order, confirm `isReconciled === true` and no
  warning banner. This is your headline "does the money add up" screen —
  see [payments-orders-subscriptions-deep-dive.md](payments-orders-subscriptions-deep-dive.md)
  for the exact formulas to check by hand.

## 5. Sellers (`/sellers`) & Drivers (`/drivers`)

- ☐ Search + category/KYC/online filters; pagination.
- ☐ Drawers are **read-only** — rating, sales, revenue, subscription status
  (sellers), vehicle/zones (drivers).
- ☐ **Stripe Connect readiness badge** (ready / pending / not_started) and a
  separate **charges-enabled badge** reflect real onboarding state — do a
  Stripe Connect onboarding on a test seller/driver account in the mobile app
  and confirm the badge flips without a page-specific refresh action (reload
  the page; there's no live-push here).
- ☐ Confirm there is **no** approve/force-onboard button anywhere on these
  pages — onboarding can only be observed, not admin-forced. Not a bug.

## 6. Listings (`/listings`)

- ☐ Search + status filter; pagination.
- ☐ Drawer shows report-count warning banner when a listing has reports —
  moderation itself happens on `/reports`, not here (no action button on
  this drawer is correct, not missing).

## 7. Reports (`/reports`) — content moderation

- ☐ Status + type filters (incl. MAUVAISE_HYGIENE).
- ☐ **PENDING** report drawer: optional admin note → **Résoudre**
  (`PATCH /admin/reports/:id/status` → RESOLVED) or **Rejeter** (→ REJECTED).
- ☐ A terminal (already-resolved/rejected) report shows "already processed"
  and no action buttons — try re-opening one from the list to confirm the
  UI doesn't let you double-process it.

## 8. Disputes (`/disputes`) — the money-decision screen

Read [payments-orders-subscriptions-deep-dive.md §Disputes](payments-orders-subscriptions-deep-dive.md)
first — the *outcome* each action produces depends on precise server-side
rules, not just "click and it works."

- ☐ Status filter: OPEN / ADMIN_REVIEW / AUTO_REFUNDED / REJECTED / RESOLVED.
  **Expect the OPEN filter to always be empty** for order disputes — the
  server never actually writes that status (every dispute is born directly
  into ADMIN_REVIEW/AUTO_REFUNDED/REJECTED). If you ever see a row under
  OPEN, that itself is worth flagging as unexpected.
- ☐ Non-terminal dispute drawer exposes 5 actions, each behind a confirm
  dialog with optional notes:
  - ☐ **approve-refund** — triggers the real Stripe refund; confirm the
    order's admin financials panel now shows the refund and wallet entries
    flipped to CANCELLED (or a debt row if already paid out).
  - ☐ **reject** — confirm any HELD wallet entries for that order flip back
    to AVAILABLE (seller/driver keep their money).
  - ☐ **resolve** (no refund) — same HELD→AVAILABLE release, no refund.
  - ☐ **confirm-allergen** — adds a SERIOUS (2pt) strike to the **seller**;
    verify it shows up on `/users` → seller drawer → strike history.
  - ☐ **confirm-chargeback-fraud** — adds a SERIOUS (2pt) strike to the
    **buyer** (the only admin action that penalizes a buyer). Verify on the
    buyer's user drawer.
- ☐ A terminal dispute shows no action buttons.

## 9. KYC (`/kyc`)

- ☐ Filter PENDING/APPROVED/REJECTED.
- ☐ Drawer: document image opens in a new tab and is actually legible.
- ☐ **PENDING only**: **Approuver** (`POST …/approve`) — confirm the
  seller/driver's mobile app now lets them go online / accept deliveries.
- ☐ **Rejeter** requires a rejection reason (min 3 chars, client-validated) →
  **Confirmer le rejet** (`POST …/reject`) — confirm the mobile app surfaces
  the rejection reason somewhere the user can see it (cross-check against
  the mobile inventory — no dedicated KYC-status screen was found client-side
  beyond onboarding gating, so this is worth a specific look).

## 10. Catalog claims (`/catalog-claims`) — B2B refunds, different from Disputes

- ☐ Status filter: OPEN / ADMIN_REVIEW / REFUNDED / REPLACEMENT_REQUESTED /
  REJECTED / RESOLVED. Unlike order disputes, **OPEN is a real, reachable
  state here** — every claim starts OPEN.
- ☐ **refund** action: try both an **empty amount** (should refund the full
  order total) and an **explicit partial amount** in € — this is the one
  place in the whole system a partial Stripe refund is actually possible.
  Confirm the catalog order's status and the seller's payment method both
  reflect a partial refund correctly.
- ☐ **request-replacement**, **resolve**, **reject** — confirm each lands in
  the right terminal status and no wallet/ledger side effects occur (catalog
  purchases never touch the seller/driver wallet ledger — only the seller's
  own card is charged/refunded).

## 11. Catalog (`/catalog`) — product management

- ☐ **Produits tab**: create a product (name 2–120 chars, description, price
  in €, up to 6 image URLs, active checkbox) → appears in the seller-facing
  supply catalog in the mobile app.
- ☐ Edit a product (row click or pencil) → change persists.
- ☐ Delete a product referenced by an **open** catalog order → server error
  surfaces verbatim in the UI (don't expect a generic failure toast — the
  actual constraint message should show).
- ☐ **Commandes tab**: read-only catalog order list, status badges/totals
  match what the seller sees in `SupplyOrdersScreen` on mobile.

## 12. Subscriptions (`/subscriptions`)

- ☐ Pure read-only list — confirm there is genuinely no cancel/refund/
  change-plan button (not a gap to report; RevenueCat/App Store/Play own
  subscription mutation, this dashboard only observes).
- ☐ After a seller purchases/restores a subscription on mobile
  (see the deep-dive doc), confirm the row here updates: plan
  (Standard/Premium), provider, period end, trial end.
- ☐ Status filter covers all 9 states — expect **PAST_DUE** reachable via a
  RevenueCat `BILLING_ISSUE` webhook test event; **UNPAID/INCOMPLETE/
  INCOMPLETE_EXPIRED are not currently written by any code path** — don't
  spend time trying to manufacture those three, they're effectively dead.

## 13. Payouts (`/payouts`) — wallets & withdrawals

- ☐ **Soldes tab**: wallet balances (available/pending/held/paid-out) per
  seller/driver, read-only — cross-check against the `WalletScreen` numbers
  the same user sees in the mobile app; they must match exactly.
- ☐ **Versements tab**: withdrawal history — confirm there is genuinely **no
  approve/reject button** (a mobile-initiated withdrawal either succeeds or
  fails synchronously against Stripe; there's nothing for an admin to
  approve). Not a gap.
- ☐ **Réconciliation tab**: diagnostic only. Run it with no filter and with a
  specific userId; for a healthy account expect zero flagged rows
  (`missing_transfer_id` / `transfer_not_found` / `amount_mismatch` /
  `reversed_uncovered` should all be absent).

## 14. Geography (`/geography`) & Zones (`/zones`)

- ☐ Geography: period selector + metric toggle (Commandes/Revenu); city
  ranking sidebar; unmatched-city notice for a city missing hardcoded
  lat/lng — fully read-only, just confirm numbers look sane vs `/orders`.
- ☐ Zones: create a zone (name, city, display order 0–1000, lat -90..90,
  lng -180..180, active) → confirm it appears in the driver signup zone
  picker (`DriverZonePage`) on mobile within the same session (no cache to
  bust — `GET /v1/zones` is called fresh at that step).
- ☐ Edit a zone's coordinates/order → persists.
- ☐ "Désactiver" (soft-delete via `DELETE /zones/:id`) → zone disappears from
  the driver-facing selector but existing drivers already assigned to it
  keep functioning (soft delete, not a hard cascade).

## 15. Notifications (`/notifications`) — ⚠️ irreversible in production

- ☐ Target select ALL/CATEGORY/CITY reveals the right conditional fields;
  client validation (title/body required, city required if target=CITY,
  max-length counters).
- ☐ **Do not send a real broadcast against production users unless the team
  has explicitly signed off** — the UI's own copy calls this irreversible.
  If you need to verify the send path works, do it against a throwaway
  QA account segment only, or verify purely at the request-validation level
  (malformed input rejected client-side) without submitting.
- ☐ On an approved test send: confirm the success banner's
  targeted/sent/failed counts are internally consistent, and the QA account
  actually receives the push (see the mobile app's `NotificationsScreen`
  inbox + system tray).

## 16. Legal documents (`/legal`)

- ☐ Create a draft (kind is immutable once chosen), version/title/content
  (edit/preview toggle, char counter).
- ☐ **Publier cette version** on a new draft → confirm dialog warns it
  deactivates the currently-active version of that kind and notifies all
  users → confirm the mobile app's `LegalTermsScreen` (fetched at
  checkout/new-dish-publish via `TermsConsentTile`) now serves the new
  content, and the previously-active version shows inactive here.
- ☐ Publish button is disabled on an already-active version (no-op
  protection).

## 17. Settings (`/settings`) — delivery fee

- ☐ Change the platform delivery fee (bounded 0–50€, comma-or-dot decimal
  input) → Save.
- ☐ Place a fresh delivery order on mobile and confirm the **new** fee is
  reflected in the checkout total (`OrderSummaryScreen`) and in the
  PaymentIntent amount — this constant is cached for 60 seconds server-side
  (`IncaCook-Server/src/modules/settings/settings.service.ts:37-61`), so wait
  a beat after saving before testing, or you may still see the stale fee.
- ☐ Revert back to the original fee afterward so you don't leave a changed
  live price behind.

## 18. Cross-cutting, every list page

- ☐ Loading skeleton → real data → (kill network) → error state with retry.
- ☐ Empty state copy differs when a filter/search is active vs a genuinely
  empty table.
- ☐ Pagination boundary (`/admin/disputes`, `/admin/catalog-claims`,
  `/admin/catalog/products`, `/admin/catalog/orders` paginate **client-side**
  off a bare array with no envelope — verify these still page correctly with
  large-ish result sets; everything else uses server-driven pagination).

## Defect log (copy per run)

| # | Page | Step | Expected | Actual | Severity | Notes |
|---|------|------|---------|--------|----------|-------|
| 1 | | | | | | |
| 2 | | | | | | |

---

**Repo:** `Feint517/incacook-admin` · **API:** `https://incacook-api-production-146b.up.railway.app`
