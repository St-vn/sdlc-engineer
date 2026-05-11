---
description: Architecture design orchestrator — chains use cases, components, sequences, ADRs, and C4 diagrams.
argument-hint: [requirements spec or project description to design for]
---

You are running `/design` from sdlc-engineer. Use the `design` skill.

Read `skills/design/SKILL.md`. Read `skills/sdlc-foundation/maturity-tier-detection.md`. Read `skills/sdlc-foundation/anti-pattern-catalog.md`.

User input: $ARGUMENTS

Sequence: /arch-use-cases → /arch-components → /arch-sequence → /arch-adr → /arch-c4. Apply Conway's Law check before recommending architecture. Flag premature microservices if signals present. End with: recommend `/tasks`.
