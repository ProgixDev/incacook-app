# Prove wallet credit, release, hold, debt, and reversal invariants

- **GitHub:** [Prove wallet credit, release, hold, debt, and reversal invariants](https://github.com/ProgixDev/incacook-app/issues/6)
- **Scope:** backend
- **Mode:** AFK research
- **Depends on:** none
- **Produces:** ledger invariant table and discrepancy hypotheses

## Question

For every terminal order and incident path, are seller/driver/platform entries
created once with correct amounts and statuses, released or reversed at the
right time, and summarized without netting unrelated accounting concepts?
Explicitly test whether positive paid earnings and the negative withdrawal row
incorrectly cancel the displayed `paidOutCents`.

## Client-flow invariants to prove

- A successful buyer payment authorizes the order flow but does not credit
  seller or driver earnings before the authoritative fulfillment event.
- Pickup credits the seller and platform commission only; delivery credits the
  seller, assigned driver, and platform commission according to the pricing
  contract.
- A seller or driver may accrue internal earnings without a ready Stripe
  connected account if that is the intended domain rule; Connect gates
  withdrawal, not earning.
- New earnings enter `PENDING`, become `AVAILABLE` only after the safety window,
  and move to `HELD`, `REVERSED`, or debt recovery states when a dispute,
  cancellation, refund, or incident requires it.
- Seller unavailable, absent drop-off recipient, driver disappearance, and
  similar incident paths preserve conservation of money and have an explicit
  recovery owner.
- Repeated delivery completion, webhook delivery, release sweep, retry, or
  operator action never creates a duplicate credit, release, reversal, debt, or
  withdrawal.
- A withdrawal changes available funds and paid-out reporting exactly once.
  Positive paid earnings and a negative withdrawal ledger row must not produce
  a false zero `paidOutCents` total.
- The €50 withdrawal threshold, if still a product rule, is enforced against the
  authoritative available balance and represented consistently in mobile and
  admin views.

## Evidence to inspect

- Buyer payment success/failure and order-state transition handlers.
- Pickup and delivery finalizers, incident handlers, retry/idempotency guards,
  and database transaction boundaries.
- Wallet ledger schema, release sweep, dispute/refund reversal, debt recovery,
  and withdrawal services.
- `/wallet/me`, role-specific wallet endpoints, admin finance endpoints, and the
  mobile models/widgets that display each aggregate.
- Historical records or fixtures that contain paid earnings plus a withdrawal.

## Test boundary

Deterministic integration tests must reconcile buyer totals to seller, driver,
platform, refund, hold, debt, and withdrawal rows across pickup, delivery,
dispute, refund, seller unavailable, absent recipient, driver disappearance,
release sweep, debt recovery, and duplicate execution.

Contract assertions must also prove the client-observable checkpoints: the API
balance immediately after payment, fulfillment, release, hold, reversal, and
withdrawal; the resulting mobile wallet state; the admin totals; and stable
results after retries or duplicate webhook delivery. Record the exact invariant
or source-of-truth defect for every mismatch before proposing a repair.
