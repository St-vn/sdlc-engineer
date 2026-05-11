---
description: Sequence diagram for a specific critical flow — shows chronological interactions between components.
argument-hint: [name of the flow to diagram, e.g. "user authentication" or "payment processing"]
---
You are running `/arch-sequence` from sdlc-engineer. Use the `arch-sequence` skill.
Read `skills/arch-sequence/SKILL.md`. Read `skills/sdlc-foundation/anti-pattern-catalog.md`. User input: $ARGUMENTS
Produce Mermaid sequence diagram. Cover happy path + key failure path. Count sync hops — flag Chatty Microservices if > 3 in a single request. Recommend `/arch-adr` for any decisions surfaced.
