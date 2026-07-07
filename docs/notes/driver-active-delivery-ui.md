# Note — Active-delivery layout: persistent action bar (frontend, TODO)

Status: **partially done.** The auto-peek is shipped; the persistent action bar
is planned.

## Decision

When a Driver has an Active delivery, the driver's **next action must always be
visible**, regardless of the bottom-sheet position — not just when the sheet is
dragged up.

- **Shipped:** on job accept/restore, the sheet auto-snaps to a ~0.6 "peek"
  (`delivery_bottom_sheet.dart`), and the map frames the route above it.
- **TODO:** the collapsed/peek sheet should show a **compact persistent action
  bar** — current stage title + distance chip + the primary CTA — so the next
  step is one tap away even with the map full-screen. Dragging up still reveals
  the full `JobLifecycleCard` (contacts, fallbacks, report link) for detail.

## Why

`JobLifecycleCard` is tall (header → destination → order meta → two contact
buttons → primary CTA → fallbacks → report). At the 0.6 peek the primary CTA
sits below the fold, so the driver sees the card but must scroll to act — a
softer replay of the original "I don't see what to do" bug. A pinned action bar
closes that gap and makes stage changes visible without a re-peek.

## Related

- `CONTEXT.md` — Active delivery.
- The original reported bug: after accepting an order the driver "saw nothing"
  (collapsed sheet hid the commands).
