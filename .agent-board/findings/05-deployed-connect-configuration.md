# 05 — Verify deployed Stripe Connect and webhook configuration

- **Ticket:** `.agent-board/backend/01-deployed-connect-configuration.md`
- **GitHub:** [issue #5](https://github.com/ProgixDev/incacook-app/issues/5)
- **Mode:** AFK where access exists; operator checklist otherwise
- **Investigated:** 2026-07-15
- **Status:** investigation complete — no code or config changed (read-only)

## Evidence provenance

| Channel | Access | Used for |
| --- | --- | --- |
| Local repos (`IncaCook`, `IncaCook-Server`, `incacook-admin`) | read | code contracts, local `.env` drift |
| `railway` CLI (`tasseltess@gmail.com`) | read-only | variables **actually loaded by the running deployment** |
| Public HTTPS (GET only) | read | callback-bridge reachability |
| Stripe Dashboard / `stripe` CLI | **NONE** | → operator checklist below |

Redaction method: no secret value was ever written to disk or to this file.
Key **identity** comparisons were done by piping values into `shasum -a 256`
and comparing 8-char digests — the digests below prove equality/inequality
without disclosing material. An attempt to spool `railway variables --json`
to a scratchpad file was correctly blocked by the credential-leak guard and
was **not** retried in a bypassing form.

---

## 1. Redacted environment matrix

### Deployment identity (from the running deployment)

| Field | Value |
| --- | --- |
| Railway workspace / project | `My Projects` / `empathetic-rebirth` |
| Project ID | `4bad8318-1bc3-4bd0-867a-e44b348f2fd0` |
| Environment | `production` (ID `d8c0a049-82ff-43e4-8644-1c9ff02df019`) |
| Services | `incacook-api`, `incacook-worker`, `Redis` |
| Linked service | `incacook-api` — ● Online, region EU West |
| Service ID | `95ec4d75-5bce-40e4-b0ce-57f250430719` |
| Deployment ID | `835ba71a-01ae-4bde-900e-5410c9e1fb10` |
| Public URL | `https://incacook-api-production-146b.up.railway.app` |
| Server repo HEAD (local) | `deb19c52` — 2026-07-13 (**not** proven to be the deployed commit) |

### Mobile artifact ↔ deployment ↔ Stripe mode

| Axis | Android | iOS | Source |
| --- | --- | --- | --- |
| Build flavor / env | **none — no product flavors, no schemes** | **none** | `android/app/src/` = `debug`/`main`/`profile` only; no `productFlavors` in `build.gradle` |
| Config injection | `--dart-define-from-file=.vscode/dart_defines.json` | same | `melos.yaml:9,13,21,25`; `.vscode/launch.json` |
| Resolved API base URL | `https://incacook-api-production-146b.up.railway.app` | same | `.vscode/dart_defines.json:2` |
| Stripe publishable key mode | **`pk_test_…`** | same | `.vscode/dart_defines.json:6` |
| App URL scheme | `incacook://` (`host=stripe`, `host=auth`) | `incacook://` | `AndroidManifest.xml:62,76-77`; `ios/Runner/Info.plist:44-47` |
| Matching backend | `incacook-api` @ Railway `production` | same | URL identical to `APP_URL` |
| Backend secret key mode | **`sk_test_…`** | — | deployed var, prefix only |
| Backend `NODE_ENV` | **`production`** | — | deployed var |

### Stripe key alignment (digest proofs, no values)

| Comparison | Digests | Verdict |
| --- | --- | --- |
| mobile `STRIPE_PUBLISHABLE_KEY` vs deployed `STRIPE_PUBLISHABLE_KEY` | `824a8038` = `824a8038` | ✅ **identical key** |
| deployed `sk` account fragment vs deployed `pk` account fragment | `804808a5` = `804808a5` | ✅ **same Stripe account** |
| mobile `pk` account fragment vs deployed `sk` account fragment | `804808a5` = `804808a5` | ✅ **app and backend share one Stripe account** |
| `.env.railway.api.local` `sk` account fragment | `804808a5` | ✅ same account |

**Verdict:** mobile and backend are *internally consistent* — one Stripe
account, test mode on both sides. The alignment the ticket asks about is
**correct**. The risk is not misalignment; it is §2.

### Deployed Stripe variables (prefix / mode only)

| Variable | `incacook-api` (production) |
| --- | --- |
| `STRIPE_SECRET_KEY` | `sk_test_…` (len 107) |
| `STRIPE_PUBLISHABLE_KEY` | `pk_test_…` (len 107) |
| `STRIPE_WEBHOOK_SECRET` | `whsec_…` (len 38) — **exactly one** |
| `STRIPE_CONNECT_CLIENT_ID` | `ca_…` (len 37) |
| `STRIPE_ONBOARDING_RETURN_URL` | `https://incacook-api-production-146b.up.railway.app/v1/stripe/return` |
| `STRIPE_ONBOARDING_REFRESH_URL` | `…/v1/stripe/refresh` |
| `STRIPE_CONNECT_ACCOUNT_COUNTRY` | ❌ **NOT SET** → code default `'FR'` (`stripe.config.ts:12`) |
| `STRIPE_SELLER_SUBSCRIPTION_PRICE_ID` | ❌ **NOT SET** → `''` |
| `STRIPE_SUBSCRIPTION_SUCCESS_URL` | ❌ **NOT SET** → `''` |
| `STRIPE_SUBSCRIPTION_CANCEL_URL` | ❌ **NOT SET** → `''` |
| `STRIPE_PORTAL_RETURN_URL` | ❌ **NOT SET** → `''` |
| `ALLOWED_ORIGINS` | `*` (→ CORS reflects any origin, `main.ts:47-54`) |

`incacook-worker` carries `NODE_ENV=production` and the same five Stripe vars.
It boots via `NestFactory.createApplicationContext` (`worker.ts:39`) — no HTTP
server — so its `STRIPE_WEBHOOK_SECRET` is **dead weight** (extra secret
surface, no consumer).

---

## 2. Headline configuration risk: test-mode keys in an environment named `production`

The deployment self-describes as production on every axis
(`NODE_ENV=production`, `RAILWAY_ENVIRONMENT_NAME=production`,
`SENTRY_ENVIRONMENT=production`) while transacting on **`sk_test_`/`pk_test_`**.

Consequences:
- No real money can move. Any "it works in prod" claim is test-mode evidence.
- `NODE_ENV=production` **disables** the dev conveniences (§6) — so this
  environment is simultaneously too strict to demo and too fake to launch.
- Sentry tags test-mode errors as `production`, polluting real alerting.
- The go-live cutover (swap to `sk_live_`/`pk_live_`) is **untested and
  unstaged**: there is no staging environment between here and live, and
  `env.validation.ts` does not assert that key mode matches `NODE_ENV`.

This is the correct state *today* (the audit wants test-mode evidence), but it
means **the environment named `production` is not a production environment**.
Classify as `configuration`; it must be resolved before launch.

---

## 3. Local-vs-deployed drift

| Variable | `.env` (dev) | `.env.railway.api.local` | Deployed `incacook-api` | Drift |
| --- | --- | --- | --- | --- |
| `NODE_ENV` | `development` | `production` | `production` | mirror OK |
| `STRIPE_SECRET_KEY` | `sk_test_…` | `sk_test_…` (acct `804808a5`) | `sk_test_…` (acct `804808a5`) | ✅ same account |
| `STRIPE_PUBLISHABLE_KEY` | `pk_test_…` | `pk_test_…` | `pk_test_…` | ✅ |
| `STRIPE_WEBHOOK_SECRET` | digest `bff78edb` | digest `bff78edb` | digest `bff78edb` | ⚠️ **all three identical — see below** |
| `STRIPE_ONBOARDING_RETURN_URL` | `https://incacook-api-**production**.up.railway.app/v1/stripe/return` | `…-production-**146b**…` | `…-production-**146b**…` | ❌ **`.env` points at a stale//nonexistent host** |
| `STRIPE_ONBOARDING_REFRESH_URL` | stale host (as above) | `…-146b…` | `…-146b…` | ❌ same |
| `STRIPE_CONNECT_ACCOUNT_COUNTRY` | absent | absent | absent | implicit `'FR'` everywhere |
| `STRIPE_SELLER_SUBSCRIPTION_PRICE_ID` | absent | absent | absent | ❌ subscriptions unconfigured |

Two drift findings:

1. **`.env` onboarding URLs point at `incacook-api-production.up.railway.app`
   (no `-146b`).** A developer running locally mints Account Links whose
   `return_url` targets a host that is not this deployment. Either it does not
   resolve (onboarding dead-ends) or — worse — it is a *different* Railway
   deployment, in which case local onboarding returns into the wrong backend.
   Classify `configuration`.

2. **The dev `.env`, the Railway mirror file, and the running deployment all
   share one `STRIPE_WEBHOOK_SECRET` (digest `bff78edb`).** This is not a
   `stripe listen` ephemeral secret — it is one dashboard endpoint's signing
   secret pasted everywhere. So a developer's laptop holds the production
   endpoint's signing secret, and there is no environment isolation of webhook
   trust. Classify `configuration` (secret hygiene).

---

## 4. Webhook topology — the key question

### What the code can do

- Exactly **one** HTTP webhook route:
  `POST /v1/stripe/webhook`
  (`src/modules/payments/webhooks/stripe-webhook.controller.ts:21,38`).
- Exactly **one** signing secret: `stripeConfig.webhookSecret`
  (`src/config/stripe.config.ts:6`), required non-empty at boot
  (`src/config/env.validation.ts:38`).
- Verification is single-secret, with no fallback list:
  ```ts
  // src/infrastructure/stripe/stripe-webhook.service.ts:21
  return this.stripe.client.webhooks.constructEvent(payload, signature, this.cfg.webhookSecret);
  ```
- The handler dispatches **both channels through the same door**:
  `account.updated` (a *connected-account* event) sits in the same `switch`
  as `payment_intent.*` / `charge.dispute.*` / `customer.subscription.*`
  (`stripe-webhook-handler.service.ts:49-87`).

### Verdict on the single-secret question

> **A single `STRIPE_WEBHOOK_SECRET` is correct if and only if the Stripe
> account has exactly ONE webhook endpoint pointing at
> `/v1/stripe/webhook`, and that endpoint has "listen to events on connected
> accounts" ENABLED so it carries both channels.**

There is no third option in this codebase. Concretely:

- **If the operator created two endpoints** (the natural dashboard flow —
  one "Events on your account", one "Events on connected accounts"), they have
  **two different `whsec_` secrets**. The backend holds one. Every event from
  the other endpoint fails `constructEvent`, is logged as
  `Stripe signature verification failed`, and returns **400** — which Stripe
  records as a *permanent* delivery failure. Because the code returns 400 (not
  5xx) *deliberately* to avoid retries
  (`stripe-webhook.controller.ts:55-57`), **those events are dropped, silently
  and forever**. The most likely victim is `account.updated`, i.e. seller and
  driver payout onboarding would never complete server-side.
- **If the operator created one Connect-enabled endpoint**, the single secret
  is correct and both channels verify.

**I cannot determine which is true without dashboard access.** This is the
single highest-value unknown in the ticket, and it is a **binary that decides
whether Connect onboarding works at all**. See operator checklist O-2/O-3.

Two facts raise the probability that something is already wrong:

- `railway logs --service incacook-api` shows **zero** lines matching
  `stripe|webhook|signature|account.updated|payment_intent|Chargeback` in the
  retained window. There is **no positive evidence any Stripe event has ever
  been verified by this deployment.**
- The mobile client deliberately **does not depend on** `account.updated`: it
  polls `GET /v1/stripe/onboarding/status` on return, which calls
  `accounts.retrieve` and persists `stripeOnboardingCompleted`
  (`onboarding.service.ts:114-156`;
  `lib/features/payments/data/payout_onboarding_service.dart:132-144`). That
  polling backstop would **mask a completely dead `account.updated` channel**
  in manual testing. The webhook could have been broken since day one without
  anyone noticing.

### Event types: handled vs in product scope

| Event | Handled? | Where | In scope per ticket |
| --- | --- | --- | --- |
| `account.updated` | ✅ | handler:51, 435-473 | ✅ connected-account channel |
| `payment_intent.succeeded` | ✅ | handler:54, 210-244 | ✅ payment success |
| `payment_intent.payment_failed` | ✅ | handler:57, 251 | ✅ payment failure |
| `payment_intent.canceled` | ✅ | handler:58 | ✅ |
| `charge.dispute.created/updated/closed` | ✅ | handler:76-79, 333-382 | ✅ dispute |
| `checkout.session.completed` | ✅ | handler:63, 95-102 | ✅ subscription |
| `customer.subscription.created/updated/deleted` | ✅ | handler:66-68, 119-154 | ✅ subscription |
| `invoice.payment_failed` | ✅ | handler:71, 106-112 | ✅ subscription |
| **`charge.refunded` / `refund.*`** | ❌ | — | ⚠️ **ticket names refunds explicitly** |
| **`transfer.*` / `payout.*`** | ❌ | — | ⚠️ Connect payout lifecycle |
| **`account.application.deauthorized`** | ❌ | — | ⚠️ seller disconnects platform |

`refund` is **in the ticket's required event list but has no handler** — the
`default` branch swallows it at `.debug` level (handler:82-85). Admin-initiated
refunds therefore never reflect back into DB state from Stripe's side.
Classify `code-contract`.

---

## 5. Code-contract findings

### 5.1 Raw body — ✅ CORRECT (the classic NestJS bug is absent)

- `NestFactory.create(AppModule, { bufferLogs: true, rawBody: true })`
  — `src/main.ts:27-30`. `rawBody: true` makes Nest retain the unparsed
  `Buffer` alongside the JSON body.
- The controller reads `request.rawBody` (the `Buffer`), **not** `request.body`,
  and hard-fails if absent — `stripe-webhook.controller.ts:41,47-49,53`.
- No global `express.json()` / `app.use(bodyParser…)` overrides it — verified by
  grep across `main.ts`/`worker.ts`; only `helmet`, `compression`,
  `cookieParser` are installed (`main.ts:38-40`), none of which touch the body.
- **Proven live:** unsigned `POST /v1/stripe/webhook` → **HTTP 400**, i.e. the
  deployment reaches signature verification and rejects. (A raw-body bug would
  also 400, so this is consistent-but-not-conclusive; the code read is the
  stronger evidence.)

### 5.2 Idempotency — ⚠️ MOSTLY, with one real race

The design is "recompute target state, last-write-wins" (handler:43-48) rather
than an `event.id` dedup table. Per handler:

| Handler | Mechanism | Verdict |
| --- | --- | --- |
| `account.updated` | `updateMany` to a boolean (handler:475-487) | ✅ naturally idempotent |
| `charge.dispute.*` | lookup by unique `stripeDisputeId`, update-or-create; never overrides admin resolution (handler:350-381) | ✅ |
| `applySubscriptionState` | unconditional `update` from Stripe's object (handler:146-153) | ✅ converges |
| `payment_intent.payment_failed` | re-reads inside `$transaction`, re-checks `status === Pending`, guards restock with `inventoryRestored` (handler:278-319) | ✅ good — this is the pattern |
| **`payment_intent.succeeded`** | **read status → check `!== Pending` → `update`. NOT atomic, NOT in a transaction** (handler:218-243) | ❌ **race** |

> **`handlePaymentIntentSucceeded` is a check-then-act race.** Two concurrent
> deliveries of the same event (Stripe retries overlapping a slow first
> attempt) can both read `PENDING`, both write `CONFIRMED`, and both call
> `notifications.notifyOrderPaid(order.sellerId, order.id)` (handler:243) —
> **double-notifying the seller.** The comment at handler:239-242 claims the
> `PENDING` check guarantees "exactly once"; it does not, because the check and
> the write are separate statements against a live DB.
>
> The fix pattern already exists in the same file: the failure path wraps in
> `$transaction` + re-reads; and `orders.service.ts:2561` uses
> `updateMany` + `if (updated === 0)` to make the transition atomic. Applying
> `updateMany({ where: { id, status: Pending } })` and notifying only when
> `count === 1` closes it.

Classify `code-contract`.

### 5.3 Observability — ❌ the weakest area

- **The channel is never identified.** `Stripe.Event.account` (set on
  connected-account events, absent on platform events) is **never read**
  anywhere in the handler or controller. On signature failure the log is:
  ```ts
  // stripe-webhook.controller.ts:56
  this.logger.warn(`Stripe signature verification failed: ${(err as Error).message}`);
  ```
  No `event.id`, no `event.type` (unavailable — verification failed), **no
  indication whether the platform or connected-account channel failed.** The
  ticket explicitly requires "logs identify which event channel failed". **Not
  met.**
- **Failures are unretryable by design.** 400 on bad signature
  (controller:54-58) tells Stripe "never retry". Correct for a genuinely
  forged request; **catastrophic for a secret mismatch**, because a
  configuration error becomes permanent silent data loss rather than a
  retry-until-fixed backlog.
- **Successful events log nothing at info level.** Only disputes log
  (`[Chargeback] received…`, handler:381). A successful
  `payment_intent.succeeded` or `account.updated` leaves **no trace**, so
  "prove the event reached the deployment" is currently unanswerable from logs.
- **Unhandled events are `.debug`** (handler:85) — invisible in production log
  levels (`pino-logger.service.ts:4` treats non-production as dev). An
  in-scope-but-unhandled event (e.g. `charge.refunded`) is indistinguishable
  from silence.
- **No delivery alerting** was found for webhook failure.

Classify `observability`.

---

## 6. Dev bypass `_secret_devbypass` — verdict: **NOT reachable in the deployment**

Grep across `src`, `scripts`, `prisma` found exactly one production-code site:

```ts
// src/modules/orders/orders.service.ts:357-376
} catch (err) {
  if (process.env.NODE_ENV === 'development') {
    pi = { id: `pi_dev_${orderId}`, client_secret: `pi_dev_${orderId}_secret_devbypass` };
  } else {
    this.logger.error(`Stripe PaymentIntent creation failed for order ${orderId}: …`);
    throw new ServiceUnavailableException('Payment provider unavailable');
  }
}
```

Reachability analysis — it requires **both**:
1. a thrown error from `paymentIntents.create`, **and**
2. `process.env.NODE_ENV === 'development'`.

Deployed reality:
- `incacook-api` → `NODE_ENV=production` ✅ (verified on the running service)
- `incacook-worker` → `NODE_ENV=production` ✅
- `env.validation.ts:7` constrains `NODE_ENV` to
  `development|test|staging|production`, so it cannot be spoofed to an
  arbitrary string — but note it **defaults to `development`** if unset.

**Verdict: unavailable in the verified environment.** In `production` the else
branch throws `503 Payment provider unavailable` — a real PaymentIntent is
mandatory, and the bypass cannot substitute for one.

The companion gate is also **fail-closed**, which is the reassuring part:

```ts
// src/modules/orders/orders.service.ts:463-466
private async isPaymentSucceeded(paymentIntentId: string | null): Promise<boolean> {
  if (!paymentIntentId || paymentIntentId.startsWith('pi_dev_')) {
    return process.env.NODE_ENV === 'development';   // → false in production
  }
```

So even if a `pi_dev_*` order were somehow seeded into the production database,
it would evaluate as **not paid** in production. Two further
`NODE_ENV === 'development'` gates exist at `orders.service.ts:2502,2561` and
driver-KYC gates at `deliveries.service.ts:139-143,573`; all are the same
fail-closed shape.

**Residual risk (low, worth closing):** the safety of the entire bypass family
rests on a single un-asserted env var that **defaults to `development`**. If
`NODE_ENV` were ever dropped from Railway, the service would boot into
`development` and silently enable payment bypass **plus** driver-KYC bypass —
with no boot-time alarm. `env.validation.ts` should assert
`NODE_ENV === 'production' ⇒ NODE_ENV explicitly set` and, better,
`sk_live_ ⇔ production`. Classify `code-contract` (defence in depth) — **not**
an active vulnerability.

---

## 7. Public callback bridge

Live probes (2026-07-15, GET only):

| Endpoint | Result |
| --- | --- |
| `GET /v1/stripe/return` | **HTTP/2 200**, `text/html`, HSTS `max-age=31536000` |
| `GET /v1/stripe/refresh` | **HTTP/2 200**, `text/html` |
| `GET /v1/health` | **HTTP/2 200** |
| `POST /v1/stripe/webhook` (unsigned) | **HTTP 400** ✅ rejects |

Both configured Account-Link URLs are HTTPS-reachable, return `200` directly
(no redirect chain), and match `STRIPE_ONBOARDING_RETURN_URL` /
`_REFRESH_URL` exactly. The served HTML bounces to `incacook://stripe/return`
(`stripe-return.controller.ts:36-58`).

### ⚠️ Finding: helmet's CSP silently kills the bridge's JS redirect

The served response carries (verified live):

```
content-security-policy: default-src 'self'; …; script-src 'self'; script-src-attr 'none'; …
```

The bridge page's redirect is an **inline** `<script>`:

```html
<!-- stripe-return.controller.ts:55 -->
<script>window.location.replace("incacook://stripe/return");</script>
```

`script-src 'self'` with **no nonce and no hash blocks inline scripts**. This
script **never executes** in any CSP-respecting browser. Helmet is applied
globally at `main.ts:38` and the controller does not exempt these two routes.

That leaves two fallbacks:
1. `<meta http-equiv="refresh" content="0; url=incacook://stripe/return">`
   (controller:43) — **CSP does not block meta-refresh, but many mobile
   browsers refuse to auto-navigate a meta-refresh to a non-HTTP custom
   scheme without a user gesture.** Unreliable, and unverifiable from curl.
2. The manual "Revenir à IncaCook" `<a href>` (controller:54) — requires the
   user to tap. This is the only *dependable* path today.

**Net:** the auto-return is likely degraded to "user must tap a button", on
both platforms. Classify `code-contract` (add a CSP nonce/hash or a per-route
helmet exemption, and prefer a top-level `<a>`-driven or 302 handoff).

### App-scheme handoff behaviour

| Scenario | Behaviour | Source |
| --- | --- | --- |
| App **installed + backgrounded** | ✅ `incacook://stripe/*` wakes it; also a resume-observer completes the wait even if the deep link is lost | `payout_onboarding_service.dart:105-130` |
| App **installed + killed** | ⚠️ `_awaitReturn`'s `uriLinkStream` listener is registered in-process — if the OS killed the app the listener is gone. Cold-start deep-link handling is not evidenced in this flow. | `payout_onboarding_service.dart:107,112-118` |
| App **not installed / scheme unhandled** | ❌ browser shows an unresolvable-scheme error; the bridge page has **no HTTPS fallback** and no store link | `stripe-return.controller.ts:36-58` |
| **Return vs refresh** | ⚠️ Not distinguished — the listener matches `host == 'stripe'` only, so `refresh` (user abandoned/link expired) is treated identically to `return` (success) | `payout_onboarding_service.dart:113-116` |
| Timeout | ✅ 5-min cap, cannot hang forever | `payout_onboarding_service.dart:122-125` |

**Mitigation that saves this flow:** the app does not trust the callback at
all — on resume it polls `GET /v1/stripe/onboarding/status` up to 6 times,
which calls `accounts.retrieve` and persists state
(`onboarding.service.ts:114-156`;
`payout_onboarding_service.dart:139-144`). This is genuinely good design and
is why onboarding likely works today **despite** the CSP bug and **despite** a
possibly-dead `account.updated` channel. It is also precisely what makes those
two defects invisible.

---

## 8. Build-reproducibility finding

`.vscode/dart_defines.json` is **git-ignored** (`.gitignore:27`; `git ls-files
.vscode/` returns only `launch.json`). Every Android/iOS artifact is therefore
built from an **untracked file that exists only on one developer's laptop**,
and `melos.yaml:9,13,21,25` hard-codes that path for all release builds.

Consequences:
- The "deployed Android and iOS artifact" the ticket asks me to pin down
  **cannot be reconstructed or audited from the repo**. My matrix reflects the
  file on *this* machine, not provably what shipped.
- There are **no flavors/schemes**, so there is no mechanism to build a
  test-mode and a live-mode artifact differently — the go-live key swap is a
  manual edit of an untracked file.
- No CI build config was found that supplies these defines.

Classify `configuration` + `operator-runbook`.

---

## 9. Gap list

### configuration

| # | Gap | Impact |
| --- | --- | --- |
| C-1 | Environment named `production` runs `sk_test_`/`pk_test_` | No live money path exists or has ever been exercised; go-live cutover untested. **Scope expanded (DEC-7, 2026-07-18)**: the account behind these keys (`acct_1TdvHCBSdl9ByXxu`) is an unverified placeholder (`business_profile.name: "environnement de test INCACOOK"`, no url/mcc/support fields, personal email) — owner confirmed no separate real account exists. Cutover therefore requires completing Stripe business verification first, not just swapping key prefixes |
| C-2 | ~~`STRIPE_SELLER_SUBSCRIPTION_PRICE_ID` unset on Railway~~ **CLOSED, deleted not configured (DEC-8, 2026-07-18)** | Investigation found the Stripe checkout path had zero live callers (mobile UI was dead code too) and RevenueCat was already the real subscription mechanism (finding 03 C7). Rather than configure a price for a path nothing reaches, the whole Stripe subscription module (`SubscriptionsController`/`Service`/`Module`) was removed |
| C-3 | ~~`STRIPE_SUBSCRIPTION_SUCCESS_URL` / `_CANCEL_URL` / `STRIPE_PORTAL_RETURN_URL` unset~~ **CLOSED, deleted not configured (DEC-8)** | Same removal as C-2 — these URLs are no longer read anywhere |
| C-4 | ~~`STRIPE_CONNECT_ACCOUNT_COUNTRY` unset → implicit `'FR'`~~ **CLOSED, moot (2026-07-18)** | Confirmed via O-1/O-5: the platform account is `US`-registered but successfully created a real `country: 'FR'` Express account (O-6's "Lyon" onboarding) — no incompatibility exists, no override needed |
| C-5 | `.env` onboarding URLs point at stale host (no `-146b`) | Local dev mints Account Links returning to the wrong/nonexistent backend |
| C-6 | One `whsec_` shared across dev laptop + Railway mirror + production | No webhook trust isolation; prod signing secret sits on developer machines |
| C-7 | `incacook-worker` holds `STRIPE_WEBHOOK_SECRET` it cannot use | Needless secret surface |
| C-8 | `ALLOWED_ORIGINS=*` in `production` | CORS reflects any origin with `credentials: true` (`main.ts:47-54`) — out of ticket scope but adjacent and worth flagging |
| C-9 | ~~`.vscode/dart_defines.json` untracked; no flavors; no CI define source~~ **PARTIALLY CLOSED (2026-07-18)** | Audit-trail half fixed: tracked `.vscode/dart_defines.example.json` (schema verified against every `fromEnvironment` call site) + `.github/workflows/ci.yml` (analyze+test, no secrets needed) — app PR #32, merged to `dev`. **Still open**: build flavors (dev/prod side-by-side installs) — owner deferred, bigger change touching Android Gradle + iOS Xcode project files and Firebase/Google Sign-In config tied to the package name. New adjacent findings surfaced, not yet actioned: `docs/requirements/accounts-and-credentials.md`'s dart-define table is stale (still lists `MAPBOX_PUBLIC_TOKEN`, which code no longer reads — Mapbox→Google Maps migration never updated it) and `dart format` finds ~177 pre-existing files repo-wide with formatting drift (too large to fold into this slice; `dart format --set-exit-if-changed` deliberately left out of the new CI for now) |

### code-contract

| # | Gap | Impact |
| --- | --- | --- |
| K-1 | `handlePaymentIntentSucceeded` check-then-act race (handler:218-243) | Duplicate seller notification on concurrent redelivery; comment claims a guarantee the code doesn't provide |
| K-2 | Single-secret verification with **no multi-secret support** (`stripe-webhook.service.ts:21`) | Backend architecturally **cannot** serve a two-endpoint Stripe topology; if the operator split endpoints, one channel is permanently dead |
| K-3 | Signature failure → **400, no retry** (controller:54-58) | Turns a fixable config error into irreversible event loss |
| K-4 | No handler for `charge.refunded` / `refund.*` | Ticket names refunds as in-scope; events hit the `default` `.debug` sink |
| K-5 | ~~No handler for `transfer.*`~~ **`transfer.reversed` handled (2026-07-18, server PR #16, issue #7)** — books a `SELLER_DEBT`/`DRIVER_DEBT` clawback, correctly delta-tracked against Stripe's cumulative `amount_reversed`. `payout.*` / `account.application.deauthorized` still unhandled — different risk profile (connected account's own bank deposit failing; no platform money lost), needs its own design |
| K-6 | Helmet CSP `script-src 'self'` blocks the bridge's inline redirect (`main.ts:38` vs `stripe-return.controller.ts:55`) | Auto-return degraded to manual tap on both platforms |
| K-7 | Bridge has no HTTPS fallback when the app is absent | Dead-end page |
| K-8 | Deep link doesn't distinguish `return` vs `refresh` (`payout_onboarding_service.dart:113-116`) | Abandoned/expired onboarding treated as success |
| K-9 | ~~`NODE_ENV` defaults to `development`~~... **no `live-key ⇔ production` assertion — CLOSED (2026-07-18, server PR #16)**. `validateEnv` now throws if `NODE_ENV=production` and `STRIPE_SECRET_KEY` starts with `sk_test_` | Was: a dropped var silently re-enables payment + KYC bypass with no alarm. Prep for C-1, not C-1 itself — still needs a real live key to exist first (DEC-7) |

### observability

| # | Gap | Impact |
| --- | --- | --- |
| O-1 | Signature-failure log omits `event.id` and **the channel** (controller:56) | Ticket requirement "logs identify which channel failed" **not met**; a dead Connect channel is undiagnosable |
| O-2 | `event.account` never read anywhere | Cannot distinguish platform vs connected-account events even on success |
| O-3 | No info-level log on successful webhook processing | Cannot evidence "event reached the deployment" — the ticket's test boundary is currently unprovable from logs |
| O-4 | Unhandled in-scope events logged at `.debug` (handler:85) | Silent gaps |
| O-5 | No webhook delivery alerting | Prolonged outage would be invisible (masked further by the status-polling backstop) |

### operator-runbook

| # | Gap |
| --- | --- |
| R-1 | Webhook endpoint topology undocumented — no record of how many endpoints exist or whether Connect events are enabled |
| R-2 | No documented test-mode → live-mode cutover procedure (keys, endpoints, price id, URLs, artifact rebuild) |
| R-3 | No documented Stripe platform account owner / country / Connect capability state |
| R-4 | No reproducible build recipe for the artifact config file (§8) |

---

## 10. OPERATOR CHECKLIST — requires Stripe Dashboard access

No `stripe` CLI and no dashboard access here, so everything below is manual.
Perform in **test mode** on the Stripe account whose key-account digest is
`804808a5` (confirm via O-1). Record evidence in the ticket **redacted** —
IDs, names, timestamps, HTTP codes only; **never** paste a `whsec_`/`sk_`.

### O-1 — Confirm platform account identity (5 min)

**RESOLVED 2026-07-18** — answered directly via `stripe.account.retrieve()`
against the platform key (no dashboard needed; the API is authoritative for
the same data). Account ID `acct_1TdvHCBSdl9ByXxu` (prefix matches the app's
`pk_test_51TdvHC…`, confirming key/account alignment), **country `US`**,
owner email a personal `@yahoo.fr` address, `business_profile.name` the
placeholder `"environnement de test INCACOOK"` with `url`/`mcc`/`support_*`
all unset. Owner confirmed live: **this is the only Stripe account in use
anywhere (local, Railway `dev`, and Railway's `production`-named env) — no
separate real business account exists yet.** See DEC-7 in `map.md`. **PASS**
on identity confirmation; **surfaces a bigger gap** than expected — folded
into C-1 (go-live now requires actual business verification, not just a key
swap).

### O-2 — Enumerate webhook endpoints ← **THE decisive check**

1. Developers → **Webhooks**.
2. **Count the endpoints** whose URL contains `incacook-api-production-146b`.
   Record every endpoint's **ID (`we_…`)**, URL, and its listen mode.
3. For each, open it and record whether it says **"Events on your account"** or
   **"Events on connected accounts"** (or a "Listen to events on Connected
   accounts" toggle).
- **PASS:** exactly **one** endpoint at
  `https://incacook-api-production-146b.up.railway.app/v1/stripe/webhook`,
  **with connected-account events ENABLED**.
- **FAIL (two endpoints):** the backend holds one secret → one channel is
  permanently 400ing. Do **not** "fix" by picking a secret; escalate — this
  needs gap **K-2** (multi-secret support) or an endpoint consolidation.
- **FAIL (one endpoint, connected-account events OFF):** `account.updated`
  never arrives; onboarding relies entirely on the polling backstop.

### O-3 — Verify the subscribed event list

On the endpoint from O-2, record the **exact enabled event names**. Compare to
the handled set (§4). Required present:
`account.updated`, `payment_intent.succeeded`, `payment_intent.payment_failed`,
`payment_intent.canceled`, `charge.dispute.created`, `charge.dispute.updated`,
`charge.dispute.closed`, `checkout.session.completed`,
`customer.subscription.created`, `customer.subscription.updated`,
`customer.subscription.deleted`, `invoice.payment_failed`.
- **PASS:** all twelve enabled.
- Note separately any event enabled in Stripe but **not** in the handler's
  `switch` — each is a silent `.debug` drop.

### O-4 — Confirm the signing secret matches (without disclosing it)

On the O-2 endpoint, reveal the signing secret and compute **locally**:
```
printf %s '<paste secret>' | shasum -a 256 | cut -c1-8
```
- **PASS:** the digest equals **`bff78edb`** (the value currently loaded by the
  running deployment). Record only the 8-char digest and PASS/FAIL.
- **FAIL:** the deployment cannot verify that endpoint at all → every event is
  400ing today.
- If O-2 found two endpoints, run this for **both** and report both digests —
  at most one can match, which *proves* the dead channel.

### O-5 — Confirm Connect is activated and the country is compatible

**RESOLVED 2026-07-18 — PASS, empirically, stronger than the dashboard check
would have given.** No need to inspect Connect settings in the abstract: the
real "Lyon" seller onboarding from O-6 already **created a live `country:
'FR'` Express account and completed onboarding to `payouts_enabled`** under
this `US`-country platform account. That's proof by successful execution,
not just a theoretical "country list" read. **C-4 is closed as moot** — the
feared incompatibility (`stripe.config.ts`'s comment that "a US test
platform can only create US connected accounts") does not hold for this
account; `STRIPE_CONNECT_ACCOUNT_COUNTRY` does not need setting.

### O-6 — Prove a connected-account `account.updated` reaches the deployment

1. Trigger real Express onboarding from a **seller** account on an app build
   from §1 (test mode → use Stripe's test onboarding values).
2. Complete the hosted form to the point `payouts_enabled` flips true.
3. Dashboard → Webhooks → the O-2 endpoint → **Events / attempts** tab.
4. Locate the `account.updated` delivery. Record: **event ID `evt_…`**,
   **the `account` field (`acct_…`) — its presence proves the connected-account
   channel**, timestamp, and **HTTP response code**.
- **PASS:** HTTP **200**, and `SellerProfile.stripeOnboardingCompleted` is
  `true` in the DB.
- ⚠️ **Do not accept the app's UI showing "payouts enabled" as proof** — the
  polling backstop (`onboarding.service.ts:114-156`) sets that flag *without*
  the webhook. **Only the dashboard's 200 delivery record proves the channel.**
  This is the trap that would let a broken topology pass a manual test.
5. **Idempotency:** hit **"Resend"** on that same event. Record the second
   delivery ID + code. **PASS:** 200 again, DB state unchanged.

### O-7 — Prove platform-account events reach the deployment

For each, capture **event ID**, **HTTP code**, and the resulting DB/API state:

| Event | How to trigger | PASS state |
| --- | --- | --- |
| `payment_intent.succeeded` | place a real test order, pay with `4242 4242 4242 4242` | 200; `Order.status = CONFIRMED`, `confirmedAt` set; seller notified **once** |
| `payment_intent.payment_failed` | pay with `4000 0000 0000 0002` (declined) | 200; `Order.status = CANCELLED`, `inventoryRestored = true`, `portionsLeft` restored |
| `charge.dispute.created` | pay with `4000 0000 0000 0259`, then dispute | 200; `OrderDispute` row, `type=CHARGEBACK`, `status=ADMIN_REVIEW`; log `[Chargeback] received orderId=… stripeDisputeId=…` |
| **refund** | refund a succeeded PI from the dashboard | ⚠️ **expected to be a no-op** — no handler (gap K-4). Record the event name Stripe actually sends and the (absent) DB effect. **This documents the gap; it is not a PASS.** |
| subscription events | **MOOT (DEC-8, 2026-07-18)** — `checkout.session.completed`/`customer.subscription.*`/`invoice.payment_failed` handlers were removed; RevenueCat is sole source of truth for seller subscription entitlement (C-2/C-3 closed) | N/A — nothing to verify here anymore |

For each: **resend once** and confirm the DB state does not change (idempotency).
For `payment_intent.succeeded` specifically, confirm the seller received
**exactly one** notification — a duplicate would confirm race **K-1**.

### O-8 — Idempotency race probe (optional, confirms K-1)

Resend `payment_intent.succeeded` **twice in rapid succession** (two resends
within ~1s) on a **fresh PENDING** order. **PASS:** one CONFIRMED transition,
one seller notification. **FAIL (expected):** two notifications → K-1 confirmed.

### O-9 — Real-device callback verification (needs devices, not the dashboard)

For **one Android** and **one iOS** build from §1:
1. Start payout onboarding; confirm the browser lands on
   `…/v1/stripe/return` over HTTPS on a **real mobile network** (not just wifi).
2. Record whether the return to the app is **automatic** or requires tapping
   **"Revenir à IncaCook"** — per K-6 the inline-script redirect is
   CSP-blocked, so **expect manual**. Record per-platform.
3. Confirm the app lands back in the **same build/environment** that started
   onboarding, and that payout status reconciles.
4. Repeat via the **refresh** path (let the Account Link expire, or hit
   `…/v1/stripe/refresh` directly). Note per K-8 the app cannot distinguish it.
5. Test **app killed** mid-onboarding (swipe it away, then tap return).
- **PASS:** both platforms return to the correct build and payout status
  reconciles, in all three states.

---

## 11. Unknowns / could not verify

1. **The webhook endpoint topology — one endpoint or two.** The single most
   important open question (§4). Determines whether `account.updated` works at
   all. Needs O-2. Everything else in this report is secondary to it.
2. **Whether the deployed signing secret matches any live endpoint.** Digest
   `bff78edb` is loaded by the deployment; nothing proves an endpoint in Stripe
   shares it. Needs O-4.
3. **Whether any Stripe event has *ever* been successfully processed.** Logs in
   the retained window contain **zero** Stripe/webhook lines. Combined with O-3
   (no success logging exists at all), this is unfalsifiable from here — the
   absence may reflect no traffic, a short retention window, or a dead channel.
4. **The "events on connected accounts" setting.** Dashboard-only. O-2.
5. ~~The Stripe platform account's country / Connect activation / Express
   capability.~~ **RESOLVED (2026-07-18)** — `US`, Express active, `FR`
   accounts creatable; see O-1/O-5/DEC-7. New unknown surfaced instead: this
   account is an unverified placeholder, not a real registered business —
   folded into C-1.
6. **Which commit is actually deployed.** Local `IncaCook-Server` HEAD is
   `deb19c52`, but no build/commit SHA was surfaced from the Railway
   deployment; all code findings assume local HEAD ≈ deployed.
7. **What config the *shipped* Android/iOS artifacts were built with.**
   `.vscode/dart_defines.json` is untracked (§8) — my matrix describes this
   machine's file. If any artifact was built elsewhere, its API URL and
   publishable key are **unknown**.
8. **Whether the meta-refresh fallback actually fires** on real iOS Safari /
   Android Chrome for a custom scheme (K-6). Not determinable via curl —
   needs O-9 on real devices.
9. **Cold-start deep-link handling** when the app was killed during onboarding
   (`payout_onboarding_service.dart:105-130` registers an in-process listener).
   Needs O-9 step 5.
10. **`incacook-admin` was not examined** — the ticket's matrix covers mobile
    artifacts and the Railway deployment only. Admin-side Stripe config, if
    any, is out of scope here.
11. **`RAILWAY_ENVIRONMENT=production` is the only environment.** No
    staging/preview environment was found, so there is no pre-production place
    to rehearse the live-key cutover (C-1). Not verified whether one is
    intended.
