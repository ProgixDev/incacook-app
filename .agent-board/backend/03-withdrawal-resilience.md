# Prove withdrawal accounting and Stripe transfer resilience

- **GitHub:** [Prove withdrawal accounting and Stripe transfer resilience](https://github.com/ProgixDev/incacook-app/issues/7)
- **Scope:** backend
- **Mode:** AFK research
- **Depends on:** wallet ledger invariants; deployed Connect configuration
- **Produces:** atomicity/idempotency decision and recovery design

## Question

Can concurrent or retried withdrawal requests, a Stripe success followed by a
database failure, a disabled connected account, insufficient platform balance,
or transfer reversal create duplicate money movement or a ledger/Stripe split?

## Test boundary

Integration tests cover concurrency, retry keys, pre/post-transfer failure,
reconciliation, and recovery without moving real funds.
