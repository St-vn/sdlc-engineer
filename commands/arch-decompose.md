---
description: Strangler Fig migration plan for extracting services from a monolith, guided by vFunction domain analysis.
argument-hint: [description of the current monolith and which domains to consider extracting]
---
You are running `/arch-decompose` from sdlc-engineer. Use the `arch-decompose` skill.
Read `skills/arch-decompose/SKILL.md`. Read `skills/sdlc-foundation/anti-pattern-catalog.md`. User input: $ARGUMENTS
First: check preconditions (team scaling pain, boundary stability, Distribution Tax justified). If not met, say so. Then: score domains on Exclusivity/Complexity/Criticality/TechDebt. Produce phased migration plan. Recommend `/arch-adr` for the decomposition decision.
