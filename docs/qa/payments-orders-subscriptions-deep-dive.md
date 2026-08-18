# Payments, Subscriptions & Orders — deep-dive QA scenarios

Scenario-based manual verification that crosses **both** apps: do the action
on mobile, verify the server-side effect in the admin dashboard (or via the
numbers below). This is the highest-value part of the QA pass — it's where
real money math, refunds, and subscription state live.

Companions: [comprehensive-qa-guide.md](comprehensive-qa-guide.md) (mobile
accounts/setup) · [admin-dashboard-testing.md](admin-dashboard-testing.md)
(dashboard checklist) · [revenuecat-testing.md](revenuecat-testing.md)
(subscription purchase mechanics in depth) ·
[../issues/payments-subscription-issues.md](../issues/payments-subscription-issues.md)
(known issues — check before filing a new one).

Last written: 2026-07-26, against `IncaCook-Server` as of that date. If the
constants below stop matching the code, trust the code
(`src/common/constants/pricing.constants.ts`,
`src/modules/wallets/wallets.service.ts`, `src/modules/orders/orders.service.ts`)
over this doc.

## 0. The constants you'll be checking arithmetic against

| Constant | Value |
|---|---|
| Delivery fee (flat, admin-configurable) | 3,50 € (350¢), see `/settings` |
| Platform buyer fee | 5% of (subtotal + delivery fee) |
| Commission — Standard plan seller | 30% of subtotal |
| Commission — Premium plan seller | 25% of subtotal |
| Commission floor | 1,00 € (100¢) minimum, even on tiny orders |
| Driver earning | 100% of the delivery fee (platform takes no cut of it) |
| Withdrawal minimum | 50,00 € (5000¢), entire available balance withdrawn at once |
| Wallet pending → available hold | 24h after delivery (cron sweeps every 5 min) |
| Buyer dispute claim window | 24h after delivery |
| Catalog (B2B) claim window | 14 days after payment |
| Fait-maison dish price cap | 4,50 € (Traiteur/Restaurant sellers have no cap) |

**Formula, worked example** (2000¢ subtotal, delivery order, Standard seller):
```
delivery fee   = 350
commission     = round(2000 × 30%) = 600
seller earning = 2000 − 600 = 1400
platform fee   = round((2000+350) × 5%) = round(117.5) = 118
buyer total    = 2000 + 350 + 118 = 2468¢  (24,68 €)
```
Same subtotal with a **Premium** seller: commission = 500, seller earning =
1500 — **buyer total is unchanged** (2468¢); only the seller/platform split
moves. Verify this exact invariant on a real order: buyer pays the same
whether the seller is Standard or Premium.

**Low-value floor case** — a 200¢ (2,00€) subtotal, Standard seller: naive
commission would be 60¢, but the 100¢ floor kicks in → seller only nets 100¢
(effectively a 50% cut on tiny orders). Worth one deliberate test with a
cheap add-on-free dish.

## 1. Test cards

| Card | Result |
|---|---|
| `4242 4242 4242 4242` | Succeeds immediately |
| `4000 0000 0000 0002` | Generic decline |
| `4000 0000 0000 9995` | Insufficient funds decline |
| `4000 0027 6000 3184` | Requires 3DS/SCA authentication |

Any expiry in the future, any 3-digit CVC, any postal code.

## 2. Order happy paths

### C1 — Delivery order, full chain

Use the seeded Paris trio (buyer/seller/driver — see
[comprehensive-qa-guide.md §3 Scenario 1](comprehensive-qa-guide.md)).

- ☐ Buyer places an order with a known subtotal, pays with `4242 4242 4242
  4242`.
- ☐ Compute the expected buyer total by hand (§0 formula) and confirm the
  checkout screen (`OrderSummaryScreen`) and the actual Stripe charge amount
  match to the cent.
- ☐ Run the order through: seller Accepter → Démarrer la préparation →
  Marquer prêt → driver Accepter → scan pickup QR → scan delivery QR →
  Delivered.
- ☐ In the admin dashboard, open `/orders` → this order → **financials
  panel**: `isReconciled === true`, and subtotal/commission/sellerEarnings/
  platformFee/buyerTotal match your hand-computed numbers exactly.
- ☐ Immediately after delivery, the seller's wallet shows the earning as
  **PENDING** (not yet AVAILABLE) — confirm in `/payouts` → Soldes, or the
  mobile `WalletScreen`.
- ☐ **Either** wait 24h and confirm the cron flips it to AVAILABLE, **or**
  ask an engineer to temporarily set `WALLET_RELEASE_HOURS=0` (or restart
  with a short value) in a non-prod environment so you can see the release
  sweep fire within the 5-minute cron cadence instead of waiting a day.
  Don't do this against production data.
- ☐ Commission + platform fee wallet rows (owned by the synthetic `PLATFORM`
  user) are **AVAILABLE immediately** at delivery — no hold — this is
  different behavior from the seller/driver rows and worth confirming
  explicitly if you have DB access via the admin reconciliation view.

### C2 — Pickup order

- ☐ Same as C1 but fulfillment = pickup: delivery fee is 0, no `Delivery`
  row/driver involved at all, confirmation is a single "confirm collection"
  tap by either buyer or seller (whichever taps first wins).
- ☐ Confirm the buyer total excludes the 3,50€ delivery fee but still
  includes the 5% platform fee (computed on subtotal + 0, not subtotal +
  350).

## 3. Payment failure paths

### C3 — Declined card

- ☐ Use `4000 0000 0000 0002` at checkout. Confirm the order is created
  (visible momentarily as PENDING) then automatically cancels — inventory
  (portions left) is restored, and the buyer app shows a clean
  failed/retry state, not a stuck spinner.
- ☐ Retry with `4242...` on the same cart/order — confirm no duplicate order
  is created (idempotency key reuse) and the retry succeeds.

### C4 — 3DS challenge

- ☐ Use `4000 0027 6000 3184`. Confirm the app actually presents a 3DS
  challenge (Stripe's test challenge screen) rather than silently failing or
  silently succeeding.
- ☐ Abandon the 3DS challenge (don't complete it) — confirm the order
  eventually resolves to cancelled rather than staying PENDING forever (this
  can take a while; Stripe auto-cancels unconfirmed PaymentIntents after 24h
  by default — a long-tail case, not something to babysit in real time, but
  worth spot-checking a day-old abandoned-3DS order shows CANCELLED, not
  stuck PENDING).

## 4. No-driver-available path

### C5 — Switch to pickup

- ☐ Get an order to READY on a delivery order with **no drivers online** (or
  simulate by not accepting on the driver device) and wait ~15 minutes (or
  ask an engineer to lower `NO_DRIVER_TIMEOUT_MINUTES` for the test) for the
  no-driver watchdog. Buyer sees a "no driver available" prompt.
- ☐ Choose "switch to pickup" — order returns to READY as a pickup order, no
  refund, buyer completes via in-person collection.

### C6 — Cancel and refund

- ☐ Same setup, but choose "cancel and refund" (or let the ~10-minute
  buyer-response window auto-expire). Confirm a full Stripe refund, and no
  strike against the seller (this path is nobody's fault).

## 5. Seller-initiated cancellation

### C7 — Seller cancels pre-pickup

- ☐ Seller taps "Je ne peux pas fournir" on a CONFIRMED/PREPARING/READY
  order → confirm dialog with optional note → confirm full refund to buyer
  **and** a strike lands on the seller's account
  (`/users` → seller drawer → strike history, LIGHT/1pt,
  `SELLER_CANNOT_PROVIDE`).
- ☐ For a delivery order where the driver has already been dispatched and
  arrives to find the seller absent (`reportSellerUnavailable` from the
  driver side): confirm the buyer is refunded, the seller gets the same
  1pt strike (`SELLER_UNAVAILABLE`), and — distinctively — the **driver is
  compensated in full** for the delivery fee immediately (no 24h hold),
  since it's not the driver's fault either.

## 6. Disputes — verify the decision matrix, not just "an action happened"

File a dispute of each type from `OrdersHistoryScreen`/`OrderTrackingScreen`
→ `DisputeScreen` (buyer side) within 24h of delivery, and confirm the
**resulting status matches this table** — a mismatch here is a real bug, not
a UX nit:

| Dispute type filed | Expected outcome | Auto-refund? | Auto strike? |
|---|---|---|---|
| Subjective dissatisfaction | REJECTED immediately | No | No |
| "Never received" **with** delivery-confirmation proof on file | ADMIN_REVIEW (admin must decide) | No | No |
| "Never received" **without** delivery proof | AUTO_REFUNDED | Yes, full | No |
| Wrong order | AUTO_REFUNDED | Yes, full | Yes — seller LIGHT 1pt |
| Spoiled food | ADMIN_REVIEW | No (pending) | No |
| Food poisoning (photo proof required to submit) | ADMIN_REVIEW | No (pending) | No |
| Allergen false declaration (description required) | ADMIN_REVIEW | No (pending admin confirm) | No |

- ☐ Confirm **Food poisoning** genuinely refuses submission without at least
  one proof photo, and **Allergen** refuses submission without a
  description — these are client + server enforced.
- ☐ Confirm filing a **second** dispute of the same type on the same order
  while one is still open is rejected.
- ☐ Confirm filing any dispute **more than 24h after delivery** is rejected.
- ☐ For every `ADMIN_REVIEW` dispute above, exercise the matching admin
  action from [admin-dashboard-testing.md §8](admin-dashboard-testing.md)
  and confirm the side effects (refund / strike / HELD-release) match.
- ☐ **Chargeback**: not buyer-filable in-app. Trigger a real Stripe test
  chargeback (Stripe dashboard, test mode) against a paid order's charge and
  confirm it lands in the admin Disputes list as `ADMIN_REVIEW`, type
  CHARGEBACK, with no auto-refund or auto-strike until an admin uses
  **confirm-chargeback-fraud** (buyer strike) or another resolution action.

## 7. Wallet & withdrawals

### C8 — Withdrawal below minimum

- ☐ With an available balance under 50,00€, confirm "Demander un retrait" is
  disabled/blocked with a message stating both the €50 threshold and the
  current balance.

### C9 — Happy-path withdrawal

- ☐ With ≥50,00€ available and Stripe Connect payout onboarding complete,
  request a withdrawal — confirm it withdraws the **entire** available
  balance (not a partial amount you might expect to type in — there's no
  amount field), moves those ledger rows to PAID_OUT, and shows up in
  `/payouts` → Versements on the admin side with a Stripe transfer id.
- ☐ Immediately re-request a withdrawal before the first completes (rapid
  double-tap) — confirm the second attempt is rejected with a
  "withdrawal already in progress" message, not a duplicate transfer.

### C10 — Debt blocks withdrawal

This one requires provoking a refund-after-payout scenario (a delivered
order that later gets refunded via a dispute, after the seller/driver
already cashed out that specific earning) — likely needs engineering
assistance to set up in a QA environment. If you can get a wallet into debt:

- ☐ Confirm withdrawal is fully blocked (not partially allowed) with a clear
  "your balance shows a debt" message, even if other, newer earnings would
  otherwise clear the €50 minimum.
- ☐ Confirm future earnings automatically net against the debt (it doesn't
  need a manual admin clear step) — once enough new earnings accrue to bring
  the net balance positive and above €50, withdrawal becomes possible again.

## 8. Seller subscriptions (RevenueCat)

Follow [revenuecat-testing.md](revenuecat-testing.md) for sandbox
purchase mechanics; this section is about verifying the **business-rule
side effects**, not the App Store plumbing itself.

- ☐ **Purchase Standard** on a fresh seller (paywall shown on first gated
  tab visit) → confirm `/subscriptions` in the admin dashboard shows
  ACTIVE + Standard, and the seller's next order settles at the **30%**
  commission rate.
- ☐ **Purchase Premium** instead → confirm **25%** commission on the next
  order, and confirm the **buyer pays the identical total either way**
  (§0 invariant) — only the seller/platform split changes.
- ☐ **Restore purchase** on a second device/reinstall with the same
  RevenueCat identity → entitlement re-activates without a new charge.
- ☐ **Cancel** the subscription (via the store's subscription management,
  not an in-app button — there isn't one) → confirm the seller's
  active-status flips to inactive **immediately**, even though the store
  may still show time remaining on the current billing period. This is
  intentional current behavior (not a bug): the code treats `CANCELLED`
  status as inactive right away rather than waiting for `EXPIRATION`. If a
  seller complains their "still-paid" period got cut short, that's this
  known behavior, already flagged in the technical notes — not a new bug to
  file, but worth confirming it still matches product intent.
- ☐ While inactive (lapsed/cancelled/never subscribed): confirm the seller
  **cannot** create/edit/publish a listing (403 `SUBSCRIPTION_INACTIVE`) and
  a buyer **cannot** place a new order against that seller (400) — but
  existing in-flight orders are unaffected.
- ☐ **Expired-but-DB-stuck-ACTIVE edge case**: if you can inspect/set
  `subscriptionCurrentPeriodEnd` to a past date while status still reads
  ACTIVE (simulating a missed webhook), confirm the seller is still
  correctly treated as inactive — the gate checks the period end date, not
  just the status string.

## 9. Catalog (B2B supply) orders — different rails from marketplace orders

- ☐ As a seller, buy something from `SupplyCatalogScreen` → pay with
  `4242...`. Confirm this creates **no wallet ledger entries at all** (it's
  the seller paying the platform directly, not an order the platform
  brokers) — cross-check `/payouts` shows nothing new for this purchase.
- ☐ File a claim (`SupplyClaimScreen`) within 14 days of payment → as admin,
  process a **partial** refund (type an amount less than the total) via
  `/catalog-claims` → confirm exactly that amount is refunded on the
  seller's card, order stays distinguishable from a full refund.
- ☐ Try filing a claim **after** the 14-day window (or ask engineering to
  backdate a test order's `paidAt`) → confirm it's rejected.
- ☐ Try opening a second claim of the same type while one is still open →
  rejected.

## 10. Known dead / unreachable states — don't chase these

- `OrderStatus.PICKED_UP` and `OrderStatus.DISPUTED` are declared in the
  schema but no code path currently writes either onto an `Order` row (the
  `Delivery` sub-record does use its own `PICKED_UP`, that's different and
  fine). If you're trying to manufacture an Order in status `DISPUTED` and
  can't — that's expected today, not a tooling failure on your part.
- `OrderDispute.status = 'OPEN'` is never assigned by any code path — every
  dispute is born directly into ADMIN_REVIEW/AUTO_REFUNDED/REJECTED. The
  admin dashboard's OPEN filter for order disputes will stay empty. (Contrast
  `CatalogClaim`, whose OPEN state *is* real and reachable.)
- `SubscriptionStatus.UNPAID` / `INCOMPLETE` / `INCOMPLETE_EXPIRED` are
  declared but not produced by current RevenueCat webhook handling — leftover
  from a removed Stripe-Billing path. Don't try to manufacture these.
- The admin dashboard has **no** Stripe Connect approval action, **no**
  withdrawal approve/reject action, and **no** subscription plan-management
  action anywhere — confirmed intentional (see
  [admin-dashboard-testing.md](admin-dashboard-testing.md) §5, §13, §12).
  Don't file "missing button" bugs for these.

## Defect log (copy per run)

| # | Scenario | Step | Expected | Actual | Severity | Notes |
|---|----------|------|---------|--------|----------|-------|
| 1 | | | | | | |
| 2 | | | | | | |

---

**Backend:** `IncaCook-Server` (Railway, production) · **Stripe:** test mode
· **RevenueCat:** sandbox — see [revenuecat-testing.md](revenuecat-testing.md)
