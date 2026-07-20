# IncaCook payment assurance board

This board mirrors the GitHub Wayfinder map for the end-to-end payment audit.
GitHub Issues are canonical; these files make execution scope, dependencies,
evidence, and test boundaries easy for agents working across sibling repos.

Canonical map: [Wayfinder: Assure payments end to end across mobile, backend,
and admin](https://github.com/ProgixDev/incacook-app/issues/2)

## Destination

Produce an evidence-backed payment assurance specification and a backlog of
small, independently testable execution slices covering buyer order payments,
seller subscriptions, Stripe Connect payout onboarding, internal wallet
accounting, withdrawals, and admin reconciliation across Android, iOS, backend,
and admin panel.

## Repositories

| Scope | Repository | Responsibility |
| --- | --- | --- |
| Mobile | `IncaCook` | Flutter UX, platform callbacks, local state, wallet reads, PaymentSheet, RevenueCat |
| Backend | `IncaCook-Server` | Payment contracts, Stripe/RevenueCat integration, ledger, transfers, webhooks, jobs |
| Admin panel | `incacook-admin` | Financial visibility, reconciliation, incident diagnosis |
| Cross-cutting | All three | Domain language, deployed configuration evidence, E2E scenarios, rollout |

## Working rules

- Planning and investigation only until the Wayfinder map is resolved.
- Claim the matching GitHub child issue before starting work.
- Never expose secret values; record presence, mode, account alignment, endpoint
  identity, event delivery, and timestamps as redacted evidence.
- Every completed investigation must leave a reproducible test or operator
  verification path.
- Preserve unrelated dirty-worktree changes in all repositories.

## Task list

Status as of 2026-07-16. Legend: ✅ done · 🟡 in flight · 🔲 todo · 🔬 investigated
(findings landed, repair not yet sliced). Mobile = `ProgixDev/incacook-app`,
server = `ProgixDev/incacook-server`. Full detail per ticket in `findings/`.

### Investigations (all landed)

- ✅ `cross-cutting/01-payment-domain-boundaries.md` (#3) — decisions
  DEC-1…DEC-5 resolved; ownership matrix in `findings/03`.
- ✅ `mobile/01-connect-onboarding-return.md` (#4) — trace + defects in
  `findings/04`.
- ✅ `backend/01-deployed-connect-configuration.md` (#5) — evidence in
  `findings/05`; webhook topology still needs Stripe dashboard access.
- ✅ `backend/02-wallet-ledger-invariants.md` (#6) — invariant table in
  `findings/06`.
- ✅ Mobile wallet freshness (#9) — refresh-trigger inventory + staleness
  matrix in `findings/08`. 8 findings (W1-W8); highest-impact one (W6,
  wallet-label bug) shipped same session (app #34); freshness/push-routing
  gap sliced to app #35.
- ✅ Mobile PaymentSheet and order-payment recovery (#10) — checkout
  sequence trace + defect list in `findings/09`. 10 findings (P1-P10);
  highest-severity one (P1, duplicate-order risk) sliced to app #36; supply-
  catalog flow gap (P5) sliced to app #37.
- ✅ Cross-platform payment test matrix (#13) — 32 state-transition rows
  (owner/fixture/oracle/platform/environment/setup) across buyer payment,
  subscription, Connect onboarding, wallet ledger, withdrawal concurrency,
  admin reconciliation, in `findings/10`. Synthesis of `findings/03`-`09`,
  no fresh code exploration. Found + corrected a stale claim on issue #12
  (admin UI is actually shipped) while checking dependencies. Sliced the
  one purely-mobile actionable gap (T13, `SubscriptionGate` test coverage)
  to app #41 and shipped it same session (app PR #42). Sliced the
  server/admin gaps that don't need a product decision first to fresh
  issues: `IncaCook-Server#20` (T9, `charge.refunded` unhandled),
  `IncaCook-Server#21` (T31, order-financials cross-check arithmetic),
  `incacook-admin#4` (T32, thin admin test coverage) — none implemented
  this session (out of this loop's mobile-repo scope).

### Shipped

- ✅ Withdrawal double-payout — claim-before-transfer CAS (server #2, **merged +
  deployed**; proven vs real Postgres). Closes S1/#6, C2/#7.
- ✅ `paidOutCents` netting → real value (server #3, **merged + deployed**).
  Closes C1/#3, headline #6.
- ✅ Seller reaches payout setup — un-gate wallet card (app #16, **merged +
  deployed**). DEC-1 / DEC-5 / D1.
- ✅ Stripe Express dashboard login-link endpoint (server #4, **merged**
  2026-07-16). #4 E6.
- ✅ Profil "Paiement" tile → Stripe dashboard + disabled visual (app #17,
  **merged**, QA-verified). #4 E6.
- ✅ DEC-4 — split payout-readiness facts (server #5 + app #18, **merged +
  owner-tested** 2026-07-16; migration applied to deployed DB). Closed
  issues #3 and #4.
- ✅ Admin 100× refund/display bug — `formatEurFromCents` (admin #2, **merged**
  2026-07-17). Closed issue #20. Also unblocked admin CI.
- ✅ D5 — `account.updated` event-ordering guard (server #7, **merged**
  2026-07-17; migration `20260717000000_account_updated_ordering_guard`
  applied to deployed DB). Closed issue #21.
- ✅ D3 — `refresh_url` bounce treated as a completed return (app PR #23,
  **merged** `3dc46b6`; closed issue #22). Introduced the
  `PayoutOnboardingService` DI seam as a prerequisite (also unlocks D2/D6
  tests). Red-first test T6.

- ✅ D2 — cold-start deep-link drop (app PR #25, **merged** `4b01bf2`; closed
  issue #24). `main.dart`'s single early `AppLinks` listener now routes
  `incacook://stripe/...` to `PayoutOnboardingService.reconcileFromDeepLink`.
  Device-level repro (Q5/Q17/Q20) still needs the owner's on-device pass —
  see `QA-TEST.md`.
- ✅ **DEC-8 — `#11` resolved: RevenueCat is sole source of truth for
  seller subscription entitlement** (server + mobile). Investigation into
  C-2/C-3 (unset Stripe subscription env vars) revealed the Stripe checkout
  path had **zero live callers** — the mobile UI that would drive it
  (`subscribe_flow.dart`/`subscription_repository.dart`) was itself
  unreferenced dead code, and the real product (RevenueCat, 3 offerings ×
  2 tiers, €4,99–€14,99/mo, `docs/revenuecat-setup.md`) never matched the
  "$4/mo" figure quoted in backend comments. Owner decided RevenueCat wins.
  **Removed** (not just disabled, since it was flagged in finding 03's C7
  as an active hazard racing the RevenueCat webhook for the same
  `SellerProfile` fields): server's `SubscriptionsController`/`Service`/
  `Module`, the four dead Stripe subscription config vars
  (`stripe.config.ts`/`env.validation.ts`), the `checkout.session.completed`/
  `customer.subscription.*`/`invoice.payment_failed` branches of
  `StripeWebhookHandlerService`, the now-dead `subscriptionStatusFromStripe`
  util, and mobile's `subscribe_flow.dart`/`subscription_repository.dart`.
  Closes C-2/C-3 (finding 05) as "delete, not configure." 3 new red-first
  tests proving Stripe subscription events no longer write
  `SellerProfile`. Server: `tsc --noEmit` clean, eslint clean, 291/291
  tests green. Mobile: `flutter analyze` clean, 105/105 tests green.
  `CONTEXT.md` updated with the ownership decision (was deliberately
  un-updated until this resolved).
- 🟡 C-9 (finding 05, build reproducibility) — **partially closed**, app PR
  #32 (**squash-merged** to `dev`). Added tracked
  `.vscode/dart_defines.example.json`, the canonical dart-define schema
  verified against every `fromEnvironment` call site in `lib/` (not copied
  from `docs/requirements/accounts-and-credentials.md`'s table, which
  turned out to be stale — it still lists `MAPBOX_PUBLIC_TOKEN`, dropped
  from code during an earlier Mapbox→Google Maps migration that never
  updated that doc). Added `.github/workflows/ci.yml` — `flutter analyze` +
  `flutter test`, first CI this repo has ever had, no secrets needed.
  **Deferred by owner choice**: real build flavors (dev/prod side-by-side
  installs via separate `applicationId`/bundle ID) — bigger change touching
  Android Gradle + iOS Xcode project files, and the package name is tied to
  Firebase/Google Sign-In config. **New findings surfaced, not yet
  actioned**: the stale Mapbox doc row above, and `dart format` finding
  ~177 pre-existing files repo-wide with formatting drift (too large for
  this slice; deliberately left out of the new CI's checks with a comment
  explaining why).
- ✅ **`#6` correction — ledger reversal/debt work was already shipped, board
  was just stale.** Went looking to implement C3/C4/C5 (refund clawback,
  `HELD` dead-end, unbooked 5% fee) and found server PR
  [#6](https://github.com/ProgixDev/incacook-server/pull/6) had already
  fixed all of it on **2026-07-16** — a pure board-hygiene gap, not a
  missed implementation. Verified against current code (not the stale
  findings doc): `SELLER_DEBT`/`PLATFORM_FEE` enum members exist;
  `creditForCompletedOrder` books `PLATFORM_FEE`;
  `reverseEntriesForRefundedOrder` reverses `PENDING`/`HELD`/`AVAILABLE`
  rows on refund (clawback debt row if already `PAID_OUT`) and cancels
  `COMMISSION`/`PLATFORM_FEE` too; `releaseHeldEntriesForOrder` is wired
  into every dispute-resolution path so nothing is ever left stuck `HELD`.
  D6 (withdrawal-atomicity hypothesis) is also moot — the claim-before-
  transfer redesign (D2's fix) means a crash mid-withdrawal can only leave
  a missing debit row (reporting gap), never a double payout. Dedicated
  tests exist for each. Full suite green (300/300). Closed the stale app
  issue `#6` (had a "queued as a single slice" comment from before the fix
  shipped) and corrected `map.md`/`findings/06`. No code changed this
  session — board correction only.
- 🟡 `#5`/`#7`/`#8`/`#12` follow-up sweep — recheck of all open app-repo
  issues found several already-partially-shipped tickets with real,
  specifically-named gaps (not stale like `#6` turned out to be). Shipped
  server PR #16 + a small #17 CI fix:
  - **`#5` (C-1 prep)**: `env.validation.ts` now refuses to boot with
    `NODE_ENV=production` + a test-mode Stripe key (K-9). C-1 itself still
    needs DEC-7's business verification first.
  - **`#7`**: `transfer.reversed` books a `SELLER_DEBT`/`DRIVER_DEBT`
    clawback; new `GET /admin/withdrawals/reconcile` compares WITHDRAWAL
    rows against Stripe directly. **code-review caught a real bug**: Stripe's
    `amount_reversed` is cumulative (multiple partial reversals can land on
    one transfer) — the first draft's clawback was keyed only on transfer
    id, so a second larger reversal would've been silently dropped as an
    already-processed duplicate. Fixed to book the delta, with a shared
    id-builder + sum helper (`transferReversalEntryId`/
    `sumClawedBackForTransfer`, exported from `wallets.service.ts`) so the
    webhook handler and the admin reconciliation agree on the same math.
    Still open: `payout.failed`/`account.application.deauthorized` (different
    risk profile — no money lost, a support/notification concern, needs its
    own design).
  - **`#8`**: 12 new tests lock in `handlePaymentIntentSucceeded`/`Failed`'s
    existing correctness — code was already right, only coverage was
    missing. No e2e test added (no Postgres reachable in this environment
    to verify one — deliberately skipped rather than committing something
    unverified) and no `charge.refunded` handler added (confirmed via grep
    it's a separate pre-existing gap, K-4, not this ticket's scope).
  - **`#12`**: `admin-sellers.service.ts` had zero Connect-readiness
    visibility (drivers had a collapsed boolean) — both now expose the full
    DEC-4 triad. Reconciliation endpoint (shared with `#7`) also serves
    this ticket. **Correction 2026-07-18 (evening)**: the admin-panel
    (Next.js) UI wiring, called "still unbuilt — backend-only so far" here,
    was actually shipped the same day as `incacook-admin` PR #3 (see the
    afternoon handoff) — this line was stale, not the underlying work.
    Genuinely still open: order-financials cross-check arithmetic, thin
    admin test coverage. Issue #12 not yet closed.
  - **`#17` (discovered, unrelated to the four tickets)**: this repo's CI
    had never triggered on a push/PR to `dev` at all — the workflow was
    configured for a `develop` branch that doesn't exist here. Every prior
    `dev` merge (including PR #16 above) shipped on local verification
    only; #17 is confirmed actually running now (watched its first real
    `dev`-PR pass before merging).
  - 20 new tests total across both PRs, full suite green (333/333),
    `tsc`/`eslint` clean. `code-review` (Standards + Spec) run on PR #16;
    every finding fixed before the follow-up commit.
- ✅ **Incident + fix: Railway isn't git-connected, and a new startup guard
  crash-looped the only environment** (2026-07-18). Discovered while
  testing `#12`'s admin UI: server PR #16's changes (including the new
  reconcile route) weren't live hours after merge. Root cause: Railway has
  no git integration at all (`source.repo: null` on every service) — every
  "auto-deploys on push" assumption in prior handoffs was wrong, likely
  someone manually deploying right after merging. Deployed `dev` directly
  via `railway up` — which then crash-looped, because server PR #16's new
  K-9 guard correctly detected `NODE_ENV=production` + a test-mode Stripe
  key on the only Railway environment that exists (a real, pre-existing
  misconfig, DEC-7/C-1) and refused to boot. Owner decision: downgrade to a
  non-fatal `console.warn` until real prod/dev environments are separated
  (server PR #18). Redeployed via `railway up`; verified restored — see
  `map.md`'s new "Operational facts" section for the full record and the
  standing instruction to explicitly deploy + verify after every future
  server merge.
- ✅ O-1/O-5 (finding 05, platform account identity + Connect/country
  compatibility) — answered directly via the Stripe API
  (`stripe.account.retrieve()` against the platform key) instead of the
  dashboard checklist. Platform account `acct_1TdvHCBSdl9ByXxu`, country
  `US`. Connect Express confirmed active and `FR`-country accounts
  confirmed creatable — proven empirically, since the real "Lyon"
  onboarding (O-6) already created one successfully under this US-country
  platform. **C-4 closed as moot** (no `STRIPE_CONNECT_ACCOUNT_COUNTRY`
  override needed). **Bigger finding surfaced instead (DEC-7,
  `.agent-board/map.md`)**: this account's `business_profile` is an
  unverified placeholder (`"environnement de test INCACOOK"`, no
  url/mcc/support fields, personal `@yahoo.fr` owner email) — owner
  confirmed live there is **no separate real production Stripe account**.
  C-1 (go-live cutover) now understood to require completing actual
  business verification, not just a `sk_test_` → `sk_live_` key swap. No
  code change; investigation + board update only.
- ✅ Webhook topology decisive check (finding 05 §4, O-2/O-3) — walked
  through live with the owner's Stripe dashboard access. **Confirmed
  broken**, not hypothetical: the sole webhook endpoint was scoped to
  "Your account" only (immutable field) — `account.updated` for
  sellers/drivers has never been delivered; onboarding completion has
  relied entirely on the app's status-polling backstop. Also found the
  endpoint was missing `charge.dispute.created/updated/closed` entirely —
  fully-implemented dispute-handling code has been dead in production.
  **Fixed:** dashboard — added dispute events to the platform endpoint,
  created a second endpoint scoped to "Connected accounts" for
  `account.updated`. Backend — multi-secret webhook verification (server
  issue #12 → server PR #13, **squash-merged + deployed**), tries the
  platform secret first, falls back to the connect secret. Commented on
  the umbrella ticket (app#5) with full findings + remaining gaps.
  **O-6 live verification done:** triggered a real seller onboarding
  ("Lyon") and checked both the endpoint's delivery log and the connected
  account's own event history directly — zero classic `account.updated`
  events, ever; the account emits only v2 Core Events
  (`v2.core.account[...].updated`) for Connect changes. **Decision
  (DEC-6, `.agent-board/map.md`): formally rely on the polling mechanism**
  (already the sole confirmed-working path) rather than migrate to v2
  Event Destinations. Webhook handler + D5's guard stay wired (harmless)
  but aren't to be chased further. Updated comments in
  `onboarding.service.ts` and `stripe-webhook-handler.service.ts` to
  reflect this.
- ✅ D9 — deployed return-URL host divergence (app PR #30, **squash-merged**;
  server-side already fixed in server PR #10 as part of D8). `.env` and
  `.env.railway.api.local` are git-ignored so the divergence never reached
  the repo — fixed on the affected machine directly. Tracked doc
  references (`docs/backend-communication.md`, `docs/prd/prd.md`,
  server's `docs/BACKEND_SCHEMA.md`) updated to the confirmed-deployed
  `-146b` host. Commented on the umbrella ticket (app#5) noting C-5
  resolved; the bigger webhook-topology decision (O-2 through O-5) in
  that same ticket is next, now that the owner has dashboard access.
- ✅ D8 — stale comments + dead signup-flow code around Connect onboarding
  (app issue #28 → app PR #29, **squash-merged**, closed issue #28; server
  doc fix in server PR #10, **squash-merged**). Re-verified all six
  original D8 items first — 2 were already resolved by D1 and left
  untouched. Fixed: `payoutSetup` enum comment (was "shared", is
  driver-only), deleted the dead `sellerSubscription` enum value +
  `SellerSubscriptionPage` widget + `subscriptionActive` field (never
  added to any step list — `SellerSubscriptionView`, the real RevenueCat
  UI used by the live paywall, is untouched), `payout_setup_banner.dart`'s
  stale "skeleton, no Stripe wiring" docstring, and (server repo)
  `BACKEND_SCHEMA.md`'s wrong deep-link scheme
  (`incacook://payout/...` → `incacook://stripe/...`). Two follow-up
  commits fixed a dangling reference and a stale section comment the
  `code-review` skill's Standards pass caught.
- ✅ D6 — silent payout-status-check failure (app issue #26 → app PR #27,
  **squash-merged** to `dev`, closed issue #26). `_reconcilePayoutStatus`
  now sets a reactive `reconcileFailed` flag when the status GET itself
  throws (not when the local `refreshFromServer` cache refresh fails —
  that stays best-effort). `PayoutSetupBanner` shows a distinct
  "Vérification impossible / Réessayer" state on both seller and driver
  home screens, prioritized over `pendingVerification`. Retry CTA reuses
  the existing `onTap` → `openOnboarding` path, no new callback needed.
  5 new red-first tests in `payout_onboarding_service_test.dart`.
- ✅ D7 — withdrawal gate never re-reads live Stripe payout capability
  (server issue #8 → server PR #9, **squash-merged** to `dev`, closed issue
  #8). `requestWithdrawal`
  re-reads the Connect account live before claiming any wallet row, so a
  missed `account.updated` can no longer let a restricted account sail past
  the gate into a raw `transfers.create` failure. Self-heals the cached
  flag on a confirmed revocation; a transient Stripe error never overwrites
  it. Red-first `wallets.service.live-payout-gate.spec.ts` (6 cases).
- ✅ **W6 — wallet transaction list showed raw `SELLER_DEBT`/`PLATFORM_FEE`
  enum strings instead of French labels** (app issue #33 → app PR #34,
  **squash-merged** to `dev`, closed issue #33). Found during the #9
  investigation (`findings/08`) — a direct regression against server PR
  #6's ledger-reversal work: the client's label switch was never updated
  to match the two new `WalletEntryType` values that PR introduced. Fix
  adds both cases + repairs a stale doc comment; 2 new red-first tests in
  `test/wallet/wallet_entry_label_test.dart`. `code-review` (Standards +
  Spec) run, no findings on either axis.
- ✅ **P1 — checkout retry through a new screen instance created a duplicate
  order/PaymentIntent/inventory-decrement** (app issue #36 → app PR #38,
  **squash-merged** to `dev`, closed issue #36). Found during the #10
  investigation (`findings/09`) — the highest-severity finding of that
  round. `CartController` now mints a `checkoutIdempotencyKey` lazily and
  reuses it across retries (it's a singleton, survives across separate
  `PaymentProcessingScreen` instances within one app session); any cart
  mutation invalidates it so a genuinely new attempt isn't wrongly
  deduplicated. **Known remaining gap, not this fix's scope**: the
  app-kill-and-relaunch sub-case is still open — `CartController` itself
  is entirely in-memory/unpersisted, so fixing that needs cart persistence
  across restarts, a materially larger change (tracked as P6 in
  `findings/09`). 5 new tests in `test/orders/checkout_idempotency_test.dart`
  (at the `CartController`/`OrdersRepository` level — no DI seam exists yet
  for a full `PaymentProcessingScreen` widget test, same gap noted for
  `PayoutOnboardingService` in the earlier Connect-onboarding work).
  `code-review` run, no hard violations on either axis.
- ✅ **P5 — supply-catalog purchase flow idempotency + non-fatal
  post-charge confirm, mobile side** (app issue #37 → app PR #39,
  **squash-merged** to `dev`, closed issue #37). Same pattern as `#36`/P1:
  `SupplyCatalogRepository.createOrder` now requires and forwards an
  idempotency key; `SupplyProductDetailScreen` caches the created order
  across retries within one screen instance (invalidated on quantity
  change); post-payment confirm call is now non-fatal like the main
  checkout. **Not fully closed** — the server-side dedup half
  (`catalog.controller.ts` needs `@IdempotencyKey()`/`IdempotencyService`
  wiring, confirmed absent via grep) is out of this repo's scope, tracked
  as a fresh `IncaCook-Server#19`. 3 new tests in
  `test/supply_catalog/supply_catalog_idempotency_test.dart` (repository
  level — same DI-seam gap as #36's PR, honestly noted rather than
  expanding scope). `code-review` run — caught and fixed a real issue: the
  first draft's commit/PR text overclaimed "Closes #37" despite the
  server-side gap; corrected before merge.
- ✅ **W1/W2 — wallet app-resume refresh + `wallet_funds_available` push
  routing** (app issue #35 → app PR #40, **squash-merged** to `dev`,
  closed issue #35). `WalletScreen` now observes app-lifecycle resume and
  refetches; both tap-routing surfaces (FCM push tap, in-app bell inbox
  tap) now recognize `wallet_funds_available` and navigate to Wallet.
  **Bonus catch**: the resume-refresh test surfaced a real pre-existing
  bug never caught by any prior test — `_refresh()`'s
  `setState(() => _future = next)` returns the assigned `Future` from the
  arrow-closure, tripping Flutter's debug-mode `setState` assertion; fixed
  to a block body. **Not fully closed**: a push landing while
  `WalletScreen` is already open in the foreground still needs a manual
  pull-to-refresh (would need a new event bus). 3 new tests across
  `test/wallet/wallet_screen_resume_refresh_test.dart` and
  `test/wallet/wallet_push_routing_test.dart` (the latter added after
  `code-review`'s Spec pass flagged the initial gap — mounts the real
  `NotificationsScreen` → real production `WalletScreen()` navigation
  path, no seam bypassed).
- ✅ **T13 — `SubscriptionGate`/`hasActiveSellerSubscription` had zero test
  coverage** (app issue #41 → app PR #42, **squash-merged** to `dev`,
  closed issue #41). Found while writing `findings/10`. No production code
  changed — the logic was already correct. 11 tests in
  `test/subscriptions/subscription_gate_test.dart`, 2 added after
  `code-review`'s Spec pass flagged two untested branches (unparseable /
  empty-string expiry).

### Todo / not yet sliced

- ✅ ~~Refund clawback / `HELD` dead-end / 5% fee unbooked (C3+C4+C5, #6)~~ —
  shipped as one slice: issue #19 → server PR #6, **merged** 2026-07-16
  (migration applied; Railway redeploy pending). See `HANDOFF.md`.
- ✅ ~~D1 — lapsed-subscription seller locked out of payout setup (#4)~~ —
  already resolved by DEC-1/DEC-5 + app #16 (`needsPayoutSetup` made
  role-agnostic; Wallet card reaches sellers via the ungated Profil tab).
  **Correction 2026-07-17:** the D3/D2 PR descriptions (app #23, #25) say
  "D1 stays blocked" — that line was carried forward stale from an older
  handoff without cross-checking this file's own Shipped list. D1 is done;
  the code (`user_controller.dart:122` `needsPayoutSetup`,
  `wallet_screen.dart:113`) and `test/core/payout_setup_prompt_test.dart`
  both confirm it.
- ✅ ~~Webhook topology (one endpoint vs two) + operator checklist (#5)~~ —
  resolved (see above); O-1/O-5 resolved 2026-07-18. Remaining in #5: C-1
  (go-live cutover, now understood to need real business verification
  first — DEC-7), C-2/C-3 (unset subscription vars), C-9 (untracked build
  config).
- 🔲 `backend/04-order-payment-lifecycle.md` (#8) — buyer payment + webhook
  recovery trace, not started.
- 🔲 `cross-cutting/02-subscription-source-of-truth.md` (#11) — RevenueCat vs
  Stripe owner; Stripe checkout built but unconfigured (C7). `CONTEXT.md` stays
  un-updated until this resolves.
- 🔲 `admin-panel/01-financial-observability.md` (#12), `cross-cutting/03`
  test matrix (#13), `cross-cutting/04` execution slices (#14).

### Handy

- QA seller balance seeder (idempotent, role-guarded): `findings/seed-qa-balance.mjs`.
- Remotes are clean: only `main` + `dev` on both repos (all feature branches
  merged + deleted 2026-07-16).
