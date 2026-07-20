# Domain Docs

This repository uses a single domain context.

## Before exploring

- Read `CONTEXT.md` at the repository root.
- Read relevant decisions under `docs/adr/` when the directory exists.
- If either location is absent, proceed without creating it pre-emptively.

## Layout

```text
/
├── CONTEXT.md
├── docs/
│   └── adr/
└── lib/
```

Use the glossary's canonical terms in issue titles, plans, hypotheses, and
tests. If a required term is missing or overloaded, resolve it through domain
modeling before adding it. Surface any conflict with an existing ADR instead of
silently overriding it.
