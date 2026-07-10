# Feature Spec: Buyer Self-Cancellation

**Feature ID**: `015-buyer-self-cancel`
**Created**: 2026-07-10
**Status**: Draft — policy decisions open (see Open Questions)
**Mobile module**: `lib/features/orders`
**Server module**: `orders` (`orders.service.ts`, `orders.controller.ts`)
**Related**: `014-driver-location-mode`, `CONTEXT.md` (Strike taxonomy)

## Problem Statement

A buyer who places an order and then changes their mind — wrong item, wrong
address, no longer available to receive it — has **no way to cancel it** from the
app. The only cancellation paths today are seller-initiated (`cancelAsSeller`,
`sellerCannotProvide`), driver-initiated (seller-unavailable), or system
watchdogs (no-driver). A buyer can only wait, or contact support out of band.

## Solution

Give the buyer a first-class "Annuler ma commande" action on an order they placed,
governed by clear, stage-aware rules: freely cancellable with a full refund
before the seller commits effort, restricted or penalised once food preparation
or delivery is underway, and blocked once the order is picked up. The exact
policy is deliberately left open below — it touches money and the strike engine
and must be decided before build.

## User Stories

1. As a buyer, I want to cancel an order I just placed but haven't been accepted
   yet, so that a misclick or change of mind costs me nothing.
2. As a buyer, I want a clear statement of whether I'll be refunded in full,
   partially, or not at all before I confirm the cancellation, so that there are
   no surprises on my card.
3. As a buyer, I want to know when it's too late to cancel (the food is being
   prepared / already picked up), so that I understand why the button is gone.
4. As a buyer, I want the cancellation to be immediate and reflected in my order
   history, so that I'm not left unsure whether it worked.
5. As a seller, I want to be notified the moment a buyer cancels, so that I stop
   preparing and don't waste ingredients.
6. As a seller, I want to be compensated if a buyer cancels after I've already
   started (or finished) preparing, so that a late buyer cancel doesn't cost me.
7. As the platform, I want to discourage serial cancellers, so that sellers and
   drivers aren't repeatedly stiffed by abuse.
8. As a driver already assigned to the delivery, I want a buyer cancel to release
   me cleanly (and compensate me if I'd already set off), so that I'm not stranded.
9. As support, I want every buyer cancellation to carry a reason + timestamp +
   refund record, so that disputes are auditable.

## Implementation Decisions

Settled:

- **New endpoint, buyer-scoped.** Add `cancelAsBuyer` (e.g. `POST
  /orders/:id/cancel-by-buyer`) guarded to the order's `buyerId`; the existing
  `/orders/:id/cancel` stays seller-only. Reuse the transactional
  `refundOrderIfNeeded` + `inventoryRestored` machinery that the seller/no-driver
  paths already use (idempotent, race-safe status re-check inside the txn).
- **Stage gate is server-authoritative.** The set of cancellable `OrderStatus`
  values is enforced in the service, not just hidden in the UI; the app only
  mirrors it to show/hide the button.
- **Terminal outcome.** A buyer cancel sets `OrderStatus = CANCELLED` with a
  distinct `cancellationReason` (e.g. `buyer_cancelled`) and, for a delivery with
  an assigned driver, cancels the `Delivery` and releases the driver — reusing
  the driver-release path from the existing cancel flows.
- **Client surface.** The action lives on the buyer's order tracking + history
  (the `014` reception-QR entry point work already added a per-order action
  slot); it opens a confirm dialog that states the refund outcome for the current
  stage before proceeding.

Open (see Open Questions — do not build until resolved): allowed stages, refund
tiers, seller compensation, and anti-abuse.

## Testing Decisions

- **Pure stage-policy first.** Extract the "can this order be cancelled by the
  buyer, and what refund tier applies?" decision as a pure function over
  `OrderStatus` (+ whether prep started / driver assigned) and unit-test the full
  matrix, mirroring the `sellerOrderBucket` / `desiredLocationMode` pattern. This
  is the highest-leverage seam and keeps the money rules out of the UI.
- **Server integration.** Test `cancelAsBuyer` for: ownership rejection (not your
  order), each allowed/blocked stage, idempotent double-cancel, refund record
  creation, inventory restore, and driver release when a driver was assigned.
  Prior art: the existing `cancelAsSeller` / `sellerCannotProvide` service tests.
- Test external behavior only (status transitions, refund/driver side-effects),
  never the private transaction internals.

## Out of Scope

- Changes to seller-, driver-, or system-initiated cancellation (unchanged).
- The refund provider mechanics (Stripe refund) — reused as-is.
- Partial-order / single-item cancellation — this is whole-order only.

## Further Notes

- This spec was split out of the driver/order/QR fix batch precisely because it is
  a net-new money+policy feature, not a bug fix. The batch shipped the confirmed
  order-status bugs and the QR reachability work; buyer self-cancel is the one
  item that needed its own policy review.
- The strike question ties directly to the sanctions taxonomy in `CONTEXT.md`
  (late cancellation = *infraction légère* → 1 strike; 3 strikes / 90 days →
  exclusion). Whatever policy is chosen should reuse that engine rather than
  inventing a parallel penalty.

## Open Questions

1. **Allowed stages.** Where is the cutoff? Recommended: freely cancellable while
   `CONFIRMED` (accepted but not yet `PREPARING`); allowed-with-consequences
   through `PREPARING`/`READY`/`IN_DELIVERY`; **blocked** once `PICKED_UP`.
2. **Refund tiers.** Full refund pre-`PREPARING`; once preparing/ready, does the
   buyer forfeit part (to compensate the seller) or still get a full refund with
   the platform absorbing it? Recommended: full refund pre-prep; seller
   compensation funded per (3) thereafter.
3. **Seller compensation.** If the buyer cancels after prep started, is the seller
   paid (and from whose money — buyer forfeit vs platform)? Recommended: seller
   paid their earnings for `READY`+ cancels, funded by a buyer forfeit.
4. **Anti-abuse / strikes.** Does a late buyer cancel count toward buyer strikes
   (per `CONTEXT.md`)? Recommended: a cancel at `PREPARING`+ is a *retard*-class
   buyer infraction (1 strike); pre-prep cancels are free and unpenalised.
5. **Assigned-driver compensation.** If a driver had already claimed and set off,
   are they compensated like the seller-unavailable path? Recommended: yes, reuse
   the existing driver-compensation path.
