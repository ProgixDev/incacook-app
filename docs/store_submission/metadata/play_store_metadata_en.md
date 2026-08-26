# Google Play Console — IncaCook (EN)

## Identity
- **App name** (30 char. max): `IncaCook`
- **Package name**: `com.incacook.app`
- **Category**: Food & Drink
- **Contact details**: support email to fill in (required in Play Console)

## Short description (80 char. max)
```
Homemade meals delivered near you. Sell or deliver with IncaCook.
```
(66 characters)

## Full description (4000 char. max)
```
IncaCook connects three worlds: food lovers who want home-cooked meals, home cooks who want to sell their dishes, and drivers who want to earn on their own schedule.

🍲 FOR BUYERS
• Discover homemade dishes near you
• Order in a few taps and track your delivery live on the map
• Pay securely by card
• Rate and message sellers through in-app chat

👩‍🍳 FOR SELLERS
• Build your dish catalog in minutes
• Manage orders, earnings, and your subscription from a dedicated dashboard
• Buy ingredients through the built-in supplier catalog
• Get paid directly to your bank account

🛵 FOR DRIVERS
• Go online whenever you want, accept deliveries near you
• Follow your pickup and drop-off route on the map
• Set up payouts in minutes and track your earnings
• Quick, simple identity verification (KYC) to get started safely

🔒 SAFETY & TRUST
• Identity verification (KYC) for sellers and drivers
• Report and block tools in messaging
• Sign in with Google

The taste of home, close to home.
```

## Graphic assets
| Asset | Play spec | File provided |
|---|---|---|
| High-res icon | 512×512 PNG, 32-bit with alpha | `android/icon_512.png` |
| Feature graphic | 1024×500 PNG/JPEG, no alpha | `android/feature_graphic_1024x500.png` |
| Phone screenshots | 2–8, 16:9 to 9:16 ratio, min 320px | `android/screenshots_phone/*.png` (1080×1920) |
| 7-inch tablet screenshots | Up to 8, 16:9 or 9:16 ratio, 320–3840px per side, ≤8MB, PNG/JPEG | `android/screenshots_tablet_7in/*.png` (1440×2560, exact 9:16) |

## Store listing details
- **App label** (launcher icon name on Android): already "IncaCook" (`android:label` in `AndroidManifest.xml`)
- **Promo video**: optional, not provided
- **Target audience**: 18 and over (real payments, seller/driver accounts requiring KYC) — set this in "Target audience and content"

## Privacy Policy
`https://incacook-admin.vercel.app/privacy` (page content is French-only — see note below)

## User account / Account deletion (the "Username and other authentication" section)
- **"My app does not allow users to create an account"** → Leave unchecked — the app does allow account creation (buyer/seller/driver).
- **Delete account URL**: `https://incacook-admin.vercel.app/data-deletion` (also French-only)
  - This page (updated 2026-08-26) satisfies Google's 3 requirements: it names IncaCook, spells out the steps (in-app first: Settings → "Delete my account"; email as a fallback), and explicitly states what data is deleted immediately (KYC, avatar, push tokens, buyer profile, login access) vs anonymized and retained indefinitely (orders, reviews, wallet, seller/driver profile, audit log) vs subject to a legal retention obligation (accounting/tax).
  - Don't confuse this with the Privacy Policy URL (separate field, above) — Play Console asks for both.

## Data safety
To declare in Play Console → Policy → Data safety:
- **Precise location** — collected AND shared with the driver during an active order; used for app functionality (delivery), not advertising. Background tracking (driver) is backed by a real Android foreground service (`ACCESS_BACKGROUND_LOCATION` + `FOREGROUND_SERVICE_LOCATION`, persistent "Delivery in progress" notification — verified in code, see the Permissions section below).
- **Personal info** (name, email, phone, address) — collected, required to create an account.
- **ID/verification info (sensitive)** — KYC selfie + ID document, required for seller/driver functionality. On-device face validation before upload; explicit consent required before capture (#55). Declare under an identity-verification category separate from "Photos" if Play Console offers one.
- **Financial info** — processed via Stripe (Connect model); IncaCook doesn't store card data, only a `stripeCustomerId` reference.
- **Messages** (buyer-seller chat) — collected, not shared with third parties, moderated with report/block (#54).
- **Encrypted in transit**: check Yes — all API requests go over HTTPS (no unencrypted `http://` endpoint found in the code, see the 2026-08-24 App Store audit).
- **In-app account deletion**: check Yes — implemented (#51); reference the URL above.
- **Third-party advertising/tracking**: check No — no ad or attribution SDK identified.

## Content rating questionnaire (IARC)
- Category: Utility / Productivity / Shopping (not "Social Networking" unless chat is public)
- Answer "No" to violence/sex/drugs content
- "Does the app let users communicate with each other?" → **Yes** (buyer-seller chat, moderated with report/block)
- "Does the app share location with other users?" → **Yes** (real-time delivery tracking)
→ Expected result: a moderate rating depending on the exact answers (unmoderated user interaction descriptors can push the rating up — note that moderation exists wherever the questionnaire allows it)

## Release notes — first release
```
The first version of IncaCook: order homemade meals, become a seller or driver, and track everything in real time.
```

## Android permissions — necessity audit (verified 2026-08-26)

Every permission declared in `android/app/src/main/AndroidManifest.xml` was
checked against real code usage — no unused permission found, no missing
permission identified:

| Permission | Justified by | Status |
|---|---|---|
| `INTERNET` | All API calls | ✅ |
| `ACCESS_FINE_LOCATION` / `ACCESS_COARSE_LOCATION` | `geolocator` — driver map, delivery tracking, address search ("use my location") | ✅ |
| `ACCESS_BACKGROUND_LOCATION` | `location_service.dart` — driver location tracking during an active delivery, app backgrounded | ✅ |
| `FOREGROUND_SERVICE` / `FOREGROUND_SERVICE_LOCATION` | Real Android foreground service confirmed in code (`ForegroundNotificationConfig`, `location_service.dart:141-157`) with a persistent "Delivery in progress" notification — not a just-in-case declaration | ✅ |
| `CAMERA` | Dish photos, KYC selfie (`image_picker`) | ✅ |
| `POST_NOTIFICATIONS` | FCM push (orders, delivery status) | ✅ |
| `USE_BIOMETRIC` / `USE_FINGERPRINT` | Optional biometric login (`local_auth`) | ✅ |

**No `RECORD_AUDIO`** on Android — consistent with removing
`NSMicrophoneUsageDescription` on iOS the same day: the mic button in chat
(`chat_input_field.dart`) is an `onPressed: widget.onMic ?? () {}` — a no-op,
no audio-recording feature exists.

**No `READ/WRITE_EXTERNAL_STORAGE`** — not needed, `image_picker` and
`path_provider` use the app's scoped storage.

## Google Play points of attention
- **Sensitive user data policy**: KYC (selfie + face detection) must be justified in Data Safety and comply with the Personal and Sensitive Info policy.
- **App bundle**: publish a signed `.aab` (App Bundle), not a raw APK — `melos run build:android:aab`.
- **Target API level**: `targetSdk`/`compileSdk` are inherited from the installed Flutter SDK (`android/app/build.gradle.kts:53,72-73`), not a fixed value in the repo — verify with `melos run verify:android:manifest` on the machine that actually produces the submission build (see #62, still open).

## Note on screenshots
The app's UI is French-only (no English localization layer exists in the codebase). Screenshots generated for this listing (`docs/store_submission/android/`) show real French UI with French marketing headlines overlaid — intentional, since users will see French text regardless of the Play listing language. A genuinely English-UI screenshot set would require localizing the app first.
