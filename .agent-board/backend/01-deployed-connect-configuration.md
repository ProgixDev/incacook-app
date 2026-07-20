# Verify deployed Stripe Connect and webhook configuration

- **GitHub:** [Verify deployed Stripe Connect and webhook configuration](https://github.com/ProgixDev/incacook-app/issues/5)
- **Scope:** backend + external configuration
- **Mode:** AFK where access exists; otherwise operator checklist
- **Depends on:** none
- **Produces:** redacted environment/config evidence and gap list

## Question

Are mobile publishable keys, backend secret keys, Stripe mode/account, Connect
activation/country, onboarding return and refresh URLs, webhook endpoint signing
secret, connected-account event delivery, and Railway deployment variables
aligned in the actual environment used by Android and iOS?

## Configuration matrix to verify

- For each deployed Android and iOS artifact: build flavor/environment, resolved
  API base URL, Stripe publishable-key mode, and application URL scheme.
- For the matching Railway deployment: environment name, secret-key mode and
  owning Stripe account, Connect platform country/capabilities, public return
  and refresh URLs, and the values actually loaded by the running process.
- For the public callback bridge: HTTPS reachability, return and refresh routes,
  redirects, app-scheme handoff, and behavior when the app is installed, closed,
  or unavailable.
- For platform-account events: the webhook endpoint, subscribed PaymentIntent,
  dispute, refund, and subscription event types that are actually in product
  scope, plus that endpoint's signing secret.
- For connected-account events: the webhook endpoint receiving
  `account.updated` and related Connect events, its “events on connected
  accounts” setting, and its signing secret.
- Whether the deployment intentionally uses one or separate webhook endpoints.
  Confirm that the backend's single `STRIPE_WEBHOOK_SECRET`, if still present,
  matches the real endpoint topology rather than assuming both event channels
  share a secret.
- Any development bypass such as `_secret_devbypass`: prove it is unavailable in
  the verified environment and does not substitute for a real PaymentIntent or
  Connect onboarding test.

## Evidence and operational checks

- Capture only redacted key prefixes/modes, Stripe account and endpoint IDs,
  configured event names, deployment/version identifiers, timestamps, event or
  delivery IDs, and HTTP outcomes. Never copy secret values into the ticket.
- Verify Railway variables against the running deployment, not a local `.env`.
- Verify webhook signature validation uses the raw request body, successful
  events are idempotent, failures are observable/retryable, and delivery alerts
  or logs identify which event channel failed.
- Confirm return/refresh URLs are reachable from real Android and iOS network
  conditions and lead back to the same build/environment that initiated setup.

## Test boundary

A redacted environment matrix plus Stripe delivery evidence must prove a
connected-account `account.updated` event and the required platform-account
payment success, payment failure, dispute/refund, and in-scope subscription
events reach the intended deployment through the correct endpoint and secret.
Each event must be signature-accepted, processed idempotently, reflected in the
expected database/API state, and visible in operational logs without secrets.

Finally, one Android and one iOS build from the matrix must complete the real
test-mode onboarding callback and refresh path against that deployment. Record
gaps as configuration, code-contract, observability, or operator-runbook work so
the repair owner is unambiguous.
