# Trace mobile wallet freshness and user-visible balance updates

- **GitHub:** [Trace mobile wallet freshness and user-visible balance updates](https://github.com/ProgixDev/incacook-app/issues/9)
- **Scope:** mobile
- **Mode:** AFK research
- **Depends on:** wallet ledger invariants
- **Produces:** refresh contract and stale-state failure matrix

## Question

When and how does the mobile wallet learn about credits, pending-to-available
releases, holds, debt, withdrawals, refunds, and remote changes while the screen
is open, revisited, resumed, or reached from a push notification?

## Evidence to inspect

- `WalletRepository`, `WalletScreen`, navigation lifetime, pull-to-refresh.
- Wallet-related push events and app lifecycle hooks.
- API cache/interceptor behavior and response decoding.

## Test boundary

Widget/repository tests and one device scenario demonstrate that each backend
ledger transition becomes visible without signing out or restarting the app.
