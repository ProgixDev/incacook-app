# Prelude test phone numbers — for App Review / QA (#56)

Captured 2026-08-26 from the Prelude dashboard's test-number pool. These
numbers accept OTP verification through Prelude's Verify V2 API **without a
real SMS being sent** — Prelude recognizes them server-side and returns a
known test code; our backend needs no special-casing (`auth.service.ts`
`requestPhoneOtp`/`verifyPhoneOtp` just forward `phone`/`code` to Prelude
generically).

> **Caveat: these may rotate.** The numbers were captured with "Xs/Xm ago"
> freshness indicators on Prelude's dashboard, consistent with a rotating
> test-number pool rather than a permanently reserved set. Before relying on
> any of these for an actual App Review submission, re-pull the current list
> from the Prelude dashboard (Verify → Testing → Test numbers) and confirm
> they're still active. Treat the list below as a snapshot, not a guarantee.

## Snapshot (2026-08-26)

| Number | Captured |
|---|---|
| +33722615098 | 0s ago |
| +33691047726 | 17s ago |
| +33749883517 | 30s ago |
| +33733591284 | 1m ago |
| +33675214963 | 1m ago |
| +33614829305 | 1m ago |

## Relationship to #47 / TASK-016 / #56

- **Phone verification is currently OFF** — `skipPhoneVerification = true`
  in `lib/core/config/feature_flags.dart` (unchanged; confirmed 2026-08-26).
  A reviewer will not see the phone-OTP screen in the current build, so these
  numbers are **not required to close #56 today**.
- They exist for whenever **#47 / TASK-016** ("re-enable phone OTP when SMS
  provider is live") ships: at that point, App Store/Play reviewers or QA can
  complete phone verification using one of these numbers instead of needing a
  real SIM in a specific country.
- No collision with the existing QA seed phones in `qa-accounts-seed.sql`
  (`+33611111101/02`, `+33622222201/02`, `+33633333301/02`) — checked
  2026-08-26.

## If/when phone verification is re-enabled

No DB seeding is needed for the numbers themselves. If a **permanent**
reviewer seller account (the actual ask in #56 — a seller with
`kycStatus='APPROVED'`, reachable to the subscription paywall without live
human KYC review) is wanted with phone verification exercised, extend
`qa-accounts-seed.sql` with one additional seller row using one of the
numbers above and `phoneVerified=true` — following the same pattern as the
6 existing QA accounts (see `comprehensive-qa-guide.md §6` for the UID
table). That's a separate, still-open piece of #56 (provisioning + approving
the account through the real admin KYC queue) — this doc only covers the
phone-number half.
