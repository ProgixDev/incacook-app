# Define payment-domain boundaries and sources of truth

- **GitHub:** [Define payment-domain boundaries and sources of truth](https://github.com/ProgixDev/incacook-app/issues/3)
- **Scope:** cross-cutting
- **Mode:** HITL grilling + domain modeling
- **Depends on:** none
- **Produces:** canonical vocabulary and ownership matrix

## Question

Which payment concepts are separate domain objects, and which system is the
source of truth for each state and amount?

Define and distinguish at least:

- buyer payment and its Stripe `PaymentIntent`;
- seller subscription and access entitlement;
- earning and internal wallet ledger entry;
- pending, available, held, paid-out, and debt balances;
- Stripe connected payout account and payout readiness;
- signup/onboarding completeness;
- withdrawal/cashout request;
- platform-to-connected-account Stripe transfer; and
- connected-account-to-bank payout.

Do not use “wallet connected” as a synonym for Stripe onboarding without an
explicit domain decision. The current architecture appears to keep the wallet
as an internal ledger and use Stripe Connect as a withdrawal destination; this
must be confirmed and documented.

Resolve the seller-flow contradiction explicitly: the QA journey describes
subscription as the final signup step and Stripe setup under Profile, while the
current app lands sellers behind `SubscriptionGate`, exposes Wallet in Settings,
and presents Connect setup from the seller home banner. Decide the intended
client journey before downstream tickets treat either version as correct.

## Client-flow questions

- Can a seller or driver earn before completing Stripe Connect, and what exactly
  is blocked until payout readiness is true?
- Which state gates seller app access: signup completion, subscription
  entitlement, payout readiness, or a deliberate combination?
- Where must each role start or resume Connect onboarding?
- What must buyers, sellers, drivers, admins, and support staff see while funds
  are pending, held, available, withdrawn, reversed, or owed as debt?

## Evidence to inspect

- Root `CONTEXT.md` and payment specs.
- `docs/qa/full-user-journey-testing.md` seller and driver journeys.
- Flutter payment, subscription, wallet, and onboarding models.
- Flutter signup composition, subscription gate, Settings, role home banners,
  and wallet setup actions.
- Backend payment, subscription, wallet, and profile contracts.
- Stripe event handling, transfer/withdrawal orchestration, scheduled releases,
  and reconciliation paths.
- Admin labels, financial views, and operator recovery actions.

## Test boundary

Produce an ownership matrix that maps every canonical term to its identifier,
authoritative store/provider, allowed writers, API contract, client readers,
user-visible gate, reconciliation mechanism, and failure owner. Every persisted
payment field and user-visible amount/status must map to exactly one term or be
listed as a conflict.

The intended seller and driver flows must be written as explicit decisions,
including whether earnings may accrue before Connect and which UI entry point
owns setup/resume. Update `CONTEXT.md` only after those decisions are resolved.
