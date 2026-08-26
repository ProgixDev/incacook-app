# RevenueCat Android + Play Store release setup (#50)

Manual dashboard steps — none of this is scriptable from this repo. Run
`melos run verify:android:keystore` first; you'll need its SHA-1/SHA-256
output in step 2.

**Do not generate a new signing keystore.** One already exists at
`android/keystores/incacook-upload.jks` (alias `incacook_upload`, valid until
2053). Its fingerprint is presumably already registered with Firebase and the
Maps API key restriction — regenerating it would break both and, if the app
has ever been uploaded to Play Console even once, would make future updates
impossible under the same listing.

## 1. Play Console — create the app (if not already done)

1. [play.google.com/console](https://play.google.com/console) → **Create app**.
2. Package name: `com.incacook.app` (must match `applicationId` in
   `android/app/build.gradle.kts:69` exactly — cannot be changed later).
3. Fill the minimum required store listing fields to unlock the rest of the
   console (title, short/full description, at least placeholder graphics —
   real screenshots come later per the general checklist in the audit
   artifact; `assets/screenshots/` isn't submission-ready yet).
4. Complete **App content** → Privacy policy (use the real URL:
   `https://incacook-admin.vercel.app/privacy`), Data safety form, Content
   rating questionnaire, Target audience, Ads declaration.

## 2. Play App Signing — enroll and register the upload key

1. **Release → Setup → App signing**. If not yet enrolled, enroll in Play App
   Signing (required for new apps — Google holds the signing key that
   actually ships to users; your local keystore becomes the **upload key**
   used to authenticate uploads to Google).
2. Run `melos run verify:android:keystore` to get the SHA-1/SHA-256.
3. If this is the app's first-ever upload, Play Console lets you upload the
   **upload certificate** directly during the first release — the `.jks`
   file itself never leaves your machine, only its public certificate does
   (export it: `keytool -export -rfc -keystore android/keystores/incacook-upload.jks -alias incacook_upload -storepass "$(grep -m1 storePassword android/key.properties | cut -d= -f2-)" -file upload_cert.pem`,
   then upload `upload_cert.pem`).
4. **Write down the SHA-1 from step 2** — needed again in steps 4 and 5.

## 3. First release build and upload

1. `melos run build:android:aab` — produces
   `build/app/outputs/bundle/release/app-release.aab`, signed with the
   existing upload key via the `key.properties`-gated config in
   `android/app/build.gradle.kts`.
2. `melos run verify:android:manifest` — confirm
   `com.android.vending.BILLING` made it into the merged manifest (closes
   #58). If it's missing, stop here and investigate the RevenueCat/
   `purchases_flutter` dependency resolution before uploading anything.
3. **Release → Testing → Internal testing** (start here, not Production) →
   **Create release** → upload the `.aab` → add internal testers (your own
   Google account + teammates) → roll out.
4. Wait for Google's processing (usually minutes, occasionally longer on a
   first upload) before continuing — RevenueCat's Play Console link and
   subscription products both need the app to exist in at least one release
   track.

## 4. Google Cloud — service account for RevenueCat

RevenueCat needs API access to Play Console to verify purchases and sync
subscription status server-side.

1. [console.cloud.google.com](https://console.cloud.google.com) → select (or
   create) the project linked to this app.
2. **IAM & Admin → Service Accounts → Create service account** — name it
   something like `revenuecat-play-integration`. No project-level roles
   needed (permissions are granted in Play Console instead, step below).
3. On the created service account → **Keys → Add key → Create new key → JSON**
   — downloads a `.json` credentials file. **Treat this like a password** —
   it grants API access to your Play Console financial/subscription data.
4. In **Play Console → Users and permissions → Invite new users**, invite the
   service account's email (looks like
   `revenuecat-play-integration@<project>.iam.gserviceaccount.com`) with:
   - **Financial data** → View financial data, orders, and cancellation survey
     responses
   - **Play Console access** is not needed beyond that — don't over-grant.

## 5. Google Cloud — restrict the Android Maps key with this SHA-1 (closes #65's Android half)

While you're in Cloud Console: **APIs & Services → Credentials** → the
Android Maps key → **Application restrictions → Android apps** → confirm
`com.incacook.app` + the SHA-1 from step 2 is listed. If Play App Signing is
enrolled (step 2), also add the **Play-managed signing certificate's SHA-1**
(Play Console → Setup → App signing → "App signing key certificate" — a
*different* SHA-1 from your upload key, since Google re-signs the final APK
users download). Missing this is the classic "maps work in internal testing,
blank in production" bug.

## 6. RevenueCat — add the Android app

1. [app.revenuecat.com](https://app.revenuecat.com) → your project → **Apps**
   → **+ New app** → Google Play Store.
2. Package name: `com.incacook.app`.
3. Upload the service-account JSON from step 4.
4. RevenueCat verifies the connection (may take a minute) — once green,
   it generates the **Android SDK key** (`goog_...`). Copy it.

## 7. Wire the Android key into the app

1. Add `REVENUECAT_ANDROID_KEY=goog_...` to `.vscode/dart_defines.json` and
   whatever CI secret store produces release builds (matches the pattern
   already used for `GOOGLE_MAPS_API_KEY` in the same file).
2. Confirm `lib/core/config/revenuecat_config.dart` reads it (it should
   already — this is config, not new code, per the #50 audit finding).
3. Rebuild: `melos run build:android:aab`.

## 8. Play Console — create the subscription products

Product IDs must match what `RevenueCatConfig` in the Flutter app expects
(`RevenueCatConfig.packageStandard` / `packagePremium`, per seller category —
check that file for the exact identifiers before creating anything, so
Play's product IDs match exactly).

1. **Monetize → Products → Subscriptions → Create subscription**.
2. For each seller category × {Standard, Premium}: create a base plan with
   matching pricing to the iOS App Store Connect products (see the parallel
   iOS half of #50 — these should be priced identically per-market).
3. **Important, ties to #59's cross-platform equivalent**: decide whether
   Standard/Premium should be mutually exclusive per category the same way
   iOS's subscription-group decision works. On Play, this means structuring
   them as **base plans within one subscription** (Play's version of an
   Apple subscription group) rather than as fully separate subscription
   products — separate products would let a user hold both simultaneously.
4. Activate each product once pricing and base plans are set.

## 9. RevenueCat — create the offering

1. **Products** tab → confirm the Play Store products from step 8 appear
   (may take a few minutes to sync).
2. **Offerings** → create/edit the offering(s) matching
   `RevenueCatConfig.offeringIdForCategory(...)` in the Flutter code — the
   offering identifiers must match exactly what the app requests.
3. Attach the Standard/Premium packages to each offering.
4. Set the offering **Current** so `Purchases.getOfferings()` returns it.

## 10. End-to-end verification (do this before touching Production track)

1. Install the Internal Testing build on a real device logged in as one of
   the testers added in step 3.
2. Open the seller subscription paywall — confirm real prices load (not the
   `RevenueCatConfig.fallbackPrice` placeholder).
3. Complete a test purchase (Play sandbox purchases are free for licence
   testers) → force-quit → relaunch → confirm the subscription still shows
   active (this is the #52 fix actually being exercised for real).
4. "Restaurer mes achats" re-grants after clearing app data.
5. Only after all of this passes: promote from Internal Testing to
   Production (or Closed/Open testing first, per your usual release process).

## Order dependency summary

Steps 1→2→3 must happen before 4 (service account needs an app + at least
one release to attach to). 4→6 before 7 (need the RevenueCat Android key
before wiring it). 8 can happen any time after 1, but 9 needs 6 and 8 both
done. Do 10 before promoting past Internal Testing, every time — including
after the very first setup.
