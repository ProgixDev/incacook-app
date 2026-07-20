# Design the cross-platform payment test matrix and fixtures

- **GitHub:** [Design the cross-platform payment test matrix and fixtures](https://github.com/ProgixDev/incacook-app/issues/13)
- **Scope:** cross-cutting
- **Mode:** AFK research
- **Depends on:** Connect onboarding; deployed configuration; wallet ledger; withdrawal resilience; order payment lifecycle; subscription ownership; admin observability
- **Produces:** executable test matrix, fixtures, accounts, and environment checklist

## Question

What smallest automated and device-level suite proves the whole payment system
on Android and iOS without relying on uncontrolled production data or real
money, while still validating deployed webhooks and background jobs?

## Test boundary

Every critical state transition has an owner, fixture, oracle, platform,
environment, reproducible setup, and pass/fail assertion.
