# Findings — Trace mobile wallet freshness and user-visible balance updates

- **Ticket:** GitHub [issue #9](https://github.com/ProgixDev/incacook-app/issues/9) — "Trace mobile
  wallet freshness and user-visible balance updates"
- **Mode:** AFK research — read-only. No source file in any repo was modified.
- **Repos read:** `IncaCook` (mobile), `IncaCook-Server` (backend).
- **Secrets:** none copied.

## 0. Answer to the ticket question, up front

**The wallet screen has no proactive freshness mechanism at all.** It fetches
once on mount (`initState`) and otherwise only refetches on pull-to-refresh or
immediately after the user's own withdrawal. There is no app-lifecycle-resume
hook, no polling, no push-triggered refresh, and no HTTP cache to blame instead
— every fetch is a genuine network round trip, so *when* a fetch happens is the
entire freshness story.

The one wallet-specific push notification that exists server-side
(`wallet_funds_available`, sent when a `PENDING` entry crosses the 24h release
window) is silently discarded by the client's push router before it can do
anything — a type-prefix filter meant for order/delivery pushes rejects it. So
even the single ledger transition the backend explicitly tries to announce
never reaches the wallet screen or the user's tap-through.

Several other ledger-mutating events (refund clawback, driver-debt recording,
transfer-reversal clawback, driver/seller compensation) send **no notification
of any kind**, which is defensible only if the design intent is "the user
checks Wallet manually" — but nothing on the client makes checking Wallet
convenient (no badge, no home-screen indicator) and, worse, the client's own
label rendering for the highest-stakes new event type (`SELLER_DEBT`, the
refund-clawback debt row from server PR #6) is broken — see W6.

Everything below is evidence for those claims.

---

## 1. Trigger inventory

`WalletRepository` has exactly three call sites, all inside
`lib/features/wallet/presentation/wallet_screen.dart` — confirmed by exhaustive
`grep -rn "WalletRepository" lib`:

| # | Trigger | file:line | Notes |
|---|---|---|---|
| F1 | Screen mount | `wallet_screen.dart:33` (`initState`) | Fires once per `WalletScreen()` instance |
| F2 | Pull-to-refresh | `wallet_screen.dart:37`, wired to `RefreshIndicator.onRefresh` at `:87` | User-initiated only |
| F3 | Manual retry (error state) | `wallet_screen.dart:98-99`, `:457` → `_refresh()` | Same underlying call as F2 |
| F4 | After the user's own withdrawal | `wallet_screen.dart:61`, inside `_withdraw()` | Sees the final state immediately since withdrawal is synchronous server-side (§2) |

**Not a trigger, confirmed absent:** app resume (`AppLifecycleState.resumed`),
route re-entry while the widget stays mounted, push-notification receipt or
tap, a timer/poll. `WalletScreen` is a plain `StatefulWidget` with
`Future<WalletSummary> _future` + `FutureBuilder` — no `Obx`/`Rx` wraps the
balance itself (only the unrelated payout-onboarding banner state is
reactive).

**Route wiring** — both entry points push a **brand-new** `WalletScreen()`
instance via `Get.to`, so leaving and re-entering the screen *does* refetch
(this is the only "implicit" freshness mechanism that exists, and it's
incidental, not designed):

- `lib/features/settings/presentation/screens/settings.dart:112`
- `lib/features/delivery/presentation/widgets/delivery_settings_section.dart:68`

**Caching layer:** none. `ApiClient` (`lib/core/network/api_client.dart:42-59`)
registers only `AuthInterceptor` (bearer-token attach + single-flight 401
refresh) and `PrettyDioLogger` — no HTTP cache interceptor exists in the repo
(`pubspec.yaml` has no `dio_cache_interceptor` or similar; `cached_network_image`
is for images only). Every `getSummary()` call is a real round trip — there is
no stale-cache failure mode to investigate, only a stale-*absence-of-fetch*
one.

---

## 2. Full request/response trace

```
WalletScreen.initState / _refresh                    wallet_screen.dart:33,37
  → WalletRepository().getSummary()                   wallet_repository.dart:17-24
      (constructs a NEW WalletRepository every call — see §5)
  → ApiClient.get<WalletSummary>('/v1/wallet/me', …)   api_client.dart:70-79
  → WalletController.me                                wallets.controller.ts:16-19
  → WalletService.summary(supabaseId)                  wallets.service.ts:641-691
      Promise.all of 4 aggregate sums (AVAILABLE / PENDING / HELD /
      PAID_OUT-excl-WITHDRAWAL) + findMany(take:50) for entries  :647-667
  → {success, data} envelope → ApiClient unwraps `data`
  → WalletSummary.fromJson                             wallet_models.dart:101-114
  → setState(() => _future = next) → FutureBuilder rebuild   wallet_screen.dart:88-101
```

**Withdrawal is fully synchronous, not queued.** `requestWithdrawal`
(`wallets.service.ts:710-878`) claims the ledger rows (CAS
`AVAILABLE→PAID_OUT`, `:818-834`) then `await stripe.client.transfers.create`
inline (`:838-849`) before returning — there is no async gap on this specific
path, which is why F4's immediate `_refresh()` is sufficient and correct for
that one case.

**Field-parsing gap found in passing:** the server's `WalletSummary` includes
`totalBalanceCents` (`wallets.service.ts:678`, `:955`) but the client's
`WalletSummary.fromJson` (`wallet_models.dart:101-114`) never reads that key —
silently dropped. No user-visible symptom found (nothing currently tries to
show a combined total), flagged as a completeness gap only.

---

## 3. Every backend event that mutates the ledger, and whether any push accompanies it

Exhaustive inventory of `WalletsService` mutating methods and their call
sites (`grep -rn` across `IncaCook-Server/src`, excluding specs):

| Ledger event | Trigger | Push sent? |
|---|---|---|
| `creditForCompletedOrder` (PENDING/HELD credit at delivery) | `orders.service.ts:2139` ← QR-scan delivery confirmation | **Yes**, but wrong type — `delivery_completed` (`deliveries.service.ts:849,858`), not wallet-specific, and (§4) not consumed by Wallet anyway |
| `releaseDuePendingEntries` (PENDING→AVAILABLE, 24h sweep) | `@Cron` every 5 min **and** a durable BullMQ repeatable job, both idempotent (`wallets.service.ts:527-534`; `src/jobs/wallet-release.processor.ts:20-53`) | **Yes** — the only wallet-specific type, `wallet_funds_available` (`wallets.service.ts:588-599`) |
| `compensateDriver` (seller-unavailable driver comp) | `orders.service.ts:1328` | **No** |
| `creditSellerEarning` (driver-disappeared, seller paid) | `orders.service.ts:1950` | **No** |
| `recordDriverDebt` | `orders.service.ts:1960` | **No** |
| `reverseEntriesForRefundedOrder` (refund clawback → `SELLER_DEBT`/`DRIVER_DEBT`) | `orders.service.ts:3343` | **No** |
| `releaseHeldEntriesForOrder` (dispute resolved, HELD→AVAILABLE) | `orders.service.ts:3060,3087,3136,3204` | Adjacent pushes exist but are generic dispute-outcome types (`dispute`, `dispute_seller`, `allergen_strike`, `chargeback_fraud`), never wallet-specific |
| `recordTransferReversal` (Stripe `transfer.reversed` → debt clawback) | `stripe-webhook-handler.service.ts:379-401` | **No** |
| `requestWithdrawal` success | client-initiated | N/A — client already knows (own request) |

Full inventory of every FCM push `type` string emitted anywhere server-side:
`account_suspended`, `catalog_claim`, `admin_broadcast`, `legal_terms_updated`,
**`wallet_funds_available`**, `no_driver_available`, `order_switched_pickup`,
`order_cancelled`, `delivery_cancelled`, `pickup_timeout`,
`driver_disappeared`, `allergen_strike`, `dispute`, `chargeback_fraud`,
`dispute_seller`, `chat_message`, `TEST`, `order_paid`, `delivery_available`,
`delivery_completed`, `seller_unavailable`. **`wallet_funds_available` is the
only wallet-relevant one** — every other ledger-mutating event in the table
above is silent.

---

## 4. Why even the one wallet push is a dead end client-side

```mermaid
flowchart TD
    A["Server sends push<br/>{type: 'wallet_funds_available'}"] --> B{"PushNotificationService.\n_emitOrderEvent\ntype.startsWith('order_'/'delivery_')?"}
    B -- "no (wallet_funds_available fails the prefix test)" --> C["Never reaches OrderNotificationsService bus.\nOnly shows as a tray / foreground banner notification."]
    B -. "delivery_completed WOULD pass .-> D["OrderNotificationsService bus"]
    D --> E["2 listeners, both seller order-list screens\norder_requests.dart / order_requests_section.dart\n— NOT WalletScreen"]
    A --> F{"User taps the notification"}
    F --> G["_routeForNotification: same order_/delivery_\nprefix guard → no-op, no navigation"]
    A --> H{"User taps it in the in-app bell inbox"}
    H --> I["Requires non-empty orderId AND order_/delivery_ type.\nwallet_funds_available payload has no orderId → tap does nothing but mark read."]
```

- `PushNotificationService._emitOrderEvent`
  (`lib/core/services/notifications/push_notification_service.dart:218-231`)
  only republishes onto the order-notifications bus when
  `type.startsWith('order_') || type.startsWith('delivery_')` (`:224`).
  `wallet_funds_available` fails that test.
- Even `delivery_completed`, which *does* pass the filter, has exactly two
  listeners in the whole app (`order_requests.dart:62-63`,
  `order_requests_section.dart:44-45`) — both seller order-list screens, not
  `WalletScreen`.
- Push-tap routing (`_routeForNotification`,
  `push_notification_service.dart:239-271`) has the identical prefix guard at
  `:244` — a `wallet_funds_available` tap is a no-op.
- The in-app notification-bell inbox (`notifications_screen.dart:52-60`)
  requires a non-empty `orderId` *and* an `order_`/`delivery_` type prefix
  before it navigates on tap. The wallet push's payload is
  `{type: 'wallet_funds_available'}` only (`wallets.service.ts:594`) — no
  `orderId` — so tapping "Gains disponibles" in the bell does nothing but mark
  it read, and it renders with the generic bell icon rather than a
  wallet-specific one (`_iconFor`, `:219-224`).

Net effect: the backend's one deliberate wallet-freshness signal is emitted
correctly and then discarded by client-side routing logic that was written for
order/delivery events and never extended to cover it.

---

## 5. App lifecycle and DI-graph findings

**No app-wide lifecycle observer exists.** Exhaustive grep
(`AppLifecycleState|WidgetsBindingObserver`) returns exactly two hits in the
whole app, neither wallet-related:
`payout_onboarding_service.dart:221-234,314-322` (scoped to one Connect-return
await) and `complete_email_screen.dart:40-72` (email-verification polling).
There is no `Timer`/polling anywhere in `wallet_screen.dart` or
`wallet_repository.dart`. Resuming the app while `WalletScreen` is the current
route does **nothing** — the cached `_future` keeps showing whatever was last
fetched.

**`WalletRepository` sits outside the app's DI graph.** It declares itself
`extends GetxService` with a `.instance => Get.find()` accessor
(`wallet_repository.dart:9,12`), matching the pattern every sibling repository
uses (`OrdersRepository`, `SellerOrdersRepository`, `PayoutOnboardingService`,
etc. — all registered via `Get.lazyPut(..., fenix: true)` in
`general_bindings.dart:35-43`). But `WalletRepository` is **never registered**
— grep confirms zero `Get.put`/`Get.lazyPut` calls for it anywhere. Every real
call site sidesteps this by constructing `WalletRepository()` fresh
(`wallet_screen.dart:33,37,56`) rather than calling `.instance`, which would
throw if anything ever called it. This is the mirror image of the DI gap the
prior Connect-onboarding investigation found in `PayoutOnboardingService`
(that class had a constructor seam added as a prerequisite fix but *was*
registered) — here a constructor seam already exists
(`WalletRepository({ApiClient? api})`, `:10`) but the class was never wired
into the graph it claims to belong to.

---

## 6. Staleness / race matrix

Verdicts: **correct** = code provably handles it as intended; **broken** =
code provably mishandles it; **by-design gap** = works as coded, but the
design itself leaves a freshness hole; **unproven** = needs a device.

| # | Scenario | What happens today | Verdict | Evidence |
|---|---|---|---|---|
| S1 | User opens Wallet, sees balance, backgrounds app, a `PENDING` entry releases server-side, user foregrounds app (Wallet still the visible route) | Nothing refetches. Balance stays stale until manual pull-to-refresh or leaving/re-entering the screen. | **by-design gap** (W1) | §1, §5 |
| S2 | Same as S1, but the release push (`wallet_funds_available`) arrives while foregrounded | Local tray/banner notification shows ("Gains disponibles"), but nothing in-app refreshes the balance and tapping it does nothing | **broken** (W2) | §4 |
| S3 | Seller receives a refund-clawback `SELLER_DEBT` row (server PR #6's ledger reversal work) | No push at all; on next Wallet visit the entry renders with the **literal string `"SELLER_DEBT"`** instead of a French label | **broken** (W2 + W6) | §3, §7 |
| S4 | User taps "Retirer" (withdraw) | Synchronous server call, `_refresh()` immediately after → correct final state shown, no staleness window | **correct** | §2 |
| S5 | User closes Wallet and reopens it (any elapsed time) | `Get.to` mounts a fresh `WalletScreen`, refetches on `initState` | **correct, incidental** | §1 |
| S6 | User pulls to refresh | Full-screen spinner replaces the entire body (old balance/entries not kept visible underneath) while refetching | **correct outcome, minor UX regression** (W7) | §1 |
| S7 | Driver/seller compensation, debt recording, or transfer-reversal clawback fires while user has the app closed | No push, no in-app signal, no badge anywhere indicating "your wallet changed" — discoverable only by manually opening Wallet | **by-design gap** (W3) | §3 |

---

## 7. Defects

Each carries a **falsifiable statement**.

### W1 — Wallet screen has no proactive refresh mechanism (highest freshness impact)

The ticket's central question — "does a backend ledger transition become
visible without restarting the app" — resolves to: only if the user manually
pulls to refresh or leaves/re-enters the screen. No lifecycle hook, no push
consumption, no polling exists (§1, §5).

> **Falsifiable:** open Wallet, keep the screen mounted, trigger a real
> `PENDING→AVAILABLE` release (or any other ledger mutation) for that user
> server-side, wait — the displayed balance does not change without a manual
> pull or screen re-entry. If it updates on its own, W1 is wrong.

### W2 — The one wallet-specific push is silently discarded by client routing

`wallet_funds_available` fails the `order_`/`delivery_` prefix filter in both
`_emitOrderEvent` and `_routeForNotification`, and fails the bell-inbox's
`orderId`-required tap condition (§4). The backend's only deliberate
freshness signal never reaches the wallet screen or produces any navigation.

> **Falsifiable:** trigger a `PENDING→AVAILABLE` release for a user with the
> app foregrounded — a local notification appears, but the wallet balance
> shown (if Wallet is open) does not update, and tapping the notification (if
> backgrounded) does not navigate to Wallet. If either occurs, W2 is wrong.

### W3 — Five of six ledger-mutating server events send no notification at all

`compensateDriver`, `creditSellerEarning`, `recordDriverDebt`,
`reverseEntriesForRefundedOrder` (the refund-clawback path from server PR
#6), and `recordTransferReversal` never call any notification method (§3). A
user whose earnings were just clawed back into debt has zero signal, in-app
or push.

> **Falsifiable:** complete a refund-after-payout scenario that books a
> `SELLER_DEBT` clawback — inspect the notification/FCM call log for that
> user; none fires. If one fires, W3 is wrong for that event.

### W4 — `WalletRepository.instance` is dead code that would throw if called

`WalletRepository extends GetxService` with an `.instance` accessor
(`wallet_repository.dart:9,12`), but is never `Get.put`/`Get.lazyPut`
registered anywhere (§5) — inconsistent with every sibling repository in
`general_bindings.dart`. Not a live bug (nothing calls `.instance` today) but
a latent trap for the next person who follows the codebase's own established
pattern.

> **Falsifiable:** call `WalletRepository.instance` from any new code path →
> `Get.find()` throws (nothing registered). Confirmed by absence in
> `general_bindings.dart:35-43`.

### W5 — `totalBalanceCents` computed server-side, silently dropped client-side

`wallet_models.dart:101-114`'s `WalletSummary.fromJson` never reads the
`totalBalanceCents` key the server includes (`wallets.service.ts:678,955`).
No current UI tries to show it, so no user-visible symptom found — flagged as
a completeness gap for whoever next touches this DTO.

### W6 — Client transaction-list labels are incomplete against the server's ledger enum

Server `WalletEntryType` has 8 values (`ORDER_EARNING, DELIVERY_EARNING,
COMMISSION, REFUND, WITHDRAWAL, DRIVER_DEBT, SELLER_DEBT, PLATFORM_FEE` —
`prisma/schema.prisma:1467-1476`). The client's label switch
(`wallet_models.dart:29-46`) handles only 6 and falls through to `default:
return type` for `SELLER_DEBT` and `PLATFORM_FEE`. `PLATFORM_FEE`/`COMMISSION`
rows are booked under a synthetic platform user id so they likely never reach
a real user's list — but `SELLER_DEBT` is real, user-facing data, and it is
exactly the row type server PR #6 introduced for refund clawbacks. **The
ledger-correctness fix shipped without a matching client display fix.**

> **Falsifiable:** a seller with a `SELLER_DEBT` row from a refund clawback
> opens Wallet → the transaction list shows the literal string `"SELLER_DEBT"`
> rather than a French label. If a French label appears, W6 is wrong.

### W7 — Pull-to-refresh discards the previously-rendered balance while refetching

`_refresh()` reassigns `_future` (`wallet_screen.dart:36-40`); the
`FutureBuilder`'s in-flight branch (`:91-93`) shows a full-screen spinner,
replacing rather than overlaying the last-good data. Minor UX regression, not
a correctness bug.

### W8 — Dead "pay with wallet balance" concept shares the name with the earnings wallet

`PaymentMethod.wallet`/`WalletPaymentMethod` (`payment_method.dart:14-18`,
four unused copy strings in `text_strings.dart:604-607`) is a checkout-side
"pay from balance" concept, entirely unconstructed anywhere. Unrelated to the
seller/driver earnings wallet this ticket is about, but the name collision is
worth flagging before anyone builds either feature and confuses the two.

---

## 8. Proposed tests (NOT written — proposals only, per the ticket's Test boundary)

### 8.1 Mobile — repository/widget tests (`test/features/wallet/`, does not exist yet)

`WalletRepository`'s constructor seam (`{ApiClient? api}`) already supports
fake injection — no DI-seam prerequisite work needed here, unlike the
Connect-onboarding ticket.

- **T1** `getSummary()` parses a full `WalletSummary` response including all 8
  entry types — asserts W6 by construction (would need the label switch fixed
  first to pass for `SELLER_DEBT`/`PLATFORM_FEE`).
- **T2** Widget test: mount `WalletScreen` with a fake repository, assert
  `initState` calls `getSummary()` exactly once (F1), pull-to-refresh calls it
  again (F2), and no other trigger fires it — characterizes W1 by proving
  there is genuinely nothing else.
- **T3** Widget test: after `_withdraw()` succeeds, assert exactly one
  additional `getSummary()` call (F4) and the displayed balance reflects the
  fake's second response.
- **T4** **Would fail today (W6)**: fake response containing a `SELLER_DEBT`
  entry → assert the rendered label is NOT the literal string `"SELLER_DEBT"`.
- **T5** Characterization test for W4: assert `WalletRepository.instance`
  throws today (documents the DI gap so a future fix — registering it — is a
  deliberate, visible change, not an accidental behavior shift).

### 8.2 Mobile — push routing tests (`test/core/` or wherever `push_notification_service_test.dart` would live — does not exist yet)

- **T6** **Would fail today (W2)**: feed `_emitOrderEvent` a
  `{type: 'wallet_funds_available'}` payload → assert it reaches *some*
  consumer (once a wallet-aware consumer exists) rather than being silently
  dropped by the prefix guard.
- **T7** **Would fail today (W2)**: feed `_routeForNotification` the same
  payload → assert it navigates to Wallet (once routing is extended) rather
  than no-op.

### 8.3 Backend — contract tests (extend `wallets.service.spec.ts`)

- **C1** Each of the five silent mutating methods (W3) — assert whether a
  notification call is intentionally absent or should be added; today none of
  them are asserted either way (only `releaseDuePendingEntries`'s push is
  tested, per `wallets.service.spec.ts:155,182`).
- **C2** `summary()` response shape includes `totalBalanceCents` — canary test
  so W5 is caught the next time this DTO changes shape (guards against
  silent drift in either direction).

### 8.4 Device scenario (per the ticket's test boundary: "one device scenario")

Seed a `PENDING` entry close to its 24h release boundary for a QA seller (the
existing `findings/seed-qa-balance.mjs` seeder or a direct DB write), open
Wallet, background the app until the release sweep fires, foreground again
with Wallet still the active route — confirm the balance does **not** update
(demonstrates W1) and, if the push arrives while backgrounded, confirm tapping
it does not navigate to Wallet (demonstrates W2).

---

## 9. Open decisions

Unlike the Connect-onboarding investigation, this ticket has no umbrella
product-decision issue yet — these are flagged for whoever slices W1-W8 into
implementation issues:

1. **Should Wallet gain an app-lifecycle-resume refresh**, mirroring the
   pattern this codebase already uses elsewhere (`seller_home.dart`,
   `delivery_home.dart` refresh on init/resume for payout readiness)? This is
   the most direct fix for W1/S1.
2. **Should `wallet_funds_available` (and ideally the five silent events in
   W3) get proper push routing** — a `wallet_` prefix branch in
   `_emitOrderEvent`/`_routeForNotification` that navigates to `WalletScreen`
   on tap? This is a small, well-scoped fix (W2).
3. **Should the five silent ledger events (W3) get a push at all**, or is
   "check Wallet manually" the accepted design for debt/compensation events
   specifically (as opposed to earnings, which do get a push)? This is a
   product call, not obviously a bug — flagging rather than asserting.
4. **W6 (`SELLER_DEBT`/`PLATFORM_FEE` label gap) is the one item here that
   reads as an unambiguous bug, not a design gap** — it directly regresses a
   feature (server PR #6's refund-clawback ledger correctness) that already
   shipped. Recommend prioritizing this over the freshness questions above.
5. **Should `WalletRepository` be registered into the DI graph** (fixing W4)
   as a small hygiene pass, independent of the freshness decisions?

---

## 10. Unknowns / could not verify

- **Whether any home-screen badge/indicator for wallet changes was ever
  intended.** No such UI element exists in the current code; whether its
  absence is a gap or simply out of scope was not decided by any doc found.
- **Real-world frequency of S1-class staleness** (user sitting on Wallet long
  enough for a server-side event to land) — plausible for the 24h `PENDING`
  release sweep if a user happens to have the screen open at the right
  5-minute tick, but no usage-pattern data exists to say how often this
  actually happens versus users closing/reopening the app between visits.
- **Whether `totalBalanceCents` (W5) was ever meant to be shown** — no
  design doc or commit message found explaining its addition; could not
  determine intent versus leftover.
