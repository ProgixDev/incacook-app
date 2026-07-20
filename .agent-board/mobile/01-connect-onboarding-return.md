# Trace Connect onboarding and payout readiness on Android and iOS

- **GitHub:** [Trace Connect onboarding and payout readiness on Android and iOS](https://github.com/ProgixDev/incacook-app/issues/4)
- **Scope:** mobile + backend callback edge
- **Mode:** AFK research
- **Depends on:** none
- **Produces:** platform sequence diagrams, race analysis, device QA cases

## Question

Does Stripe Connect onboarding reliably return to the app, reconcile live
payout readiness, update the cached user, and hide the home banner on both
Android and iOS, including cold start, warm resume, cancellation, refresh-link,
slow Stripe settlement, and missed webhook scenarios?

Before asserting the expected seller behavior, resolve the client-flow
contradiction: the QA journey expects setup from Profile/Settings, but the
current seller setup prompt is a home banner behind `SubscriptionGate`, Settings
links only to Wallet, and the wallet setup card appears driver-only.

## Entry points and role paths to trace

- Driver optional payout step during signup.
- Driver home setup banner.
- Driver Settings and Wallet setup/resume actions.
- Seller home setup banner after subscription gating.
- The documented seller Profile/Settings path, including whether it is missing,
  stale documentation, or intentionally replaced.
- Re-entry after incomplete onboarding, expired onboarding link, restricted
  account, or later loss of payout capability.

For each entry point, trace the complete state chain: create/refresh onboarding
link, external browser, return/refresh bridge, app-scheme handoff, status poll,
backend persistence of `stripeOnboardingCompleted` or its replacement,
`/users/me`, `UserController`, and every banner/action that consumes the state.

## Platform and lifecycle matrix

Exercise Android and iOS with warm foreground return, background resume, cold
start, app killed while the browser is open, callback received twice, user
cancellation, refresh-link path, slow Stripe settlement, missed
`account.updated`, offline return, and reopening the app later. Separate payout
readiness from signup completion, identity/KYC state, driver claim eligibility,
and seller subscription entitlement.

## Evidence to inspect

- `PayoutOnboardingService`, `UserController`, signup flow composition,
  `SubscriptionGate`, Settings, Wallet, and seller/driver home banners.
- Android intent filters and activity launch mode.
- iOS URL schemes and Flutter deep-link settings.
- Backend account/link creation, return/refresh bridge, onboarding status
  endpoint, user serialization, and `account.updated` reconciliation.
- `docs/qa/full-user-journey-testing.md` for the documented role flows.
- Existing client incident notes and commit history.

## Test boundary

Automated service/state tests must prove polling and reconciliation update the
cached user and every role-specific consumer without requiring a restart.
Contract tests must cover stale `/users/me`, delayed/missed webhook recovery,
duplicate callbacks, cancellation, and loss of payout capability.

An Android/iOS device matrix must cover every intended role/entry-point pair and
lifecycle case above. It passes only when the chosen setup action is reachable,
the banner hides after authoritative payout readiness, remains visible while
incomplete, and reappears if Stripe later disables payouts. Record the desired
seller flow as a product decision rather than silently treating current code or
the QA document as authoritative.
