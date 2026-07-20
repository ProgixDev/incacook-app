# Payment-domain boundaries and sources of truth — decisions + ownership matrix

- **GitHub:** [#3 Define payment-domain boundaries and sources of truth](https://github.com/ProgixDev/incacook-app/issues/3)
- **Mode:** HITL grilling + domain modeling
- **Status:** decisions RESOLVED (owner sign-off recorded 2026-07-15); ownership
  matrix partially blocked on `#5` config evidence.
- **Evidence sources:** this session's grilling, plus
  `findings/04-connect-onboarding-return.md` and
  `findings/06-wallet-ledger-invariants.md`.

---

## 1. Product decisions (authoritative)

These were decided by the product owner in session on 2026-07-15. They override
both the current code and `docs/qa/full-user-journey-testing.md` wherever those
disagree. Downstream tickets may now treat these as settled.

### DEC-1 — Seller Connect setup/resume lives in the Wallet setup card

The seller's durable entry point to Stripe Connect onboarding is the **payout
setup card inside the Wallet screen**, which is reached via the **ungated Profil
tab → Wallet**. The Accueil home banner is retained as a *discovery* surface
only; it is not the owning entry point.

**Consequence:** the driver-only condition on the setup card must be removed so
it renders for sellers too. Today `wallet_screen.dart:111` gates the card on
`UserController.driverNeedsPayoutSetup`, which is defined as
`d != null && !d.stripeOnboardingCompleted` (`user_controller.dart:112-115`) —
so it is structurally unreachable for a seller, whose `driverAccount` is null.

**This decision ratifies intent already asserted twice in code** and never
implemented:

- `seller_nav_tabs.dart:11-14` — *"Messages and Profil stay ungated so the seller
  can still chat, reach settings, and finish payout onboarding."*
- `subscription_gate.dart` — *"the Profil tab is intentionally left ungated so
  settings + payout onboarding stay reachable."*

The QA doc's "Profil → settings → Stripe Connect payout" path (step 19) is
therefore **directionally correct and is NOT stale**; it is unimplemented. The
QA doc's precise wording should be updated to name the Wallet card.

### DEC-2 — Connect gates withdrawal, never earning

A seller or driver **accrues earnings to the internal wallet ledger regardless of
Stripe Connect state**. Payout readiness is evaluated **only at withdrawal
time**. The wallet is an internal ledger; Stripe Connect is a withdrawal
destination and nothing more.

"Wallet connected" is **banned** as a synonym for Stripe onboarding. A wallet
always exists for an earner; a Connect account may not.

This ratifies the existing architecture rather than changing it — confirmed
independently in `WalletEntry` (`prisma/schema.prisma:1530`, which carries no
Connect dependency) and in code comments at `wallet_screen.dart:42,242-243`
(*"drivers can deliver + earn without Stripe payout onboarding; it's only needed
to withdraw"*).

### DEC-3 — Seller app access is gated by subscription entitlement ONLY

`SubscriptionGate` on Accueil / Commandes / Mes plats, driven by subscription
entitlement alone. Messages / Profil stay ungated. **Payout readiness must never
gate app access**, and signup completeness is not an access gate. This preserves
current behavior.

### DEC-4 — Payout readiness is split into distinct persisted facts

The single `stripeOnboardingCompleted` boolean is **retired as the sole model**.
Persist the distinct facts Stripe actually reports: `detailsSubmitted`,
`chargesEnabled`, `payoutsEnabled`.

The backend already computes all four and discards three
(`onboarding.service.ts:149` returns them; `:143` persists only the bool). The
collapse makes three materially different states indistinguishable to the client:

| Real state | Today | After DEC-4 |
|---|---|---|
| Never started | `false` | `detailsSubmitted=false` |
| Submitted, awaiting Stripe review | `false` | `detailsSubmitted=true, payoutsEnabled=false` |
| Stripe later revoked payouts | `false` | `payoutsEnabled=false` after having been true |

Per `#4`, payout readiness is `payouts_enabled && details_submitted` and must
**not** include `charges_enabled` (a connected account that can take charges is
not thereby payable).

### DEC-5 — The lapsed-seller money trap is a defect, not accepted behavior

DEC-1 + DEC-2 + DEC-3 combine into a trap that DEC-1 exists to close:

1. A seller accrues earnings without Connect (DEC-2).
2. Their subscription lapses → Accueil shows the paywall (DEC-3).
3. Their only Connect entry is the banner **on the now-paywalled Accueil**.
4. Profil → Wallet is reachable and shows the balance, but the setup card is
   driver-only and never renders.

Net: **a lapsed seller must pay €4/mo to reach money they have already earned.**
`#4` confirms the backend simultaneously instructs them to *"Configurez vos
paiements pour retirer vos gains"* — an action the UI does not offer. Since
sellers earn before subscribing, this state is **normal, not an edge case**.

**Ruling:** ability to withdraw already-earned funds must never depend on an
active subscription. DEC-1 closes this. Any future gate proposal that
re-introduces the dependency must be rejected on this ground.

---

## 2. Canonical vocabulary + ownership matrix

Each term is one domain object. Where two terms share one field today, the row is
flagged as a **conflict**.

| # | Canonical term | Identifier | Source of truth | Allowed writers | Client reader | User-visible gate | Reconciliation | Failure owner |
|---|---|---|---|---|---|---|---|---|
| 1 | **Buyer payment** | Stripe `PaymentIntent` id | **Stripe** | Stripe webhook only | Order status | Checkout | `payment_intent.*` webhooks | Backend `#8` |
| 2 | **Seller subscription entitlement** | `SellerProfile.subscriptionStatus` + `subscriptionCurrentPeriodEnd` | **RevenueCat, sole source of truth (DEC-8, resolved `#11`)** | RevenueCat webhook only (Stripe path removed) | `SubscriptionGate` | Accueil/Commandes/Mes plats (DEC-3) | RevenueCat sync | `#11` ✅ |
| 3 | **Earning** | `WalletEntry(type=*_EARNING)` | **Backend ledger** | Fulfillment finalizer | Wallet | none (DEC-2) | `@@unique(orderId,userId,type)` | Backend `#6` |
| 4 | **Platform commission** | `WalletEntry(type=COMMISSION, userId='PLATFORM')` | Backend ledger | Fulfillment finalizer | Admin only | none | same | Backend `#6` |
| 5 | **Pending balance** | `sum(status=PENDING)` | Backend ledger | Release sweep | Wallet | none | `availableAt` + sweep | Backend `#6` |
| 6 | **Available balance** | `sum(status=AVAILABLE)` | Backend ledger | Release sweep | Wallet | €50 withdraw threshold | sweep CAS | Backend `#6` |
| 7 | **Held balance** | `sum(status=HELD)` | Backend ledger | Dispute handler | Wallet | none | **NONE — see conflict C3** | Backend `#6` |
| 8 | **Paid-out total** | `sum(status=PAID_OUT)` | Backend ledger | Withdrawal txn | Wallet + admin | none | **BROKEN — see conflict C1** | Backend `#6` |
| 9 | **Debt** | — | **DOES NOT EXIST** | — | — | — | — | **see conflict C4** |
| 10 | **Connected payout account** | `stripeConnectAccountId` | **Stripe** | Onboarding svc | — | none (DEC-2) | `account.updated` + live poll | `#4` |
| 11 | **Payout readiness** | `payoutsEnabled && detailsSubmitted` (DEC-4) | **Stripe** (live) | Onboarding svc + webhook | Wallet setup card (DEC-1) | **Withdrawal only** (DEC-2) | live `accounts.retrieve` on return | `#4` |
| 12 | **Signup completeness** | per-role profile fields | Backend | Signup flow | Signup | signup only | — | — |
| 13 | **Withdrawal request** | `WalletEntry(type=WITHDRAWAL, amountCents<0, orderId=null)` | Backend ledger | `requestWithdrawal` | Wallet | payout readiness + €50 | **NONE — see conflict C2** | Backend `#7` |
| 14 | **Platform→connected transfer** | Stripe `Transfer` id | **Stripe** | `requestWithdrawal` | — | — | idempotency key (**broken, C2**) | Backend `#7` |
| 15 | **Connected→bank payout** | Stripe `Payout` id | **Stripe** | Stripe (automatic) | — | — | none — Stripe-owned | Stripe |

### Terms deliberately held apart

`#4` confirms these are correctly separated today and must stay separated:
payout readiness (11) ≠ signup completeness (12) ≠ KYC status ≠ driver claim
eligibility (**KYC only** — `user_controller.dart:117-118`) ≠ subscription
entitlement (2).

---

## 3. Conflicts — fields that map to more than one term

- **C1 — `PAID_OUT` status means two different things.** It is stamped on both
  the positive earnings rows and the negative withdrawal debit
  (`wallets.service.ts:491-505`), so term 8 sums to a permanent zero. `type` is
  correct on every row but never consulted. *(Owner: `#6`. Root cause: the ledger
  conflates* what kind of money *(`type`) with* what stage *(`status`), and every
  aggregation filters on `status` alone.)*
- **C2 — withdrawal (13) has no identity before Stripe.** The Stripe idempotency
  key is minted per-call (`wallets.service.ts:470,480`), so term 13 and term 14
  are not 1:1 under concurrency → double payout. *(Owner: `#7`.)*
- **C3 — `HELD` (7) is a terminal state with no exit.** One write
  (`wallets.service.ts:92`), zero exits: a seller who *wins* a dispute is never
  paid. *(Owner: `#6`.)*
- **C4 — debt (9) has no representation.** No `SELLER_DEBT` type exists, so a
  post-release refund (`orders.service.ts:3325-3327`, `PENDING`-only) has no
  recovery instrument. Money conservation is violated. *(Owner: `#6`.)*
- **C5 — the 5% platform buyer fee is booked nowhere.** No ledger row, no `Order`
  column; the schema comment at `:853` still carries the pre-fee formula. The
  ledger can never reconcile to `buyerTotal`. *(Owner: `#6`.)*
- **C6 — `stripeOnboardingCompleted` collapses terms 10, 11 and 12.** Resolved by
  DEC-4; migration owned by `#4`.
- **C7 — RESOLVED (DEC-8, 2026-07-18).** term 2 had a fully-built Stripe
  implementation that could never run. `#5` found
  `STRIPE_SELLER_SUBSCRIPTION_PRICE_ID` and all three subscription URLs
  **unset in the deployment**, so Stripe subscription checkout 503s — while the
  webhook handler implemented the subscription events in full. Meanwhile the QA
  journey buys the subscription through **RevenueCat / App Store** (step 10-13).
  Confirmed via `#11`: the mobile UI that would have driven Stripe checkout
  (`subscribe_flow.dart`/`subscription_repository.dart`) was itself dead code
  with zero live callers, and the "$4/mo" figure quoted throughout the backend
  never matched the real RevenueCat product catalog (6 tiers, €4,99–€14,99/mo).
  **Decision: RevenueCat is the sole source of truth.** The Stripe subscription
  writer (`SubscriptionsController`/`Service`/`Module`, and the
  `checkout.session.completed`/`customer.subscription.*`/`invoice.payment_failed`
  branches of `StripeWebhookHandlerService`) was **removed**, not merely
  disabled — it was a real hazard (racing the RevenueCat webhook for the same
  `SellerProfile.subscriptionStatus`/`subscriptionCurrentPeriodEnd` fields), not
  just dead weight.

---

## 4. Consequences for downstream tickets

- **`#4`** — its D1 (severity 1) fix direction is now unblocked: implement DEC-1
  (drop the driver-only condition at `wallet_screen.dart:111`). Its Q18/Q19 pass
  criteria are now decidable. DEC-4 governs the readiness-field migration.
- **`#6`** — DEC-2 is ratified: "Connect gates withdrawal, not earning" is a
  confirmed domain rule, so no earning-time Connect check may be added. C1/C3/C4
  are confirmed defects, not design.
- **`#11`** — term 2's source of truth stays **open**; it is that ticket's call.
- **`#5`** — must confirm `account.updated` is subscribed on the deployed
  connected-account endpoint; if it is not, `#4`'s D7 is permanent, not
  intermittent.
- **QA doc** — step 19 is directionally right but must name the Wallet card, not
  a generic "settings" path.

`CONTEXT.md` should be updated with §2's vocabulary **only after `#11` resolves
term 2** — otherwise the glossary would enshrine a contested owner.

---

## 5. Unknowns / not verified

- Term 2's true owner (RevenueCat vs Stripe) — deferred to `#11` by design.
- Whether any **production** seller is currently in the DEC-5 trap (has a
  balance + lapsed subscription). This needs a read-only production query and is
  the input to any backfill decision; not attempted here (planning-only rule).
- Real financial exposure of C1/C2 — needs production data, not code reading.
- Deployed webhook topology — pending `#5`.
