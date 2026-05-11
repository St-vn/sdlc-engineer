---
name: arch-adr
description: Produces Architecture Decision Records (ADRs) documenting significant engineering decisions with context, options considered, decision made, and consequences. Use when the user says "document this decision", "write an ADR", "why did we choose X", "record our architecture decision", or when /design surfaces a non-obvious choice that needs to be preserved for future team members. Also use proactively when a user makes an architectural choice without documenting it — the ADR is cheap insurance against future confusion. One ADR per decision.
---

# /arch-adr — Architecture Decision Record

Captures the context, options, decision, and consequences of a significant architectural choice. ADRs are cheap to write and expensive not to have — every non-obvious decision made without one becomes tribal knowledge that walks out the door.

Read `sdlc-foundation/decision-frameworks.md` (cost-benefit framing section) for how to present tradeoffs.
Read `sdlc-foundation/maturity-tier-detection.md` — skip at hackathon tier unless explicitly asked.

## When an ADR is warranted

Write an ADR for any decision that:
- Has a reversal cost greater than one sprint of effort
- Would confuse a new team member if they encountered it without explanation
- Involves a meaningful tradeoff between options (not just "we used Postgres because it's standard")
- Involves a compliance or security implication

Skip ADRs for obvious or convention-following choices. "We use Git" doesn't need an ADR.

## ADR format (Nygard-style)

```markdown
# ADR-NNN: [Short title — decision made, not question asked]

**Date:** YYYY-MM-DD
**Status:** Proposed | Accepted | Deprecated | Superseded by ADR-NNN

## Context

[The situation that forced this decision. What is the problem? What constraints exist?
What is the system doing or about to do that makes this decision necessary?
2-4 sentences.]

## Decision

[What we decided to do. Written as an active, affirmative statement.
"We will use X" not "X was considered."]

## Options considered

| Option | Pros | Cons |
| :--- | :--- | :--- |
| [Chosen option] | [Key advantages] | [Key disadvantages] |
| [Alternative 1] | [Key advantages] | [Key disadvantages] |
| [Alternative 2 if applicable] | ... | ... |

## Consequences

**Positive:**
- [Benefit unlocked by this decision]

**Negative / tradeoffs accepted:**
- [Cost accepted by this decision]

**Risks:**
- [What could go wrong; what needs monitoring]

## Reversal cost: [Low / Medium / High]
[One sentence on what it would take to undo this decision later.]
```

## Procedure

1. **Identify the decision** from context. If the user hasn't stated it explicitly, name it clearly: "Decided: use Modular Monolith over microservices for initial architecture."
2. **Establish context** — why was this decision necessary? What forced it?
3. **Document options** — at minimum 2 options (including the rejected one). Real decisions aren't between "our choice" and "nothing."
4. **State the decision** — affirmative, unambiguous
5. **Surface consequences** — both positive and the tradeoffs accepted. Every real decision has both.
6. **Estimate reversal cost** — this is the most important field for future teams

## ADR numbering

Start at ADR-001. If producing multiple ADRs in one session (e.g., from a `/design` session that surfaced several decisions), number them sequentially. Suggest storing in `docs/decisions/` in the repository.

## Common ADRs to produce proactively

When the user makes these choices during a session without documenting them, offer to write the ADR:
- Database choice (SQL vs NoSQL; specific engine)
- Monolith vs services architecture
- Authentication mechanism (JWT vs session; OAuth provider)
- Async vs sync communication pattern
- Cloud provider and deployment target
- Testing strategy and coverage thresholds
- API design style (REST vs GraphQL vs gRPC)
