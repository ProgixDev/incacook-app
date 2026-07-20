# Issue tracker: GitHub

Issues and PRDs for this repo live as GitHub issues. Use the `gh` CLI for all
operations and infer the repository from `git remote -v`.

## Conventions

- Create: `gh issue create --title "..." --body "..."`.
- Read: `gh issue view <number> --comments`.
- List: `gh issue list --state open --json number,title,body,labels,comments`.
- Comment: `gh issue comment <number> --body "..."`.
- Label: `gh issue edit <number> --add-label "..."`.
- Close: `gh issue close <number> --comment "..."`.

## Pull requests as a triage surface

External pull requests are not a triage surface. Triage only reads issues.

## Publishing and fetching

- When a skill says to publish to the issue tracker, create a GitHub issue.
- When a skill says to fetch a ticket, use `gh issue view <number> --comments`.

## Wayfinding operations

The map is one issue labelled `wayfinder:map`; its tickets are child issues.

- **Map:** create it with the destination, notes, decisions index, fog, and
  out-of-scope sections.
- **Child ticket:** link it through GitHub's sub-issues API. If sub-issues are
  unavailable, put the children in a map task list and add `Part of #<map>` to
  each child body.
- **Labels:** use `wayfinder:research`, `wayfinder:prototype`,
  `wayfinder:grilling`, or `wayfinder:task`.
- **Blocking:** prefer GitHub's native issue dependencies. Add an edge through
  `repos/<owner>/<repo>/issues/<child>/dependencies/blocked_by`, passing the
  blocker's numeric database ID. If dependencies are unavailable, add a
  `Blocked by: #<n>` line to the child body.
- **Frontier:** among the map's open children, select the first unassigned
  ticket with no open blockers.
- **Claim:** `gh issue edit <number> --add-assignee @me` before investigation.
- **Resolve:** comment with the answer, close the ticket, then append a linked
  one-line gist to the map's Decisions-so-far section.

Refer to maps and tickets by linked title in human-facing text, never by a bare
issue number.
