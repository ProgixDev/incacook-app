# IncaCook — End-to-End QA Master Checklist (Mobile + Admin Dashboard)

The single entry point for a full A-to-Z manual QA pass across **both**
apps — the Flutter mobile app (buyer/seller/driver) and the
`incacook-admin` Next.js dashboard — ending with the payment/subscription/
order money-flow verification. Use this doc to navigate; the detailed
checklists live in the companion docs below so this one stays a map, not a
1,500-line wall of text.

Last written: 2026-07-26.

## How the QA docs fit together

| Doc | Covers |
|---|---|
| **This file** | Setup, accounts, order of operations, links everything else |
| [comprehensive-qa-guide.md](comprehensive-qa-guide.md) | Mobile app — seeded accounts, cross-role happy-path scenarios (buyer→seller→driver chain), device rig |
| [full-user-journey-testing.md](full-user-journey-testing.md) | Mobile app — the signup/onboarding wizard itself, per role (only needed if testing signup; the seeded accounts skip it) |
| [driver-zones-testing.md](driver-zones-testing.md) | Driver zone system internals |
| [revenuecat-testing.md](revenuecat-testing.md) + [revenuecat-android-setup.md](revenuecat-android-setup.md) | Subscription purchase mechanics (App Store/Play sandbox) |
| [supabase-firebase-apple-auth-reset.md](supabase-firebase-apple-auth-reset.md) | Auth/push provider config, QA DB reset |
| **[admin-dashboard-testing.md](admin-dashboard-testing.md)** *(new)* | Every admin dashboard page/action, route by route |
| **[payments-orders-subscriptions-deep-dive.md](payments-orders-subscriptions-deep-dive.md)** *(new)* | Cross-app money-flow scenarios: orders, payments, refunds, disputes, wallets, subscriptions — the part you specifically asked to verify manually through to real payments/subscriptions/orders |
| [../issues/payments-subscription-issues.md](../issues/payments-subscription-issues.md) | Living known-issues register — check before filing something as new |

**Suggested order for a full pass:**
1. §1–2 below (accounts/environment) once.
2. Mobile per-screen checklist (§3) — click through everything once, cold,
   noting anything broken before you know "the plan."
3. [admin-dashboard-testing.md](admin-dashboard-testing.md) — same, for the
   dashboard.
4. [comprehensive-qa-guide.md](comprehensive-qa-guide.md) Scenarios 1–4 — the
   cross-role happy path end to end, so you've proven the basic chain works.
5. [payments-orders-subscriptions-deep-dive.md](payments-orders-subscriptions-deep-dive.md)
   — the deep money-flow scenarios (C1–C10 orders/payments/wallets, plus
   subscriptions and catalog). Do this last — it deliberately provokes
   failure/edge paths (declines, disputes, no-driver, debt) that you don't
   want polluting your first clean look at the happy path.

## 1. Accounts you'll need

### Mobile (pre-seeded, hosted DB, no onboarding needed)

| Email | Password | Role | Setup |
|-------|----------|------|-------|
| `qa+seller-paris@incacook.fr` | `Seller123!` | Seller | Chez Pierre - Paris 11e · 4 dishes · Premium |
| `qa+seller-lyon@incacook.fr` | `Seller123!` | Seller | Bouchon Lyonnais · 3 dishes |
| `qa+driver-paris@incacook.fr` | `Driver123!` | Driver | Bicycle · zone: Paris 11e |
| `qa+driver-national@incacook.fr` | `Driver123!` | Driver | Car · zones: Paris ×3, Lyon, Marseille |
| `qa+buyer-paris@incacook.fr` | `Buyer123!` | Buyer | Delivery address: Paris 11e |
| `qa+buyer-lyon@incacook.fr` | `Buyer123!` | Buyer | Delivery address: Lyon Centre |

Full detail, re-seeding instructions and dish list in
[comprehensive-qa-guide.md](comprehensive-qa-guide.md) / [qa-accounts-seed.sql](qa-accounts-seed.sql).

You'll want at least one **fresh, un-subscribed seller account** too (not one
of the two above, since both already have an active subscription) for the
subscription-purchase scenarios in the deep-dive doc — either sign one up
through the real wizard ([full-user-journey-testing.md](full-user-journey-testing.md))
or ask engineering to reset one seeded account's subscription status to NONE.

### Admin dashboard

- Log in with your existing ADMIN-role account
  (`libertadhif+claudeadmin2@gmail.com` — this was the account fixed on
  2026-07-26; get the current password from whoever last ran
  `scripts/create-admin.ts`, or re-run it yourself to mint a new one).
- If you need a MODERATOR-role account to verify role parity, ask
  engineering — there's no self-serve way to create one from the dashboard
  itself.

### Payments / subscriptions

- Stripe **test mode** cards and RevenueCat **sandbox** — see
  [payments-orders-subscriptions-deep-dive.md §0–1](payments-orders-subscriptions-deep-dive.md)
  for the exact card numbers and constants you'll be checking arithmetic
  against.

## 2. Device rig

| Device | Role | Why |
|---|---|---|
| Android physical | Driver | QR scanning needs a real camera |
| Android physical | Seller | real subscription purchase/RevenueCat |
| iOS Simulator | Buyer | no camera/purchase needed |
| Any browser | Admin | dashboard is a standard web app |

Minimum: 1 Android + 1 iOS Sim + 1 browser tab, switching mobile roles by
sign-out/in. Ideal: 2 Android + 1 iOS Sim + 1 browser so you see real-time
cross-role pushes while also watching the admin side update.

## 3. Mobile app — per-screen checklist

This is the "click through everything once" pass, organized by role. For
the deeper cross-role order-lifecycle scenarios, use
[comprehensive-qa-guide.md](comprehensive-qa-guide.md) instead — this section
is about each individual screen in isolation.

### 3.1 Auth & onboarding (shared)

- ☐ Welcome screen: Google sign-in (native), "S'inscrire par e-mail", "Se
  connecter". Facebook is currently feature-flagged **hidden** — don't
  expect to see it; that's intentional, not a bug.
- ☐ Login: email/password; biometric unlock pill only appears if a
  previously-stored session + prior opt-in exist.
- ☐ Signup wizard end to end for **each** role at least once (full step list
  in [full-user-journey-testing.md](full-user-journey-testing.md)) — kill
  the app mid-wizard and relaunch, confirm it resumes at the exact same
  step rather than restarting or skipping ahead.
- ☐ Phone verification step is currently **feature-flagged off**
  (`skipPhoneVerification=true`) — phone is saved unverified and no OTP
  screen appears. Not a bug; flag to engineering only if you're told this
  flag should be on for your test build.
- ☐ Legal acceptance: CGU/CGV checkbox required to proceed; "Lire les
  CGU/CGV" opens the live-fetched legal text (confirm it matches whatever's
  currently published in the admin dashboard's `/legal`).
- ☐ Seller-specific: SIRET format validation, weekly opening-hours editor
  (toggle a day on → defaults to 09:00–22:00), KYC ID + selfie upload.
- ☐ Driver-specific: vehicle type picker, KYC ID + selfie + driving
  license + carte grise photos, multi-zone picker (searchable, chips),
  optional Stripe Connect payout setup (skippable, re-prompted later).

### 3.2 Buyer

- ☐ Home feed: category chips, search, location-based sort; deny location
  permission once and confirm a sane fallback (not a crash/blank screen).
- ☐ Listing detail: add-ons customize sheet, add-to-cart animation,
  "Signaler" report sheet (fait-maison listings only), reviews section.
- ☐ Adding a second seller's item while cart is non-empty → "clear cart?"
  dialog (single-seller-cart rule).
- ☐ Cart: increment/decrement/remove, an "unavailable" item blocks
  Continue.
- ☐ Fulfillment choice (pickup vs delivery, ASAP vs scheduled) — pickup only
  offered if the seller supports it.
- ☐ Checkout summary: price breakdown matches §0 of the deep-dive doc
  exactly (subtotal + delivery fee + 5% platform fee).
- ☐ Payment: card-entry sheet, CGU/CGV checkbox gates Pay button, cancel
  returns cleanly to summary.
- ☐ Order tracking: live stage updates, pickup/delivery QR display, "no
  driver available" card offers switch-to-pickup / cancel, chat + call
  driver buttons.
- ☐ Order history: "Noter" (delivered orders only) → review sheet; "Signaler
  un problème" → dispute screen.
- ☐ Review sheet: overall stars + comment required; hygiene binary; food
  quality + packaging stars; submitting twice on the same order is
  rejected.
- ☐ Notifications inbox: mark-read on tap, "Tout lire", infinite scroll, tap
  routes to the right screen per notification type.
- ☐ Settings: profile edit, dietary/allergen preferences, saved addresses,
  Apparence (theme — System/Light/Dark, persists across restart), "Obtenir
  de l'aide" mailto, sign out.

### 3.3 Seller

- ☐ Subscription paywall shows whenever the subscription isn't active
  (never subscribed / lapsed / cancelled) on Accueil, Commandes, and Mes
  plats specifically — Messages and Profil stay accessible regardless.
- ☐ Home dashboard: payout-setup banner if Stripe Connect incomplete,
  subscription card (status/renewal), supply-catalog shortcut, today
  snapshot, order-request carousel.
- ☐ Order requests: tab structure (À accepter/En cours/Historique), accept
  → start preparing → mark ready, pickup QR display for delivery orders,
  "Je ne peux pas fournir" cancel path, contact-driver chat.
- ☐ Dish CRUD (`AddProductSheet`): photo grid, price cap enforcement at
  €4.50 for fait-maison sellers (**no cap** for Traiteur/Restaurant —
  confirm the cap genuinely doesn't apply to those categories, don't
  mistake that for a bug), allergens required ("Autres" reveals free text,
  "Aucun" clears all other selections), availability time window, CGU/CGV
  consent shown only on **new** dishes (not when editing an existing one).
- ☐ Supply catalog: browse, buy, order history — see the deep-dive doc §9
  for the money-flow specifics.
- ☐ Wallet: available/pending/held/paid-out balances, withdrawal button
  disabled below €50 or with outstanding debt.
- ☐ Settings → "Paiement" tile opens the Stripe Express dashboard, but only
  once payout onboarding is complete (disabled/greyed until then).

### 3.4 Driver

- ☐ Full-screen map home: pickup/dropoff/driver markers + route polyline,
  center/fit-route buttons.
- ☐ Go online/offline toggle; app relaunch restores online status + any
  active job.
- ☐ Incoming order modal: Accepter gated on **KYC completion only** — Stripe
  payout completion is **not** required to claim a job, only to later cash
  out. Confirm a driver with approved KYC but no Stripe Connect can still
  accept deliveries.
- ☐ Stage progression: scan seller's pickup QR → onTheWay; scan buyer's
  delivery QR → delivered. Try scanning an invalid/duplicate QR and confirm
  a clear error rather than a silent failure.
- ☐ Seller-absent-at-pickup and buyer-absent-at-dropoff each show their own
  distinct failure screen, not a generic error.
- ☐ Issue report sheet from the active-job view.
- ☐ Today stats card, wallet (same screen as seller — same checks apply),
  Stripe Connect payout onboarding banner until complete.

### 3.5 Cross-cutting (all roles)

- ☐ Theme toggle (System/Light/Dark) persists across app restart and
  applies immediately without a manual refresh.
- ☐ Push notifications: foreground messages self-display (FCM alone
  wouldn't show a tray notification while foregrounded); background/killed
  delivery still lands; tapping each notification type routes correctly
  (`order_*`/`delivery_*` → order tracking or the Commandes tab depending on
  role; `wallet_funds_available` → Wallet).
- ☐ Legal terms (CGU/CGV) viewer and its "read + accept" checkbox
  (`TermsConsentTile`) are shared between checkout and new-dish publish —
  testing it once at checkout is a reasonable proxy for both, but do check
  the new-dish path at least once too since it's a distinct entry point.
- ☐ Chat/messaging: buyer↔seller, seller↔driver, buyer↔driver conversations
  are scoped correctly per order — confirm you can't see a conversation tied
  to someone else's order.

### 3.6 Known gaps worth extra manual attention

These areas have **no automated test coverage at all** today (per a full
`test/` audit) — treat them as higher-risk and look harder:

- The entire signup wizard UI (only the resulting onboarding-completeness
  logic is unit-tested, not the screens).
- Checkout payment UI itself (Stripe PaymentSheet / card-entry sheet /
  failure-retry UI) — only the idempotency-key plumbing underneath is
  tested.
- RevenueCat purchase/restore UI and the offering-unavailable banners.
- The dish add/edit sheet's price-cap and allergen-toggle logic.
- The driver QR scan-to-confirm stage transitions.
- Dispute and review submission screens.
- Notifications inbox UI, chat/messaging screens, theme toggle, legal-terms
  screen, report sheet — all manual-only today.
- Social login (Google/Facebook) end-to-end and biometric login/setup —
  inherently hard to automate; this is genuinely device-only testing.

## 4. Admin dashboard

Full route-by-route checklist: **[admin-dashboard-testing.md](admin-dashboard-testing.md)**.
Headline reminder: the dashboard's own e2e suite only checks pages *render*
— every approve/reject/refund/publish/suspend action is currently unverified
by automation, so that's where to spend the most manual time.

## 5. Payments, subscriptions & orders — the deep dive

Full scenario list (order happy paths, declines/3DS, no-driver handling,
seller cancellations, the dispute decision matrix, wallet withdrawals and
debt, subscription purchase/restore/lapse, catalog B2B claims):
**[payments-orders-subscriptions-deep-dive.md](payments-orders-subscriptions-deep-dive.md)**.

This is the section that walks you through actually placing orders, paying
with test cards, purchasing/restoring a subscription, requesting a
withdrawal, and filing disputes/claims — then cross-checking the resulting
numbers in the admin dashboard's order-financials and payouts-reconciliation
views. Do this after the per-screen passes above so you're provoking known
edge cases deliberately rather than tripping over them by accident.

## 6. Known dead states — don't lose time chasing these

Carried up from the deep-dive doc so you see it before you start, not after
you've already spent an hour trying to reproduce something unreachable:

- Order-level `PICKED_UP` and `DISPUTED` statuses are never written by any
  code path today.
- `OrderDispute.status = 'OPEN'` never occurs — every dispute is born
  directly into ADMIN_REVIEW/AUTO_REFUNDED/REJECTED.
- Subscription statuses `UNPAID`/`INCOMPLETE`/`INCOMPLETE_EXPIRED` are
  declared but unused.
- The admin dashboard has no Stripe Connect approval action, no withdrawal
  approve/reject action, and no subscription plan-management action — all
  intentional.
- Driver zones are stored but **not yet used for delivery-job filtering**
  (open dispatch — every online driver sees every job regardless of zone).
  Don't log this as a bug in Scenario 2 of the comprehensive guide.

## Defect log (copy per run)

| # | App | Area | Step | Expected | Actual | Severity | Notes |
|---|-----|------|------|---------|--------|----------|-------|
| 1 | | | | | | | |
| 2 | | | | | | | |

---

**Mobile repo:** `/Users/macbookpro/Documents/Progix/IncaCook` ·
**Admin repo:** `/Users/macbookpro/Documents/Progix/incacook-admin` ·
**Backend repo:** `/Users/macbookpro/Documents/Progix/IncaCook-Server` ·
**API:** `https://incacook-api-production-146b.up.railway.app` ·
**Supabase:** `https://supabase.com/dashboard/project/eoxrrofpdtrwjbhywcvz`
