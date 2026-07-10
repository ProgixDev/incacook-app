# IncaCook QA — Quick Reference Card

> Accounts are **already seeded** in the hosted DB (`eoxrrofpdtrwjbhywcvz`).
> To re-seed or reset, run `qa-accounts-seed.sql` (idempotent) — see
> [comprehensive-qa-guide.md](comprehensive-qa-guide.md) for how.

## 🔑 The 6 Accounts

### 🏪 Sellers — password `Seller123!`
```
qa+seller-paris@incacook.fr   Chez Pierre - Paris 11e   4 dishes  Premium
qa+seller-lyon@incacook.fr    Bouchon Lyonnais          3 dishes
```

### 🚗 Drivers — password `Driver123!`
```
qa+driver-paris@incacook.fr      Bicycle   1 zone  (Paris 11e)
qa+driver-national@incacook.fr    Car       5 zones (Paris 11e/1er/4e, Lyon, Marseille)
```

### 🛒 Buyers — password `Buyer123!`
```
qa+buyer-paris@incacook.fr    Paris 11e address
qa+buyer-lyon@incacook.fr     Lyon Centre address
```

All sellers/drivers are **KYC APPROVED** with **active subscription** — no
onboarding needed. Log in and go straight to the operational screens.

---

## 📍 Location Spoofing

| Zone | Lat | Lng |
|------|-----|-----|
| **Paris 11e** | 48.8530 | 2.3799 |
| **Paris 1er** | 48.8656 | 2.3489 |
| **Paris 4e — Le Marais** | 48.8566 | 2.3614 |
| **Lyon Centre** | 45.7640 | 4.8357 |
| **Marseille Vieux-Port** | 43.2965 | 5.3698 |

### iOS Simulator
```bash
xcrun simctl location booted set 48.8530,2.3799   # Paris 11e
xcrun simctl location booted set 45.7640,4.8357   # Lyon
xcrun simctl location booted reset
```

### Android (physical, mock-location app)
Set your fake GPS app to the coordinates above. Enable via
Developer Options → "Select mock location app".

---

## 🎯 Core Scenarios

| # | Scenario | Buyer | Seller | Driver |
|---|----------|-------|--------|--------|
| 1 | **Same-zone happy path** | buyer-paris @ Paris 11e | seller-paris | driver-paris |
| 2 | **Inter-city** | buyer-lyon @ Lyon | seller-lyon | driver-national |
| 3 | **Cross-city (no local driver)** | buyer-lyon @ Lyon | seller-paris | driver-national |
| 4 | **Discovery/proximity** | buyer-paris @ Paris 11e | both sellers | — |

---

## 📱 Device Rig

| Device | Role | Why |
|--------|------|-----|
| **Android physical** | Driver | QR scanning needs real camera |
| **Android physical** | Seller | production subscription/purchase |
| **iOS Simulator** | Buyer | no camera/purchase needed |

Minimum: 1 Android + 1 iOS Sim (switch roles by signing out/in).
Ideal: 2 devices + 1 sim to see real-time cross-role updates.

---

## ⚠️ Known Behaviors

- **Zone filtering NOT implemented** — all online drivers see all jobs
  (open dispatch). Driver zones are stored but not yet used for matching.
- **Stripe test mode** — card `4242 4242 4242 4242`, any future expiry/CVC.
- **Single-seller cart** — can't mix items from two sellers.
- **No SMS OTP** in debug builds — phone stored unverified.

---

## 📋 Defect Log

| # | Scenario | Step | Expected | Actual | Severity |
|---|----------|------|---------|--------|----------|
| 1 | | | | | |

---

**Supabase:** https://supabase.com/dashboard/project/eoxrrofpdtrwjbhywcvz
**Last Updated:** 2026-07-10
