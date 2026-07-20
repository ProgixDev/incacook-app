# Payment assurance — session handoff (2026-07-16, evening)

> **CLOSED 2026-07-17 (night).** This handoff cycle is fully resolved —
> nothing left pending from it. Four slices shipped after the state below:
> (1) admin 100× refund/display bug — app#20 **closed**, PR incacook-admin#2
> **merged** (`e061d69`); (2) **D5** `account.updated` ordering guard —
> app#21 **closed**, PR incacook-server#7 **merged** (`92a3421`), migration
> applied to the deployed DB; (3) **D3** `refresh_url` bounce — app#22
> **closed**, PR app#23 **merged** (`3dc46b6`), introduced the
> `PayoutOnboardingService` DI seam; (4) **D2** cold-start deep-link drop —
> app#24 **closed**, PR app#25 **merged** (`4b01bf2`). **D1 turned out to
> already be done** (app#16, shipped before this cycle began) — a stale
> "D1 blocked" line got carried forward through two handoffs before being
> caught and corrected; see the night handoff's "Correction" section.
> **All of D1/D2/D3/D5 are now shipped** — finding 04's primary defect set
> is closed. Remaining from the same finding (D4/D6/D7/D8/D9) are lower
> priority; D6 is the recommended next slice (self-contained, no blockers).
> Manual QA → `.agent-board/QA-TEST.md`. See
> `/private/tmp/incacook-payment-handoff-2026-07-17-night.md` for full
> narrative context and next-task requirements; a fresh handoff starts with
> D6 (or D7/webhook-topology per the night handoff's options).

## State

Investigations #3, #4, #5, #6 complete (`findings/03`–`07`). Product decisions
DEC-1…DEC-5 resolved by the owner — and now ALL FIVE are executed. Issues
app#3 and app#4 are **closed** (2026-07-16); their remaining edge work (D2/D3/D5,
below) needs a fresh issue when sliced.

### Shipped + merged
- **server #2** — withdrawal double-payout fixed (claim-before-transfer CAS),
  proven against real Postgres. Deployed.
- **server #3** — `paidOutCents` netting fixed. Deployed.
- **server #4** — Stripe Express dashboard login-link endpoint. Merged.
- **app #16** — seller reaches payout setup (un-gate wallet card). Deployed.
- **app #17** — Profil "Paiement" tile → Stripe dashboard + disabled visual.
  Merged, QA-verified.
- **DEC-4 — server #5 + app #18** (merged + owner-tested 2026-07-16): payout
  readiness split into persisted `stripeDetailsSubmitted` / `stripeChargesEnabled`
  / `stripePayoutsEnabled` on both profiles; serialized on `/users/me` as
  `detailsSubmitted`/`chargesEnabled`/`payoutsEnabled`; readiness =
  `payoutsEnabled && detailsSubmitted`; legacy bool kept in sync for back-compat.
  App derives `PayoutSetupState` (notStarted / pendingVerification / ready) in
  `lib/core/models/auth/payout_readiness.dart` with old-server fallback, and
  surfaces "Vérification en cours" on home banners, wallet card, driver settings.
  **Migration `20260716000000_split_payout_readiness_facts` already applied to
  the deployed Supabase DB** (`prisma migrate status` clean; the Railway deploy's
  migrate step will no-op). Deployed server build must include server #5 before
  the app sees the split facts (fallback covers the gap).

Remote branches fully cleaned on both repos (only `main` + `dev` remain; the
pre-split backup branch tip was `6209433` if ever needed). Both local repos on
`dev`. Task list + status: `README.md`, `map.md`.

### Working style (owner feedback 2026-07-16)
Finished slice = push branch + open PR immediately (never leave work local),
delete merged remote branches, PR body must include a **QA section**
(automated counts + numbered manual steps), and **close** fixed issues rather
than just commenting on them.

### Verified in the wild
Withdrawal fix confirmed on `qa+seller-paris`: a transfer that failed at Stripe
(empty platform **test** balance) correctly released the claim and left the
balance intact. Retirer only moves money once the **platform Stripe balance ≥ the
withdrawal** — in test, fund it via a real test-mode buyer order (card
`4242…`) or Stripe dashboard; in production, buyer payments fund it automatically.

## SHIPPED — the refund/HELD/debt slice (issue #19 → server PR #6, merged `f6166dd` 2026-07-16)

Verified three ways: 276/276 unit (+49 red-first), real-Postgres e2e 3/3 vs the
deployed DB, admin Playwright suite 26/26 vs the live API post-migration.
Migration `20260716120000_ledger_reversal_debt` applied to the deployed DB.
**Railway has NOT been redeployed yet** — the running API predates the merge;
redeploy `dev` to activate the reversal/clawback/HELD logic (migrate step
no-ops). Policy calls encoded (owner merged on green): driver fee clawed back
on full refund; allergen-confirm + chargeback-confirm release HELD;
SELLER_DEBT mirrors DRIVER_DEBT. Latent: nothing writes order status
`DISPUTED` yet, so the HELD machinery arms only once a dispute flow sets it.
Follow-ups spotted: admin drawer French labels for the new entry types +
reconciliation assertion. ~~Admin catalog-claims 100× refund-input bug~~ —
**fixed 2026-07-17**: issue app#20 + PR incacook-admin#2 (`fix/eur-cents-formatting`
→ `dev`, awaiting owner merge; close app#20 on merge). New `formatEurFromCents`
in `lib/utils.ts`; all `*Cents` call sites migrated; repo's first unit tests
(`pnpm test`, node --test). Note: admin repo also lives under **ProgixDev** now.

## Original scope — the refund/HELD/debt slice (#6, highest remaining money risk)

Three confirmed money-losing defects share one root — the ledger has no
reversal/debt instrument — so fix them as one coherent slice:

1. **Refund clawback (C4).** A full buyer refund *after* the 24h release window
   leaves the seller's `AVAILABLE` earnings intact → platform eats the loss.
   `orders.service.ts:3325-3327` reverses `PENDING` only.
2. **`HELD` dead-end (C3).** One write, zero exits (`wallets.service.ts:92`). A
   seller who *wins* a dispute is never paid; a loser's funds never convert to a
   reversal/debt.
3. **5% platform fee unbooked (C5).** No ledger row, no `Order` column → the
   ledger can never reconcile to `buyerTotal`.

Shape: a `SELLER_DEBT`/reversal path — post-release refunds book a debt row that
future earnings settle (mirror the existing driver-debt netting), `HELD` resolves
to `AVAILABLE` (won) or reversal/debt (lost), and the commission fee gets booked.
`findings/06` has the invariant table + 16 proposed tests.

## Later
- **#5 webhook topology** — real production risk (one endpoint vs two, single
  `STRIPE_WEBHOOK_SECRET`), but needs **Stripe dashboard access** → operator
  task. The deployment named `production` still runs test keys — resolve before
  live cutover.
- **Connect return edges** — D2 (cold-start deep-link drop), D3
  (refresh/expired-link treated as success), D5 (`account.updated` ordering).
  Build on DEC-4's model. Issue #4 is closed — open a fresh issue when slicing
  these (details: `findings/04`).

## Working notes
- Issues live in `ProgixDev/incacook-app`; server code in
  `ProgixDev/incacook-server` (no issues there → server commits use
  fully-qualified `owner/repo#n` refs).
- Both repos are **public** — keep exploit mechanics out of PR/issue text; full
  detail lives in `findings/`.
- Repos hold unrelated dirty worktrees on `dev` — preserve them; use a worktree
  off `dev` for new work (`node_modules` won't `pnpm install` on the network
  seen this session — symlink the main repo's).
- QA seller balance seeder (idempotent, role-guarded): `findings/seed-qa-balance.mjs`.
