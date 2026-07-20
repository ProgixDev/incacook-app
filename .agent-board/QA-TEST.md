# QA test steps — solved issues

Manual verification steps for the closed/shipped payment-assurance issues.
One section per solved issue, each with the fix, prerequisites, numbered steps
and the expected result. Automated coverage is noted but the focus here is the
human/device checks a reviewer runs before trusting a deploy.

**Conventions:** Stripe is in **test mode** everywhere (incl. the deployment
named `production`) — fund the platform balance with card `4242 4242 4242 4242`
or the dashboard. QA account: `qa+seller-paris`. Idempotent balance seeder:
`.agent-board/findings/seed-qa-balance.mjs`.

Legend: ✅ merged + (where relevant) migrated · ⏳ needs Railway redeploy of
`dev` to be live in the API.

---

## #20 — Admin: `formatEur` misused with raw cents (100× display, incl. refund input) ✅

**Repo:** incacook-admin · **PR:** #2 (merged `e061d69`) · **Live:** yes (Vercel).

**Fix:** `formatEur(x,{cents:true})` never divided by 100. New
`formatEurFromCents(cents)` is now the single path for every `*Cents` field.
The dangerous site was the catalog-claim **refund input placeholder**, seeded
from `order.totalCents` — an operator typing it back over-refunded 100×.

**Prerequisites:** admin login; at least one catalog (B2B) product + order, one
catalog claim linked to an order, one resolved dispute with a refund.

**Steps:**
1. **Catalogue B2B** → seed/open a product and an order: prices and order totals
   read euro-scale (e.g. « 25,00 € », **not** « 2 500,00 € »).
2. **Réclamations catalogue** → a claim linked to an order: line totals and
   order total match the app's order amounts.
3. On a non-terminal claim, open the refund action: the amount input's
   **placeholder equals the real order total in euros**. Leave it empty →
   confirm → full refund of the correct amount. Type the placeholder value back
   → refund equals the order total (not 100×).
4. **Litiges** → a resolved dispute with a refund: « Montant remboursé » shows
   the euro-scale value.
5. Regression: **Commandes, Annonces, Versements, Réglages → frais de
   livraison** — amounts identical to before (these were already correct and
   were unified onto the same helper).

**Automated:** `pnpm test` 3/3 (red-first), `tsc` clean, `eslint` 0 errors,
Playwright 26 passed / 2 skipped vs live API. Also unblocked the admin Quality
Gates CI (pnpm double-version spec).

---

## #21 — Backend: `account.updated` has no event-ordering guard (D5) ✅ ⏳

**Repo:** incacook-server · **PR:** #7 (merged `92a3421`) · **Migration:**
`20260717000000_account_updated_ordering_guard` **applied** to the deployed DB.
**Live in code on next Railway redeploy of `dev`** (migrate step no-ops).

**Fix:** Stripe doesn't guarantee event order. A stale `account.updated`
redelivery flipped `stripeOnboardingCompleted` back to false (banner reappears,
withdrawals 403). Now each profile stamps `stripeAccountEventAt` from
`event.created` and the `updateMany` only applies when the row is null or
not-newer — a stale event matches zero rows, atomically.

**Prerequisites:** ⚠️ **Railway redeploy of `dev` must be done first** (guard
code isn't live until then). Stripe dashboard + Stripe CLI, a `sk_test_`
Connect account for a test seller. Confirm the deployed webhook endpoint is
actually **subscribed to `account.updated`** (else the guard never runs — see
finding 04 §8).

**Steps:**
1. Complete Connect onboarding for a test seller → `payouts_enabled:true`;
   banner hidden; DB `stripeOnboardingCompleted=true`, `stripeAccountEventAt`
   set.
2. Via Stripe CLI, **replay an earlier `account.updated`** (the
   `payouts_enabled:false` one, older `created`) after the newer one.
3. Confirm `stripeOnboardingCompleted` stays **true**, the banner does **not**
   reappear, and withdrawals still pass the gate.
4. Control (genuine demotion): fire a *newer* `account.updated` with
   `payouts_enabled:false` (Stripe restricts the account) → this **does**
   demote; banner reappears, as intended.

**Automated:** onboarding spec 9/9 (7 re-asserted to the guarded shape + 2
red-first: timestamp stamp, no-regression-on-stale-redelivery); full suite
278/278; `tsc` clean.

---

## #22 — Mobile: `refresh_url` bounce treated as a completed onboarding return (D3) ✅

**Repo:** IncaCook (mobile) · **PR:** #23 (**merged** `3dc46b6`) · **Live:** on next app release build/deploy.

**Fix:** `PayoutOnboardingService._awaitReturn` matched an incoming
`incacook://stripe/...` deep link on scheme + host only, ignoring `uri.path`.
Stripe's `refresh_url` bounce (expired/invalid Account Link) was therefore
treated exactly like a completed `return_url` bounce: the client polled a
payout status that couldn't have changed, left the banner up, minted no new
link, and showed nothing. Now the path is read; a `refresh` bounce mints a
fresh Account Link and reopens it (bounded to 2 retries) instead of
reconciling. Also introduced the DI seam finding 04 flagged as a
prerequisite: `PayoutOnboardingService` is now a constructor-injected
`GetxService` (`ApiClient`/`UserController`/`AppLinks`/`launchUrl` all
fakeable), matching the existing `ApiClient`/`OrdersRepository` convention.

**Prerequisites:** a seller or driver test account with Connect onboarding
not yet complete; ability to force an Account Link to expire (wait out
Stripe's expiry window, or hit the `refresh_url` from the account-link
response directly).

**Steps:**
1. Tap any payout-setup entry point (delivery home banner, wallet setup
   card, seller home banner, settings row, or the driver signup payout
   step) → hosted Stripe onboarding opens.
2. Let the Account Link expire (or navigate directly to its `refresh_url`)
   instead of completing onboarding.
3. Confirm the app receives the bounce and **opens a fresh hosted onboarding
   page** rather than silently returning to a stuck banner with no message.
4. Control: complete a normal onboarding via `return_url` → confirm exactly
   **one** `account-link` request was made (no extra link minted) and the
   banner hides as before (regression check for the DI-seam refactor —
   every existing entry point still calls through `.instance`).

**Automated:** new `test/features/payments/payout_onboarding_service_test.dart`
(finding 04's T6), 2/2, red-first (confirmed failing against the pre-fix
path-blind behavior, then green after the fix). Full mobile suite unaffected
(98/98). `flutter analyze` clean.

---

## #24 — Mobile: cold-start return drops the Stripe Connect payout reconcile (D2) ✅

**Repo:** IncaCook (mobile) · **PR:** #25 (**merged** `4b01bf2`) · **Live:** on next app release build/deploy.

**Fix:** `main.dart`'s single early `AppLinks().uriLinkStream` listener
(`_initDeepLinkDiagnostic`) now also routes `incacook://stripe/...` URIs to
`PayoutOnboardingService.reconcileFromDeepLink(uri)`, so a return that
arrives after the app process was killed (iOS jetsam / Android task kill)
while the Stripe tab was open still reconciles payout status instead of
being silently dropped. A `refresh` bounce on cold start is a deliberate
no-op — no auto-relaunching the browser on cold boot.

**Prerequisites:** a physical device (or emulator) with the app installed,
a seller/driver test account with Connect onboarding not yet complete, and
the ability to force-kill the app process while the hosted onboarding tab is
foregrounded.

**⚠️ Cannot be verified from code — needs the owner's device pass:**

**Steps:**
1. Tap any payout-setup entry point → hosted Stripe onboarding opens.
2. Complete onboarding in the browser, but **before** returning to the app,
   force-kill the app process (`adb shell am kill <package>` on Android;
   background the app and let iOS jetsam it under memory pressure, or use
   Xcode's "Debug → Simulate Memory Warning" / just swipe-kill for a rough
   approximation).
3. Tap through the browser's return link → app **cold-launches**.
4. Confirm the logs show `[DeepLink] received: incacook://stripe/return`
   followed by a `[Payout] status completed=…` line (proves the reconcile
   ran), and the payout-setup banner is **hidden on the first frame** — not
   stuck, not waiting on an unrelated refresh.
5. Control: repeat with the browser tab hit at its `refresh_url` instead
   (expired link) and a cold kill+relaunch → confirm **no** browser
   auto-opens and the banner correctly stays in "not complete".

**Automated:** extended `test/features/payments/payout_onboarding_service_test.dart`
with 2 new cases for `reconcileFromDeepLink`, red-first. Full mobile suite
100/100, `flutter analyze` clean. Device-level cold-start behavior (Q5/Q17/Q20
in finding 04) is **not** covered by automated tests — see Steps above.

---

## app#26 — Mobile: silent failure when the payout status check fails (D6) ✅

**Repo:** IncaCook (mobile) · **PR:** #27 (**squash-merged** to `dev`; closed
issue #26) · **Live:** on next app release build/deploy.

**Fix:** `PayoutOnboardingService.reconcileFailed` (`RxBool`) is reset
`false` at the start of every reconcile attempt (both the warm return path
and the cold-start deep-link path, D2) and set `true` only when the status
GET itself throws — not when the subsequent local
`UserController.refreshFromServer()` fails, which stays a "best-effort,
next poll retries" case. `PayoutSetupBanner` shows a distinct
"Vérification impossible" / "Réessayer" state on both seller and driver
home screens (same `Obx` that already watches `sellerPayoutReady`/
`driverPayoutReady`), prioritized over `pendingVerification`. The retry
CTA reuses the existing `onTap` → `openOnboarding` path.

**Prerequisites:** a seller/driver test account with onboarding not yet
complete, and the ability to force the status endpoint offline (airplane
mode, or block backend connectivity) during the return.

**Steps:**
1. Tap the payout-setup banner to open Stripe Connect Express onboarding.
2. Put the device in airplane mode (or kill backend connectivity) before
   returning to the app.
3. Complete onboarding in the browser (or just background/foreground the
   app) while still offline, so the reconcile's status GET fails.
4. **Expected:** the banner switches to "Vérification impossible" /
   "Réessayez" — not the normal setup copy, and not silently unchanged.
   Logs show `[Payout] status refresh failed: ...`.
5. Restore connectivity and tap "Réessayer" — banner returns to its normal
   state (hidden if complete, normal setup/pending copy otherwise).
6. Control: repeat steps 1-3 fully online — banner must show the normal
   pending/complete state, never the error state.

**Automated:** new `reconcileFailed` test group in
`payout_onboarding_service_test.dart` (5 cases, red-first): starts false,
clean reconcile stays false despite the fake's `refreshFromServer` always
throwing, cold-start failure sets it, warm-path failure sets it, a later
success clears a prior failure. Full mobile suite 105/105 (up from
100/100), `flutter analyze` clean, `dart format` clean.

---

## server#8 — Backend: withdrawal gate never re-reads live Stripe payout capability (D7) ✅

**Repo:** IncaCook-Server · **PR:** #9 (**squash-merged** to `dev`; closed
issue #8) · **Live:** on next `dev` deploy (Railway redeploy not verified).

**Fix:** `WalletService.requestWithdrawal` re-reads the Connect account live
via `stripe.accounts.retrieve` right after the persisted `stripeOnboardingCompleted`
gate and **before** any wallet row is claimed — same `payouts_enabled &&
details_submitted` rule `onboarding.service.ts`'s `createDashboardLink`
already applies before minting a dashboard login link. A confirmed
incomplete/revoked account self-heals the cached flag to `false` and rejects
with the existing `PayoutSetupRequired` (403) — same error the app already
prompts on, no mobile change needed. A stale/deleted Connect account id
rejects the same way without a cache write. Any other Stripe failure
(network/rate-limit) fails the request without touching the cache, so a
blip can't falsely flip a correct `true` to `false`.

**Prerequisites:** Stripe test-mode Connect account + dashboard access.

**Steps:**
1. Onboard a seller/driver test account through Connect Express onboarding
   until `stripeOnboardingCompleted=true` in the DB.
2. In the Stripe dashboard, restrict the test account's payouts capability
   (or flip `payouts_enabled` to `false`) **without** letting `account.updated`
   reach the API — simulates a missed webhook.
3. As that seller/driver, request a withdrawal while the persisted flag
   still reads `true`.
4. **Expected:** rejected with `INCACOOK_PAYOUT_SETUP_REQUIRED` (403) — no
   Stripe transfer attempted, no wallet row changes status. The DB flag is
   now `false`; a subsequent `/users/me` read reflects it immediately.
5. Restore `payouts_enabled=true` and repeat step 3 — withdrawal succeeds
   normally (happy path unaffected).

**Automated:** new `wallets.service.live-payout-gate.spec.ts` (6 cases,
red-first: happy path, live-revoked rejection, no-ledger-touch-on-reject,
self-heal, stale account id, transient-failure-doesn't-flip-cache). Existing
wallet spec files (4) + e2e specs (2) updated to stub the new
`accounts.retrieve` call. Full suite 43/43 files, 284/284 tests green;
`eslint` clean; `tsc --noEmit` shows only pre-existing unrelated errors
(stale generated Prisma client for `stripeAccountEventAt`), reproduced
identically on `dev` before this branch.

---

## #19 — Ledger: reversal/debt instrument (refund clawback, HELD exits, platform fee) ✅

**Repo:** incacook-server · **PR:** #6 (merged `f6166dd`, 2026-07-16) ·
**Migration:** `20260716120000_ledger_reversal_debt` applied. **Deployed** —
several server merges to `dev` have redeployed since (D7 `#9` on 2026-07-17,
the DEC-6 doc PR `#14`, this session's subscription/CI work), each an
observed auto-redeploy; the original "⏳ needs Railway redeploy" flag is
stale. **Correction (2026-07-18):** the umbrella research ticket
[app#6](https://github.com/ProgixDev/incacook-app/issues/6) was still open
with a stale "queued as a single slice" comment predating this PR by days —
closed today after re-verifying against current code (not just this file).
See `.agent-board/map.md`'s `#6` correction note. **Still latent** (verified
2026-07-18, unchanged): `HELD` machinery only arms once a flow writes order
status `DISPUTED` — confirmed **nothing does yet** (`grep`-verified: the only
`OrderStatus.Disputed` reference in `src/` is the read at
`wallets.service.ts:108`, no writer exists). Disputes today proceed through
`OrderDispute` without ever touching `Order.status`, so credited earnings
follow the normal `PENDING`→`AVAILABLE` path regardless of an open dispute —
the HELD fix is correct and tested but dormant until/unless something wires
`Order.status = DISPUTED` at dispute-open time.

**Fix:** post-release refunds now book a `SELLER_DEBT`/`DRIVER_DEBT` clawback
that future earnings net against; `HELD` earnings resolve to `AVAILABLE` (won) or
cancel (refunded); the 5% platform fee is persisted (`Order.platformBuyerFeeCents`)
and booked as a `PLATFORM_FEE` ledger row so `Σ(rows) == buyerTotalCents`.

**Prerequisites:** `qa+seller-paris` with balance (seeder above); admin access;
funded platform test balance for the withdrawal path.

**Steps:**
1. Deliver an order as `qa+seller-paris`, wait for release (or run the sweep),
   then **refund it from admin** → seller's available balance drops by the
   earning; the order's ledger rows all read `CANCELLED`; platform commission +
   fee rows cancelled too.
2. Same, but **withdraw first, then refund** → wallet shows a **debt** equal to
   the withdrawn earning; **Retirer blocked**; a subsequent delivered order's
   earnings net against the debt.
3. `GET /admin/orders/:id/financials` on a fresh order → wallet rows include the
   `PLATFORM_FEE` entry and **sum to `buyerTotal`**.

**Automated:** 276/276 unit (+49 red-first), real-Postgres e2e 3/3 vs the
deployed DB, admin Playwright 26/26 post-migration.

---

## Research/decision issues (no runtime QA)

**#3** (payment-domain boundaries) and **#4** (Connect onboarding trace) were
closed as **research/decision** deliverables — evidence lives in
`.agent-board/findings/03` and `04`. Nothing to exercise at runtime. All of
D1-D9 (finding 04's defect list) are now shipped except D4 (poll-window
tuning, data-blocked — needs real p95 Stripe settlement-latency measurement).

**#6** (ledger invariants) closed 2026-07-18 — see the `#19` section above;
its fix predates the closure by two days (board-hygiene correction, not new
work).

**#11** (seller subscription ownership, RevenueCat vs Stripe) closed via
**DEC-8**: RevenueCat is sole source of truth. Fix was **removing** a dead
Stripe Checkout/Billing-Portal path (zero live callers) — no new runtime
behavior to script, same category as D8/D9 below. Server PR #15 (+ a
follow-up PR adding a RevenueCat webhook event-ordering guard the removal
alone hadn't covered), app PR #31. 12 new red-first tests cover the
ordering guard + all six of the issue's named scenarios (store purchase,
renewal, cancellation, billing failure, restore, delayed/out-of-order
events) directly at the unit level.

**C-9** (build reproducibility, finding 05) partially closed via app PR #32
— a tracked dart-define schema file + first-ever CI (analyze+test). Pure
tooling/docs, no runtime behavior change.

**O-1/O-5** (finding 05, platform account identity + Connect/country
compatibility) resolved via a direct Stripe API query, no dashboard needed —
investigation only, nothing shipped to exercise.

**D8/D9/webhook-topology** were comments/docs/dashboard-config changes with
no new runtime behavior to script — covered narratively in
`README.md`/`map.md` instead of a dedicated section here.

**`#5`/`#7`/`#8`/`#12` follow-up sweep** (server PR #16 + #17) — no
buyer/seller/driver-visible behavior change (backend resilience + new
admin-only endpoints/fields). Manual spot-check once deployed: `GET
/v1/admin/withdrawals/reconcile` returns cleanly with no withdrawals yet;
`GET /v1/admin/sellers` responses include the four new `stripe*` boolean
fields. Full detail: `README.md`.

**Still-open tickets re-verified 2026-07-18, confirmed genuinely open (not
stale)** — no QA section exists because nothing has shipped yet: **#7**
(withdrawal transfer-reversal handling + reconciliation — the concurrency/
crash half is already covered by the `#2`/`#19`-adjacent fixes above, see
its GitHub comment for the split), **#8** (buyer payment-webhook test
coverage — the code is solid, tests are the gap), **#9** (mobile wallet
freshness — load-once, no resume/revisit/push refresh), **#10** (mobile
PaymentSheet recovery — no tests, no distinct cancel/3DS/restart handling),
**#12** (admin reconciliation + seller Connect-readiness visibility).
