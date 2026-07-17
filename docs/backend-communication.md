# How the app talks to the backend

This is a snapshot of what the Flutter app actually does today — not what
the backend will eventually support, not what's been spec'd. If you want to
know "is feature X wired up right now?", read this.

The app **only ever talks to the IncaCook backend**. It never calls Supabase
directly (the one exception is the second leg of the file-upload flow — a
raw `PUT` to a signed Supabase Storage URL the backend hands us). Single
base URL, single auth surface.

---

## 1. Base URL & build flags

The base URL is a compile-time constant resolved from `--dart-define`s, in
priority order (from
[lib/core/constants/api_constants.dart](../lib/core/constants/api_constants.dart)):

```dart
static const String _apiBaseUrlOverride = String.fromEnvironment('API_BASE_URL');
static const String _lanApiBaseUrl = String.fromEnvironment('LAN_API_BASE_URL');
static final String baseUrl = _resolveBaseUrl(); // override → LAN → local default
```

1. `API_BASE_URL` — explicit override; **production builds MUST pass this**
   (e.g. `https://incacook-api-production-146b.up.railway.app`).
2. `LAN_API_BASE_URL` — your PC's IPv4, for testing on a real phone on the
   same Wi-Fi.
3. No define at all → a **local dev default** (`http://10.0.2.2:3000` on
   the Android emulator, `http://localhost:3000` elsewhere) — deliberately
   never a production host, so a build that forgets to pass `API_BASE_URL`
   fails loudly (connection refused) instead of silently talking to the
   wrong deployment.

All endpoints are mounted under `/v1`.

| Where you build | Command |
|---|---|
| Production | `flutter run --dart-define=API_BASE_URL=https://incacook-api-production-146b.up.railway.app` |
| Local backend on iOS simulator | `flutter run` (uses the `localhost:3000` default) |
| Local backend on Android emulator | `flutter run` (uses the `10.0.2.2:3000` default) |
| Local backend, real device on Wi-Fi | `flutter run --dart-define=LAN_API_BASE_URL=http://<your-pc-ip>:3000` |
| Staging / another env | `--dart-define=API_BASE_URL=https://…` |

Other `--dart-define` keys consumed today:

- `MAPBOX_PUBLIC_TOKEN` — passed to the Mapbox SDK in [lib/main.dart](../lib/main.dart).

---

## 2. The HTTP client

Single Dio instance, wrapped in a GetX service:
[lib/core/network/api_client.dart](../lib/core/network/api_client.dart).

- Base URL = `apiBaseUrl + /v1`.
- `connectTimeout`, `receiveTimeout`, `sendTimeout` all 30 s.
- Default headers: `Content-Type: application/json`, `Accept: application/json`.
- Interceptors, in order:
  1. **`AuthInterceptor`** — attaches the bearer, handles 401 refresh.
  2. **`PrettyDioLogger`** — request/response logging in dev.

Repositories don't talk to Dio directly. They call the typed wrappers on
`ApiClient` (`get<T>`, `post<T>`, `patch<T>`, `put<T>`, `delete<T>`), each
of which decodes the response envelope and returns `ApiSuccess<T>` (or
throws `ApiFailure`).

---

## 3. Response envelope

The backend always returns the same wrapper, decoded in
[lib/core/network/api_response.dart](../lib/core/network/api_response.dart).

**Success:**
```json
{
  "success": true,
  "data": { ... },
  "meta": { "timestamp": "...", "version": "v1" },
  "pagination": { "hasMore": false, "total": 12, "nextCursor": null, "page": null, "limit": null }
}
```

**Error:**
```json
{
  "success": false,
  "error": {
    "statusCode": 409,
    "code": "INCACOOK_CONFLICT",
    "message": "…",
    "correlationId": "01K…",
    "details": { … }
  }
}
```

On the Dart side:

- `ApiSuccess<T>(data, pagination?)` — what `ApiClient` returns on `2xx` +
  `success: true`.
- `ApiFailure` — thrown on `success: false` or on transport errors. Carries
  `statusCode`, `code`, `message`, `correlationId`, `details`.
- `Pagination` — mirrors the wire shape (`hasMore`, `total`, `nextCursor`,
  `page`, `limit`).

Repositories let `ApiFailure` propagate. Controllers branch on `failure.code`
(see [error_codes.dart](../lib/core/network/error_codes.dart) for the stable
constants like `INCACOOK_UNAUTHORIZED`, `INCACOOK_VALIDATION`, etc.).
**`correlationId` is parsed and kept on `ApiFailure` but is not yet shown
anywhere in the UI** — it only appears in `toString()`. When we add a
"contact support" surface, surfacing it is one line.

---

## 4. Auth, tokens, and the refresh dance

### Token storage

Tokens live in `flutter_secure_storage` (Keychain on iOS,
EncryptedSharedPreferences on Android) via
[lib/core/network/token_storage.dart](../lib/core/network/token_storage.dart).
Registered as a permanent GetX service before `ApiClient`, so the
interceptor can always read it.

Keys persisted:

- `incacook.access_token`
- `incacook.refresh_token`
- `incacook.expires_at`
- `incacook.auth_email`
- `incacook.auth_first_name`, `incacook.auth_last_name` — JWT name claims,
  used to pre-fill Gate 2 for first-time Google sign-ups.

`TokenStorage.clear()` wipes all six in parallel. Called on signout and on
a failed refresh.

### Bearer attachment

[`AuthInterceptor`](../lib/core/network/auth_interceptor.dart) attaches
`Authorization: Bearer <accessToken>` to every request unless the call
opts out via the `skipAuth()` Options extension. Public endpoints that
opt out today: `/auth/signin`, `/auth/signup`, `/auth/google`,
`/auth/refresh`, `/auth/password/reset-request`, `/charters/active`.

### 401 → refresh → replay

On a `401` response from any non-`/auth/refresh` request, the interceptor:

1. Checks the request hasn't already been retried (avoids loops).
2. Acquires a single-flight `_refreshCompleter` — concurrent 401s from a
   burst of parallel requests all await the same refresh future instead
   of racing it.
3. Uses a **bare** Dio (no interceptors) to call
   `POST /v1/auth/refresh` with `{ refreshToken: ... }`.
4. On success: stores the new tokens via `TokenStorage.writeTokens()`
   (preserving identity claims), marks the original request as retried,
   replays it, and resolves the queued waiters with their replays.
5. On failure: clears tokens and lets the error bubble. The UI is
   responsible for routing back to signin (we don't navigate from inside
   the interceptor).

Access token TTL is 1 hour. The refresh token lives until explicit signout.

### Google Sign-In

Through the native `google_sign_in` plugin only — Dart never makes HTTP
calls to Google. The plugin returns an ID token whose `aud` is the
**Web** OAuth client ID (required for Supabase to accept it on the
backend), and we post it to `POST /v1/auth/google` for the same session
shape as email signup.

The `serverClientId` parameter on both iOS and Android must be the Web
client ID. If it isn't, the backend returns `400 Bad ID token` with an
audience mismatch.

### Password reset deep link

`POST /v1/auth/password/reset-request` triggers Supabase to email a magic
link. The link uses the `incacook://auth/recover#…` scheme, the app
parses the fragment, stores the recovery tokens, then calls
`POST /v1/auth/password/update` with the new password and the recovery
bearer.

---

## 5. The signup wizard's two gates

The wizard
([signup_flow_controller.dart](../lib/features/authentication/controllers/signup_flow_controller.dart))
has two committed points:

- **Gate 1 — `POST /v1/auth/signup`**
  Issues a JWT immediately. From here on, every wizard step is an
  authenticated call.
- **Gate 2 — `POST /v1/users`** (`UsersRepository.completeProfile`)
  Creates the IncaCook User aggregate + role stub, and records CGU/CGV
  acceptance. **Sent with a fresh ULID `Idempotency-Key` header** — the
  one endpoint that requires it today.

Cold-start resume hits `GET /v1/users/me/onboarding`, which returns a
cursor pointing at the next incomplete step regardless of which device
the user signed up on.

---

## 6. Idempotency and correlation IDs

### Idempotency

`ApiClient.post` accepts `idempotencyKey` (explicit) or
`requiresIdempotencyKey: true` (auto-generates a ULID). When set, the
request carries `Idempotency-Key: <ULID>` and the backend dedupes for 24 h.

| Endpoint | Idempotency today |
|---|---|
| `POST /v1/users` (Gate 2) | Yes, ULID auto-generated |
| `POST /v1/orders`, Stripe writes | Spec'd, not wired (order placement isn't built yet) |
| `POST /v1/listings`, `POST /v1/kyc/documents` | Not sent today (server is idempotent on its own keys) |

### Correlation IDs

Captured into `ApiFailure.correlationId`. Not surfaced in the UI yet —
no error screen reads it. Easy to add when needed.

---

## 7. Repositories — what's actually wired

All repositories live under
[lib/features/.../data/repositories/](../lib/features/) and are registered
as permanent services in [lib/main.dart](../lib/main.dart) (lines 43–55),
**except `ListingsRepository`, which is defined but not registered yet** —
it's currently a `GetxService` that no `Get.put` call instantiates, so
`Get.find<ListingsRepository>()` will fail at runtime until that's added.

### Auth — [`AuthRepository`](../lib/features/authentication/data/repositories/auth_repository.dart)

| Method | Endpoint |
|---|---|
| `signup` | `POST /v1/auth/signup` |
| `signin` | `POST /v1/auth/signin` |
| `googleSignIn` | `POST /v1/auth/google` |
| `signout` | `POST /v1/auth/signout` (always clears local tokens, even on failure) |
| `requestPasswordReset` | `POST /v1/auth/password/reset-request` (no bearer) |
| `updatePassword` | `POST /v1/auth/password/update` |
| `requestPhoneOtp` | `POST /v1/auth/phone/request-otp` |
| `verifyPhoneOtp` | `POST /v1/auth/phone/verify` |
| `requestEmailOtp` | `POST /v1/auth/email/request-otp` (temporary SMS-down fallback) |
| `verifyEmailOtp` | `POST /v1/auth/email/verify` |

### Users — [`UsersRepository`](../lib/features/authentication/data/repositories/users_repository.dart)

| Method | Endpoint | Notes |
|---|---|---|
| `completeProfile` | `POST /v1/users` | Gate 2, idempotent ULID header |
| `fetchMe` | `GET /v1/users/me` | Full aggregate |
| `fetchOnboarding` | `GET /v1/users/me/onboarding` | Resume cursor |
| `acceptCharter` | `POST /v1/users/me/charters` | Per-charter acceptance |
| `upsertAddress` | `PUT /v1/users/me/addresses/:kind` | Address by kind |

### Charters — [`ChartersRepository`](../lib/features/authentication/data/repositories/charters_repository.dart)

- `GET /v1/charters/active` — **public** (skips bearer). Active version per
  charter family (CGU, CGV, HYGIENE, FAIT_MAISON, PUNCTUALITY, CARE).

### Buyers — [`BuyersRepository`](../lib/features/authentication/data/repositories/buyers_repository.dart)

- `PUT /v1/buyers/me/preferences` — dietary tags + allergens (wholesale
  replace; empty arrays allowed).

### Sellers — [`SellersRepository`](../lib/features/authentication/data/repositories/sellers_repository.dart)

- `PUT /v1/sellers/me/profile` — category, display name, etc. First PUT
  for a fait-maison seller flips `kycStatus` to APPROVED server-side.
- `PUT /v1/sellers/me/business` — business info + opening hours. Rejects
  with `400` for fait-maison.
- `PUT /v1/sellers/me/cuisines` — wholesale replace of both cuisine sets.

### Drivers — [`DriversRepository`](../lib/features/authentication/data/repositories/drivers_repository.dart)

- `PUT /v1/drivers/me/vehicle` — vehicle type + DOB.
- `PUT /v1/drivers/me/zones` — operating zones (wholesale replace).

### KYC — [`KycRepository`](../lib/features/authentication/data/repositories/kyc_repository.dart)

- `POST /v1/kyc/documents` — submit a doc. Idempotent on
  `(user, document_type)`; re-uploading resets review state to PENDING.
- `GET /v1/kyc/documents/me` — list the caller's documents.

### Uploads — [`UploadsRepository`](../lib/features/authentication/data/repositories/uploads_repository.dart)

Two-step flow:

1. `createUpload()` → `POST /v1/uploads` → backend returns
   `{ signedUrl, storageKey }`.
2. `putFile()` → bare `PUT <signedUrl>` directly to Supabase Storage,
   bypassing both the IncaCook backend and the auth interceptor.

The convenience method `upload()` chains both. Used by KYC, profile
photos, business facade photos, and (when the seller flow is wired)
listing images. The storage key returned by step 1 is what gets stored
on the resource that owns the file.

### Listings — [`ListingsRepository`](../lib/features/catalog/data/repositories/listings_repository.dart)

Implemented but **not registered**. The endpoints it wraps:

| Method | Endpoint |
|---|---|
| `create` | `POST /v1/listings` |
| `update` | `PATCH /v1/listings/:id` |
| `softDelete` | `DELETE /v1/listings/:id` |
| `setAvailability` | `PATCH /v1/listings/:id/availability` |
| `feed` | `GET /v1/listings` |
| `getById` | `GET /v1/listings/:id` |
| `mySellerListings` | `GET /v1/sellers/me/listings` |

Wiring this into `main.dart` and pointing the seller's `AddProductSheet`
and the buyer's `ClientHomeScreen` at it is the next step to remove
`SellerProductMockData` and `ClientMockData` from those screens.

---

## 8. Mock vs real data, today

| Mock file | Status |
|---|---|
| [`MapMockData`](../lib/features/map/data/map_mock_data.dart) | **Still in use** — supplies the demo pins around central Paris in `MapController`. |
| [`SellerProductMockData`](../lib/features/seller/data/seller_product_mock_data.dart) | Still in use until `ListingsRepository` is wired into the seller dashboard. |
| [`ClientMockData`](../lib/features/client/data/client_mock_data.dart) | Still in use on the buyer feed for the same reason. |
| `OrderMockData`, `DeliveryDriverMockData`, `OrderRequestMockData`, `AcceptedOrderMockData` | Present, no real-backend equivalents yet — order/delivery endpoints aren't built. |

Mock-data screens will switch over endpoint-by-endpoint as the backend
lands and the corresponding repository gets registered.

---

## 9. Pagination

When a list endpoint returns a `pagination` block, `ApiSuccess<T>.pagination`
is non-null. The shape supports both styles the backend uses:

- **Cursor** (feeds, infinite scroll): `hasMore` + `nextCursor`.
- **Offset/page** (admin/moderation lists): `page`, `limit`, `total`,
  `hasMore`.

The repository decoders just pass the `Pagination` object up; controllers
decide how to use it.

---

## 10. Things to know when adding a new endpoint

- Add the wrapper method to the appropriate repository under
  `lib/features/<feature>/data/repositories/`. If the feature doesn't have
  one yet, create the repository and **register it in
  [lib/main.dart](../lib/main.dart)** alongside the others.
- Use the typed `ApiClient.get/post/patch/put/delete<T>` methods. Pass a
  `decoder` that builds the model from the `data` map.
- Public endpoints opt out of bearer with
  `options: AuthInterceptor.skipAuth()`.
- Mutating creates that should be safe to retry: pass
  `requiresIdempotencyKey: true` on `post`, or generate the key
  explicitly with `Ulid().toString()`.
- Branch on `ApiFailure.code` in controllers, never on `message`. Add
  new codes to [error_codes.dart](../lib/core/network/error_codes.dart)
  as the backend introduces them.
- File uploads use the two-step flow in `UploadsRepository` — never
  pipe a file through a regular endpoint.

---

## 11. Common pitfalls

- **Calling Supabase directly from Dart.** The one legit exception is the
  signed-URL `PUT` inside `UploadsRepository.putFile()`. Anywhere else,
  go through the backend.
- **Storing tokens in `SharedPreferences`.** Always `TokenStorage`.
- **Showing `error.message` for 5xx.** These can be internal noise.
  Show a generic copy plus (once it's surfaced) the `correlationId`.
- **Forgetting to register a new repository in `main.dart`.** GetX will
  throw at the first `Get.find`. The current `ListingsRepository` gap is
  exactly this — file exists, registration doesn't.
- **Refreshing without single-flight protection.** Don't write your own
  refresh logic; the interceptor already queues concurrent 401s.

---

## 12. Where to look next

- Network plumbing: `lib/core/network/`.
- All wired repositories: registered list in
  [`main.dart` lines 43–55](../lib/main.dart#L43-L55).
- Stable error codes: [error_codes.dart](../lib/core/network/error_codes.dart).
- Signup wizard end-to-end: [signup-flow.md](./signup-flow.md).
- Running the backend locally: [local-testing.md](./local-testing.md).
- Schema source of truth: [BACKEND_SCHEMA.md](../BACKEND_SCHEMA.md).
