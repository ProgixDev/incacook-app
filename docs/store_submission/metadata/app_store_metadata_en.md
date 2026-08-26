# App Store Connect — IncaCook (EN)

## Identity
- **App name** (30 char. max): `IncaCook`
- **Subtitle** (30 char. max): `Homemade meals, delivered fast` (31 char. — trim to fit, e.g. `Homemade meals, delivered` at 26 char.)
- **Bundle ID**: `com.incacook.app`
- **SKU**: `incacook-ios` (or existing one if already created)
- **Primary category**: Food & Drink
- **Secondary category**: Shopping
- **Copyright**: `© 2026 IncaCook`

## Promotional text (170 char. max — editable without a new version)
```
Order homemade meals near you, or become an IncaCook seller or driver. Secure payment, real-time tracking.
```

## Description (4000 char. max)
```
IncaCook connects three worlds: food lovers who want home-cooked meals, home cooks who want to sell their dishes, and drivers who want to earn on their own schedule.

FOR BUYERS
• Discover homemade dishes near you
• Order in a few taps and track your delivery live on the map
• Pay securely by card
• Rate and message sellers through in-app chat

FOR SELLERS
• Build your dish catalog in minutes
• Manage orders, earnings, and your subscription from a dedicated dashboard
• Buy ingredients through the built-in supplier catalog
• Get paid directly to your bank account

FOR DRIVERS
• Go online whenever you want, accept deliveries near you
• Follow your pickup and drop-off route on the map
• Set up payouts in minutes and track your earnings
• Quick, simple identity verification (KYC) to get started safely

SAFETY & TRUST
• Identity verification (KYC) for sellers and drivers
• Report and block tools in messaging
• Optional biometric login (Face ID / Touch ID)
• Sign in with Apple or Google

The taste of home, close to home.
```

## Keywords (100 char. max, comma-separated, no space after commas)
```
homemade food,meal delivery,local cooking,home cook,food delivery driver,homemade meals,foodtech
```
*(check the exact character count in App Store Connect — adjust if needed; this is a direct translation of the French keyword set, not independently keyword-researched for English-speaking markets)*

## URLs
- **Marketing URL**: TBD (IncaCook marketing site, if one exists — otherwise leave blank)
- **Support URL**: TBD — no public `/support` page exists on `incacook-admin.vercel.app` yet; use a dedicated support email in the meantime, or build one (the in-app "Get help" button calls `_openSupport()` in `settings.dart` — check what that actually opens before picking the URL here)
- **Privacy Policy URL**: `https://incacook-admin.vercel.app/privacy` (page content is French-only — see note below)
- **Delete Account URL** (if asked separately): `https://incacook-admin.vercel.app/data-deletion` (also French-only)

## What's New — first submission
```
The first version of IncaCook: order homemade meals, become a seller or driver, and track everything in real time.
```

## Age Rating questionnaire
Answer "No" to all sensitive content (violence, adult content, gambling, etc.) except:
- **Unrestricted user-generated content / user-to-user communication** → Yes (buyer-seller messaging) → typically pushes toward a higher age band because of unmoderated UGC, BUT since messaging is moderated (report + block, see #54) and closed (no public discovery of strangers), answer the newer descriptor-based questionnaire accordingly (App Store Connect replaced the old "4+/9+/12+/17+" tiers with descriptors — answer honestly, the rating follows).
- Plan for 18+ minimum to create a seller/driver account given real payments are involved — see the KYC section.

## Privacy (App Privacy / "Nutrition label")
Confirmed data types (from the actual privacy policy content, `incacook-admin` `app/(public)/privacy/page.tsx`):
- **Contact Info**: name, email, phone (account) — Linked to you
- **Location**: precise location (delivery, driver map), including background location for drivers during an active delivery — Linked to you
- **Financial Info**: payment info processed by Stripe (Connect model — IncaCook doesn't store card data, only a reference `stripeCustomerId`) — Linked to you
- **Sensitive Info**: identity-verification photo (KYC selfie), ID document — on-device face validation before upload (see #45), explicit consent required before capture (see #55) — Linked to you
- **User Content**: messages (buyer/seller chat, moderated with report/block — #54), dish photos
- **Identifiers**: user ID, device ID (FCM push token)
- **Diagnostics**: no third-party crash-reporting SDK found in `pubspec.yaml` as of this writing — do not declare Crashlytics/Sentry unless one is added later

**Tracking (ATT)**: No — no ad or attribution SDK collects the IDFA (confirmed, see the 2026-08-24 App Store audit). Don't trigger the App Tracking Transparency prompt.

**Account deletion**: implemented in-app (#51) — mention in "App Privacy" that users can delete their account and data directly in the app.

## Demo account for Apple review
Provide in "App Review Information":
- A test **buyer** account (email + password)
- A test **seller** account with KYC already approved (so the dashboard is reachable without getting blocked)
- A test **driver** account with KYC already approved
- Note: "The seller/driver account requires identity verification (KYC); the provided test account is already approved so the review team can explore every feature."

## Apple guideline points of attention
- **Payments**: meal/delivery payments are physical goods/services → allowed outside In-App Purchase (Guideline 3.1.5). Confirm no digital content is sold through a third-party payment system without IAP.
- **Sign in with Apple**: already implemented (#53) — required since Google/Facebook Sign-In is offered (Guideline 4.8). ✅
- **Account deletion**: already implemented (#51) — required by Guideline 5.1.1(v). ✅
- **User-generated content (chat)**: moderation + report/block already in place (#54) — required by Guideline 1.2. ✅
- **Runtime permissions — verified 2026-08-26**:
  - `NSCameraUsageDescription`, `NSFaceIDUsageDescription`, `NSPhotoLibraryUsageDescription`, `NSLocationWhenInUseUsageDescription`, `NSLocationAlwaysAndWhenInUseUsageDescription`: each maps to a real, used feature. ✅
  - `NSMicrophoneUsageDescription`: **removed from `Info.plist`** — no audio/video recording feature exists anywhere in the code (only `ImagePicker().pickImage`, never `pickVideo`); the description ("video recordings attached to listings") matched nothing real and could have triggered a review question.
  - Remaining language inconsistency (Camera/Face ID in French, Location/Photos in English) was not fixed in this pass (see ticket #60) — no functional impact.

## Note on screenshots
The app's UI is French-only (no localization layer for English strings exists in the codebase). Screenshots generated for this listing (`docs/store_submission/ios/`) show real French UI with French marketing headlines overlaid — this is intentional and accurate, not an oversight, since users will see French text regardless of which App Store listing language they browse in. If a genuinely English-UI screenshot set is wanted later, that requires localizing the app itself first, not just re-rendering these images.
