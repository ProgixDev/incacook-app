## Destination

Produce an evidence-backed payment assurance specification and an ordered
backlog of small, independently testable execution slices covering buyer order
payments, seller subscriptions, Stripe Connect payout onboarding, internal
wallet accounting, withdrawals, and admin reconciliation across Android, iOS,
backend, and admin panel.

## Notes

Domain: IncaCook marketplace payments across `IncaCook`, sibling
`IncaCook-Server`, and sibling `incacook-admin`. Every session must consult
`backend-architect`, `domain-modeling`, and the repository domain docs; use
Flutter-specific guidance when changing mobile code. Treat client reports as
incident evidence, not established root causes. Preserve unrelated dirty
worktree changes. Never expose secrets. Planning only: implementation begins
after the map resolves into approved execution slices.

## Operational facts (not decisions — corrections to prior assumptions)

- **Railway is NOT git-connected for `incacook-api`.** `railway status --json`
  shows `"source": {"repo": null}` for every service. There is no
  auto-deploy-on-push — every prior "it auto-deployed" observation in past
  handoffs was very likely someone manually running a deploy right after
  merging, not real automation. **Deploys are manual**: `railway up` from a
  local checkout (or the Railway dashboard). Discovered 2026-07-18 when a
  merged PR's changes (including a route) turned out not to be live hours
  later — the running deployment was still from 2026-07-17 23:39, predating
  the whole day's merges. **Consequence for every future session: after
  merging a server PR, explicitly deploy it (`railway up` from `dev`) and
  verify with a quick `curl` — do not assume it's already live.**
- **The Railway environment named `production` runs a placeholder Stripe
  account** (DEC-7) and is the **only** environment — there is no separate
  dev/staging Railway environment. `NODE_ENV=production` is set on it despite
  it not being a real live-key deployment. This caused a real incident
  2026-07-18: a new startup guard (K-9, server PR #16) correctly detected
  `NODE_ENV=production` + a test-mode key and refused to boot — crash-looping
  the only environment that exists. Downgraded to a non-fatal `console.warn`
  (server PR #18) per owner decision, **until real prod/dev environments are
  actually separated** — re-enable the hard fail then. Service was restored
  by deploying the fix directly via `railway up`.
- **Prisma migrations are ALSO not auto-applied on deploy.** The Dockerfile's
  `CMD` is just `node dist/main.js` — no `prisma migrate deploy` step, no
  Railway pre-deploy command configured. Bit us immediately after the above:
  the `20260718000000_revenuecat_event_ordering_guard` migration (adds
  `SellerProfile.revenueCatEventAt`) had never been applied, so **every**
  `/v1/users/me` call (i.e. sign-in for every real user, not just admin
  testing) 500'd with `The column SellerProfile.revenueCatEventAt does not
  exist`. Fixed with `railway run npx prisma migrate deploy` (confirms via
  `railway run npx prisma migrate status` first which migration(s) are
  pending — there was exactly one). **Consequence: after merging ANY PR
  with a new migration, explicitly run `railway run npx prisma migrate
  deploy` against the real DB — a code deploy alone does not apply it, and
  the failure mode is a full outage of anything touching the changed
  table, not a graceful degradation.**

## Decisions so far

Resolved by the product owner on 2026-07-15 via `#3` grilling. Full record and
ownership matrix: `findings/03-payment-domain-boundaries.md`.

- **DEC-1** — The seller's Connect setup/resume entry point is the **Wallet
  payout setup card** (Profil → Wallet, ungated). The driver-only condition at
  `wallet_screen.dart:111` is a defect. The Accueil banner stays as discovery
  only. The QA doc's step-19 "Profil → payout" path is directionally correct and
  unimplemented — not stale.
- **DEC-2** — **Connect gates withdrawal, never earning.** Earnings accrue to the
  internal ledger regardless of Connect state; readiness is checked only at
  withdrawal. "Wallet connected" is banned as a synonym for Stripe onboarding.
- **DEC-3** — Seller app access is gated by **subscription entitlement only**.
  Payout readiness must never gate app access.
- **DEC-4** — Payout readiness splits into `detailsSubmitted` / `chargesEnabled`
  / `payoutsEnabled`; the single `stripeOnboardingCompleted` bool is retired.
  Readiness is `payoutsEnabled && detailsSubmitted` (not `chargesEnabled`).
- **DEC-5** — The lapsed-seller trap (earned funds unreachable without an active
  €4/mo subscription) is a **defect**, not accepted behavior. Any future gate
  that makes withdrawal depend on subscription is rejected on this ground.
- **DEC-6** (2026-07-18, live Stripe dashboard verification, finding 05 §4/O-6)
  — **Connect account-status webhook (`account.updated`) is not
  load-bearing and won't be chased further.** Confirmed empirically: the
  connected Stripe account's own event history shows only v2 Core Events
  (`v2.core.account[...].updated`) for capability/requirement changes —
  zero classic `account.updated` events, ever, regardless of endpoint
  configuration. The app's live poll (`GET /v1/stripe/onboarding/status` →
  `accounts.retrieve`, `onboarding.service.ts`) is the **sole confirmed
  mechanism** and already handles every successful onboarding to date.
  The webhook handler (`handleAccountUpdated`) and D5's ordering guard
  stay wired — correct and harmless if this account's event model ever
  changes (e.g. a different API version pin, live vs test mode) — but no
  further effort goes into proving or fixing that channel specifically.
  Migrating to Stripe's v2 Event Destinations was considered and
  explicitly deferred (bigger, separate piece of work: different
  subscription model, different signature scheme; not scoped here).

- **DEC-7** (2026-07-18, direct Stripe API query answering finding 05's O-1/O-5)
  — **The current Stripe account (`acct_1TdvHCBSdl9ByXxu`, used everywhere:
  local `.env`, Railway `dev`, and Railway's `production`-named env per C-1)
  is a throwaway test account, not a properly registered business.**
  `business_profile.name` is the placeholder `"environnement de test
  INCACOOK"`; `url`/`mcc`/`support_*` are all unset; the account email is a
  personal `@yahoo.fr` address; country is `US`. Confirmed with the owner:
  **no separate, real, FR-registered production Stripe account exists yet.**
  Consequence: **C-1 (go-live cutover) is bigger than "swap `sk_test_` for
  `sk_live_`"** — it requires actually completing Stripe business
  verification (on this account or a fresh one) before any live key can
  exist. Separately, the country mismatch itself is **not a blocker**: this
  account already proved it can create `country: 'FR'` Express accounts
  (the real "Lyon" onboarding in O-6) despite being `US`-registered, so
  **C-4 is closed as moot** — no `STRIPE_CONNECT_ACCOUNT_COUNTRY` override
  needed regardless of what the eventual real account's country turns out
  to be.

- **DEC-8** (2026-07-18, resolves `#11`) — **RevenueCat is the sole source of
  truth for seller subscription entitlement.** Decided with the owner after
  research confirmed the Stripe subscription Checkout/Billing-Portal path
  (`SubscriptionsController`/`SubscriptionsService`) had **zero live
  callers** — the mobile UI that would have driven it
  (`subscribe_flow.dart`/`subscription_repository.dart`) was itself
  unreferenced dead code, and the real "€4/mo" figure in backend comments
  never matched the actual documented product (`IncaCook/docs/
  revenuecat-setup.md`: 3 offerings × 2 tiers, €4,99–€14,99/mo). Finding
  03's **C7 resolved**: the dead-but-wired Stripe subscription writer was a
  real hazard (raced the RevenueCat webhook for the same `SellerProfile`
  fields) — removed, not merely disabled. **Closes C-2/C-3 as "delete,
  not configure"** (finding 05) — the unset Stripe subscription env vars are
  no longer read anywhere. `CONTEXT.md` **now updated** with this ownership
  (see its new "Payments & Subscriptions" section) — no longer a contested
  owner.

## Shipped (2026-07-16)

Implementation began after the decisions above resolved. Repos: mobile =
`ProgixDev/incacook-app`, server = `ProgixDev/incacook-server`. Historically
issues lived only in the app repo (server commits used fully-qualified refs);
as of 2026-07-17 the server repo has its first issue (`server#8`, D7), opened
directly against it since D7 has no corresponding app-repo Wayfinder child.

| Change | PR | State | Findings |
| --- | --- | --- | --- |
| Withdrawal double-payout — claim-before-transfer (CAS); fixes S1/`#6`, C2/`#7` | server #2 | **merged + deployed** | `findings/06`, `findings/07` |
| `paidOutCents` netting → real value; fixes C1/`#3`, headline `#6` | server #3 | **merged + deployed** | `findings/06` |
| CAS proven against real Postgres (repo's first e2e) | server #2 | **merged** | `findings/07` |
| Seller reaches payout setup — un-gate wallet card; DEC-1/DEC-5, D1/`#4` | app #16 | **merged + deployed** | `findings/03`, `findings/04` |
| Stripe Express dashboard login-link endpoint | server #4 | **open** | `findings/04` (E6) |
| Profil "Paiement" tile → Stripe dashboard + disabled visual | app #17 | **open** (needs server #4) | `findings/04` (E6) |
| Withdrawal gate re-reads live Stripe payout capability (D7) | server #9 | **merged** (Railway redeploy not verified) | `findings/04` (D7) |
| Ledger reversal/debt instrument — refund clawback (`SELLER_DEBT`), `HELD` exits on every dispute-resolution path, platform-fee (`PLATFORM_FEE`) booking | server #6 | **merged** 2026-07-16 (board update was late — corrected 2026-07-18) | `findings/06` |
| Silent payout-status-check failure surfaced to the banner (D6) | app #27 | **merged** | `findings/04` (D6) |
| Stale comments + dead signup-flow code (D8) | app #29 + server #10 | **merged** | `findings/04` (D8) |
| Wallet transaction list shows raw `SELLER_DEBT`/`PLATFORM_FEE` enum strings instead of French labels (W6) | app #34 (closed app#33) | **merged** 2026-07-18 | `findings/08` (W6) |
| Duplicate order/PaymentIntent on checkout retry through a new screen instance — persisted `checkoutIdempotencyKey` (P1) | app #38 (closed app#36) | **merged** 2026-07-18 (app-restart sub-case still open, needs cart persistence — separate, larger gap) | `findings/09` (P1) |
| Supply-catalog purchase flow idempotency-key + non-fatal post-charge confirm, mobile side (P5) | app #39 (closed app#37) | **merged** 2026-07-18 (server-side dedup wiring still open — `catalog.controller.ts` needs `@IdempotencyKey()`; tracked as `IncaCook-Server#19`) | `findings/09` (P5) |
| Wallet app-resume refresh + route `wallet_funds_available` push to Wallet (W1/W2); incidental fix for a pre-existing `setState`/Future debug-assert bug | app #40 (closed app#35) | **merged** 2026-07-18 (foreground-push-while-open refresh-in-place still open, needs a new event bus) | `findings/08` (W1, W2) |

Verified end to end on the QA seller (`qa+seller-paris`, seeded to 63.50 €):
onboarding round-trip works; withdrawal **fix confirmed in the wild** — the
Stripe "insufficient platform balance" failure released the claim and restored
the balance intact (test-mode funding gap, not a defect). Seed helper:
`findings/seed-qa-balance.mjs`.

### Still open from the investigations (not yet sliced)

- **`#6` — CORRECTION (2026-07-18): already fully shipped, board was just
  never updated.** This bullet previously claimed refund clawback/`HELD`
  dead-end/unbooked platform fee were still open. Re-verified against
  current code: **all fixed** by server PR
  [#6](https://github.com/ProgixDev/incacook-server/pull/6)
  (`feat(wallets): ledger reversal/debt instrument`, merged 2026-07-16,
  **predates this correction by two days** — purely a board-hygiene gap,
  not a missed implementation). `WalletEntryType` now has `SELLER_DEBT` and
  `PLATFORM_FEE` (`schema.prisma`); `creditForCompletedOrder` books
  `PLATFORM_FEE`; `reverseEntriesForRefundedOrder`
  (`wallets.service.ts:335-384`) reverses `PENDING`/`HELD`/`AVAILABLE` rows
  on refund (booking a debt clawback if already `PAID_OUT`) and cancels
  `COMMISSION`/`PLATFORM_FEE` too; `releaseHeldEntriesForOrder` is called
  from every dispute-resolution path (`adminApproveRefund`,
  `adminRejectDispute`, `adminResolveDispute`,
  `adminConfirmAllergenViolation`, `adminConfirmFraudulentChargeback`) so no
  row is ever left stuck `HELD`. Dedicated test files exist for each
  (`wallets.service.platform-fee.spec.ts`,
  `wallets.service.reversal.spec.ts`, `orders.service.disputes.spec.ts`,
  `orders.service.refund-reversal.spec.ts`). Full suite green (300/300).
  App issue `#6` was still open with a stale "queued as a single slice"
  comment — closed with a summary comment. **Genuinely still open** (minor,
  non-blocking policy questions from findings/06 §8, not defects): dormancy
  policy for unbounded driver/seller accrual without Connect onboarding;
  whether `DRIVER_DEBT`/`SELLER_DEBT` are write-off markers or pursued
  receivables; whether debt magnitude (full `buyerTotalCents`) is
  deliberately punitive; withdrawal-threshold visibility in admin.
- ~~**`#3` DEC-4:** payout readiness still a single `stripeOnboardingCompleted`
  bool~~ — **stale, already shipped** (see Shipped table: server #5 + app
  #18, merged + owner-tested 2026-07-16).
- **`#4`:** every defect except D4 is now shipped. ~~Lapsed-
  subscription seller has no reachable payout entry (D1)~~ — resolved by
  DEC-1/DEC-5 + app #16. ~~Refresh/expired-link treated as success (D3)~~,
  ~~`account.updated` ordering guard (D5)~~, and ~~cold-start deep-link
  drop (D2)~~ — all shipped; D2's device-level repro still needs the
  owner's on-device pass (`.agent-board/QA-TEST.md`). ~~Withdrawal gate
  never re-reads live Stripe (D7)~~ — shipped `server#8` → server PR #9
  (**merged** to `dev`). ~~Silent payout-status-check failure (D6)~~ —
  shipped `app#26` → app PR #27 (**merged** to `dev`). ~~Stale comments /
  dead signup-flow code (D8)~~ — shipped `app#28` → app PR #29 + server
  PR #10 (both **merged**). ~~Deployed return-URL host divergence (D9)~~ —
  shipped app PR #30 + server PR #10 (both **merged**); `.env` fixed
  directly (git-ignored, never reached the repo). Only D4 (poll-window
  tuning, data-blocked) remains from finding 04 itself.
- **`#5`:** webhook topology **fully resolved** — confirmed broken (sole
  endpoint scoped to "Your account" only; `account.updated` never
  delivered for connected accounts) and fixed at the endpoint/secret
  level (second "Connected accounts" endpoint + server PR #13's
  multi-secret verification, merged + deployed). Also fixed the missing
  `charge.dispute.*` subscription found along the way. **O-6 live
  verification done** — real seller onboarding confirmed the deeper
  finding: this account emits only v2 Core Events for Connect changes,
  never classic `account.updated` — decided (DEC-6) to formally rely on
  the polling mechanism rather than chase v2 Event Destinations. **O-1/O-5
  resolved (2026-07-18, direct Stripe API query, no dashboard needed)**:
  platform account `acct_1TdvHCBSdl9ByXxu`, country **`US`**, Connect
  Express active — proven empirically, not just theoretically, since the
  real "Lyon" seller onboarding (O-6) already created a `country: 'FR'`
  Express account successfully under this US platform. **C-4 closed as
  moot** — the feared FR/US incompatibility does not occur; no
  `STRIPE_CONNECT_ACCOUNT_COUNTRY` override needed. **New finding
  (folds into C-1, see DEC-7)**: this account's `business_profile` is a
  placeholder (`name: "environnement de test INCACOOK"`, no url/mcc/support
  fields set) owned by a personal email — confirmed by the owner there is
  **no separate real production Stripe account**. Remaining in this
  umbrella ticket: C-1 (now understood to require full business
  verification, not just a key swap). C-9 **partially closed** (2026-07-18,
  app PR #32): audit trail fixed (tracked dart-define schema + analyze/test
  CI); build flavors deferred by owner choice — see `findings/05`.
  C-2/C-3 closed (DEC-8, see `#11` below). **K-9 closed** (2026-07-18,
  server PR #16): `env.validation.ts` refuses to boot with
  `NODE_ENV=production` + a test-mode key — prep for C-1, not C-1 itself.
  **K-5 partially closed** same PR: `transfer.reversed` clawback handling;
  `payout.failed`/`account.application.deauthorized` still open (`#7`).
- **`#7`/`#8`/`#12` follow-up sweep** (2026-07-18): each had real,
  specifically-named remaining gaps (unlike `#6`, which turned out to be
  fully done already). Server PR #16 shipped: `#7`'s transfer-reversal
  clawback (delta-tracked against Stripe's cumulative `amount_reversed` —
  a real bug `code-review` caught and fixed before merge) + a withdrawal
  reconciliation endpoint; `#8`'s missing payment-intent handler tests (12
  new, code was already correct); `#12`'s seller Connect-readiness parity
  with drivers. Full detail + what's still open in each: `README.md`.
  Server PR #17 (separate, discovered along the way): CI had never
  triggered on `dev` at all (configured for a nonexistent `develop`
  branch) — fixed and confirmed running.
- **`#11`:** ~~seller subscription entitlement owner (RevenueCat vs
  Stripe)~~ — **resolved (DEC-8)**: RevenueCat is sole source of truth; the
  vestigial Stripe subscription path (backend module + dead mobile UI)
  removed. See DEC-8 above.
- **`#9`/`#10`** (2026-07-18) — mobile wallet freshness and PaymentSheet
  recovery, both investigated and **closed** (deliverable — the findings
  doc — is complete; `findings/08`, `findings/09`). W6 (wallet debt/fee
  label bug) shipped same session, see Shipped table above. Three
  implementation issues sliced from the remaining findings — **all three
  now shipped** (see Shipped table above for each PR):
  - **`#35`** (W1/W2) — ✅ **shipped**, app PR #40, merged. Resume-refresh
    added to `WalletScreen`; both tap-routing surfaces (FCM push, in-app
    bell) now recognize `wallet_funds_available`. Incidentally fixed a
    real pre-existing `setState`/Future debug-assert bug the new test
    surfaced. **Not fully closed**: a push landing while `WalletScreen` is
    already open in the foreground still needs a manual pull-to-refresh —
    would need a new event bus, not sliced.
  - **`#36`** (P1, highest-severity finding) — ✅ **shipped** same session,
    app PR #38, merged. `CartController` now mints a `checkoutIdempotencyKey`
    reused across retries within one app session. The app-kill-and-relaunch
    sub-case named in the issue is **not** fixed (needs cart persistence
    across restarts, a separate larger gap — see P6 in `findings/09`).
  - **`#37`** (P5) — ✅ **shipped, mobile side**, app PR #39, merged. Same
    pattern as `#36`: cached order + idempotency key per screen instance,
    non-fatal post-charge confirm. **Not fully closed**: server-side dedup
    (`catalog.controller.ts` needs `@IdempotencyKey()`/`IdempotencyService`)
    is out of this repo's scope — tracked as `IncaCook-Server#19`.

  Lower-severity findings from both investigations (W3-W5/W7/W8,
  P2-P4/P6-P10) are documented in `findings/08`/`findings/09` but not yet
  sliced into issues — see each doc's "Open decisions" section, some of
  which need a product call (e.g. W3: should silent debt/compensation
  events get a push at all) rather than being pure implementation work.

## Not yet specified

- The exact repair and data-reconciliation slices depend on which ledger,
  refresh, configuration, or callback hypotheses survive investigation.
- Any historical wallet backfill or compensating action depends on measuring
  real production discrepancies and agreeing on the financial correction rule.
- Production rollout order, monitoring thresholds, and rollback gates depend on
  the final failure modes and test harness capabilities.

## Out of scope

- Adding new payment providers or buyer payment methods that the current product
  does not already claim to support.
- Visual redesign unrelated to payment state clarity or incident recovery.
- Moving real funds or mutating production financial records during planning.
