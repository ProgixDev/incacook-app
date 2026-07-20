# Withdrawal double-payout — adversarial repro (TEAM-LOCAL, do not publish)

- **PR:** https://github.com/ProgixDev/incacook-server/pull/2
- **Branch:** `fix/withdrawal-double-payout` (off `dev`) in `ProgixDev/incacook-server`
- **Related:** `#6` (S1), `#7`, `#3` conflict C2

> **Why this is not in the PR.** `ProgixDev/incacook-server` is **public** and the
> fix is **not yet merged or deployed**. The steps below are a working
> double-spend against any deployment running `dev`, so they stay here until the
> fix ships. The PR carries the safe half of the QA (local red-green, manual
> double-tap, DB assertions, regressions).

## The exploit, precisely

`requestWithdrawal` on `dev` does: read AVAILABLE → `transfers.create` → settle.

- No lock, no `FOR UPDATE`, no CAS anywhere on the path.
- `@@unique([orderId, userId, type])` is **inert** for payout rows: `orderId` is
  null and Postgres treats NULLs as distinct, so it permits unlimited rows.
- The Stripe idempotency key is `withdrawal_${ulid}` where the ULID is generated
  **inside each call** → concurrent calls send **different keys** → Stripe treats
  them as distinct requests and **honours both**.

Net: N concurrent requests → **N transfers of the full balance**. Unrecoverable
once the funds land in the connected account.

## Repro against a deployment running `dev`

Requires: user with ≥ 50 € AVAILABLE + Connect complete. **Test mode only —
never run this against a live-key deployment.**

```bash
curl -X POST "$API/v1/wallet/withdraw" -H "Authorization: Bearer $TOKEN" & \
curl -X POST "$API/v1/wallet/withdraw" -H "Authorization: Bearer $TOKEN" & wait
```

- **`dev` (vulnerable):** two `200`s, **two `transferId`s**, and Stripe → Connect
  → Transfers shows **two transfers** of the full balance. The ledger then
  settles twice.
- **`fix/withdrawal-double-payout`:** one `200`, one **`409`** ("Un retrait est
  déjà en cours"), and **exactly one transfer**. Logs show
  `lost a claim race (0/N rows); released`.

Raise concurrency (`-P 5`) to make the race land reliably if two requests don't
interleave.

## The concurrency-free variant

Also fixed, and worth proving separately because it needs no race at all: kill
the process between `transfers.create` and the settle `$transaction`. On `dev`
the money has moved but the rows stay `AVAILABLE` → the user withdraws the same
balance again on the next tap. On the fix branch the rows were already claimed,
so the second attempt finds nothing to withdraw.

Simulate by throwing inside the settle step, or `kill -9` mid-request.

## Post-merge

Once the fix is deployed, this file can be folded into the PR/issue history —
the recipe is only sensitive while `dev` is both vulnerable and public.

## Residual, accepted

Debit-row creation failing *after* a successful transfer leaves the balance
correctly spent with no `WITHDRAWAL` row → **reporting gap, not lost money** (the
claim prevents re-withdrawal). Resolved properly by the `paidOutCents` slice.
