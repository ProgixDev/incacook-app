# Findings — Cross-platform payment test matrix, fixtures, and environment checklist

- **Ticket:** GitHub [issue #13](https://github.com/ProgixDev/incacook-app/issues/13) — "Design
  the cross-platform payment test matrix and fixtures"
- **Mode:** AFK research — synthesis, not fresh code exploration. This ticket's own dependency
  list (Connect onboarding, deployed configuration, wallet ledger, withdrawal resilience, order
  payment lifecycle, subscription ownership, admin observability) maps directly onto
  `findings/03`–`09`, already landed. This document indexes and organizes that existing evidence
  into the matrix the ticket asks for — it does not re-derive it.
- **Repos read:** `IncaCook`, `IncaCook-Server`, `incacook-admin` (current `dev` on all three,
  2026-07-18 evening).

## 0. Answer to the ticket's question, up front

**"What smallest suite proves the whole payment system without real money, while still
validating deployed webhooks and background jobs?"** — three layers, ordered cheapest-and-most-
frequent to most-expensive-and-least-frequent, matching what this codebase already does for its
non-payment surfaces:

1. **Unit/contract tests, no network, no device** (`flutter test` / `pnpm test` — Jest). The
   overwhelming majority of the matrix belongs here: every ledger invariant, every idempotency
   guard, every client-side state-machine branch. This layer is **already large and already
   running in CI on every PR** in both `IncaCook` (118 tests, GitHub Actions `Analyze, test`) and
   `IncaCook-Server` (per-file counts below). It needs no real Stripe account, no real device, no
   real money — every Stripe/DB/FCM boundary is faked at the seam.
2. **Integration tests against real infrastructure, no device.** A small, deliberately narrow
   layer: real ephemeral Postgres (proves DB-level constraints — `@@unique`, CAS predicates —
   actually hold, not just that the application code calls the right Prisma methods) and Stripe
   **test-mode** CLI (`stripe trigger`, `stripe listen --forward-to <deployed-or-local-url>`) to
   prove a **deployed** webhook endpoint actually receives and processes real Stripe-shaped
   events — this is the layer that answers "does the deployed webhook config work," not just
   "does the handler function work." Two examples already exist in this repo
  (`test/e2e/wallet-withdrawal-cas.e2e-spec.ts`, `test/e2e/ledger-reversal.e2e-spec.ts`) — this
  layer is the right shape, just under-populated (§6).
3. **Device-level QA, Android + iOS, real app builds.** The smallest possible set — only what
   layers 1-2 structurally cannot reach: native SDK behavior (`flutter_stripe` PaymentSheet,
   Stripe's hosted Connect onboarding pages, real deep-link delivery through the OS), app-process
   lifecycle (cold start, backgrounding, jetsam), and push-notification delivery through real FCM.
   `.agent-board/QA-TEST.md` already catalogs this layer for the flows it covers — §7 below maps
   what's covered there against what this matrix needs and names the gaps.

**Deployed webhooks and background jobs specifically** (the ticket's own qualifier) are proven at
layer 2, not layer 3 — no device is needed to prove a webhook endpoint or a BullMQ cron job
behaves correctly; a device is needed only for the *mobile app's own* reaction to state that
changed as a result. Conflating these two would make the suite far larger than it needs to be —
this is the single most load-bearing design choice in this matrix.

---

## 1. State-transition matrix

Columns: **Owner** = repo/module responsible for correctness. **Fixture** = the minimal reproducible
setup. **Oracle** = what specifically proves pass/fail (not "it looks right" — a concrete assertion
target). **Platform** = which layer from §0 this belongs to. **Today** = existing automated coverage,
file:line where it exists, or the honest gap.

### 1.1 Buyer payment lifecycle

| # | Transition | Owner | Fixture | Oracle | Platform | Today |
|---|---|---|---|---|---|---|
| T1 | Order create → `PaymentIntent` created, order `PENDING` | server `orders.service.ts` | cart with 1+ listing, valid address | order row exists, `status=PENDING`, PaymentIntent id persisted | 1 | Covered indirectly via handler specs; no dedicated create-order contract test found — **gap** |
| T2 | `payment_intent.succeeded` → order `PENDING→CONFIRMED`, idempotent on redelivery | server `stripe-webhook-handler.service.ts` | fire the same event twice | order status flips once; 2nd delivery is a no-op | 1 | `stripe-webhook-handler.payment-intent.spec.ts` (12 cases, server PR #16) |
| T3 | `payment_intent.payment_failed` → inventory restored exactly once, even under concurrent redelivery | server, same file | concurrent duplicate webhook delivery | `inventoryRestored` flag prevents double-restore | 1 | `stripe-webhook-handler.payment-intent.spec.ts` |
| T4 | Deployed webhook endpoint actually receives `payment_intent.*` for the platform account | server, deployed config | `stripe listen --forward-to <deployed-url>` + `stripe trigger payment_intent.succeeded` | event appears in Stripe dashboard's delivery log against the correct endpoint | 2 | **Manually verified once** (`findings/05` §4, O-2/O-3) — not an automated/repeatable check. **Gap: no scheduled/CI re-verification.** |
| T5 | Mobile: checkout retry through a new `PaymentProcessingScreen` instance does not duplicate the order | mobile `CartController`/`OrdersRepository` | fail first attempt, retry via "choisir un autre moyen" | exactly one order created, one idempotency key reused | 1 | `test/orders/checkout_idempotency_test.dart` (app PR #38) |
| T6 | Mobile: app kill + relaunch mid-checkout with cart still populated | mobile, cart persistence (does not exist) | kill process between Stripe confirm and navigation | on relaunch, no duplicate order is created on the user's next attempt | 3 (would need 1 first) | **Gap — no fix exists yet.** Findings/09 P6; needs cart persistence before this row is even testable at layer 1. |
| T7 | Refund after the 24h release window claws back an already-`AVAILABLE`/`PAID_OUT` seller earning | server `orders.service.ts` / `wallets.service.ts` | deliver → release sweep → refund at T+25h | `SELLER_DEBT` row booked for the clawback amount | 1 | `orders.service.refund-reversal.spec.ts`, `wallets.service.reversal.spec.ts` (server PR #6) |
| T8 | Dispute resolved (any outcome) releases `HELD` earnings — never a permanent dead-end | server `orders.service.ts` | credit while `DISPUTED`, then resolve via every admin path | row leaves `HELD` regardless of resolution path | 1 | `orders.service.disputes.spec.ts` |
| T9 | `charge.refunded` webhook | server webhook handler | Stripe-initiated (not admin-initiated) refund | order/ledger reconciles | 1 | **Confirmed unhandled** (K-4, `findings/05`) — **known, named gap, not silently missing** |
| T10 | Live-Postgres e2e across the full create→webhook→inventory→refund chain, crash-boundary included | server, real DB | kill process mid-transaction at each step | no order stuck mid-state after restart | 2 | **Gap** — blocked on Postgres access in this sandbox every session so far (issue #8's own stated blocker) |

### 1.2 Seller subscription (RevenueCat)

| # | Transition | Owner | Fixture | Oracle | Platform | Today |
|---|---|---|---|---|---|---|
| T11 | RevenueCat webhook → `SellerProfile.subscriptionStatus` updates, ordering-safe | server `revenuecat-webhook-handler.service.ts` | out-of-order event redelivery | `revenueCatEventAt` guard rejects a stale event | 1 | `revenuecat-webhook-handler.service.spec.ts` |
| T12 | Stripe subscription events never write `SellerProfile` (DEC-8 — the path was removed, not disabled) | server | fire a legacy `checkout.session.completed`/`customer.subscription.*` event | `SellerProfile` fields unchanged | 1 | 3 red-first tests from DEC-8's slice (per `map.md`) |
| T13 | `SubscriptionGate` correctly paywalls Accueil/Commandes/Mes plats only, not Profil/Messages | mobile | seller with `subscriptionStatus=EXPIRED` | gated tabs show paywall, ungated tabs don't | 1 | Not directly located in this pass — **verify exists, else gap** |

### 1.3 Connect onboarding / payout readiness

| # | Transition | Owner | Fixture | Oracle | Platform | Today |
|---|---|---|---|---|---|---|
| T14 | Warm-return onboarding completes, banner hides without restart | mobile `PayoutOnboardingService` | complete real Stripe test-mode onboarding | poll + `/users/me` refresh flips `payoutSetupState` | 1 | Would need the DI seam noted in `findings/04` §5.1 — **partially covered, prerequisite seam not yet built per that doc** |
| T15 | Cold-start deep-link delivery after process death mid-onboarding | mobile, `main.dart` global listener | kill app while Stripe page open, complete, relaunch | banner reflects true state on first frame | 3 | `.agent-board/QA-TEST.md` Q5/Q17/Q20 (device-only, by nature) |
| T16 | `account.updated` ordering guard prevents a stale event from reverting readiness | server `stripe-webhook-handler.service.ts` | replay an older event after a newer one | final state matches the newer event | 1 | Server PR #7's slice (D5) — dedicated spec exists per `map.md` |
| T17 | Withdrawal gate re-reads live Stripe payout capability, doesn't trust a stale cached flag | server `wallets.service.ts` | restrict account in Stripe, block the webhook, then withdraw | gate rejects before `transfers.create` | 1 | `wallets.service.live-payout-gate.spec.ts` (6 cases, server PR #9) |
| T18 | Deployed webhook is actually subscribed to `account.updated` for connected accounts | server, deployed config | live seller onboarding + endpoint delivery log | delivery log shows the event (or confirms v2-only, per DEC-6) | 2 | **Manually verified once** (`findings/05` §4, O-6) — DEC-6 formally deprioritizes chasing this further; not a re-testable automated check by design |

### 1.4 Wallet ledger

| # | Transition | Owner | Fixture | Oracle | Platform | Today |
|---|---|---|---|---|---|---|
| T19 | Delivery completion books seller + driver + platform commission + platform buyer fee, summing to `buyerTotal` | server `wallets.service.ts` | priced order, both fulfillment choices | `Σ ledger rows == buyerTotalCents` | 1 | `wallets.service.platform-fee.spec.ts` (server PR #6 fixed the missing-fee defect this row used to fail on) |
| T20 | `PENDING → AVAILABLE` only after the 24h safety window, sweep is idempotent on re-run | server `wallets.service.ts` + `jobs/wallet-release.processor.ts` | seed a `PENDING` row near the boundary | sweep flips it once; re-run is a no-op | 1 | `wallets.service.spec.ts`, `jobs/wallet-release.processor.spec.ts` |
| T21 | `paidOutCents` reflects real withdrawal magnitude, not a net-zero of the same status flip | server `wallets.service.ts` / admin | withdraw, then read `/wallet/me` and the admin list | `paidOutCents == Σ WITHDRAWAL rows` (not 0) | 1 | `wallets.service.paid-out.spec.ts`, `admin-wallets.service.paid-out.spec.ts` (server PR #3, closes H4) |
| T22 | `SELLER_DEBT`/`PLATFORM_FEE` render with real labels on mobile, not raw enum strings | mobile `WalletEntry.label` | entry with each of the 8 backend enum types | no fallback to the raw type string | 1 | `test/wallet/wallet_entry_label_test.dart` (app PR #34) |
| T23 | Wallet screen refetches on app-resume; the one wallet push routes to Wallet on tap | mobile `WalletScreen`, push routing | background/foreground cycle; tap a `wallet_funds_available` notification | refetch count increments; navigation lands on `WalletScreen` | 1 | `test/wallet/wallet_screen_resume_refresh_test.dart`, `test/wallet/wallet_push_routing_test.dart` (app PR #40) |
| T24 | Five of six ledger-mutating server events (compensation, debt recording, transfer-reversal clawback) send no push at all | server, notifications | trigger each event type | assert push fires or is deliberately absent (**policy decision, not yet made** — see §7) | 1 | Partial — `wallets.service.spec.ts` asserts the one push that *does* fire; the five silent ones are undecided, not untested-by-oversight |

### 1.5 Withdrawal concurrency / atomicity

| # | Transition | Owner | Fixture | Oracle | Platform | Today |
|---|---|---|---|---|---|---|
| T25 | Two concurrent withdrawal requests for the same user never both succeed | server `wallets.service.ts` | fire 2 concurrent `requestWithdrawal` calls | exactly one `transfers.create`, the loser gets a claim-race rejection | 1+2 | `wallets.service.withdrawal-concurrency.spec.ts` (unit) + `test/e2e/wallet-withdrawal-cas.e2e-spec.ts` (real Postgres, server PR #2) — **the strongest-proven row in this whole matrix**, and the template every other concurrency-sensitive row should be tested against |
| T26 | Process crash between the Stripe transfer and the ledger settle transaction doesn't allow a second full withdrawal | server, same | inject a throw after the transfer, before the settle `$transaction` | claim-before-transfer design (server PR #2) means the claimed row is already unavailable to a retry | 1 | Covered by the same claim-before-transfer redesign that fixed T25 — `findings/06`'s D6 hypothesis was reclassified moot by the `#6` correction, since the redesign structurally prevents this, not just the original race |
| T27 | `transfer.reversed` books a `DRIVER_DEBT`/`SELLER_DEBT` clawback, delta-tracked against Stripe's cumulative `amount_reversed` | server `stripe-webhook-handler.service.ts` | a second, larger partial reversal on the same transfer | clawback books only the *new* delta, not the full amount again | 1 | `wallets.service.transfer-reversal.spec.ts`, `stripe-webhook-handler.transfer-reversed.spec.ts` (server PR #16 — the delta-tracking bug `code-review` caught before merge) |
| T28 | `payout.failed` / `account.application.deauthorized` handling | server | Stripe-initiated payout failure on the connected account's own bank | **undecided** — needs a product/support-flow decision first (issue #7's own stated remaining scope) | — | **Not testable yet — blocked on a decision, not an implementation gap** |

### 1.6 Admin reconciliation

| # | Transition | Owner | Fixture | Oracle | Platform | Today |
|---|---|---|---|---|---|---|
| T29 | `GET /admin/withdrawals/reconcile` surfaces missing transfers / amount mismatches against live Stripe | server `admin-wallets.service.ts` | seed a WITHDRAWAL row with no matching Stripe transfer | endpoint flags it | 1 | `admin-wallets.service.reconcile.spec.ts` (server PR #16) |
| T30 | Seller Connect-readiness triad visible in admin, parity with drivers | server + admin UI | seller with partial onboarding | admin shows `detailsSubmitted`/`chargesEnabled`/`payoutsEnabled`, not a collapsed boolean | 1 | `admin-sellers.service.connect-readiness.spec.ts` (server) + `incacook-admin` PR #3 (UI, confirmed shipped this session — see §7 correction) |
| T31 | Order-financials view cross-checks `commission + earnings + fee == buyerTotal` instead of rendering independent, unverified lines | admin `order-drawer.tsx` | an order with a deliberately broken split (test fixture) | the panel flags the mismatch instead of rendering a clean-looking but wrong panel | 1 | **Gap** — confirmed absent in `findings/06` §7 and re-confirmed open in issue #12 as of this session |
| T32 | Admin panel has real unit test coverage on wallets/payouts, not just one Playwright smoke test | admin | — | meaningful assertions beyond "renders without error" | 1 | **Gap** — `lib/utils.test.ts` covers formatting only; `e2e/*.spec.ts` are auth/smoke tests |

---

## 2. Existing automated coverage — the honest inventory

Counted directly from each repo's `dev` at time of writing (2026-07-18 evening):

| Repo | Test runner | File count | Notably deep coverage |
|---|---|---|---|
| `IncaCook` (mobile) | `flutter test`, CI-gated on every PR (`.github/workflows/ci.yml`, added this session's C-9 slice) | 24 files, 118 cases | Wallet (5 files, all shipped this session), payments/onboarding, checkout idempotency |
| `IncaCook-Server` | Jest, CI-gated on every PR (server PR #17 fixed CI never having triggered on `dev`) | 50 `.spec.ts` files + 2 real-Postgres `.e2e-spec.ts` | Wallets (9 files — the most heavily tested module in the whole codebase, proportional to its risk), orders/disputes (10 files), payment webhooks (6 files) |
| `incacook-admin` | Playwright (e2e) + `node --test` (unit) | 3 e2e specs (auth/smoke only) + 1 unit test file (formatting only) | **Thinnest coverage of the three repos** — no reconciliation, wallet-display, or Connect-readiness-UI test exists |

**Pattern worth naming explicitly**: every ledger-adjacent server module (`wallets.service.ts`) has *heavier* test coverage than almost anything else in that repo, and it is the one file this session's investigations (and the ones before it) kept finding real bugs in anyway (H1-H11 in `findings/06`, the transfer-reversal delta bug in server PR #16). This isn't a contradiction — it's evidence that the *domain* is genuinely hard (money math, concurrency, multi-party ledger splits), not that testing effort has been wasted. The admin panel's thinness by contrast is a straightforward, addressable coverage gap (T31/T32), not a sign the domain there is unusually hard.

---

## 3. Fixtures

### 3.1 Stripe test-mode fixtures (no real money, ever)

- **Platform account**: `acct_1TdvHCBSdl9ByXxu` (`findings/05`/DEC-7) — already the account every environment uses; test-mode only. **Do not create a second test account** — every existing digest-comparison and CLI trick in `findings/05` assumes this one.
- **Connect test accounts**: mint fresh via `accounts.create(type:'express', country:'FR')` per test run — already proven to work under this US-country platform (DEC-7/O-6). Reuse `findings/seed-qa-balance.mjs`'s pattern for a role-guarded, idempotent seeder rather than hand-rolling new ones per ticket.
- **Card numbers**: Stripe's published test PANs (`4242 4242 4242 4242` success, `4000 0000 0000 9995` decline, `4000 0025 0000 3155` requires 3DS) — no fixture file needed, these are Stripe's own public constants.
- **Webhook replay**: `stripe trigger <event-type>` for synthetic events; `stripe events resend <id>` to replay a real captured event (needed for T4, T16's ordering test, T27's delta test).

### 3.2 QA accounts (already exist, per `README.md`'s "Handy" section)

- `qa+seller-paris` — seeded seller with a real balance, used for T21/T25's live withdrawal proof this session's predecessors already ran.
- `findings/seed-qa-balance.mjs` — idempotent, role-guarded seeder. **This is the one fixture script that already exists and should be the template for any new one**, not a one-off.

### 3.3 Fixtures still needed (named gaps, not yet built)

- A seeder for a **disputed order with a `HELD` earning**, needed to test T8 across every resolution path without waiting for a real buyer dispute.
- A seeder for a **refund-after-24h-release** scenario (T7) — currently proven only by unit tests with mocked time, not an integration fixture.
- An admin-side fixture for a **deliberately-broken order split** (T31) — doesn't exist because the cross-check itself doesn't exist yet.

---

## 4. Environment checklist

What each layer from §0 needs, and — honestly — what has and hasn't been available in the
environment these investigations have run in this session and prior ones:

| Requirement | Layer | Available in this sandbox? | Consequence when unavailable |
|---|---|---|---|
| Local Node/Dart toolchains, `flutter test`, `pnpm test` | 1 | ✅ always | — |
| Local ephemeral Postgres for `.e2e-spec.ts` | 2 | ❌ **not available this session or prior ones** (issue #8, #7's original adversarial QA note it explicitly) | T10, and any new real-DB integration test, cannot be written *and verified* here — can be written and left for a CI environment or a session with DB access to run |
| Stripe test-mode API access (server-side key, already deployed) | 1, 2 | ✅ (via the deployed environment) | — |
| Stripe CLI (`stripe listen`/`trigger`) against a reachable endpoint | 2 | ⚠️ available in principle, not exercised this session (no need arose) | — |
| Stripe **Dashboard** access (event-subscription config, not API) | 2 (config verification only) | ⚠️ intermittent — some prior sessions had it (`findings/05` §4's live verification), this one didn't need it | T4/T18's *config* rows can only be manually re-verified when dashboard access is available; cannot be automated away entirely since Stripe doesn't expose endpoint event-subscription config via the API key alone |
| Android/iOS device or simulator | 3 | ❌ not available in this sandboxed environment, any session | Every device-only row (T6, T15, and everything in `QA-TEST.md`) stays a manual-QA checklist item, not something an agent session can execute end-to-end — this is a structural, not incidental, limitation |
| Chrome browser automation (for admin-panel visual checks) | — (admin UI verification, adjacent to this matrix) | ⚠️ intermittent — unavailable this session | Admin UI changes get HTTP-level verification (curl, `vercel inspect`) but not full visual/interaction confirmation without it |
| Railway CLI access (deploy + `prisma migrate deploy`) | operational, not test | ✅ this session, confirmed working | Needed to actually activate anything this matrix's layer-2/3 tests would exercise against the deployed environment — see `map.md`'s "Operational facts" |

**Net assessment**: layer 1 is fully achievable in this environment and is where this session's
work concentrated (rightly — it's also where the risk concentrates, per §2's pattern). Layer 2 is
achievable in principle but has been Postgres-blocked every session so far for the live-DB half;
the Stripe-CLI half is achievable but wasn't exercised this pass since no row currently needs it
freshly proven. Layer 3 is structurally out of reach for any agent session in this environment —
it is real device/human QA territory, which is exactly why `QA-TEST.md` exists as a separate,
owner-executed document rather than something this matrix tries to automate away.

---

## 5. Device-level QA — smallest necessary set

Per §0's design choice, this is deliberately short — only transitions layers 1-2 cannot reach.
Cross-referenced against what `.agent-board/QA-TEST.md` already documents:

| Row | Already in `QA-TEST.md`? | Note |
|---|---|---|
| T6 (app kill mid-checkout) | ❌ not yet — no fix landed to QA against | Add once P6 (cart persistence) ships |
| T15 (cold-start deep link) | ✅ Q5/Q17/Q20 | Covers Android `adb shell am kill` + the realistic iOS jetsam trigger |
| T14 (warm-return onboarding) | ✅ Q1/Q3/Q6/Q7/Q16 | Full role × entry-point matrix already there |
| Native PaymentSheet / 3DS device behavior | ❌ not explicitly enumerated | Findings/09 §1 confirms the native sheet path is currently unreachable dead code — nothing to QA on-device until/unless it's revived |
| Push-notification delivery through real FCM (`wallet_funds_available`, `order_paid`, etc.) | ⚠️ partial — order/delivery pushes implicitly covered by existing delivery-flow QA steps, wallet push not yet added | Add a step exercising the new tap-routing from app PR #40 |

No new device-QA rows are proposed beyond what naturally falls out of already-shipped fixes
needing their manual-QA counterpart — consistent with this board's established practice of adding
`QA-TEST.md` sections per shipped, user-visible slice rather than speculatively.

---

## 6. Gaps — ranked, with owners

Every row above marked **Gap** or **partial**, consolidated and ranked by what blocks it:

| Gap | Blocked by | Ranking |
|---|---|---|
| T9 — `charge.refunded` webhook unhandled | Nothing — implementable now | Real, actionable, not yet sliced into its own issue (K-4) |
| T10 — live-Postgres e2e for the full order lifecycle | Postgres access | Structural, recurring blocker — not resolvable by an agent session in this environment |
| T6 — app-kill-mid-checkout duplicate-order protection | Cart persistence design (P6) | Real, actionable, larger scope than a quick slice — needs its own design pass |
| T24 — five silent wallet-mutating events | **Product decision** (should debt/compensation events push at all?) | Not an implementation gap — explicitly flagged as needing owner input in `findings/08` §9 |
| T28 — `payout.failed` handling | **Product/support-flow decision** | Same category — issue #7's own stated remaining scope |
| T31 — order-financials cross-check arithmetic | Nothing — implementable now | Real, actionable, the single highest-value gap in the admin layer (a broken split currently renders as a clean panel) |
| T32 — admin test coverage | Nothing — implementable now | Real, actionable, but lower urgency than T31 since it's coverage-of-existing-correct-code, not a live blind spot |
| T13 — `SubscriptionGate` tab-gating test | Nothing — implementable now, just not located in this pass | Needs a quick verify-or-write pass, not a design decision |
| T4/T18 — deployed webhook config re-verification | Stripe Dashboard access | Intermittent, not permanently blocked; re-run opportunistically when access is available rather than treating as unresolvable |

---

## 7. Correction found while writing this document

Issue #12's most recent comment (before this session) says *"the `incacook-admin` Next.js frontend
doesn't display any of this yet — no UI wiring."* Checking `incacook-admin`'s current `dev`: PR #3
(`d33c77d`, "Connect-readiness badges + reconciliation tab") is merged and live, the same day as
that comment's session. **T30 in this matrix reflects the corrected, current state** — the UI
gap is closed; only T31/T32 remain genuinely open for issue #12. Posted as a separate correction
comment on issue #12 directly (not just here) so it doesn't only live in this document.

---

## 8. What this document deliberately does not do

- It does not propose a CI topology change (e.g., "add a nightly live-Postgres run") — that's an
  infrastructure decision for the owner, informed by this matrix, not decided by it.
- It does not attempt to write the T31 cross-check arithmetic, the T9 `charge.refunded` handler,
  or any other named gap's actual fix — those are implementation slices for fresh issues, matching
  this board's established granularity (one focused issue per gap, not one mega-ticket).
- It does not re-litigate any of `findings/03`'s product decisions (DEC-1 through DEC-8) — this
  matrix tests the *current, decided* domain model, not alternatives to it.
