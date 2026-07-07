---
status: accepted
date: 2026-07-06
---

# Driver online presence is server-authoritative, expired loosely, and heartbeat cadence scales by state

## Context

`DriverProfile.isOnline` is only ever written by the explicit `POST /online`
toggle — nothing expires it. So a driver who force-quits (or crashes / loses
signal) without going offline stays `isOnline = true` forever: still matched,
still pushed, and (with the relaunch restore feature) silently resumed online.
We also need the flag to be **trustworthy** because the driver app restores its
online session on relaunch by reading `isOnline` from `/users/me`.

Separately, the location heartbeat ran at ~5s for every Online driver — each
push is a Postgres `UPDATE` + an active-delivery `SELECT` (+ a Redis publish
when active). For the vast majority (idle drivers) this is wasted write load we
can't afford at launch capacity.

## Decision

**1. Server-authoritative expiry (cron), scoped by the two-clocks rule.**
A scheduled job (~30–60s) sets `isOnline = false` for drivers whose `lastSeenAt`
is stale **and who have no Active delivery** (a committed driver is governed by
Delivery watchdogs, never the idle clock). The persisted column stays the single
source of truth, so `/users/me` and the client restore code need no changes. A
lazy `lastSeenAt` guard is added to the matching/push query as a belt-and-
suspenders against the cron-tick window.

**2. Loose expiry threshold + FCM as the real availability signal.**
Staleness threshold is **~10 minutes**, not seconds. Backgrounding is a
legitimate Online state — a driver waits for an order push while backgrounded,
and a Dart location timer does not run in the background — so a tight heartbeat
would wrongly offline available drivers. Availability ultimately rests on
**FCM-token reachability** (invalid tokens are already pruned on send); the
10-min heartbeat expiry only kills genuinely-dead sessions. Reopen within
10 min → still online (restore resumes); longer → booted offline.

**3. Heartbeat cadence scales by driver state; DB write is decoupled from the
socket broadcast.**
- Idle-online: push position ~every 60s (coarse matching position + liveness).
- Active-delivery: keep the fast throttle (3s-min / 10m-move / 15s-keepalive),
  but those drivers are bounded by concurrent-delivery count.
- Server persists `lastKnownPoint`/`lastSeenAt` at most ~every 20–30s regardless
  of push rate (always broadcasts to Redis for smooth Live tracking); skips the
  active-delivery `SELECT` for idle drivers.

## Consequences

- The relaunch online-restore already implemented is correct **as-is** under
  this model — it trusts a now-truthful `isOnline`.
- Matching sees positions up to ~60s (idle) stale — fine for coarse nearest-
  first with atomic claim.
- Reliable background heartbeat/persistence **during an Active delivery** is a
  separate frontend concern (foreground service / persistent notification) —
  see `docs/notes/driver-background-persistence.md`.

## Revisit if

- We need much fresher idle positions (dense dispatch optimisation) → move to a
  tight (~2 min) threshold backed by **background location** (`ACCESS_BACKGROUND_
  LOCATION` is already declared), trading battery for freshness.
