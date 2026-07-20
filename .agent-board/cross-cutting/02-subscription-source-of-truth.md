# Resolve seller subscription ownership across RevenueCat and Stripe

- **GitHub:** [Resolve seller subscription ownership across RevenueCat and Stripe](https://github.com/ProgixDev/incacook-app/issues/11)
- **Scope:** mobile + backend
- **Mode:** AFK research followed by HITL decision if ownership is ambiguous
- **Depends on:** none
- **Produces:** authoritative writer decision and migration/guard requirements

## Question

Can RevenueCat and Stripe subscription handlers overwrite the same seller gate,
and what is the correct source of truth for iOS, Android, and any future web
seller flow?

## Test boundary

Tests prove store purchase, renewal, cancellation, billing failure, restore, and
delayed/out-of-order webhook events cannot incorrectly disable or activate the
seller across platforms.
