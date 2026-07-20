# Findings — Prove wallet credit, release, hold, debt, and reversal invariants

> ## ⚠️ STATUS UPDATE (2026-07-18): all defects below are FIXED.
> Everything this document calls a defect (D1/D3/D4/D5) and the withdrawal
> race D2 (+ D6's actual risk) was fixed and merged in server PR
> [#6](https://github.com/ProgixDev/incacook-server/pull/6),
> **2026-07-16** — two days before this document was re-verified against
> current code and found to already be stale. The narrative below (sections
> 0-10) is the **original investigation, kept for its analysis/evidence
> value** — do not treat its "PROVEN DEFECT" language as describing current
> code. See `.agent-board/map.md`'s `#6` correction note for exactly what
> changed and where. Remaining open items are non-blocking **policy**
> questions (§8), not defects.

- **Issue:** [#6](https://github.com/ProgixDev/incacook-app/issues/6) (closed 2026-07-18)
- **Ticket:** `.agent-board/backend/02-wallet-ledger-invariants.md`
- **Mode:** AFK research — read-only. No source file modified, no migration run, no DB touched.
- **Repos read:** `IncaCook-Server` (primary), `IncaCook` (Flutter), `incacook-admin` (Next.js).
- **Paths below are relative to their repo root.**

---

## 0. Headline verdict — `paidOutCents` netting

> **The hypothesis is CONFIRMED. `paidOutCents` is not merely "sometimes wrong" — it is
> mathematically pinned to `0` for every user, in every state, on both `/wallet/me` and the
> admin wallets list. It is a constant-zero field wearing the costume of a total.**

### Why (mobile / `/wallet/me`)

`IncaCook-Server/src/modules/wallets/wallets.service.ts:377` computes:

```ts
this.sumByStatus(user.id, WalletEntryStatus.PAID_OUT),
```

and `sumByStatus` (`wallets.service.ts:356-362`) is:

```ts
const agg = await this.prisma.db.walletEntry.aggregate({
  where: { userId, status },      // ← filters on STATUS ONLY, never on `type`
  _sum: { amountCents: true },
});
```

The defect is that `PAID_OUT` is a **status**, and the withdrawal transaction stamps that
status onto **both sides of the same payout**:

`wallets.service.ts:490-506`

```ts
await this.prisma.$transaction([
  this.prisma.db.walletEntry.updateMany({
    where: { id: { in: available.map((e) => e.id) } },
    data: { status: WalletEntryStatus.PAID_OUT, withdrawalId },   // ← the POSITIVE earnings: +total
  }),
  this.prisma.db.walletEntry.create({
    data: {
      type: WalletEntryType.WITHDRAWAL,
      amountCents: -total,                                        // ← the NEGATIVE debit: −total
      status: WalletEntryStatus.PAID_OUT,                         // ← same status
      ...
    },
  }),
]);
```

`total` is defined at `wallets.service.ts:434` as exactly `available.reduce((s, e) => s + e.amountCents, 0)`
— the sum of precisely the rows that line 491-494 flips. So for every withdrawal *k*:

```
Σ(PAID_OUT rows of withdrawal k) = (+total_k) + (−total_k) ≡ 0
```

This is not a rounding artefact or a race — it is an **algebraic identity**. Summing over all
withdrawals `1..n` gives `Σ 0 = 0`. Therefore:

| Wallet state | `paidOutCents` returned |
|---|---|
| No withdrawal ever | `0` (no PAID_OUT rows) |
| 1 withdrawal of 6 000 c | `+6000 − 6000` = **`0`** |
| 12 withdrawals totalling 90 000 c | **`0`** |
| Withdrawal that settled a `DRIVER_DEBT` row | **`0`** |

**There is no data condition under which this field is non-zero.** The ticket framed this as
"paid earnings **plus** a withdrawal produce a false zero"; the sharper truth is that a
withdrawal *cannot exist* without its own offsetting pair, so the false zero is unconditional.

### Why (admin) — same bug, defeated mitigation

`IncaCook-Server/src/modules/admin/wallets/admin-wallets.service.ts:112-115`

```ts
case WalletEntryStatus.PAID_OUT:
  // WITHDRAWAL debits are negative — report the magnitude paid out.
  acc.paidOutCents += Math.abs(sum);
  break;
```

The comment proves the author's mental model: *"this group contains only the negative WITHDRAWAL
row, so take its magnitude."* That model is wrong. The `groupBy` at
`admin-wallets.service.ts:85-89` groups by `['userId', 'status', 'currency']` — **`type` is not a
grouping key**. So `sum` is the same net-zero as above, and `Math.abs(0) === 0`.

The `Math.abs` is a **defence that fires after the information is already destroyed**: netting
happens inside the `groupBy`, `Math.abs` is applied to the collapsed scalar. Admin shows `0 €` in
the "Versé" column (`incacook-admin/app/(dashboard)/payouts/_components/payouts-client.tsx:85`)
for every user, forever.

### Blast radius

Both consumers of the field are affected, and they agree with each other — which is the
dangerous part. Mobile and admin display the **same wrong number**, so cross-checking one against
the other *confirms* the bug rather than exposing it.

- Mobile: `IncaCook/lib/features/wallet/presentation/wallet_screen.dart:195` renders it under the
  label **"Déjà versé"** ("already paid out") — an unqualified lifetime-cumulative claim.
  Every seller and driver who has ever withdrawn is told they have been paid **0 €**.
- Admin: `payouts-client.tsx:85`, column **"Versé"**.

### The fix (proposed, NOT implemented)

Filter by **type**, not just status, and negate the debit rows. The authoritative definition of
"paid out" is the magnitude of the `WITHDRAWAL` rows alone:

```ts
// wallets.service.ts — replace the sumByStatus(PAID_OUT) call at :377
const paidOutAgg = await this.prisma.db.walletEntry.aggregate({
  where: { userId, type: WalletEntryType.WITHDRAWAL, status: WalletEntryStatus.PAID_OUT },
  _sum: { amountCents: true },
});
const paidOutCents = Math.abs(paidOutAgg._sum.amountCents ?? 0);
```

For admin, add `'type'` to the `groupBy` keys and sum only `WITHDRAWAL` rows (its existing
`listWithdrawals` at `admin-wallets.service.ts:173-211` already does the right thing — it filters
`type: WalletEntryType.WITHDRAWAL` at :178 and uses `Math.abs(r.amountCents)` at :204 on a
*single row*, which is correct precisely because no netting precedes it).

> **Why the bug survived review:** the ledger overloads one `status` column with two orthogonal
> meanings — *"this earning has been settled"* and *"this is a settlement instrument"*. See
> §6 / H1. Every test fixture hardcodes `PAID_OUT: 0`
> (`wallets.service.driver-debt.spec.ts:88,99`), so the constant-zero looks like a pass.

---

## 1. Ledger schema summary + sign conventions

**Model** — `IncaCook-Server/prisma/schema.prisma:1530-1555`

| Field | Type | Notes |
|---|---|---|
| `id` | `String @id` | ULID, generated in app (`generateUlid()`) |
| `userId` | `String` | Beneficiary `User.id`; the **string literal `'PLATFORM'`** for `COMMISSION` rows (`schema.prisma:1532-1533`) |
| `orderId` | `String?` | `null` for payout rows |
| `type` | `WalletEntryType` | see below |
| `amountCents` | `Int` | **Positive = credit; negative = debit** (`schema.prisma:1536`) |
| `currency` | `String @default("eur")` | never varied in code |
| `status` | `WalletEntryStatus @default(AVAILABLE)` | see below |
| `withdrawalId` | `String?` | groups a payout: the debit + the entries it settled |
| `availableAt` | `DateTime?` | `deliveredAt + 24h`; when the sweep may release |
| `releasedAt` | `DateTime?` | when the sweep actually released |
| `metadata` | `Json?` | `transferId`, `reason`, `compensation` |

**Constraints** — `schema.prisma:1552-1554`

```prisma
@@unique([orderId, userId, type])   // idempotency for earning/commission rows
@@index([userId, status])
@@index([orderId])
```

> ⚠️ The unique is **`(orderId, userId, type)` with `orderId` nullable**. Postgres treats
> `NULL`s as distinct in a unique index, so **`WITHDRAWAL` rows (which always have
> `orderId = null`) are entirely unconstrained** — unlimited duplicates permitted. The schema
> comment at `schema.prisma:1550-1551` acknowledges this as deliberate ("many allowed"), but it
> means **the ledger's only idempotency mechanism does not cover payouts at all**. See §5 / D2.

**`WalletEntryType`** — `schema.prisma:1439-1446`

| Value | Sign | Booked where | Status at birth |
|---|---|---|---|
| `ORDER_EARNING` | `+` | `wallets.service.ts:112` (normal), `:216` (driver-disappeared) | `PENDING` / `HELD` / `AVAILABLE` |
| `DELIVERY_EARNING` | `+` | `wallets.service.ts:140` (normal), `:185` (compensation) | `PENDING` / `HELD` / `AVAILABLE` |
| `COMMISSION` | `+` | `wallets.service.ts:124` — `userId = 'PLATFORM'` | **always `AVAILABLE`** (`:126`) |
| `REFUND` | — | **NEVER WRITTEN ANYWHERE** — dead enum member (verified by grep across `src/`) | — |
| `WITHDRAWAL` | `−` | `wallets.service.ts:499-501` (`amountCents: -total`) | `PAID_OUT` |
| `DRIVER_DEBT` | `−` | `wallets.service.ts:250-251` (`amountCents: -amountCents`) | `AVAILABLE` |

**`WalletEntryStatus`** — `schema.prisma:1448-1454`

| Value | Meaning | Written at | Exit paths |
|---|---|---|---|
| `PENDING` | earning inside the 24h safety window | `wallets.service.ts:92` | → `AVAILABLE` (`:326`), → `CANCELLED` (`:348`, `orders.service.ts:3327`) |
| `AVAILABLE` | withdrawable (or negative debt) | `:126`, `:187`, `:218`, `:251`, `:326` | → `PAID_OUT` (`:493`) |
| `HELD` | disputed — not payable | `wallets.service.ts:92` (only) | **NONE — terminal dead-end. See §4 / D3.** |
| `PAID_OUT` | settled by a payout | `:493`, `:501` | terminal |
| `CANCELLED` | reversed | `:348`, `orders.service.ts:3327`, `:1938` | terminal |

**Sign convention summary.** Two independent negative-signed concepts share the `AVAILABLE`/
`PAID_OUT` statuses: `DRIVER_DEBT` (a clawback that *should* net against balance — netting is
correct and intended, `wallets.service.ts:374`) and `WITHDRAWAL` (a settlement instrument that
*must not* net against the earnings it settles). **The ledger has no way to distinguish
"netting is meaningful" from "netting is destructive" without consulting `type`** — and
`sumByStatus` never does. That single omission is the root of §0.

**No materialised balance table exists.** Every balance is aggregated on the fly from
`WalletEntry` (`admin-wallets.service.ts:59-61`). The ledger is the sole source of truth.

**Money never moves at fulfilment.** Real Stripe money moves only in `requestWithdrawal`
(`wallets.service.ts:473-482`). Confirmed: `stripe.client.transfers.create` appears nowhere else
in the wallet path.

---

## 2. Invariant table

Verdicts: **HOLDS** = proven correct against code · **VIOLATED** = proven defective ·
**UNPROVEN** = could not establish either way (see §9).

| # | Invariant | Verdict | Evidence (`IncaCook-Server/` unless noted) | Notes |
|---|---|---|---|---|
| I1 | Buyer payment authorizes the order flow but does **not** credit seller/driver earnings before the authoritative fulfilment event | **HOLDS** | `src/modules/payments/webhooks/stripe-webhook-handler.service.ts:209-246` | `payment_intent.succeeded` only flips `PENDING → CONFIRMED` (`:230-238`) and notifies. No wallet call. The only `creditForCompletedOrder` caller is `releaseFundsForCompletedOrder` (`orders.service.ts:2138-2140`), reached from `confirmPickup` (`:2090`) and `confirmDeliveredByDriver` (`:2123`). Independently guarded by `creditForCompletedOrder`'s own status check (`wallets.service.ts:79-86`) — defence in depth. |
| I2 | Pickup credits **seller + platform commission only** | **HOLDS** | `wallets.service.ts:130-145`; `orders.service.ts:2074-2090` | Driver row is gated on `order.fulfillmentChoice === FulfillmentChoice.Delivery && driverId && fulfillmentFeeCents > 0` (`:131-135`). `confirmPickup` rejects non-`PICKUP` orders at `orders.service.ts:2074-2078`. Pickup orders have `fulfillmentFeeCents = 0` by construction (`pricing.constants.ts:68`), so the guard is belt-and-braces. |
| I3 | Delivery credits **seller + assigned driver + platform commission** per the pricing contract | **VIOLATED** (incomplete) | `wallets.service.ts:107-145` vs `src/common/constants/pricing.constants.ts:81-93` | Split math for the three booked rows is **correct**, but the **5% platform buyer fee is never booked as a ledger row**. See §3 / D1. |
| I4 | Earnings accrue **without** a ready Stripe Connect account (Connect gates withdrawal, not earning) | **HOLDS** — and is explicit/deliberate | `src/modules/deliveries/deliveries.service.ts:594-600`; `wallets.service.ts:457-467` | Claim path comments: *"Stripe Connect onboarding is deliberately NOT required to claim… payout setup is enforced only at withdrawal"* and logs `[DriverClaim] allowed without Stripe onboarding`. `creditForCompletedOrder` never reads Connect state. Gate lives solely in `requestWithdrawal` (`:460-467`, throws `ErrorCodes.PayoutSetupRequired` / 403). **Domain decision owned by issue #3 — see §8.** |
| I5 | New earnings enter `PENDING` | **HOLDS** | `wallets.service.ts:92,115,143` | `earningStatus = disputed ? HELD : PENDING`. Both `ORDER_EARNING` and `DELIVERY_EARNING` use it. |
| I5b | …**except** the two incident credits, which are born `AVAILABLE` | **HOLDS** (deliberate) | `wallets.service.ts:187` (`compensateDriver`), `:218` (`creditSellerEarning`) | Documented rationale (`:172-176`, `:201-207`): the order ends `CANCELLED`, so a `PENDING` row would be reversed by the sweep (`:311-313`). Bypassing the window is **necessary and correct** here. |
| I6 | `PENDING → AVAILABLE` **only after** the safety window | **HOLDS** | `wallets.service.ts:93-95, 286-292, 322-327` | `availableAt = deliveredAt + WALLET_RELEASE_HOURS` (default 24, env-overridable at `:35`). Sweep filters `status: PENDING, availableAt: { lte: now }` and re-checks the order is still `Delivered`/`Completed` (`:308`). Double-guarded. |
| I7 | Refund/cancellation reverses `PENDING` earnings | **HOLDS** | `orders.service.ts:3325-3328`; `wallets.service.ts:311-313, 345-350` | Two independent paths reverse to `CANCELLED`. |
| I7b | Refund reverses earnings that are **already `AVAILABLE`** | **VIOLATED** | `orders.service.ts:3325-3327` | `updateMany({ where: { orderId, status: 'PENDING' } })` — `AVAILABLE` rows untouched. See §3 / D4. |
| I7c | Refund reverses the **`COMMISSION`** row | **VIOLATED** | `orders.service.ts:3325-3327` vs `wallets.service.ts:126` | Commission is born `AVAILABLE`, so the `status: 'PENDING'` filter never matches it. See §3 / D5. |
| I8 | Dispute → `HELD`, and `HELD` resolves on dispute outcome | **VIOLATED** | `wallets.service.ts:92` is the **only** `HELD` write in the codebase | No transition **out of** `HELD` exists anywhere. See §4 / D3. |
| I9 | Incident paths preserve conservation of money | **VIOLATED** (2 of 4 paths) | §4 | Seller-unavailable ✅ · driver-disappeared ⚠️ (recoverable, by design) · dispute-refunded ❌ · delivered-then-refunded ❌ |
| I10 | Incident paths have an explicit recovery owner | **PARTIAL** | §4 | Only `DRIVER_DEBT` has one (`wallets.service.ts:232-263`). Refund-failure has an audit trail but no assigned owner (`orders.service.ts:3277-3291`). `HELD` limbo has none. |
| I11 | Repeated **delivery completion** never double-credits | **HOLDS** | `wallets.service.ts:148-151` + `schema.prisma:1552` | `createMany({ skipDuplicates: true })` against `@@unique([orderId, userId, type])`. Enforced by the DB, not app logic. Genuinely sound. |
| I12 | Duplicate **webhook** delivery never double-credits | **HOLDS** | `stripe-webhook-handler.service.ts:225-228`; `wallets.service.ts:148-151` | Webhook doesn't credit at all (I1); status guard `if (order.status !== OrderStatus.Pending) return;` makes the confirm idempotent. |
| I13 | **Release sweep** re-run never double-releases | **HOLDS** | `wallets.service.ts:324-327, 345-349` | Both `updateMany` calls carry `status: WalletEntryStatus.PENDING` in the `where`, making the flip a compare-and-set. Re-run is a no-op. Comment at `:323` states the intent. |
| I14 | **Concurrent sweep** instances never double-release | **HOLDS** (by CAS, not by lock) | `wallets.service.ts:324-327` | No lock exists, but the `status: PENDING` predicate in `updateMany` means the DB serialises the flip; the loser updates 0 rows. Safe. **However** the notification loop (`:332-342`) is *outside* the CAS and could double-push. Cosmetic, not financial. |
| I15 | **Operator action** never double-creates | **N/A** | — | No operator/admin mutation endpoint for the ledger exists. Admin surface is strictly read-only (`admin-wallets.service.ts:58-61`, `wallets.controller.ts:32-43`). Nothing to double-execute. |
| I16 | A withdrawal changes **available funds** exactly once | **VIOLATED** | `wallets.service.ts:427-506` | Read-then-write with **no lock, no CAS, no transaction spanning the Stripe call**. See §5 / D2 — this is the highest-severity defect found. |
| I17 | A withdrawal changes **paid-out reporting** exactly once | **VIOLATED** | `wallets.service.ts:377` + `:490-506` | It changes it by **exactly zero**, always. §0. |
| I18 | €50 threshold is enforced against the **authoritative available balance** | **HOLDS** (server) | `wallets.service.ts:28, 434, 440-444` | `WITHDRAWAL_MIN_CENTS = 5000`; compared against `total` = live sum of `AVAILABLE` rows **including negative `DRIVER_DEBT`** (`:427-434`). Correct balance, correctly netted. |
| I19 | €50 threshold is represented **consistently** in mobile and admin | **PARTIAL** | `IncaCook/lib/features/wallet/data/wallet_models.dart:108`; `wallet_screen.dart:298` | Mobile: server value used, but `?? 5000` client fallback invents policy if the field is absent, and `toStringAsFixed(0)` rounds (4 999 c → "50 €"). Admin: **never displays the threshold at all** — the only `5000` in the admin tree is an unrelated delivery-fee cap (`settings/_components/delivery-fee-card.tsx:29`). See §7. |
| I20 | Debt blocks cashout | **HOLDS** | `wallets.service.ts:436-439, 397` | `if (total < 0) throw` server-side; `canWithdraw = debtCents === 0 && availableCents >= WITHDRAWAL_MIN_CENTS`. |
| I21 | The ledger's aggregate rows reconcile to `buyerTotalCents` | **VIOLATED** | `pricing.constants.ts:84` vs `wallets.service.ts:107-145` | Ledger sum = `buyerTotal − platformBuyerFee`. See §3 / D1. |

---

## 3. Money-conservation analysis — the pricing contract

**The contract** — `src/common/constants/pricing.constants.ts:6-13, 84-93`:

```
buyerTotal = subtotal + deliveryFee + platformBuyerFee        (:84)
sellerEarning = subtotal − commission                         (:78)
driverEarning = deliveryFee                                   (:12, doc)
platformTake  = commission + platformBuyerFee                 (:13, doc)
```

The function even self-asserts the identity at `:88-93` (throws `'Money math mismatch'`). That
assertion covers the **pricing** side. Nothing asserts the **ledger** side.

### D1 — PROVEN DEFECT: the 5% platform buyer fee is never booked to the ledger

`creditForCompletedOrder` books exactly three row types (`wallets.service.ts:107-145`):

| Row | Amount | Line |
|---|---|---|
| `ORDER_EARNING` | `order.sellerEarningsCents` | `:113-114` |
| `COMMISSION` | `order.commissionCents` | `:124-125` |
| `DELIVERY_EARNING` | `order.fulfillmentFeeCents` | `:140-141` |

Ledger sum for a delivered DELIVERY order:

```
sellerEarnings + commission + fulfillmentFee
  = (subtotal − commission) + commission + deliveryFee
  = subtotal + deliveryFee
  = buyerTotal − platformBuyerFee          ← the 5% is MISSING from the ledger
```

**Worked example** (subtotal 2 000 c, delivery 350 c, standard 30% commission):

| Quantity | Value |
|---|---|
| `commissionCents` | `max(round(2000×0.30), 100)` = **600** |
| `sellerEarningsCents` | `2000 − 600` = **1 400** |
| `platformBuyerFeeCents` | `round((2000+350)×0.05)` = **118** |
| `buyerTotalCents` | `2000 + 350 + 118` = **2 468** |
| **Ledger rows** | `1400 + 600 + 350` = **2 350** |
| **Unaccounted** | **118 c** |

`platformBuyerFeeCents` is **not a column on `Order`** — `schema.prisma:848-853` has
`subtotalCents`, `fulfillmentFeeCents`, `commissionCents`, `sellerEarningsCents`,
`buyerTotalCents`, and nothing else. It is reconstructed as a **remainder** at
`src/modules/orders/dto/order-response.dto.ts:126-127`:

```ts
platformBuyerFeeCents:
  order.buyerTotalCents - order.subtotalCents - order.fulfillmentFeeCents,
```

This derivation is arithmetically exact, so the API response is right. But because the fee is
never persisted and never booked, **the ledger cannot reconcile to `buyerTotal`**, and platform
revenue is understated by ~5% of GMV in every ledger-derived report.

**Corroborating evidence that this is drift, not design:** `schema.prisma:853` still comments
`buyerTotalCents Int // subtotalCents + fulfillmentFeeCents` — the **pre-platform-fee formula**.
The schema comment and `pricing.constants.ts:84` contradict each other. The fee was added to
pricing without a corresponding ledger/schema change.

**Financial risk:** HIGH (systematic revenue understatement, scales linearly with GMV) but
**not a customer-facing loss** — the buyer is charged correctly, Stripe holds the money, and the
platform's Stripe balance is the true figure. This is a **reporting/attribution** defect: the
ledger under-reports what the platform actually kept. It becomes a *real* problem the moment
anyone reconciles the ledger against Stripe and finds a permanent 5% gap with no explanation.

### D4 — PROVEN DEFECT: refund does not reverse `AVAILABLE` earnings

`orders.service.ts:3325-3328`:

```ts
const reversed = await this.prisma.db.walletEntry.updateMany({
  where: { orderId, status: 'PENDING' },     // ← PENDING only
  data: { status: 'CANCELLED' },
});
```

The comment at `:3322-3324` states the intent — *"if earnings were credited PENDING (delivered
then refunded within the 24h window), reverse them"* — and the code matches the comment exactly.
The gap is that the comment's premise ("within the 24h window") is an **assumption the code does
not enforce**. Nothing prevents a refund at T+25h.

**Trigger:** order delivered → sweep releases at T+24h (`wallets.service.ts:326`) → refund issued
at T+25h (admin dispute approval `orders.service.ts:3020`, or any `refundOrderIfNeeded` caller).
The buyer receives a **full** Stripe refund (`:3270-3274`, no `amount` → full). The seller's
`AVAILABLE` row is untouched and remains withdrawable.

**Money conservation: BROKEN.** Platform pays the buyer `buyerTotal` *and* still owes the seller
`sellerEarnings`. Net platform loss = `sellerEarnings` per occurrence, unrecoverable — there is
no `DRIVER_DEBT`-style clawback for sellers (the `DRIVER_DEBT` type is driver-specific; a
hypothetical `SELLER_DEBT` does not exist in the enum, `schema.prisma:1439-1446`).

**Worst case:** the seller withdraws between T+24h and the refund. Money has left via Stripe
transfer (`wallets.service.ts:473`) and clawback is impossible even in principle.

### D5 — PROVEN DEFECT: refund never reverses the `COMMISSION` row

Same `status: 'PENDING'` filter at `orders.service.ts:3326`. The `COMMISSION` row is born
`AVAILABLE` (`wallets.service.ts:126`) and so is **structurally unreachable** by the only
reversal query in the codebase.

Every refunded-after-delivery order leaves a live `COMMISSION` credit under `userId='PLATFORM'`.
Platform revenue is **overstated** by `commissionCents` per refunded order.

**Note the interaction with D1:** the platform's ledger position is now wrong in *both*
directions — understated by `platformBuyerFee` on every order (D1), overstated by `commission`
on every refunded order (D5). These do not cancel; they compound the un-auditability. `PLATFORM`
is a synthetic accounting bucket (`wallets.service.ts:23-25`) excluded from the admin wallets
list (`admin-wallets.service.ts:87`), so **no UI surfaces it and no test covers it** — which is
why both defects are invisible today.

---

## 4. Money-conservation per terminal / incident path

Notation: `S` = `sellerEarningsCents`, `C` = `commissionCents`, `F` = `fulfillmentFeeCents`,
`P` = `platformBuyerFeeCents`, `B` = `buyerTotalCents` = `S + C + F + P`.

### Path 1 — Pickup, delivered ✅ (modulo D1)

| Party | Movement | Evidence |
|---|---|---|
| Buyer | `−B` (Stripe) | `stripe-webhook-handler.service.ts:230-238` |
| Seller | `+S` `PENDING` → `AVAILABLE` @ T+24h | `wallets.service.ts:112-116, 326` |
| Platform | `+C` `AVAILABLE` | `wallets.service.ts:118-129` |
| Driver | none (`F = 0`) | `wallets.service.ts:131-135` |

Ledger `S + C = subtotal`. Buyer paid `subtotal + P`. **Gap = `P` (D1).**

### Path 2 — Delivery, delivered ✅ (modulo D1)

Adds `Driver +F PENDING → AVAILABLE @ T+24h` (`wallets.service.ts:136-144`).
Ledger `S + C + F = B − P`. **Gap = `P` (D1).**

### Path 3 — Seller unavailable at pickup ✅ CONSERVED

`orders.service.ts:1271-1345`

| Step | Effect | Evidence |
|---|---|---|
| Order → `CANCELLED`, inventory restored (idempotent via `inventoryRestored`) | — | `:1294-1321` |
| Buyer refunded `B` | `−B` platform | `:1323` → `:3250-3332` |
| Seller `PENDING` rows reversed | `0` | `:3325-3327` (correct here — nothing was ever credited; order never reached `DELIVERED`) |
| Driver compensated `+F` `AVAILABLE` | `+F` | `:1327-1329` → `wallets.service.ts:177-199` |
| Seller strike (light, 1pt) | — | `:1333-1341`, matches `CONTEXT.md` "seller absent → 1 strike" |

**Platform net = `−F`.** Deliberate cost-of-doing-business: the driver is paid for a wasted trip
out of platform funds. **Explicit recovery owner: none needed — platform absorbs by design**
(`wallets.service.ts:172-176` documents this). **Conservation holds.**

Guard: `resolved` status check at `orders.service.ts:1284-1292` throws `ConflictException` if
already `Cancelled`/`Refunded`/`Delivered`/`Completed` — prevents replay.

### Path 4 — Driver disappears after pickup ⚠️ CONSERVED-IF-RECOVERED

`orders.service.ts:1902-1975`

| Step | Effect | Evidence |
|---|---|---|
| Delivery → `FAILED`, order → `CANCELLED`, inventory **not** restored (dish is gone) | — | `:1912-1932` |
| Driver `PENDING` earnings reversed (normally none) | `0` | `:1935-1941` |
| Buyer refunded `B` | `−B` | `:1944` |
| Seller paid `+S` **`AVAILABLE` immediately** | `−S` | `:1949-1952` → `wallets.service.ts:208-230` |
| Driver debt `−B` (`DRIVER_DEBT`, `AVAILABLE`) | `+B` *if recovered* | `:1957-1965` → `wallets.service.ts:241-263` |
| Driver immediate exclusion | — | `:1969-1974`, matches `CONTEXT.md` "disparition après le retrait → immediate exclusion" |

**Platform net = `−B − S + B = −S` in the best case (full recovery).**

Two observations, both **design questions rather than defects**:

1. **The platform always loses `S`, even on full recovery.** Correct-ish: the seller genuinely
   produced the food and must be paid. But note the driver is excluded (`:1969`) — an excluded
   driver will never earn again, so `DRIVER_DEBT` recovery via "future earnings"
   (`wallets.service.ts:236-238`) is **structurally impossible**. The debt row is, in practice,
   a **write-off marker**, not a recoverable asset. The code comment at `wallets.service.ts:238-239`
   ("the platform absorbs whatever the wallet never recovers") is honest about this, but the
   realistic recovery rate is **~0%** unless the driver had a positive balance at incident time.
   Real platform loss ≈ `B + S − (balance at incident)`.
2. **The debt is `B` (full buyer total), not the platform's actual loss.** The driver is charged
   `C` and `P` — amounts the platform never lost (it refunded them, but it also never paid them
   out). Defensible as a punitive measure; should be a **stated** policy, not an emergent one.
   Flagging for issue #3.

**Explicit recovery owner: YES** — `DRIVER_DEBT` + cashout block (`wallets.service.ts:436-439`).
The only incident path with one.

**Best-effort caveat:** `recordDriverDebt` is wrapped in try/catch (`orders.service.ts:1958-1965`)
— a failure logs and continues, leaving the buyer refunded and the seller paid with **no debt row
at all**. Silent, unbounded loss. Low probability, but there is no retry and no reconciliation job.

### Path 5 — Order disputed, refund approved ❌ NOT CONSERVED

`orders.service.ts:3013-3042`

| Step | Effect | Evidence |
|---|---|---|
| Buyer refunded `B` | `−B` | `:3020` → `refundForDispute` → `:3250-3332` |
| Dispute → `RESOLVED`, `refundApproved: true` | — | `:3022-3031` |
| `HELD` earnings reversed? | **NO** | `:3325-3327` filters `status: 'PENDING'` — `HELD` never matches |
| `COMMISSION` reversed? | **NO** | same filter; commission is `AVAILABLE` (D5) |

Order status at credit time was `Disputed` → earnings booked `HELD` (`wallets.service.ts:92`).
The refund's reversal query cannot see them.

**Platform net = `−B`, and `S`(+`F`) sit in `HELD` limbo forever.** See D3.

### Path 6 — Order disputed, dispute rejected ❌ SELLER NEVER PAID

`orders.service.ts:3045-3065` — updates `OrderDispute.status = 'REJECTED'` and notifies. **No
wallet call whatsoever.** Same for `adminResolveDispute` (`:3068-3080`).

The seller's legitimately-earned `HELD` row stays `HELD`. The seller wins the dispute and is
**still never paid**. The buyer is not refunded. **Platform keeps `B` and owes `S` it will never
pay.** Conservation broken in the platform's favour — which is worse reputationally than the
reverse.

### D3 — PROVEN DEFECT: `HELD` is a terminal dead-end

Exhaustive grep of `src/` for `HELD` (excluding specs) returns **six** hits:

| Location | Role |
|---|---|
| `wallets.service.ts:92` | the **only write** — `earningStatus = disputed ? HELD : PENDING` |
| `wallets.service.ts:376` | read (summary aggregation) |
| `admin-wallets.service.ts:109` | read (admin aggregation) |
| `wallets.service.ts:51, 89`, `orders.service.ts:2136` | comments |

**There is no code path anywhere in the codebase that transitions a row out of `HELD`.**

- The release sweep filters `status: PENDING` (`wallets.service.ts:288`) — cannot see `HELD`.
- Refund reversal filters `status: 'PENDING'` (`orders.service.ts:3326`) — cannot see `HELD`.
- Withdrawal reads `status: AVAILABLE` (`wallets.service.ts:429-431`) — cannot see `HELD`.
- No admin mutation endpoint exists (`wallets.controller.ts:32-43` is `@Get` only).

The comment at `wallets.service.ts:89-90` says *"Disputed → HELD (never released **automatically**)"*
— implying a manual/operator release was intended. **That operator tool was never built.**
`HELD` money is unreachable by every query in the system regardless of dispute outcome.

**Impact:** every disputed order permanently freezes `S` (+`F`). Funds are invisible to the
seller as spendable (mobile folds `heldCents` into the "En attente" label — see §7), never
payable, never reversed. Silent, permanent, and grows monotonically with dispute volume.

**Aggravating factor:** the `HELD` path only triggers if the dispute is opened **before**
`creditForCompletedOrder` runs (`wallets.service.ts:81, 92`). If the dispute is opened *after*
delivery (the overwhelmingly common case), earnings are already `PENDING`/`AVAILABLE` and the
`HELD` branch never fires — so this defect is **rare in practice but unrecoverable when it
fires**, which is precisely the profile that escapes testing.

---

## 5. Idempotency analysis

### Guards that exist and work ✅

| Operation | Guard | Location | Assessment |
|---|---|---|---|
| Order earning / commission credit | `@@unique([orderId, userId, type])` + `createMany({ skipDuplicates: true })` | `schema.prisma:1552`; `wallets.service.ts:148-151` | **Sound.** DB-enforced. Duplicate completion is a genuine no-op. |
| Driver compensation | same unique | `wallets.service.ts:179-193` | **Sound.** |
| Seller incident credit | same unique | `wallets.service.ts:210-224` | **Sound.** |
| Driver debt | same unique | `wallets.service.ts:243-257` | **Sound.** |
| Release sweep | CAS: `where: { id: {in}, status: PENDING }` | `wallets.service.ts:324-327` | **Sound.** Re-run/concurrent-run safe. |
| Sweep reversal | CAS: `where: { id: {in}, status: PENDING }` | `wallets.service.ts:345-349` | **Sound.** |
| Payment webhook | status guard `if (order.status !== Pending) return;` | `stripe-webhook-handler.service.ts:225-228` | **Sound.** |
| Stripe refund | `if (order.stripeRefundId) return;` + `@unique` on column | `orders.service.ts:3258-3260`; `schema.prisma:885` | **Sound**, though the check is a read-then-write with no lock. Concurrent double-refund is narrowly possible; the `@unique` constraint would make the *second DB write* fail **after** Stripe already refunded twice. Low probability, real exposure. |
| Incident replay | `resolved` status check → `ConflictException` | `orders.service.ts:1284-1292` | Sound for the common case. |

The earning-credit idempotency story is genuinely good. The DB constraint is the right mechanism
and it is used consistently. **That makes the withdrawal gap below all the more striking** — it
is the one money-moving operation with *no* equivalent protection.

### D2 — PROVEN DEFECT (HIGHEST FINANCIAL RISK): withdrawal has no concurrency guard

`wallets.service.ts:415-512`. The sequence:

```ts
// :427-433  READ — no lock, no FOR UPDATE, no transaction
const available = await this.prisma.db.walletEntry.findMany({
  where: { userId: user.id, status: WalletEntryStatus.AVAILABLE },
  select: { id: true, amountCents: true, type: true },
});
const total = available.reduce((s, e) => s + e.amountCents, 0);   // :434

// :436-444  validate (total >= 0, total >= 5000)
// :460-467  validate Connect onboarding

const withdrawalId = generateUlid();                              // :470  ← NEW ULID PER CALL

// :473-481  STRIPE TRANSFER — real money leaves here
const transfer = await this.stripe.client.transfers.create(
  { amount: total, currency: 'eur', destination: connectAccountId, ... },
  { idempotencyKey: `withdrawal_${withdrawalId}` },               // :480  ← keyed on the NEW ulid
);

// :490-506  WRITE — flips rows to PAID_OUT, creates the debit
await this.prisma.$transaction([...]);
```

**Verified absent** (grepped `src/modules/wallets` and `src/jobs` for `advisory`,
`SELECT FOR UPDATE`, `$queryRaw`, `Mutex`, `lock(`): **zero hits**. There is no advisory lock, no
row lock, no unique constraint reachable by `WITHDRAWAL` rows (`orderId` is `null` → the
`@@unique` is inert, `schema.prisma:1550-1552`), and no rate limiter on the route
(`wallets.controller.ts:25-29` has only `@HttpCode`).

**Why the Stripe idempotency key does not save this:** `withdrawalId` is generated fresh via
`generateUlid()` **inside each call** (`:470`). Two concurrent requests produce two different
ULIDs → two different idempotency keys → **Stripe treats them as two distinct transfers and
honours both.** The key protects against *network-level retries of one call*, which is what it
was designed for. It provides **zero** protection against two concurrent calls.

**Interleaving that double-pays** (user has 6 000 c `AVAILABLE`, taps "Retirer" twice, or the
mobile client retries on a slow response — note `wallet_screen.dart` uses a raw `FutureBuilder`
with a `withdrawing` flag that is *client-side only*):

| t | Request A | Request B | State |
|---|---|---|---|
| 1 | `findMany` → `[{a1: 6000}]`, `total = 6000` | | rows `AVAILABLE` |
| 2 | | `findMany` → `[{a1: 6000}]`, `total = 6000` | rows still `AVAILABLE` — A hasn't written |
| 3 | passes `>= 5000` | passes `>= 5000` | |
| 4 | `withdrawalId = W_A` | `withdrawalId = W_B` | **different ULIDs** |
| 5 | `transfers.create(6000, key=withdrawal_W_A)` ✅ | | **6 000 c leaves** |
| 6 | | `transfers.create(6000, key=withdrawal_W_B)` ✅ | **another 6 000 c leaves** |
| 7 | `updateMany({id: {in: [a1]}})` → `PAID_OUT`, `withdrawalId=W_A` | | |
| 8 | | `updateMany({id: {in: [a1]}})` → `PAID_OUT`, `withdrawalId=W_B` | **overwrites A's `withdrawalId`** |
| 9 | creates `WITHDRAWAL −6000` (`W_A`) | creates `WITHDRAWAL −6000` (`W_B`) | |

**Result: 12 000 c transferred against a 6 000 c balance. Direct, unrecoverable loss of 6 000 c.**

The `$transaction` at `:490` is **too late and too narrow** — it makes the *bookkeeping* atomic
*after* the money has already moved. It does not cover the read, and it does not cover the Stripe
call. Note also `updateMany` at `:491-494` uses `where: { id: { in: [...] } }` with **no
`status: AVAILABLE` predicate** — unlike every other update in this file (`:325`, `:347`), which
*do* carry the CAS guard. Adding that one predicate would not prevent the double-transfer (money
has already moved at step 5-6) but would at least make the ledger corruption detectable rather
than silent.

Ledger damage beyond the cash loss: row `a1` ends with `withdrawalId = W_B`, so withdrawal `W_A`
has a `−6000` debit and **no** corresponding settled earnings. The `withdrawalId` grouping — the
only forensic link between a payout and what it paid (`schema.prisma:1540-1541`) — is corrupted,
making the incident hard to even diagnose after the fact.

**Aggravating:** the endpoint withdraws the **full** balance with **no amount parameter**
(`wallets.controller.ts:25-29`), so every double-fire is a maximal-value double-fire.

**Realistic triggers** (this is not theoretical):
- Double-tap on a slow network. The mobile guard is a local `withdrawing` bool in a
  `StatefulWidget` — it does not survive a rebuild, and there is no request de-duplication in
  `wallet_repository.dart`.
- Client retry on timeout (the Stripe transfer at `:473` is the slow part; a gateway/client
  timeout during it, followed by a retry, hits this exactly).
- Any future BullMQ/worker retry wrapping this call.

**Proposed fix direction** (not implemented — issue #6 is investigation-only): derive the
idempotency key from a **stable** value (e.g. `withdrawal_${userId}_${total}_${epochBucket}`, or
better, insert a `Withdrawal` row under a unique constraint **before** calling Stripe and use its
id as the key), and/or take a Postgres advisory lock on `userId` for the duration, and/or add
`status: AVAILABLE` to the `updateMany` at `:491` plus verify `count === available.length` before
committing.

### D6 — HYPOTHESIS: withdrawal is not atomic across the Stripe boundary

If the process crashes between `:481` (transfer succeeded) and `:490` (`$transaction`), money has
left Stripe but the ledger still shows the rows `AVAILABLE`. The user can withdraw **again**.
There is no reconciliation job, and no `Withdrawal` table to record intent-before-action.

**Falsifiable:** kill the process between the transfer and the transaction (inject a throw after
`:481`); assert the ledger still shows `AVAILABLE` and a second `requestWithdrawal` issues a
second transfer. **Classified HYPOTHESIS not DEFECT** — I could not exercise the crash window; the
code shape makes it near-certain, but it is unproven by execution.

---

## 6. Discrepancy hypotheses, ranked by financial risk

| # | Hypothesis | Status | Risk | Falsification test |
|---|---|---|---|---|
| **H1** | Concurrent `POST /wallet/me/withdraw` transfers the balance N times (D2) | **PROVEN by code inspection**; not yet reproduced against a live Stripe test account | 🔴 **CRITICAL** — direct, unbounded, unrecoverable cash loss; trivially triggerable by a double-tap | Fire 2 concurrent `requestWithdrawal` for one user with 6 000 c; assert `transfers.create` called **once**. Currently will be called twice. |
| **H2** | Refund after the 24h window leaves the seller paid AND the buyer refunded (D4) | **PROVEN** — `orders.service.ts:3326` filters `PENDING` only | 🔴 **HIGH** — loses `S` per occurrence, unrecoverable if withdrawn; no seller-side clawback type exists | Deliver → release → refund at T+25h; assert seller `AVAILABLE == 0`. Currently `== S`. |
| **H3** | Disputed earnings are frozen in `HELD` forever on **every** dispute outcome (D3) | **PROVEN** — `HELD` has zero exit transitions | 🔴 **HIGH** — permanent liability; seller who *wins* a dispute is never paid | Credit with order `DISPUTED`; run every dispute resolution path + the sweep; assert the row leaves `HELD`. Currently never does. |
| **H4** | `paidOutCents` is constant zero on `/wallet/me` **and** admin (§0) | **PROVEN** — algebraic identity | 🟠 **MED-HIGH** — no direct cash loss, but destroys payout auditability and misleads every seller/driver; blocks any reconciliation that would have caught H1/H2 | Credit 6 000 c → release → withdraw → `GET /wallet/me`; assert `paidOutCents == 6000`. Currently `0`. |
| **H5** | Platform buyer fee (5%) is absent from the ledger (D1) | **PROVEN** — no `platformBuyerFeeCents` column, no booking call | 🟠 **MED** — systematic ~5%-of-GMV revenue understatement; reporting-only (Stripe holds the real money) | Price + credit an order; assert `Σ ledger rows == buyerTotalCents`. Currently `== buyerTotal − platformBuyerFee`. |
| **H6** | `COMMISSION` survives refund, overstating platform revenue (D5) | **PROVEN** — commission is `AVAILABLE`, reversal filters `PENDING` | 🟠 **MED** — compounds H5's un-auditability in the opposite direction | Deliver → refund; assert `PLATFORM` `AVAILABLE == 0` for that order. Currently `== commissionCents`. |
| **H7** | Crash between Stripe transfer and ledger write allows a second full withdrawal (D6) | **HYPOTHESIS** — code shape strongly implies it; not executed | 🟠 **MED** — low frequency, high severity per occurrence | Inject throw after `wallets.service.ts:481`; assert a second `requestWithdrawal` is refused. |
| **H8** | Excluded drivers make `DRIVER_DEBT` structurally unrecoverable (§4 Path 4) | **PROVEN mechanism**, policy intent unconfirmed | 🟡 **LOW-MED** — the loss is already booked; this is about honest reporting, not new loss | Assert an excluded driver can never earn again → debt recovery rate is 0. Then decide whether to keep the row as an asset or write it off. |
| **H9** | Mobile folds `heldCents` into the "En attente" label, hiding frozen funds | **PROVEN** — `wallet_models.dart:92`, `heldEuros` (`:93`) never referenced | 🟡 **LOW** — display-only, but it is what **conceals H3** from the only people who would report it | Assert a wallet with `held > 0` renders a distinct "Bloqué/litige" figure. |
| **H10** | `totalBalanceCents` is computed server-side and silently dropped by mobile | **PROVEN** — `wallets.service.ts:394` sends it; `wallet_models.dart:101-114` never parses it | 🟢 **INFO** — dead payload | Contract test: every `WalletSummary` field is consumed by a client or removed from the DTO. |
| **H11** | `WalletEntryType.REFUND` is dead | **PROVEN** — declared `schema.prisma:1443`, written nowhere | 🟢 **INFO** — but its existence implies a refund-booking design that was never built, consistent with D4/D5 | Grep. Then either implement refund rows or drop the enum member. |

### Root-cause note

H4, H5, H6, D3 and D4 share one structural cause worth calling out to whoever picks up the fix:
**the ledger conflates "what kind of money is this" (`type`) with "what stage is it at"
(`status`), and every aggregation and reversal query filters on `status` alone.** The
`type` column exists and is correct on every row — it is simply never consulted by the code that
needs it most. Fixing the queries to be `type`-aware addresses §0, D5, and (with a `SELLER_DEBT`
type or an `AVAILABLE` filter) D4 in one coherent change. This is worth treating as one repair,
not five.

---

## 7. Client-vs-API authority — where clients display what the API does not own

### Mobile (`IncaCook`)

| Aggregate | Source | Verdict |
|---|---|---|
| "Solde disponible" (`wallet_screen.dart:179`) | server `availableCents` | ✅ authoritative |
| "Déjà versé" (`wallet_screen.dart:195`) | server `paidOutCents` | ✅ faithful — **but the server value is always 0 (§0)**. The client is honest; the API lies. |
| **"En attente" (`wallet_screen.dart:190`)** | **`pendingEuros` = `(pendingCents + heldCents) / 100` — `wallet_models.dart:91-92`** | ⚠️ **CLIENT-DERIVED.** Merges two server fields the API deliberately separates. `heldEuros` (`:93`) is defined but never rendered. **Disputed funds masquerade as "awaiting the 24h window"** — the client invents a category the API does not own, and in doing so hides D3 from the seller. |
| "Dette" (`wallet_screen.dart:199-206`) | `hasDebt => debtCents > 0` (`wallet_models.dart:99`) | ⚠️ client re-derivation of a server rule (`wallets.service.ts:397`). Currently consistent; will silently drift if the server rule changes. |
| `minWithdrawalCents` (`wallet_models.dart:108`) | server, **`?? 5000` fallback** | ⚠️ **client invents policy** if the field is absent. Rendered with `toStringAsFixed(0)` (`wallet_screen.dart:298`) → a 4 999 c minimum displays as "50 €". |
| `totalBalanceCents` | **never parsed** — absent from `fromJson` (`wallet_models.dart:101-114`) | ⚠️ server computes it (`wallets.service.ts:394`) and it is silently dropped (H10). |
| Withdraw button (`wallet_screen.dart:297`) | `summary.canWithdraw && !withdrawing` | ✅ **server-authoritative** — no local balance comparison. Correct. |

**Copy defect:** `wallet_screen.dart:312-326` — every non-debt `canWithdraw == false` renders
*"Retrait disponible à partir de 50 €"*. But `canWithdraw` is false for payout-setup-required too
(`wallets.service.ts:397` is only *one* of the reasons; `requestWithdrawal` also throws
`PayoutSetupRequired` at `:461-466`). A driver with 200 € and no Connect account is told they
need 50 €. **This is the client asserting a *reason* the API never supplied** — the API sends a
boolean, the client fabricates a cause.

**Error handling:** `wallet_screen.dart:61-68` catches `ApiFailure` and shows `e.message` in a
generic snackbar with no `code`-based branching, despite `ApiFailure` carrying a `code`
(`api_response.dart:72`) and the server sending the typed `ErrorCodes.PayoutSetupRequired`
(`wallets.service.ts:462`). The typed code is sent and discarded. The payout prompt
(`wallet_screen.dart:110-117`) is **driver-only** (`user_controller.dart:112-115`); a seller with
incomplete onboarding gets no prompt in the wallet.

**Stale comments** claiming client-side 50 € gating that does not exist: `wallet_screen.dart:17`,
`wallet_repository.dart:27-28`.

### Admin (`incacook-admin`)

| Aggregate | Source | Verdict |
|---|---|---|
| "Versé" column (`payouts/_components/payouts-client.tsx:85`) | server `paidOutCents`, pure per-row passthrough | ✅ faithful — **server value always 0 (§0)** |
| `WalletBalance` shape (`payouts/_components/types.ts:3-14`) | mirrors `AdminWalletListItem` (`admin-wallets.service.ts:12-22`) | ✅ aligned |
| Any column footer / dashboard-level SUM over wallets or withdrawals | **does not exist** | ✅ **no client-side money summing anywhere in the admin tree.** No `.reduce()` over money, no `Math.abs`. Every figure is an API scalar ÷ 100. The admin is disciplined about API authority — which is why it faithfully reproduces the server's zero. |
| Withdrawal threshold | **not displayed anywhere** | ⚠️ **inconsistency vs mobile (I19).** The only `5000` in the admin tree is an unrelated delivery-fee cap (`settings/_components/delivery-fee-card.tsx:28-29`). Admins cannot see or verify the rule mobile enforces. |
| Per-row `currency` (`payouts/_components/types.ts:12`) | **never read** | ⚠️ every figure hard-formatted `EUR`/`fr-FR` (`lib/utils.ts:8-18`). Dormant today (see §10/6); a defect the day a second currency exists. |
| Reconciliation view (buyer total vs seller/driver/platform rows) | **does not exist** | ⚠️ See below — the sharpest gap in the admin surface. |

**The reconciliation gap.** `orderFinancials` (`wallets.service.ts:541-570`) returns exactly the
data a reconciliation needs, is exposed at `GET /admin/orders/:id/financials`
(`wallets.controller.ts:39-42`), **and is consumed** — by the order drawer
(`orders/_components/order-drawer.tsx:81`), which renders the split and the raw `walletEntries`
side by side (`:193-241`). But it renders them as **independent API-supplied lines and never
asserts any relationship between them**: not `subtotal + fee == buyerTotal`, not
`commission + sellerEarnings + driverEarnings == buyerTotal`, not `Σ walletEntries == buyerTotal`.

**A broken split renders as a clean, plausible-looking panel.** D1's missing 5% and D5's orphaned
commission are *already on screen today*, in the one view built to surface them, and are invisible
because nothing does the arithmetic. This is the one place where the admin's otherwise-correct
"never recompute" discipline cuts the wrong way: a cross-check here would be an **assertion
against** the API, not a replacement for it — exactly the recompute you want.

*(The `payouts` types/columns, threshold grep, `paidOutCents` passthrough, and the absence of a
reconciliation assertion were verified directly; the broader admin sweep came from a parallel read
of the tree.)*

**Out of scope but worth flagging to whoever owns the admin:** the parallel sweep found a
`formatEur(x, { cents: true })` misuse family — the flag only sets fraction digits, it does **not**
convert (`lib/utils.ts:14-22`) — rendering raw cents 100× too large in the catalog, disputes, and
catalog-claims drawers. The dangerous instance is a **write path**:
`catalog-claims/_components/catalog-claim-drawer.tsx:298` seeds a euro-denominated refund input
with a placeholder reading "2 500,00 €" for a 25,00 € order; an operator who types the placeholder
back issues a **100× over-refund**. **None of this touches the wallet ledger** and it is not an
issue #6 finding — but it is real money and should be raised separately.

---

## 8. Open decisions for issue #3

Issue #3 owns the Connect/payout domain rules. This investigation surfaced the following
**decisions**, not defects — the code is internally consistent; what is missing is a *stated*
policy to test against.

1. **Earning without Connect — CONFIRM AS INTENDED.** The code is unambiguous and deliberate:
   `deliveries.service.ts:594-600` (*"Stripe Connect onboarding is deliberately NOT required to
   claim"*) and the gate exists only at `wallets.service.ts:460-467`. This **matches the ticket's
   stated rule** ("Connect gates withdrawal, not earning"). ✅ Recommend ratifying as-is.
2. **Unbounded accrual for a never-onboarding user.** A driver can earn indefinitely with no
   Connect account. Nothing caps the balance, ages it, escheats it, or nags beyond the
   driver-only mobile prompt (`wallet_screen.dart:110-117`, absent for sellers). **Decide:** cap?
   expiry? dormancy policy? mandatory onboarding after N € or N days? This is a growing
   liability with no policy attached.
3. **`HELD` release ownership (blocks D3's repair).** The comment *"never released
   **automatically**"* (`wallets.service.ts:89-90`) implies a manual path that was never built.
   **Decide:** who releases `HELD`, through which surface, and what happens on each dispute
   outcome (approved / rejected / resolved-without-refund)? Without this decision D3 cannot be
   fixed, only worked around.
4. **`DRIVER_DEBT` for excluded drivers.** Recovery depends on "future earnings"
   (`wallets.service.ts:236-238`), but the same incident triggers immediate exclusion
   (`orders.service.ts:1969-1974`), so future earnings are structurally impossible. **Decide:**
   is the debt row an accounting write-off marker or a genuine receivable to pursue off-platform?
   This changes how it must be reported.
5. **Debt magnitude.** Debt = `buyerTotalCents` (`orders.service.ts:1960`) charges the driver the
   platform's commission `C` and buyer fee `P` — sums the platform never lost. Punitive-by-design
   or a bug? **Needs a stated policy.**
6. **Seller-side clawback (blocks D4's repair).** No `SELLER_DEBT` type exists
   (`schema.prisma:1439-1446`). Fixing D4 for the already-withdrawn case requires either a new
   debt type or an accepted write-off. **Decide before D4 is repaired.**
7. **Platform buyer fee ledger representation (blocks D1's repair).** `platformBuyerFeeCents` has
   no column and no row type. **Decide:** new `PLATFORM_FEE` entry type + `Order` column, or fold
   into the existing `COMMISSION` row? Also resolve the contradiction between `schema.prisma:853`
   (`// subtotalCents + fulfillmentFeeCents`) and `pricing.constants.ts:84`.
8. **Threshold visibility in admin (I19).** Should `WITHDRAWAL_MIN_CENTS` be admin-configurable
   (like the delivery fee at `settings/_components/delivery-fee-card.tsx`) and displayed? It is
   currently a hardcoded server constant (`wallets.service.ts:28`) that only mobile surfaces.

---

## 9. Proposed deterministic integration tests

**Proposed only — none written**, per the ticket's investigation-only scope. Ordered by the risk
they retire. Each is deterministic (fake clock, stubbed Stripe, seeded DB) and asserts on the
**API contract**, not internals.

### Tier 1 — the four defects that lose or hide money

**T1 · `paidOutCents` survives a withdrawal** *(retires H4 — the ticket's headline)*
```
Seed: seller, Connect ready. Credit order (S=6000). Advance clock +24h. Run sweep.
Act:  POST /wallet/me/withdraw
Assert GET /wallet/me:
  paidOutCents   == 6000     ← FAILS TODAY (returns 0)
  availableCents == 0
  entries: exactly one WITHDRAWAL row, amountCents == -6000, status PAID_OUT
Then: credit + release a 2nd order (S=7000), withdraw again.
  paidOutCents == 13000      ← FAILS TODAY (returns 0) — proves accumulation, not just non-zero
Admin: GET /admin/wallets → that user's paidOutCents == 13000  ← FAILS TODAY (returns 0)
```

**T2 · Concurrent withdrawal transfers exactly once** *(retires H1 — highest risk)*
```
Seed: driver, 6000 AVAILABLE, Connect ready.
Act:  fire 2 × POST /wallet/me/withdraw concurrently (Promise.all)
Assert:
  stripe.transfers.create called EXACTLY ONCE        ← FAILS TODAY (called twice)
  exactly one response 200, the other 409/400
  Σ WITHDRAWAL rows == -6000                          ← FAILS TODAY (-12000)
  every AVAILABLE row now PAID_OUT with ONE consistent withdrawalId
```

**T3 · Refund after the release window claws back the seller** *(retires H2)*
```
Seed: delivered order, S=1400, C=600, F=350, P=118, B=2468.
Advance +24h. Run sweep → seller AVAILABLE == 1400.
Act:  refund the order (T+25h).
Assert:
  seller availableCents == 0                          ← FAILS TODAY (== 1400)
  PLATFORM commission row is CANCELLED                ← FAILS TODAY (still AVAILABLE) [H6]
  Σ all non-CANCELLED rows for the order == 0
```

**T4 · `HELD` always has an exit** *(retires H3)*
```
Seed: order DISPUTED at credit time → earnings booked HELD.
Case A (refund approved):  assert HELD → CANCELLED      ← FAILS TODAY (stays HELD)
Case B (dispute rejected): assert HELD → AVAILABLE      ← FAILS TODAY (stays HELD)
Case C (resolved no refund): assert an explicit, asserted outcome (needs §8/3 decision first)
Invariant: after resolution, zero rows for that order remain HELD.
```

### Tier 2 — conservation

**T5 · Ledger reconciles to buyer total** *(retires H5)*
```
For each of {PICKUP, DELIVERY} × {premium, standard} × {subtotal: 500, 2000, 33333}:
  price + credit the order.
  Assert Σ(all ledger rows for orderId) == buyerTotalCents   ← FAILS TODAY (short by platformBuyerFee)
Guards the D1 gap AND the commission-floor / rounding edges in pricing.constants.ts:74-83.
```

**T6 · Conservation across every terminal & incident path**
Table-driven; asserts `Σ ledger + Σ Stripe movements == 0` per path:

| Path | Expected platform net | Currently |
|---|---|---|
| pickup delivered | `+C +P` | short by `P` (D1) |
| delivery delivered | `+C +P` | short by `P` (D1) |
| seller unavailable | `−F` | ✅ |
| driver disappeared | `−S` (best case) | ✅ mechanism; recovery ≈ 0 (H8) |
| dispute → refund | `0` | `−B`, `S` stuck HELD (D3) |
| dispute → rejected | `+C +P` | `+B`, `S` stuck HELD (D3) |
| delivered → refunded (T+25h) | `0` | `−S` (D4) |

### Tier 3 — idempotency (each asserts *exactly once*, not merely *no crash*)

**T7 ·** `creditForCompletedOrder(o1)` × 3 → row count stable, sums unchanged. *(should PASS today — locks in the good guard)*
**T8 ·** `payment_intent.succeeded` × 3 → order `CONFIRMED` once, **zero** wallet rows. *(should PASS — proves I1)*
**T9 ·** `releaseDuePendingEntries()` × 3 → `released` is `N` then `0`, `0`. *(should PASS)*
**T10 ·** `cancelForSellerUnavailable` × 2 → 2nd throws `Conflict`; exactly one compensation row; exactly one Stripe refund.
**T11 ·** `resolveDriverDisappeared` × 2 → exactly one `DRIVER_DEBT`, one seller credit, one refund.
**T12 ·** Crash-injection after `wallets.service.ts:481` → 2nd withdrawal refused. *(retires H7)*

### Tier 4 — client-observable checkpoints (the ticket's contract-assertion boundary)

**T13 · Balance snapshot at every lifecycle checkpoint.** Single seeded order; snapshot
`GET /wallet/me` after each transition. Every cell is a contract assertion:

| Checkpoint | `available` | `pending` | `held` | `paidOut` | `debt` | `canWithdraw` |
|---|---|---|---|---|---|---|
| after payment (`CONFIRMED`) | 0 | 0 | 0 | 0 | 0 | false |
| after fulfilment (`DELIVERED`) | 0 | `S` | 0 | 0 | 0 | false |
| after release (T+24h) | `S` | 0 | 0 | 0 | 0 | `S >= 5000` |
| after hold (dispute) | 0 | 0 | `S` | 0 | 0 | false |
| after reversal (refund) | 0 | 0 | 0 | 0 | 0 | false |
| after withdrawal | 0 | 0 | 0 | **`S`** | 0 | false |

The `paidOut == S` cell is **the ticket's headline assertion**. It fails today.

**T14 · Stability after retry/duplicate webhook.** Snapshot `/wallet/me` → replay the webhook ×3
+ re-run the sweep ×3 → snapshot again. **Byte-identical** (modulo `entries[].createdAt`).

**T15 · Mobile model contract.**
- Every `WalletSummary` field is parsed or removed from the DTO *(fails today —
  `totalBalanceCents`, H10)*.
- A summary with `held > 0` renders a **distinct** held figure, not folded into "En attente"
  *(fails today — H9, `wallet_models.dart:92`)*.
- `canWithdraw == false` **with** sufficient balance does **not** render the "à partir de 50 €"
  copy *(fails today — `wallet_screen.dart:322`)*.
- Omitting `minWithdrawalCents` from the payload does **not** silently produce "50 €"
  *(fails today — `wallet_models.dart:108`)*.

**T16 · Admin totals contract.** After T1's fixture: `GET /admin/wallets` `paidOutCents == 13000`
*(fails today)*; `GET /admin/withdrawals` lists 2 rows with positive magnitudes *(passes today —
`admin-wallets.service.ts:204` is correct)*; `GET /admin/orders/:id/financials` rows sum to
`buyerTotalCents` *(fails today — D1)*.

### Suggested fixture — the one the ticket asked for and does not exist

No fixture in the repo contains **paid earnings + a withdrawal**. Every existing test hardcodes
`PAID_OUT: 0` (`wallets.service.driver-debt.spec.ts:88,99`) — which is exactly why §0 survived.
The gap is the *fixture*, not the assertions. Proposed shared fixture:

```
seller-1: ORDER_EARNING +6000 PAID_OUT (withdrawalId=W1)
seller-1: WITHDRAWAL    -6000 PAID_OUT (withdrawalId=W1)
→ correct paidOutCents == 6000;  sumByStatus(PAID_OUT) == 0  ← the bug, in two rows
```

---

## 10. Unknowns / could not verify

Honest list. No padding.

1. **No live execution.** Every verdict is from static reading. I ran no tests, no DB, no Stripe
   calls (per the read-only constraint). H1/H2/H3/H4/H5/H6 are proven *by code inspection and
   algebra* — I consider them settled — but none was reproduced at runtime. H7 (crash window) is
   explicitly a **hypothesis**, not a finding.
2. **Production data never inspected.** I cannot state how many rows are currently stuck in
   `HELD`, how many refunds landed after T+24h, or whether H1 has already fired. The financial
   *impact to date* is unquantified; only the *mechanisms* are proven.
3. **Postgres NULL-distinct behaviour in the `@@unique`** is asserted from the documented
   Postgres semantics and the schema's own comment (`schema.prisma:1550-1551`), not verified
   against the live index definition. It could not be otherwise without a `NULLS NOT DISTINCT`
   clause, which is absent from the schema — but I did not read the generated migration SQL.
4. **`WALLET_RELEASE_HOURS` deployed value unknown.** Default is 24 (`wallets.service.ts:35`);
   the deployed env was not inspected (out of scope, and secrets must not be surfaced). If it is
   set to `0` in any environment, D4's window collapses and every refund becomes a D4 case.
5. **Admin findings are partly second-hand.** I directly verified the `payouts` types
   (`types.ts:3-14`), the "Versé" column (`payouts-client.tsx:85`), the threshold grep, and the
   absence of reconciliation arithmetic. The broader admin sweep came from a parallel read; if
   a finance view exists outside `app/(dashboard)/payouts/` and `app/(dashboard)/orders/`, I may
   have missed it.
6. **Multi-currency untested.** `currency` defaults to `"eur"` (`schema.prisma:1538`) and the
   transfer hardcodes `currency: 'eur'` (`wallets.service.ts:475`). The admin `groupBy` includes
   `currency` as a key (`admin-wallets.service.ts:86`) but the accumulator keeps only the
   **first** currency seen (`:100`) and sums across currencies regardless; the admin UI then
   ignores the per-row `currency` entirely and hard-formats EUR. Dormant today, but note a
   backend catalog currency default was recently `usd` (fixed in `7b759cc`), so mixed-currency
   rows in existing data are plausible. Not investigated further.
6b. **Admin dashboard revenue cross-sourcing.** `overview-client.tsx:231-232` renders the same
   logical figure from two independent endpoints (`r?.totalRevenueCents ?? o?.totalRevenueCents`)
   under two labels on one screen. Whether `/dashboard/overview` and `/dashboard/revenue` compute
   revenue identically — and whether either accounts for the D1 platform-fee gap — was **not
   traced**. If they diverge, the dashboard shows a silent contradiction.
7. **`stripeTransferId` / `stripeDriverTransferId`** columns exist on `Order`
   (`schema.prisma:891-893`) but appear unused by the wallet path — likely vestigial from a
   direct-transfer-at-delivery design that predates the internal ledger. **Not traced.** If any
   code still writes them, there may be a second, parallel payout path I have not seen. Worth a
   follow-up grep.
8. **BullMQ worker path.** `wallet-release.processor.ts:57` calls `releaseDuePendingEntries()`,
   and the `@Cron` at `wallets.service.ts:270-277` calls it too. Whether **both** run in the same
   deployment (double sweep) was not established. Financially harmless — the CAS at `:325` makes
   concurrent sweeps safe (I14) — but it would double the `wallet_funds_available` push
   (`:332-342`, outside the CAS).

---

## Appendix — full evidence index

**IncaCook-Server**
| File | Lines | Subject |
|---|---|---|
| `prisma/schema.prisma` | 1530-1555 | `WalletEntry` model, unique, indexes |
| `prisma/schema.prisma` | 1439-1454 | `WalletEntryType` / `WalletEntryStatus` enums |
| `prisma/schema.prisma` | 844-893 | `Order` money columns, Stripe ids |
| `src/modules/wallets/wallets.service.ts` | 28, 35 | `WITHDRAWAL_MIN_CENTS`, `WALLET_RELEASE_HOURS` |
| ″ | 58-168 | `creditForCompletedOrder` |
| ″ | 177-199 | `compensateDriver` |
| ″ | 208-230 | `creditSellerEarning` |
| ″ | 241-263 | `recordDriverDebt` |
| ″ | 285-353 | `releaseDuePendingEntries` |
| ″ | **356-362** | **`sumByStatus` — the netting root cause** |
| ″ | **371-407** | **`summary` — `paidOutCents` bug at :377** |
| ″ | **415-512** | **`requestWithdrawal` — D2 concurrency, §0 at :490-506** |
| ″ | 516-538 | `resolvePayoutTarget` (Connect gate) |
| ″ | 541-570 | `orderFinancials` (unconsumed by admin) |
| `src/modules/wallets/wallets.controller.ts` | 16-29 | `/wallet/me`, `/wallet/me/withdraw` |
| ″ | 32-43 | `/admin/orders/:id/financials` |
| `src/modules/admin/wallets/admin-wallets.service.ts` | **85-121** | **`listWallets` — `groupBy` netting, `Math.abs` at :114** |
| ″ | 173-211 | `listWithdrawals` (correct) |
| `src/modules/orders/orders.service.ts` | 1271-1345 | `cancelForSellerUnavailable` |
| ″ | 1902-1975 | `resolveDriverDisappeared` |
| ″ | 2051-2092 | `confirmPickup` |
| ″ | 2100-2125 | `confirmDeliveredByDriver` |
| ″ | 2138-2140 | `releaseFundsForCompletedOrder` |
| ″ | 3013-3080 | dispute admin handlers (no wallet calls) |
| ″ | **3250-3332** | **`refundOrderIfNeeded` — D4/D5 at :3325-3327** |
| `src/common/constants/pricing.constants.ts` | 6-13, 53-104 | pricing contract + self-assertion |
| `src/modules/orders/dto/order-response.dto.ts` | 126-127 | `platformBuyerFeeCents` remainder derivation |
| `src/modules/payments/webhooks/stripe-webhook-handler.service.ts` | 209-246 | `payment_intent.succeeded` (proves I1) |
| `src/modules/deliveries/deliveries.service.ts` | 594-600 | Connect not required to claim (I4) |
| `src/jobs/wallet-release.processor.ts` | 57 | worker sweep entry |
| `src/modules/wallets/wallets.service.spec.ts` | 66-170 | existing coverage |
| `src/modules/wallets/wallets.service.driver-debt.spec.ts` | 88, 99 | `PAID_OUT: 0` fixtures — the blind spot |

**IncaCook (Flutter)**
| File | Lines | Subject |
|---|---|---|
| `lib/features/wallet/data/wallet_models.dart` | 101-114 | `fromJson`; `?? 5000` at :108; no `totalBalanceCents` |
| ″ | 91-93 | `pendingEuros` merges pending+held; `heldEuros` unused |
| ″ | 99 | `hasDebt` local derivation |
| `lib/features/wallet/presentation/wallet_screen.dart` | 179-206 | aggregate cards |
| ″ | 195 | **"Déjà versé" ← always-zero `paidOutCents`** |
| ″ | 297, 312-326 | withdraw gating + misattributed copy |
| ″ | 110-117 | driver-only payout prompt |
| `lib/features/wallet/data/wallet_repository.dart` | 27-28 | stale gating comment |

**incacook-admin**
| File | Lines | Subject |
|---|---|---|
| `app/(dashboard)/payouts/_components/types.ts` | 3-13 | `WalletBalance` shape |
| `app/(dashboard)/payouts/_components/payouts-client.tsx` | 85 | **"Versé" ← always-zero `paidOutCents`** |
| `app/(dashboard)/settings/_components/delivery-fee-card.tsx` | 28-29 | unrelated `5000` cap (threshold not shown anywhere) |
