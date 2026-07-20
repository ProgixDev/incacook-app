# Payments & Subscription — known issues register

Living list of the seller payment / payout / subscription issues, each with a
**root cause** (traced to file:line across the Flutter app and the
`IncaCook-Server` NestJS backend) and a **proposed solution**. Solutions are
**not yet implemented** — this doc is the plan of record.

Related QA docs: [revenuecat-testing.md](../qa/revenuecat-testing.md) ·
[revenuecat-android-setup.md](../qa/revenuecat-android-setup.md) ·
[full-user-journey-testing.md](../qa/full-user-journey-testing.md) ·
[supabase-firebase-apple-auth-reset.md](../qa/supabase-firebase-apple-auth-reset.md).

Decided approach for the Stripe return-to-app: **custom-scheme bridge** — reuse
the existing `incacook://` scheme, no new domain/entitlements (see ISSUE-2
solution).

Last updated: 2026-07-19.

**Status legend:** 🔧 Ready to fix (root cause found, fix known) · ⚙️ Config only
(dashboard/env) · 🤔 Needs decision · ✅ Already correct in source (verify/ship) ·
🧩 Depends on another issue.

| ID | Title | Area | Severity | Status |
|---|---|---|---|---|
| [ISSUE-1](#issue-1) | App Store subscription "not discovered" on app re-entry | iOS IAP / gate | 🔴 High | 🔧 Code done on branch (launch reconcile) — set RC webhook token to finish |
| [ISSUE-2](#issue-2) | Stripe Connect: can't return to app after onboarding | Stripe Connect / deep links | 🔴 High | ✅ Bridge wired; iOS crash fixed; seller banner now reads refreshed payout state — verify on device |
| [ISSUE-3](#issue-3) | Stripe `account.updated` webhook not firing when account is set | Stripe webhook | 🔴 High | ⚙️ Config only — Stripe dashboard |
| [ISSUE-4](#issue-4) | Stripe ↔ RevenueCat dual subscription systems write the same fields | Architecture | 🟡 Medium | 🤔 Needs decision — pick canonical |
| [ISSUE-5](#issue-5) | Sandbox offerings intermittently "not fetchable" (paywall fallback) | App Store config | 🟡 Medium | ⚙️ Config / propagation |
| [ISSUE-6](#issue-6) | "Obtenir de l'aide" (+ "À propos") buttons do nothing | Client / settings | 🟡 Medium | ✅ Fixed on `fix/client-reported-ux-bugs` |
| [ISSUE-7](#issue-7) | Phone "déjà utilisé" red error vs green "Code renvoyé" toast | Signup / OTP | 🟡 Medium | ✅ Fixed in source — decision + rebuild |
| [ISSUE-8](#issue-8) | Buyer can't edit allergens/preferences after signup (and they don't filter) | Buyer prefs | 🟡 Medium | ✅ Preferences editor fixed on branch (allergen-filter wiring still optional) |
| [ISSUE-9](#issue-9) | Adding a library photo fails (5 MB cap / HEIC MIME) | Seller add-product | 🔴 High | ✅ Code fixed — verify Supabase bucket cfg |
| [ISSUE-10](#issue-10) | Product detail: hardcoded rating/orders + mock seller on tap | Product detail | 🟡 Medium | 🔧 Ready to fix — frontend + seed data |
| [ISSUE-11](#issue-11) | Order-customize sheet: keyboard hides "Commander", can't dismiss | Checkout / layout | 🔴 High | ✅ Fixed on `fix/client-reported-ux-bugs` |
| [ISSUE-12](#issue-12) | Cart shows "Livraison" fee by default, before any choice | Cart | 🔴 High | ✅ Fixed on `fix/client-reported-ux-bugs` |
| [ISSUE-13](#issue-13) | Cart↔summary mismatch: delivery fee & vendor name | Checkout | 🟡 Medium | ✅ Fee half fixed via ISSUE-12; vendor-name half fixed on branch (2026-07-02) |
| [ISSUE-14](#issue-14) | Payment method hard to select (dead tap zones) | Payment | 🔴 High | ✅ Fixed on `fix/client-reported-ux-bugs` |
| [ISSUE-15](#issue-15) | Removing a cart article doesn't refresh | Cart | 🟡 Medium | ✅ Likely fixed in source — verify/ship |
| [ISSUE-16](#issue-16) | Restaurant/seller details show dummy user-account data | Seller profile | 🟡 Medium | ✅ Fixed on branch (real-but-sparse) — `GET /sellers/:id` + real profile; mock removed |
| [ISSUE-17](#issue-17) | "Ajouter aux favoris" (favourite) not working | Seller profile | 🟡 Medium | 🔧 Ready to fix — frontend + backend (new) |
| [ISSUE-18](#issue-18) | Profile "Préférences" & "Paiement" tiles disabled | Profile | 🟡 Medium | ✅ Préférences wired on branch; Paiement still needs the saved-cards feature |
| [ISSUE-19](#issue-19) | Map is limited — re-evaluate provider (client: Firebase/Google) | Maps / geo | 🟡 Medium | ✅ Google Maps frontend + backend geocoding wired; Railway server key still must be set |
| [ISSUE-20](#issue-20) | Client address form has separate fields instead of unified search | Client / addresses | 🟡 Medium | ✅ Fixed (2026-07-04) — `GoogleMapAddressPicker` widget created; `_AddressEditorSheet` now uses Google Places autocomplete + map preview |
| [ISSUE-21](#issue-21) | Product/dish detail shows hardcoded dummy ratings & orders | Product detail | 🟡 Medium | 🔧 Ready to fix — need to thread real values from backend |
| [ISSUE-22](#issue-22) | Cart image loading fails for Supabase URLs (AssetBundle error) | Cart / images | 🟡 Medium | 🔧 Needs fix — URL passed as AssetImage instead of NetworkImage |
| [ISSUE-23](#issue-23) | Payment method list saturating; should show only Stripe + wallet | Payment | 🟡 Medium | 🔧 Ready to fix — simplify payment options UI |
| [ISSUE-24](#issue-24) | Shop location marker doesn't open real map app | Seller profile | 🟢 Low | 🔧 Ready to fix — add url_launcher to map marker tap |
| [ISSUE-25](#issue-25) | Home screen map markers need visual update | Client home | 🟢 Low | 🤔 Design decision needed |
| [ISSUE-26](#issue-26) | Driver "Go Online" button active when KYC not approved | Driver / state | 🟡 Medium | 🔧 Ready to fix — disable button + show reason |
| [ISSUE-27](#issue-27) | Driver signup area search has 5 static options | Driver / signup | 🟡 Medium | 🔧 Ready to fix — implement real search |
| [ISSUE-28](#issue-28) | Keyboard lacks "Done" button across the app | General / UX | 🟡 Medium | ⚙️ Platform-level — keyboardType configuration |
| [ISSUE-29](#issue-29) | Add product form keyboard overshadows screen | Seller / UX | 🟡 Medium | 🔧 Related to ISSUE-11 (partially addressed) |
| [ISSUE-30](#issue-30) | Second seller account sharing an Apple ID hits Apple's native "already subscribed" sheet | Subscriptions / iOS IAP | 🟡 Medium | ✅ Fixed + verified on device (PR #43, merged) |

---

<a name="issue-1"></a>
## ISSUE-1 — App Store subscription "not discovered" on app re-entry 🔴

### Symptom (reported)
The App Store subscription payment succeeds on iOS (sandbox), but after finishing
it, re-entering the app shows **no active subscription** — the paywall / disabled
"Terminer" reappears as if nothing was bought.

### Root cause
The subscription gate is driven **only by the backend**, and **nothing
reconciles the local store entitlement back into the backend on launch**.

- **Gate reads backend only.** `SubscriptionGate` watches
  `UserController.hasActiveSellerSubscription`
  (`lib/features/subscriptions/presentation/widgets/subscription_gate.dart:26`),
  computed purely from `SellerAccount.subscriptionStatus` /
  `subscriptionCurrentPeriodEnd` (`lib/core/controllers/user_controller.dart:131`).
  It **never** reads RevenueCat `CustomerInfo` and **never** calls the status
  endpoint at gate time.
- **Launch hydration doesn't reconcile.** On cold start the only hydration is
  `PostAuthRouter.decide()` → `getMe()`
  (`lib/features/authentication/services/post_auth_router.dart:92`), a plain
  `GET /v1/users/me`. It does **not** re-check RevenueCat or re-run the sync.
- **The only store→backend writers are unreliable:**
  1. A **best-effort** `POST /v1/sellers/me/subscription/sync` whose failure is
     **swallowed** with a "webhook will reconcile" log
     (`lib/features/subscriptions/presentation/widgets/seller_subscription_view.dart:194`).
  2. The **RevenueCat webhook**, which currently **401s on every event** because
     `REVENUECAT_WEBHOOK_AUTH_TOKEN` is empty
     (`IncaCook-Server/src/modules/payments/webhooks/revenuecat-webhook.controller.ts:49`;
     `.env.example:45`).

Net effect: if the sync POST fails (or the purchase wasn't synced), `/users/me`
returns `subscriptionStatus=NONE` indefinitely. The device holds the entitlement,
but the gate never learns about it on re-entry.

### Proposed solution
**Config (Railway + dashboard):**
- Set `REVENUECAT_WEBHOOK_AUTH_TOKEN` in the Railway env **and** in RevenueCat →
  Project → Webhooks (Authorization header) so the ongoing source of truth
  actually writes. (See revenuecat-testing.md §1.3.)

**Code (frontend):**
- On launch for sellers, **reconcile store → backend**: read
  `Purchases.getCustomerInfo()`; if it has an active `seller_*` entitlement but
  `/users/me` says `NONE`, re-run `syncSubscription(...)` then
  `refreshFromServer()`.
- Stop silently swallowing the sync failure at
  `seller_subscription_view.dart:194` — retry, or flag for the launch reconcile.

**Code (backend, optional hardening):**
- `POST /sellers/me/subscription/sync` already REST-verifies when
  `REVENUECAT_SECRET_API_KEY` is set — ensure that key is set in Railway so the
  sync doesn't rely on the client hint alone.

---

<a name="issue-2"></a>
## ISSUE-2 — Stripe Connect: can't return to the app + status never updates 🔴

### Symptom (reported)
After completing Stripe Connect payout onboarding in the browser, the app must
return through `incacook://stripe/return`, reconcile live Stripe Connect status,
and stay on the normal role home. On iOS, the return previously triggered
Flutter's automatic deep-link router, which sent GetX to `/_unknown` after the
app already received the link through `app_links`.

### Current state

- **Backend bridge exists:** Stripe gets HTTPS return/refresh URLs, and the
  backend bridge bounces those to `incacook://stripe/return` /
  `incacook://stripe/refresh`.
- **Backend status endpoint exists:** `GET /v1/stripe/onboarding/status`
  re-reads the Stripe Connect account and persists the latest payout readiness.
- **Frontend return handling exists:** `PayoutOnboardingService.openOnboarding`
  waits for `incacook://stripe/...` or app resume before calling the status
  endpoint and refreshing `/users/me`.
- **Android works:** Android has a `stripe` host intent-filter and
  `flutter_deeplinking_enabled=false`.
- **iOS fix (2026-07-03):** `ios/Runner/Info.plist` now sets
  `FlutterDeepLinkingEnabled=false`, matching Android. This keeps
  `incacook://stripe/return` out of Flutter's Navigator so `app_links` can own
  the callback without GetX navigating to `/_unknown`.
- **Seller banner fix (2026-07-03):** Flutter now deserializes
  `sellerProfile.stripeOnboardingCompleted` from `/users/me`, and seller home
  hides `PayoutSetupBanner` reactively once that value is true. The status
  refresh also logs Stripe's non-sensitive status booleans
  (`completed/charges/payouts/details`) for device QA.

> Note: `url_launcher` `externalApplication` (system Safari) is fine here — when
> the bridge page hits `incacook://…`, iOS/Android hand control back to the app
> via the registered scheme. (Alternatively, `flutter_web_auth_2` with
> `callbackUrlScheme: "incacook"` would auto-close the browser, but it's not
> required and isn't currently a dependency.)

---

<a name="issue-3"></a>
## ISSUE-3 — Stripe `account.updated` webhook not firing when the account is set 🔴

### Symptom (reported)
Once the Connect account is created, the Stripe webhook "doesn't work" — the
payout status never reconciles server-side.

### Root cause
The handler code is correct
(`src/modules/payments/webhooks/stripe-webhook-handler.service.ts:435`,
routes by `metadata.role`, falls back to a lookup by `stripeConnectAccountId`),
and signatures are verified against `STRIPE_WEBHOOK_SECRET`
(`src/infrastructure/stripe/stripe-webhook.service.ts`). **The problem is
delivery configuration:** `account.updated` for **connected** accounts is only
delivered if the Stripe webhook endpoint is set to **"Listen to events on
Connected accounts."** A platform-only endpoint never receives connected-account
events — exactly this symptom.

### Proposed solution (Stripe dashboard config)
- In Stripe → Developers → Webhooks, on the endpoint
  `…/v1/stripe/webhook`, enable **events on connected accounts** and subscribe to
  **`account.updated`** (plus the payment events already handled).
- Confirm `STRIPE_WEBHOOK_SECRET` in Railway equals that endpoint's signing
  secret. (If a separate Connect endpoint is used, it has its **own** secret —
  the current code reads a single `webhookSecret`, so prefer **one** endpoint
  that listens to both platform and connected-account events.)
- Pairs with ISSUE-2's `GET /onboarding/status` so the app isn't solely dependent
  on webhook timing for the immediate return UX.

---

<a name="issue-4"></a>
## ISSUE-4 — Stripe ↔ RevenueCat: two subscription systems write the same fields 🟡

### Symptom (reported)
"Check the Stripe / RevenueCat config with our backend server."

### Root cause
The seller subscription has **two** writers of the same gate fields
(`subscriptionStatus`, `subscriptionCurrentPeriodEnd`, `isPremium`):
- **RevenueCat** (App Store / Play) — `revenuecat.util.ts` +
  `revenuecat-webhook-handler.service.ts` + `POST /sellers/me/subscription/sync`.
- **Stripe** — the card subscription flow
  (`lib/features/subscriptions/presentation/subscribe_flow.dart`,
  `createSubscription()`) + `customer.subscription.*` / `checkout.session.completed`
  webhooks (`stripe-webhook-handler.service.ts`,
  `applySubscriptionState`). `.env.example` still calls this the
  "Mandatory seller platform subscription ($4/mo)".

Both paths write the same columns, so they can **overwrite each other**
(e.g. a stale Stripe `customer.subscription.deleted` could flip a
RevenueCat-active seller to inactive, or vice-versa).

### Proposed solution
- **Pick one canonical system per platform.** For mobile (iOS/Android) the store
  rules require IAP → **RevenueCat is canonical**; the Stripe **card subscription
  path should be disabled/guarded** on mobile to stop conflicting writes. (Stripe
  stays for orders / wallet / payouts / Connect — unrelated to the subscription.)
- If a web seller dashboard ever needs Stripe subscriptions, namespace the writes
  (e.g. a `subscriptionSource` column) so the two never clobber one another.
- Verify the keys in Railway: `REVENUECAT_SECRET_API_KEY` (server-side verify),
  `REVENUECAT_WEBHOOK_AUTH_TOKEN` (ISSUE-1), and that the Stripe subscription
  price/env vars aren't accidentally driving the mobile flow.

---

<a name="issue-5"></a>
## ISSUE-5 — Sandbox offerings intermittently "not fetchable" 🟡

### Symptom (reported / screenshot)
The paywall shows **"Produits non encore disponibles dans l'environnement Apple
Sandbox"** with fallback "€ HT" prices and a disabled "Terminer" — i.e.
`getOfferings` returned a `storeError` / `configurationError` and no packages.

### Root cause
This is the known App Store Connect propagation / config path (not an app bug) —
`loadOfferingForCategory` reports `OfferingFailure.storeError`
(`lib/core/services/revenuecat_service.dart:144`) when products can't be fetched.
Causes: products not all "Prêt à soumettre", subscription-group localization
incomplete, or simply propagation lag after an agreement/product edit. When
offerings fail, **`restore` also can't re-grant**, compounding ISSUE-1.

### Proposed solution
- Per revenuecat-testing.md §1: Paid Applications Agreement Active, every product
  "Prêt à soumettre", subscription-group localization complete, then wait up to
  ~24h for sandbox propagation.
- Track separately per category — currently only **Le Bon Fait Maison** fetches;
  `traiteur` / `sauve_ton_panier` also need the swapped-products fix (RC doc §1.2).

---

# Client-reported app bugs (round 1 — 2026-07-01)

Reported by the client, investigated across frontend + backend. Several are
placeholders or already-fixed-in-source but not yet shipped — noted per issue so
we don't "fix" what's already correct.

<a name="issue-6"></a>
## ISSUE-6 — "Obtenir de l'aide" (and "À propos") do nothing 🟡

### Symptom (reported)
The "Obtenir de l'aide" (Get help) button in the client app is non-functional.

### Root cause — **frontend only**
The settings menu item has an **empty handler**:
- `lib/features/settings/presentation/screens/settings.dart:102` —
  `SettingMenuItem(title: AppTexts.settingsGetHelp, onTap: () {})`.
- Same empty `onTap: () {}` on **"À propos"** (`settings.dart:107`) and the
  app-bar action (`settings.dart:138`). String: `text_strings.dart:233`.

### Proposed fix
Wire the handler to a real action: a `mailto:support@…`, an external FAQ/support
URL (`url_launcher`), or push a Help/FAQ screen. Do the same for "À propos".

---

<a name="issue-7"></a>
## ISSUE-7 — Phone "déjà utilisé" (red) vs "Code renvoyé" (green) toast 🟡

### Symptom (reported / screenshot)
On the 6-box phone OTP screen: a **red** "Ce numéro de téléphone est déjà
utilisé." while tapping "Renvoyer le code" shows a **green** "Code renvoyé — On
t'a renvoyé un nouveau code par SMS." — contradictory.

### Root cause — **the screenshotted build is stale; current source is reconciled**
- The **SMS OTP step is currently disabled**: `feature_flags.dart:44`
  `skipPhoneVerification = true`, and `signup_flow_controller.dart:338` adds the
  `phoneVerification` step **only** `if (!FeatureFlags.skipPhoneVerification)`. So
  the screenshotted screen only appears in a build where the flag is `false`.
  (Backend silently saves a duplicate phone as `null` rather than erroring —
  `IncaCook-Server/.../users/users.service.ts:304`.)
- The red-vs-green contradiction is **already fixed in current source**: resend
  and initial send share `requestOtp()`, which returns `false` on the
  already-used case → no green toast (`phone_verification_page.dart:179-187`), and
  `canResend = secs == 0 && !alreadyUsed` disables resend entirely
  (`phone_verification_page.dart:170`). Red error set at
  `signup_flow_controller.dart:1321-1325`.

### Proposed fix — **decision, not a bug fix**
- Decide whether SMS verification should be live. If **yes**, flip
  `skipPhoneVerification = false` and **ship the current build** (the toast
  contradiction is already handled). If **no**, remove/hide the OTP page and
  confirm the silent-null-phone behavior is acceptable.
- The client's contradiction screenshot is almost certainly a **build predating
  the reconile** — rebuild from current source.

---

<a name="issue-8"></a>
## ISSUE-8 — Buyer can't edit allergens/preferences after signup 🟡

### Symptom (reported)
No way to modify allergens/preferences entered during buyer account creation; a
mistaken allergen means "you don't see dishes with those allergens."

### Root cause — **frontend gap (backend ready); allergens don't actually filter**
- **No edit entry point.** The profile card already has a Preferences action
  (`profile_user_card.dart:20,102-107`), but `settings.dart:177-180` constructs
  `ProfileUserCard(...)` passing **only `onEditProfile`** — `onPreferences` stays
  `null`, so the tile does nothing. The backend edit path **exists**:
  `PUT /v1/buyers/me/preferences` (`buyers.controller.ts:14`, upsert).
- **Allergens have zero effect on the feed today.** The plumbing exists on both
  sides but is **unwired**: backend `avoidAllergens` param works
  (`listings.service.ts:446`), the Flutter query serializes it
  (`list_listings_query.dart:54`), and `ListingFilter.allergensToExclude` exists
  (`listing_filter.dart:16`) — but `FilterController.toQuery()`
  (`filter_controller.dart:79-93`) never sets it and the feed never reads the
  buyer's saved allergens. So mistaken allergens **don't hide dishes**; the only
  over-restrictive filter is the manual **dietary AND** filter
  (`filter_controller.dart:108-110`).

### Proposed fix
- **Primary (frontend):** pass `onPreferences:` in `settings.dart:177` →
  navigate to a preferences editor (reuse `buyer_dietary_page`'s chip UI seeded
  from `BuyerAccount.dietaryTags/allergens`) → call `setPreferences`. This alone
  resolves the complaint (they can correct a mistake).
- **Optional (if allergen-avoidance is a real requirement):** map
  `ListingFilter.allergensToExclude → avoidAllergens` in `toQuery()` and/or seed
  it from the buyer's saved prefs, and add allergen UI to `filters_sheet.dart`.

---

<a name="issue-9"></a>
## ISSUE-9 — Adding a photo from the library fails 🔴

### Symptom (reported / screenshot)
In "Ajouter un produit", a photo tile is stuck on a red retry state — "impossible"
to add a library photo. Client asks the max photo size.

### Root cause — **frontend + Supabase storage config**
- **Answer to "max size": 5 MB**, measured **after** an image_picker downscale to
  1600×1600 @ JPEG q85. `upload_picker.dart:42` `_maxUploadBytes = 5*1024*1024`;
  over-limit throws `ImageTooLargeException` (`upload_picker.dart:66-77`).
- Upload is a **signed-URL PUT straight to Supabase Storage** (`listings` bucket):
  `POST /v1/uploads` mints the URL (`files.service.ts:90-138`, no size/MIME
  check), then `UploadsRepository.putFile` PUTs raw bytes
  (`uploads_repository.dart:50-79`) with a `Content-Type` from `_guessContentType`
  that can emit **`image/heic`** (`upload_picker.dart:90-96`).
- The red tile is set when the PUT fails (`add_product_controller.dart:348-365`).
  Most likely cause: the Supabase **`listings` bucket** `file_size_limit` or
  `allowed_mime_types` rejects the file (e.g. iOS HEIC library photos sent as
  `image/heic`). The NestJS backend imposes no cap — it's not the failure point.

### Fix implemented — mirror the suich-mobile approach
Reference: `/Users/macbookpro/Documents/projects/suich-mobile` (validate → resize
via picker → size-check → multipart upload with a retry handler).
- **Frontend fixed:** picked images are decoded, re-encoded to JPEG, written to a
  `.jpg` preview file, size-checked at 5 MB **after** normalization, then uploaded
  with `contentType=image/jpeg` (`upload_picker.dart`).
- **Backend fixed:** `POST /v1/uploads` now rejects disallowed MIME hints per
  upload purpose; listing images only accept `image/jpeg`
  (`IncaCook-Server/src/modules/files/files.service.ts`).
- **Retry UX already present:** the failed add-product photo tile remains
  tappable and re-opens the picker; signup image widgets keep their explicit
  retry chip.
- **Remaining config check:** Supabase `listings` bucket should allow
  `image/jpeg` and have `file_size_limit >= 5242880` bytes.

---

<a name="issue-10"></a>
## ISSUE-10 — Product detail: name "always La Cuisine d'Alice", hardcoded stats 🟡

### Symptom (reported)
The cook's name always shows "La Cuisine d'Alice", and the description looks wrong.

### Root cause — **mostly correct binding + real placeholders**
- **Name & description are correctly bound to real data**, not a placeholder.
  `product_detail.dart:415-420` binds `sellerName` from fetched/listing data with
  fallback `AppTexts.productSellerFallbackName` = **"Cuisinier"**. The string
  "La Cuisine d'Alice" is a **dead sample constant** (`text_strings.dart:357`)
  referenced in **no** render path. → If the client always sees it, that's the
  **seed seller's real `displayName`** in the DB. Likewise "Bella. Plus…" means
  the stored `description` literally is "Bella" (the seller typed the title into
  both fields; `description` is required).
- **The genuinely hardcoded bits** (all frontend placeholders):
  - Rating **4.8** and **"1,284 commandes terminées"** — `SellerCard` defaults
    (`seller_card.dart:17-18`), because `product_detail.dart:506-521` never passes
    real `rating`/`ordersCompleted`.
  - Short description under the title — `product_detail.dart:482`
    (`AppTexts.productSampleShortDesc`).
  - Tapping the seller card opens `SellerMockData.demoSeller()` ("Aïcha Benali")
    — always the **mock** seller (`product_detail.dart:516-519`).

### Proposed fix
- Thread real values into `SellerCard`: `rating: l?.rating ?? 0`; either add a
  real orders/meals-sold field to the feed DTO + `Listing` model or **hide** the
  orders metric until it's backed by data (`product_detail.dart:506-521`,
  `seller_card.dart:17-18`).
- Fix the seller-card tap to open the **real** seller
  (`product_detail.dart:516-519`); drop the hardcoded `shortDescription`
  (`product_detail.dart:482`).
- Name/description need **no code change** — if the values are wrong, fix the
  seed/DB data. (Optionally delete the dead `productSampleSellerName` constant.)

---

<a name="issue-11"></a>
## ISSUE-11 — Order-customize sheet: keyboard hides "Commander" 🔴

### Symptom (reported)
When typing a "Note pour le vendeur", the keyboard covers "Commander" and can't
be dismissed to reach it.

### Root cause — **frontend layout**
`lib/features/orders/presentation/widgets/order_customize_sheet.dart`: the sheet
is a `DraggableScrollableSheet` (line 111) with a `Column` → `Expanded(scroll)` +
a **sibling `_TotalAndCta` pinned outside the scroll** (line 167). Nothing reacts
to `MediaQuery.viewInsets.bottom`, so the keyboard overlays the CTA; and there's
**no unfocus gesture**, so tapping the body doesn't dismiss the keyboard (the
barrier tap closes the whole sheet).

### Proposed fix
- Pad the CTA above the keyboard: wrap the container / `_TotalAndCta` with
  `Padding(EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom))`.
- Add `GestureDetector(behavior: opaque, onTap: () => FocusScope.of(context).unfocus())`
  around the sheet body.
- Optionally move `_TotalAndCta` inside the scroll view / `ensureVisible` on focus.

### Follow-up fix (2026-07-03)
- The app shell now provides a visible **OK** keyboard dismiss control while the
  keyboard is open, plus tap-outside unfocus.
- `AddProductSheet` now pads its scroll content and save bar by
  `MediaQuery.viewInsets.bottom`, dismisses on drag/tap, and its text fields
  submit/unfocus cleanly. This addresses the seller add-plate/add-dish keyboard
  overlap reported on iOS.

---

<a name="issue-12"></a>
## ISSUE-12 — Cart shows "Livraison" fee by default, before any choice 🔴

### Symptom (reported / screenshot)
The cart applies delivery by default ("Livraison €2.50") and no longer asks the
buyer to choose delivery vs pickup.

### Root cause — **frontend**
The cart **hardcodes** a delivery line before any choice: `cart_footer.dart:37`
passes `shipping: AppTexts.cartShippingFee` (constant, `text_strings.dart:697`)
into `OrderSummaryBlock`, which always renders a "Livraison" row and folds it into
the total (`order_summary_block.dart:22-23,36`). The choice sheet is still wired
(`my_cart.dart:39` `FulfillmentChoiceSheet.resolve`) but (a) only appears when the
seller offers **both** modes, and (b) **pre-selects delivery**
(`fulfillment_choice_sheet.dart:64-71`).

### Proposed fix
- At the cart stage (before a choice), don't show a concrete delivery fee/total —
  show subtotal + "frais calculés à l'étape suivante", or defer the fee to the
  `FulfillmentSelection`.
- Stop pre-selecting delivery so the buyer makes an explicit choice
  (`fulfillment_choice_sheet.dart:64-71`).

---

<a name="issue-13"></a>
## ISSUE-13 — Cart↔summary mismatch: delivery fee & vendor name 🟡

### Symptom (reported / screenshots)
On the summary the **delivery fee is absent** (only "Frais de service €0.50",
"À récupérer") while the cart showed "Livraison €2.50"/total €20.50; and the
**vendor name doesn't appear** — it shows the category "Le Bon Fait Maison".

### Root cause
- **Fee mismatch is a symptom of ISSUE-12.** The summary is *correct*: it uses the
  real `FulfillmentSelection` (`order_summary.dart:27,34-37`) — pickup ⇒ no
  delivery fee, gated by `if (isDelivery)` (`order_summary.dart:472`). The cart
  lied with its hardcoded "Livraison" line. Fixing ISSUE-12 removes the
  discrepancy.
- **Vendor name empty → category shown.** `_SellerSummary` renders
  `seller.sellerName` (bold) + `seller.category.label` (subtitle,
  `order_summary.dart:395,414`). The name is empty because the
  `Listing → FoodListing` adapter falls back to `''` when the object lacks a
  joined seller name (`product_detail.dart:779` `sellerName ?? ''`), so the
  category label "Le Bon Fait Maison" is the only visible text.
  *(Note: the detail/feed endpoints DO expose `sellerName` —
  `listing-response.dto.ts:81`, `listings.service.ts:534` — so this is about the
  object threaded into cart→summary carrying the name, or the seed name being
  empty.)*

### Proposed fix
- **Frontend:** stop falling back to `''` (`product_detail.dart:779`); use a real
  placeholder/shop name, and don't let the category label stand in for the name in
  `_SellerSummary`. Ensure `sellerName` is threaded through cart → summary.
- **Backend:** confirm the object powering the cart line carries the joined
  `sellerName` (it's available on the DTOs). Fix ISSUE-12 for the fee half.

---

<a name="issue-14"></a>
## ISSUE-14 — Payment method hard to select (dead tap zones) 🔴

### Symptom (reported / screenshot)
Tapping a payment method (Mastercard/PayPal/…) often doesn't apply the green
"selected" highlight even though the tap lands.

### Root cause — **frontend hit-target (not state)**
Selection logic is correct (`payment.dart:84-93` setState; `_MethodCard.selected`
at `:156`; green fill animates `:281-290`). But `_MethodCard` wraps the card in a
plain `GestureDetector` with the default `HitTestBehavior.deferToChild`
(`payment.dart:276`). Its descendants (`FrostedSurface → … → Container`) don't
hit-test themselves, so only the 48×48 icon and the two `Text` widgets are
tappable — the card's padding and empty space fall through. Tapping "the card"
frequently hits dead space → no selection.

### Proposed fix (one line)
Add `behavior: HitTestBehavior.opaque` to the `GestureDetector` at
`payment.dart:276` (or replace with an `InkWell`/`Material` filling the card), so
the whole card rectangle is one reliable tap target.

---

<a name="issue-15"></a>
## ISSUE-15 — Removing a cart article doesn't refresh 🟡

### Symptom (reported)
Removing items from the cart doesn't update the totals/line items.

### Root cause — **likely already fixed in current source**
The current cart path is correctly reactive: `CartController.items` is an
`RxList` (`cart_controller.dart:14`); `removeItem`/decrement call `items.refresh()`
explicitly (`cart_controller.dart:87-103`); `subtotal`/`itemCount` are getters
over `items`; and the cart screen builds the list **and** footer inside one `Obx`
(`my_cart.dart:76-115`) with stable `ValueKey(item.id)` dismissibles. Removal
*does* update totals here — this appears fixed in a prior commit.

### Proposed fix
- If the client still sees stale totals, it's a **build predating** the fix — ship
  current code.
- Otherwise audit non-reactive consumers of `itemCount`/`subtotal` — notably
  `CartBadge` (`cart_badge.dart:7-9`) takes a plain `count` and only refreshes if
  its caller wraps it in `Obx`. Wrap any such call sites.

---

# Client-reported app bugs (round 2 — 2026-07-01)

<a name="issue-16"></a>
## ISSUE-16 — Restaurant/seller details show dummy user-account data 🟡

### Symptom (reported)
The restaurant/seller details screen shows dummy account data (name, stats, etc.).

### Root cause — **frontend mock + missing backend endpoint**
Tapping a seller/kitchen always opens `SellerProfileScreen(profile:
SellerMockData.demoSeller())` — the same fixed fake seller regardless of who is
tapped (`product_detail.dart:518`, `client_home.dart:326`). See **GAP-3**. The
product-detail seller card also shows hardcoded **rating 4.8** / **"1,284
commandes"** (see **ISSUE-10**).

### Proposed fix
- **Backend:** add `GET /v1/sellers/:id` returning the real public seller profile
  (displayName, bio, avatar, aggregated rating, criteria, location).
- **Frontend:** fetch it and feed `SellerProfileScreen` the real profile instead
  of `SellerMockData.demoSeller()`; thread real rating into `SellerCard`
  (ISSUE-10).

---

<a name="issue-17"></a>
## ISSUE-17 — "Ajouter aux favoris" (favourite seller) not working 🟡

### Symptom (reported)
Add-to-favourites does nothing.

### Root cause — **dead handler + no backend**
The favourite (heart) button on the seller profile is a dead handler
(`seller_profile.dart:32` → `onPressed: () {}`) — see **GAP-7**. There is no
favourites backend (no endpoint, no table wired).

### Proposed fix
- **Backend (new):** `POST/DELETE /v1/buyers/me/favorites/:sellerId` +
  `GET /v1/buyers/me/favorites` (and a `BuyerFavorite` relation).
- **Frontend:** wire the heart to toggle it, reflect state, and optionally a
  "Favoris" list in the buyer area.

---

<a name="issue-18"></a>
## ISSUE-18 — Profile "Préférences" & "Paiement" tiles are disabled 🟡

### Symptom (reported)
In the profile, the **Préférences** and **Paiement** actions are disabled.

### Root cause — **frontend (unwired) + one feature gap**
`ProfileUserCard` exposes three actions — Éditer / **Préférences**
(`onPreferences`) / **Paiement** (`onPayment`) (`profile_user_card.dart:14-21,
97-114`). But `settings.dart:177` constructs it passing **only `onEditProfile`**,
so `onPreferences` and `onPayment` are `null` → both tiles do nothing.
- **Préférences** — the backend edit path already exists
  (`PUT /v1/buyers/me/preferences`); this is purely a wiring gap (**ISSUE-8**).
- **Paiement** — managing saved payment methods is not built; the payment list is
  demo data (**GAP-2**), so this needs the saved-cards feature first.

### Proposed fix
- **Préférences (easy, frontend):** pass `onPreferences:` → a preferences editor
  (reuse `buyer_dietary_page` chips seeded from `BuyerAccount`), call
  `setPreferences`.
- **Paiement (feature):** build saved payment methods (Stripe SetupIntent +
  list/detach) then wire `onPayment:`; until then, hide the tile rather than show
  it disabled.

---

<a name="issue-19"></a>
## ISSUE-19 — Map is limited — re-evaluate provider (client: Firebase/Google) 🟡

### Symptom (reported)
The current map is limited; the client wants to reconsider it (suggests
Firebase/Google).

### Current state
Google Maps Platform is now the chosen map + geo stack.

- **Frontend:** `mapbox_maps_flutter` has been replaced by
  `google_maps_flutter`. The map screen, driver map, buyer tracking map, seller
  location preview, address autocomplete/reverse-geocode, static address preview,
  and delivery route drawing now use Google Maps / Places / Directions.
- **Android:** the Maps SDK key is injected into `AndroidManifest.xml` from the
  same Flutter `GOOGLE_MAPS_API_KEY` dart-define used by the app.
- **iOS:** Dart sends `GOOGLE_MAPS_API_KEY` to the native Google Maps SDK through
  the startup method-channel bridge before any map view is created.
- **Dart HTTP clients:** use `GOOGLE_MAPS_API_KEY` from
  `.vscode/dart_defines.json` / `--dart-define-from-file` for Places,
  Directions, and Static Maps.
- **Backend:** address geocoding is already behind the `GEOCODER` seam and bound
  to `GoogleGeocodingService`; address writes geocode server-side when the
  client omits lat/lng.

### Remaining config

- Set backend `GOOGLE_MAPS_API_KEY` in Railway with a **server-side** key
  restricted by API + IP for Geocoding API. Do not reuse the mobile app key for
  the backend.
- In Google Cloud, ensure billing is enabled and the mobile key has Maps SDK for
  Android, Maps SDK for iOS, Places API, Directions API, Geocoding API, and
  Maps Static API enabled as needed by the app.

---

# Missing functionality — codebase scan (2026-07-01)

Full frontend + backend sweep. **Headline: the backend is largely
production-grade** (real Stripe transfers/payouts, subscriptions, FCM push,
tracking sockets, chat, files, OTP). The gaps are mostly **frontend mock/demo
data still wired into live screens**, plus a few backend stubs.

## Tier 1 — user-visible fake/broken (before launch)

| ID | Gap | Evidence | Fix |
|---|---|---|---|
| GAP-1 | **Checkout delivery-address is fake** — 3 hardcoded Paris addresses + dead "add address" button, in the live cart→pay flow | `delivery_address.dart:23,209` | ✅ **Fixed on branch** — loads real `UsersRepository.listAddresses`, empty-state add button wired |
| GAP-2 | **Payment methods are demo** — fake saved cards + fake **€12.00** wallet balance; PayPal/Apple/Google Pay don't transact (only Stripe card works) | `payment.dart:41-58`, `payment_processing.dart:127` | Medium — saved-cards lookup (Stripe SetupIntent); decide PayPal/Apple Pay |
| GAP-3 | **Seller/kitchen public profile always shows the same mock seller** | `product_detail.dart:518`, `client_home.dart:326` (`SellerMockData.demoSeller()`) | Medium — needs a real `GET /sellers/:id` + wire `SellerProfileScreen` |
| GAP-4 | **Driver "Today" earnings/stats are mock** — shown live when online | `today_stats_card.dart:17` | ✅ **Fixed on branch (2026-07-02)** — `GET /v1/drivers/me/stats/today` (real earnings+deliveries) + card reads `DeliveryDriverController.todayStats`; online-time now measured on-device |
| GAP-5 | **No notifications inbox** — bell is a dead handler; push registers but nothing to view | `settings.dart:164` | ✅ **Fixed on branch (2026-07-02)** — new `Notification` table + persistence on every push + `GET /v1/notifications` (+ read/read-all/unread-count); Flutter inbox screen + bell badge wired. **Migration applied to Railway/Supabase (2026-07-03).** |
| GAP-14 | **Seller "Today" revenue/orders were mock** — showed **€34.50** and **12** after seller payment/onboarding | `today_snapshot_card.dart` | ✅ **Fixed on branch (2026-07-03)** — seller home now derives today's revenue/order count from authenticated `GET /v1/sellers/me/orders`, using `sellerEarningsCents` from the real order DTO. |
| GAP-15 | **Client address form used manual entry** — separate street/postal/city fields instead of Google Places | `saved_addresses_sheet.dart` (_AddressEditorSheet) | ✅ **Fixed (2026-07-04)** — created `GoogleMapAddressPicker` widget; `_AddressEditorSheet` now uses Google Places autocomplete with map preview and current location button. |

## Tier 2 — disabled / partial

| ID | Gap | Evidence |
|---|---|---|
| GAP-6 | **Phone verification off** by flag — accounts created unverified | `feature_flags.dart:43` (`skipPhoneVerification=true`) |
| GAP-7 | **Dead handlers** — favourite-seller heart, driver map menu, edit-cart-from-summary | `seller_profile.dart:32`, `delivery_top_buttons.dart:28`, `order_summary.dart:363` |
| GAP-8 | **"Partages solidaires"** (solidarity free-food) section not built — needs a backend listing type | `client_home.dart:442` |

## Tier 3 — backend stubs

| ID | Gap | Evidence | Impact |
|---|---|---|---|
| GAP-9 | **Server-side address geocoding** | `GoogleGeocodingService` behind `GEOCODER` | ✅ **Fixed on branch** — real Google geocoding behind a provider seam. **Address-save wiring done (2026-07-02)**: `upsertAddress`/create/update geocode the address text when the client omits lat/lng, so `point` is populated server-side. Needs server-side `GOOGLE_MAPS_API_KEY` on Railway. |
| GAP-10 | **Transactional email = no-op** | `email.service.ts:25` (empty `send()`, zero callers) | ✅ **Fixed on branch** — SMTP send via nodemailer + `MAIL_*` env. No callers yet (dispatchers = follow-up). |
| GAP-11 | **Generic SMS = no-op** | `twilio.service.ts:24` (empty, zero callers) | Only OTP works (via Prelude). |
| GAP-12 | **Review metrics stubbed** | `reviews.service.ts:254-256` | `responseRatePercent` always null, `sentimentTags` always []. |
| GAP-13 | **Empty modules** — Boosts / Search / Geo | `boosts.module.ts`, `search.module.ts`, `geo.module.ts` (empty `@Module({})`) | Registered but inert; no UI yet either, so not user-facing today. |

## Tier 4 — dead code to delete (risk of accidental wiring)
`checkout.dart` `Placeholder()`; mock `ChatListScreen` + orphan
`home/client_nav_tabs.dart`; `SignupRepository` stub (fake OTP `123456`, fake
address search); unused mock-data files (`order_request_mock_data`,
`accepted_order_mock_data`, `seller_product_mock_data`, `client_mock_data`,
`map_mock_data`, `ScheduledPickup`).

> ⚠️ **Prod safety:** a dev-only `pi_dev_*` PaymentIntent path marks orders paid
> without charging — gated to `NODE_ENV=development`. Ensure prod never enables
> it (`orders.service.ts:309-320`).

---

# Keys, secrets & access to obtain

What's **still needed** (per "others already set"). ✅ blocking the urgent fixes.

| Provider | Item | Where it goes | Unblocks |
|---|---|---|---|
| **Stripe** ✅ | `STRIPE_WEBHOOK_SECRET` from an endpoint with **connected-account `account.updated`**; confirm `STRIPE_SECRET_KEY`; Connect **enabled** (FR) | Railway env | ISSUE-2, ISSUE-3, payouts |
| **RevenueCat** ✅ | `REVENUECAT_WEBHOOK_AUTH_TOKEN` (generate, same in dashboard) + `REVENUECAT_SECRET_API_KEY` (`sk_`) | Railway env + dashboard | ISSUE-1 |
| **Supabase** ✅ | Dashboard access to set `listings` bucket `file_size_limit` + `allowed_mime_types` | Supabase dashboard | ISSUE-9 (photo upload) |
| **RevenueCat / Google** | `REVENUECAT_ANDROID_KEY` (`goog_`) + Play Developer API **service-account JSON** | `dart_defines.json` + RC dashboard | Android IAP |
| **App Store Connect** | **App-Specific Shared Secret** | RevenueCat dashboard | iOS receipt validation |
| **Firebase** | Backend **service-account JSON** (FCM) + iOS **APNs auth key** uploaded to Firebase. Mobile Dart now initializes Firebase from explicit Android/iOS `DefaultFirebaseOptions`, so iOS no longer depends on plist bundling before Dart startup. | Railway env + Firebase dashboard | Push on iOS/prod |
| **Google Maps** ✅ | **Server-side** key (Geocoding API enabled, restrict by API+IP) → backend `GOOGLE_MAPS_API_KEY`; mobile key in `.vscode/dart_defines.json` and passed to native Android/iOS Maps SDKs from Flutter dart-defines | Railway env (server); app dart-defines for mobile | GAP-9 geocoding + ISSUE-19 Google Maps frontend |
| ~~Mapbox~~ | ~~Server-side token~~ — superseded by Google (2026-07-02) | — | — |
| **Resend** | API key + verified sending domain | Railway env | GAP-10 email |
| **Railway** | A **production environment** mirroring dev settings + all the above | Railway | prod cutover |
| **Stripe (optional)** | Apple Pay **merchant ID + cert**, PayPal business creds | Stripe / Apple / PayPal | GAP-2 real wallet methods |

---

# Client-reported app bugs (round 3 — 2026-07-04)

Latest issues reported across all three apps (seller, client, driver).

<a name="issue-20"></a>
## ISSUE-20 — Client address form has separate fields instead of unified search ✅

### Symptom (reported)
When adding a new address in the client app, there are separate fields for "Adresse", "Code postal", and "Ville" — not the Uber Eats-style single search bar.

### Root cause — **frontend manual entry pattern**
`_AddressEditorSheet` in `saved_addresses_sheet.dart` used three manual `TextField` widgets (`_fullAddress`, `_postalCode`, `_city`) with no Google Places integration. Other flows (checkout `AddressSearchSheet`, signup `SignupAddressPicker`) already used autocomplete — this was the outlier.

### Fix implemented (2026-07-04)
- **Created reusable widget:** `lib/core/widgets/map/google_map_address_picker.dart`
  - Single Google Places autocomplete search field (debounced 350ms)
  - "Use my current location" button (GPS → reverse geocode)
  - Map preview with pin when address selected
  - Returns complete `Address` (street + postal + city + coordinates)
- **Updated `_AddressEditorSheet`:** Replaced three text fields with `GoogleMapAddressPicker`
- **Result:** Client address entry now matches the Uber Eats pattern across all flows

---

<a name="issue-21"></a>
## ISSUE-21 — Product/dish detail shows hardcoded dummy ratings & orders 🟡

### Symptom (reported)
When clicking on a dish/restaurant, fake reviews, fake descriptions, and fake order numbers appear.

### Root cause — **frontend placeholders (partially overlapping ISSUE-10)**
- Rating **4.8** and **"1,284 commandes terminées"** are defaults in `SellerCard`
  (`seller_card.dart:17-18`) because `product_detail.dart` never passes real values
- `product_detail.dart:482` has hardcoded `shortDescription`
- Tapping seller card opens mock data (`SellerMockData.demoSeller()`)

### Proposed fix
- Thread real `rating`/`ordersCompleted` from backend DTO to `SellerCard`
- Fix seller-card tap to open real seller profile via `GET /v1/sellers/:id`
- Remove hardcoded description constant

---

<a name="issue-22"></a>
## ISSUE-22 — Cart image loading fails (AssetBundle error) 🟡

### Symptom (reported)
Exception in cart when loading listing images from Supabase Storage:
```
Unable to load asset: "https://eoxrrofpdtrwjbhywcvz.supabase.co/storage/v1/..."
Exception: Asset not found
```

### Root cause — **wrong image provider type**
Supabase URLs are being passed to `AssetImage` instead of `NetworkImage`. The app treats HTTPS URLs as local asset paths.

### Proposed fix
Find where listing/shop images are instantiated and ensure `NetworkImage` (or `CachedNetworkImage`) is used for remote URLs, `AssetImage` only for local assets.

---

<a name="issue-23"></a>
## ISSUE-23 — Payment method list saturating; should show only Stripe + wallet 🟡

### Symptom (reported)
When making a payment, numerous payment options appear, "saturating" the UI.

### Root cause — **demo payment methods**
`payment.dart:41-58` shows fake saved cards (Mastercard, PayPal, Apple Pay, Google Pay, wallet with €12.00). Only Stripe card actually works.

### Proposed fix
- Simplify to show only:
  - Stripe (card) — functional
  - Wallet — if/when implemented
- Hide demo PayPal/Apple/Google Pay until implemented
- Remove fake €12.00 wallet balance

---

<a name="issue-24"></a>
## ISSUE-24 — Shop location marker doesn't open real map app 🟡

### Symptom (reported)
When viewing a seller's location on the map in-app, tapping the marker/location should open the real Google Maps app for navigation.

### Root cause — **missing deep link**
The map marker tap handler doesn't launch external maps.

### Proposed fix
Add `url_launcher` call with `geo:` or Google Maps URL scheme on map marker tap:
```
https://www.google.com/maps/search/?api=1&query=${lat},${lng}
```

---

<a name="issue-25"></a>
## ISSUE-25 — Home screen map markers need visual update 🟢

### Symptom (reported)
Change the markers appearing in the clickable map icon on client home screen.

### Root cause — **design preference**
Current markers are functional but may not match updated design guidelines.

### Proposed fix
Update marker assets/icons in the map implementation. Needs design decision on new marker style.

---

<a name="issue-26"></a>
## ISSUE-26 — Driver "Go Online" button active when KYC not approved 🟡

### Symptom (reported)
When clicking "Go Online" with unvalidated KYC, a 403 error appears:
```json
{"message": "Driver KYC must be APPROVED before going online"}
```
The button should be disabled with a clear reason shown.

### Root cause — **frontend state not gated**
The driver home screen doesn't check KYC status before enabling the online button.

### Proposed fix
- Disable "Go Online" button when KYC != APPROVED
- Show deactivation reason inline (e.g., "Complete KYC verification to go online")
- Map KYC state to button style (disabled + tooltip/badge)

---

<a name="issue-27"></a>
## ISSUE-27 — Driver signup area search has 5 static options 🟡

### Symptom (reported)
In driver account creation, when adding a work area/location, there are 5 static options and search doesn't work.

### Root cause — **frontend stub**
Area selection is hardcoded instead of using Google Places autocomplete.

### Proposed fix
Replace static options with `GoogleMapAddressPicker` or similar Places search to allow dynamic location/area selection.

---

<a name="issue-28"></a>
## ISSUE-28 — Keyboard lacks "Done" button across the app 🟡

### Symptom (reported)
When filling forms in the app, the keyboard doesn't have an OK/Done button to dismiss it.

### Root cause — **platform-level keyboard configuration**
iOS/Android keyboard behavior depends on `TextInputAction` and `keyboardType` configuration. Flutter's `TextField` defaults may not show Done button in all contexts.

### Proposed fix
Ensure form fields use appropriate `TextInputAction.done` on the last field, and consider adding a visible "Done" bar above the keyboard (accessory view) for complex forms.

---

<a name="issue-29"></a>
## ISSUE-29 — Add product form keyboard overshadows screen 🟡

### Symptom (reported)
In the add plate/dish form, when clicking a field, the screen doesn't adjust based on keyboard — keyboard overshadows the content.

### Root cause — **frontend layout (related to ISSUE-11)**
The form doesn't pad for `MediaQuery.viewInsets.bottom` or scroll focused fields into view.

### Proposed fix
- Wrap form content in `Padding(bottom: MediaQuery.viewInsets.bottom)`
- Use `ScrollController` + `ensureVisible` on text field focus
- Add unfocus-on-tap-outside gesture

---

# Client-reported app bugs (round 4 — 2026-07-19)

<a name="issue-30"></a>
## ISSUE-30 — Second seller account sharing an Apple ID hits Apple's native "already subscribed" sheet 🟡

### Symptom (reported / screenshot)
"En utilisant un autre compte, il m'indique que je dispose déjà d'un
abonnement." Tapping to subscribe on a **different** backend seller account
(same device) shows Apple's own native StoreKit sheet — "Abonnement requis" →
"Vous êtes déjà abonné — Votre abonnement à Le Bon Fait Maison Standard sera
renouvelé le 8 juil. 2026… touchez Gérer" — instead of a purchase sheet. The
green card + "Gérer"/"OK" buttons + the mandatory beta-tester disclaimer are
Apple's own UI, not anything IncaCook renders.

### Root cause — **not (only) a code bug: Apple ties the entitlement to the Apple ID, not our app account**
- App Store subscriptions are scoped to **(Apple ID × subscription group)**.
  The same Apple ID/sandbox tester already holding an active "Fait Maison"
  subscription under seller-account A cannot hold a second, independent one
  under seller-account B on the same device — iOS intercepts the purchase
  attempt itself, before `Purchases.purchase()` in
  `lib/core/services/revenuecat_service.dart` even returns. No app code
  causes this dialog; it's an inherent platform constraint, not something we
  can suppress.
- **What IS a real gap: nothing in our code handles this outcome.**
  - `RevenueCatService.purchase()` (`lib/core/services/revenuecat_service.dart:179-193`)
    only special-cases `PurchasesErrorCode.purchaseCancelledError`; any other
    result — including whatever this dialog resolves to — falls through to a
    generic `"Abonnement impossible. Veuillez réessayer."` with no
    explanation or recovery path (e.g. pointing at "Restaurer mes achats").
  - Server-side, `RevenueCatWebhookHandlerService.handleEvent`
    (`IncaCook-Server/src/modules/payments/webhooks/revenuecat-webhook-handler.service.ts:55`)
    explicitly no-ops `TRANSFER` events: `// TEST / TRANSFER /
    SUBSCRIBER_ALIAS / etc. — nothing to apply.` If RevenueCat's dashboard
    "Transfer Behavior" (default: transfer to the new app_user_id) ever moves
    this entitlement from seller A to seller B, the backend never learns
    about it via webhook — activation for B would depend entirely on the
    client's own post-purchase `syncSubscription()` call happening to catch
    the transferred `CustomerInfo`, which is unverified.
- **Status: traced via code inspection, not confirmed on a physical device**
  (no device available in this pass) — the mechanism above fully explains the
  screenshot, but the exact `PlatformException` code / `CustomerInfo` state
  `Purchases.purchase()` returns after the user dismisses this specific sheet
  needs a real sandbox repro to pin down before writing the fix.

### Decision — block with a clear message (2026-07-19)
Chosen over transfer-and-activate: matches "one Apple ID = one seller" as an
explicit product rule, and avoids the added complexity of wiring the
currently-inert `TRANSFER` webhook + deciding what happens to seller A's
`SellerProfile` when an entitlement moves.

### Fix implemented
`RevenueCatService.purchase()` (`lib/core/services/revenuecat_service.dart`)
now special-cases two RevenueCat error codes documented for "this store
receipt is already tied to a *different* app_user_id" —
`receiptAlreadyInUseError`, `receiptInUseByOtherSubscriberError` — and throws
a `RevenueCatException` with an explanatory French message ("Cet identifiant
Apple/Google dispose déjà d'un abonnement actif sur un autre compte vendeur.
Un seul compte vendeur par identifiant.") instead of the generic "Abonnement
impossible. Veuillez réessayer." `productAlreadyPurchasedError` is
deliberately **not** included — that code fires when the *same* app_user_id
already owns the product (e.g. a double-tap on subscribe), which the generic
message already handles correctly; bundling it in would misfire the
cross-account message on an unrelated case. The seller paywall
(`seller_subscription_view.dart`) already surfaces
`RevenueCatException.message` verbatim via a snackbar, so no UI change was
needed.

**Required companion action — not code, a dashboard setting.** The client-side
catch above only fires if `Purchases.purchase()` actually throws one of those
codes. RevenueCat's project-level **Transfer Behavior** setting controls what
happens instead: if it's left on its default ("Transfer to new App User ID"),
RevenueCat may silently move the entitlement to seller B's app_user_id and
return a *successful* `CustomerInfo` — no exception, so this fix's catch block
never runs and the block-vs-transfer decision is silently overridden by the
dashboard config. To make "block" actually hold, the RevenueCat dashboard
Transfer Behavior must be set to keep the entitlement with the original
app_user_id (not auto-transfer).

**✅ Confirmed 2026-07-20** — dashboard was on "Transfer to new App User ID"
(the default); changed to "Keep with original App User ID." See config
checklist below.

**✅ Confirmed on physical device — 2026-07-20.** Reproduced on iPhone d'Ali
(real sandbox, not simulator/StoreKit file): attempted to subscribe under a
second seller account while the sandbox tester already held an active
subscription under a different account. `Purchases.purchase()` threw
`PurchasesErrorCode.receiptAlreadyInUseError` — exactly one of the two codes
this fix catches — and the app showed the new explanatory message instead of
the generic "Abonnement impossible." Log: `[RevenueCat] purchase blocked:
already-subscribed-elsewhere code=PurchasesErrorCode.receiptAlreadyInUseError`.
Both open items (Transfer Behavior dashboard setting + on-device repro) are
now closed — **ISSUE-30 fully verified, no further work needed.**

---

## Cross-cutting config checklist (Railway env + dashboards)

- [ ] `REVENUECAT_WEBHOOK_AUTH_TOKEN` set in Railway **and** RevenueCat webhook (ISSUE-1, 3)
- [ ] `REVENUECAT_SECRET_API_KEY` set in Railway (server-side sync verify)
- [x] RevenueCat dashboard **Transfer Behavior** set to "Keep with original
      App User ID" (was "Transfer to new App User ID", the default) — set
      2026-07-20 (ISSUE-30 — required for the "block, don't transfer"
      decision to actually hold; the default setting would have silently
      overridden it)
- [ ] Stripe webhook endpoint listens to **connected-account** `account.updated` (ISSUE-3)
- [ ] `STRIPE_WEBHOOK_SECRET` matches the endpoint (ISSUE-3)
- [x] `STRIPE_ONBOARDING_RETURN_URL` / `REFRESH_URL` → backend HTTPS bridge routes that bounce to `incacook://stripe/...` (ISSUE-2)
- [x] `incacook://stripe/...` registered in iOS Info.plist + Android intent-filter; `app_links` catcher extended; iOS Flutter auto-routing disabled (ISSUE-2)
- [x] Mobile Firebase initializes with explicit Android/iOS `DefaultFirebaseOptions` before FCM token registration (iOS `[core/not-initialized]` fix)
- [ ] Firebase dashboard has the iOS APNs auth key/cert uploaded for production iOS push delivery
- [ ] App Store products "Prêt à soumettre" + group localized + propagated (ISSUE-5)
- [ ] Decide RevenueCat-vs-Stripe canonical subscription source (ISSUE-4)
- [ ] Server-side `GOOGLE_MAPS_API_KEY` set in Railway (Geocoding API) — GAP-9
- [x] **Apply the `20260702170000_notifications_inbox` migration on deploy** (`prisma migrate deploy`) — GAP-5 inbox has the `Notification` table
</content>
</invoke>
