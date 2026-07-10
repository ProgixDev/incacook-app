# IncaCook — Comprehensive QA Testing Guide

Step-by-step manual test scripts for the buyer ↔ seller ↔ driver chain,
using pre-seeded accounts across two cities (Paris, Lyon).

**Companion docs:**
- [quick-reference.md](quick-reference.md) — one-page cheat sheet
- [full-user-journey-testing.md](full-user-journey-testing.md) — signup/onboarding
  flows (only needed if testing signup itself; the accounts below skip it)
- [driver-zones-testing.md](driver-zones-testing.md) — zone system internals

---

## 1. The accounts (already seeded)

All 6 accounts live in the hosted DB with KYC APPROVED, active subscriptions,
addresses, listings, and driver zones — **no onboarding required**.

| Email | Password | Role | Setup |
|-------|----------|------|-------|
| `qa+seller-paris@incacook.fr` | `Seller123!` | Seller | Chez Pierre - Paris 11e · 4 dishes · Premium |
| `qa+seller-lyon@incacook.fr` | `Seller123!` | Seller | Bouchon Lyonnais · 3 dishes |
| `qa+driver-paris@incacook.fr` | `Driver123!` | Driver | Bicycle · zone: Paris 11e |
| `qa+driver-national@incacook.fr` | `Driver123!` | Driver | Car · zones: Paris ×3, Lyon, Marseille |
| `qa+buyer-paris@incacook.fr` | `Buyer123!` | Buyer | Delivery address: Paris 11e |
| `qa+buyer-lyon@incacook.fr` | `Buyer123!` | Buyer | Delivery address: Lyon Centre |

### Seeded dishes

**Chez Pierre (Paris 11e):** Boeuf Bourguignon €12 · Tarte aux Fruits €6 ·
Blanquette de Veau €13.50 · Végé Bowl €9.50 (vegan)

**Bouchon Lyonnais (Lyon):** Quenelle de Brochet €11.50 · Saucisson Brioché €8 ·
Poulet de Bresse €14

---

## 2. Location coordinates

| Zone | Lat | Lng |
|------|-----|-----|
| Paris 11e | 48.8530 | 2.3799 |
| Paris 1er | 48.8656 | 2.3489 |
| Paris 4e — Le Marais | 48.8566 | 2.3614 |
| Lyon Centre | 45.7640 | 4.8357 |
| Marseille Vieux-Port | 43.2965 | 5.3698 |

**iOS Simulator:** `xcrun simctl location booted set <lat>,<lng>`
**Android:** fake-GPS app + Developer Options → mock location.

---

## 3. Test scenarios

### SCENARIO 1 — Same-zone happy path (the baseline)

Everyone in Paris 11e. Run this first; it proves the whole chain.

| Device | Role | Account | Location |
|--------|------|---------|----------|
| iOS Sim | Buyer | `qa+buyer-paris` | 48.8530, 2.3799 |
| Android | Seller | `qa+seller-paris` | 48.8530, 2.3799 |
| Android | Driver | `qa+driver-paris` | 48.8530, 2.3799 |

1. ☑ Buyer home → "Chez Pierre - Paris 11e" appears in kitchens near you
2. ☑ Buyer adds **Boeuf Bourguignon** → cart → checkout with **delivery**
3. ☑ Buyer pays (Stripe test card `4242 4242 4242 4242`)
4. ☑ Seller "Commandes" → order appears → **Accepter** → **Démarrer la
   préparation** → **Marquer prêt** → pickup QR shows
5. ☑ Driver (online) → incoming order modal → **Accepter**
6. ☑ Driver → "Commande récupérée" → **scans seller pickup QR** → onTheWay
7. ☑ Driver → "Confirmer la livraison" → **scans buyer reception QR** → delivered
8. ☑ Buyer tracking shows live stages + completion popup

**Watch for:** stage desync between the three screens, socket not pushing,
driver marker not moving.

---

### SCENARIO 2 — Inter-city (Lyon self-contained)

Proves a second city works end to end with a wide-coverage driver.

| Device | Role | Account | Location |
|--------|------|---------|----------|
| iOS Sim | Buyer | `qa+buyer-lyon` | 45.7640, 4.8357 |
| Android | Seller | `qa+seller-lyon` | 45.7640, 4.8357 |
| Android | Driver | `qa+driver-national` | 45.7640, 4.8357 |

Same 8 steps as Scenario 1 but with **Quenelle de Brochet** from Bouchon
Lyonnais. Only `driver-national` covers Lyon — `driver-paris` should never
see this order (once zone filtering ships; see §5).

---

### SCENARIO 3 — Discovery / proximity sorting

| Device | Role | Account | Location |
|--------|------|---------|----------|
| iOS Sim | Buyer | `qa+buyer-paris` | Change between Paris & Lyon |

1. ☑ At **Paris 11e** (48.8530, 2.3799) → Chez Pierre appears near top;
   Bouchon Lyonnais is far/hidden by distance filter
2. ☑ Change location to **Lyon** (45.7640, 4.8357) → Bouchon Lyonnais now
   near top; Chez Pierre far/hidden
3. ☑ Category / search / filter hub narrows the feed correctly

**Watch for:** feed ignoring location, both sellers always showing regardless
of distance, images 404.

---

### SCENARIO 4 — Seller listing management

| Device | Role | Account |
|--------|------|---------|
| Android | Seller | `qa+seller-paris` |

1. ☑ "Mes plats" → 4 seeded dishes visible under Disponible
2. ☑ Add a dish (⚠️ **€4.50 fait-maison price cap** must be enforced),
   allergens required, availability window
3. ☑ Publish → appears in buyer feed (verify from Scenario 1 buyer)
4. ☑ Edit → change persists · Delete → removed from feed

---

## 4. Device rig

| Device | Role | Why |
|--------|------|-----|
| Android physical | Driver | QR scanning needs a real camera |
| Android physical | Seller | production purchase/subscription |
| iOS Simulator | Buyer | no camera/purchase needed |

**Minimum:** 1 Android + 1 iOS Sim, switching roles by sign-out/in.
**Ideal:** 2 Android + 1 iOS Sim so you see real-time cross-role pushes.

---

## 5. Known behaviors (won't-fix during this test)

- **Zone filtering is NOT wired.** All online drivers see all SEARCHING jobs
  (open dispatch). Driver zones are stored but not used for matching yet, so
  in Scenario 2 `driver-paris` *can* currently see a Lyon job. Don't log that
  as a bug — it's expected until zone matching ships.
- **Stripe test mode** — card `4242 4242 4242 4242`. A `_secret_devbypass`
  intent may skip the real charge and still complete the order.
- **Single-seller cart** — adding from a second seller triggers a swap dialog.
- **No SMS OTP** in debug builds.

---

## 6. Re-seeding / resetting accounts

The seed lives at [`qa-accounts-seed.sql`](qa-accounts-seed.sql). It's
**idempotent** (safe to re-run; ON CONFLICT guards every row) and re-asserts
KYC/subscription state.

**Prerequisite:** the 6 users must exist in **Supabase Auth** first
(Dashboard → Authentication → Users) with these UIDs — already created:

| Email | Supabase UID |
|-------|--------------|
| qa+seller-paris | `de71fccf-c5fe-4bb1-9041-dbc945d1905a` |
| qa+seller-lyon | `614f04a8-8cae-4837-a2f6-b74cee577014` |
| qa+driver-paris | `68fd4ac3-cd0b-47f7-9508-c3aa127c39a6` |
| qa+driver-national | `6be14ff6-a467-4c9c-bff9-c0b0072c6bdb` |
| qa+buyer-paris | `91b8bc5f-8f41-4d50-9141-fb2ae89b0ac8` |
| qa+buyer-lyon | `5b757ac3-8d08-4119-8581-036bff07c940` |

The `User.id` = `User.supabaseId` = the Auth UID, so if you ever recreate an
Auth user, update the matching id in the seed before re-running.

**To run it:** paste the file contents into Supabase Dashboard → SQL Editor →
Run. (It's the same SQL that was applied to seed these accounts.)

---

## 7. Defect log (copy per run)

| # | Scenario | Step | Expected | Actual | Severity | Log line |
|---|----------|------|---------|--------|----------|----------|
| 1 | | | | | | |
| 2 | | | | | | |

---

**Supabase:** https://supabase.com/dashboard/project/eoxrrofpdtrwjbhywcvz
**Last Updated:** 2026-07-10
