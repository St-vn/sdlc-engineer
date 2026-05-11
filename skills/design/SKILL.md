---
name: design
description: Orchestrator for producing a tier-appropriate architecture specification. Chains use-case diagrams, component decomposition, sequence diagrams for critical flows, architecture decision records, and C4 model views at the depth appropriate for the maturity tier. Use when the user wants "architecture", "system design", "how should this be structured", "design the system", "what components do I need", "draw the architecture", or has a spec and wants to move to the structural layer. Refiner mode: takes existing architecture descriptions and evaluates them against frameworks (Modular Monolith First, Conway's Law, anti-pattern catalog). Called after /spec in the lifecycle.
---

# /design — architecture specification orchestrator

Produces a complete architecture specification by sequencing the granular architecture skills:

```
/arch-use-cases → /arch-components → /arch-sequence → /arch-adr → /arch-c4
```

Optional: `/arch-decompose` (for systems migrating from a monolith), `/arch-complexity` (for existing codebases).

## Tier-appropriate depth

| Step | Hackathon | MVP | Scaling |
|:---|:---|:---|:---|
| Use cases | Skip | 1 diagram, text description | Full UML use case diagram |
| Components | Mermaid sketch, 1 paragraph | Component diagram + brief descriptions | Full component diagram with interface contracts |
| Sequence | Skip | 1-2 flows for the riskiest interactions | Sequence diagrams for all critical flows |
| ADRs | Skip | 1 ADR for any decision costing >1 week to reverse | ADR for every notable decision |
| C4 | Skip | C4 Level 1 (System Context) + Level 2 (Containers) | C4 Levels 1-3; Level 4 only for complex areas |
| Architecture | Modular monolith or simple 3-tier | Modular monolith (explicit Hexagonal structure) | Modular monolith OR bounded-context microservices if team size warrants |

**Default architectural stance**: Modular Monolith First. If the user proposes microservices, apply the Conway's Law test before proceeding. Apply the Distribution Tax argument. If after that they still want microservices, produce the architecture — but document the tradeoffs in an ADR.

## Procedure

### Step 1 — Read prior artifacts
Check for: SRS / user stories from `/spec`, any existing architecture diagrams or descriptions, technology stack mentions. The architecture should emerge from the requirements, not precede them.

### Step 2 — Tier check
Per `sdlc-foundation/maturity-tier-detection.md`. Ask once if ambiguous.

### Step 3 — Anti-pattern scan
Per `sdlc-foundation/anti-pattern-catalog.md`. Before producing any architecture, check:
- Premature microservices → apply Conway's Law test, flag Distribution Tax
- User describing a distributed monolith → catch it before it's drawn
- Vendor lock that wasn't a decision → flag for ADR

### Step 4 — Default architecture recommendation
Based on tier and context, lead with a recommended architectural pattern:
- New system, 1-2 person team, <12 months: **Modular Monolith** with Hexagonal/Clean Architecture
- New system, 3-5 person team, stable domain: **Modular Monolith** with DDD bounded contexts
- Existing monolith with scaling pain + multiple teams: **Strangler Fig** into bounded-context services
- Greenfield with multiple teams owning distinct domains: **Microservices** with justification

### Step 5 — Sequence the granular skills
Invoke each in sequence, passing outputs forward:
1. `/arch-use-cases` — scope the system boundaries and actor interactions
2. `/arch-components` — decompose into modules/services with interface contracts
3. `/arch-sequence` — detail the 2-3 most critical or risky interaction flows
4. `/arch-adr` — record every decision made during Steps 1-3
5. `/arch-c4` — assemble the diagrams

Between steps: brief summary of what was decided and what's next. User can pause at any step.

### Step 6 — Final output
Summary of the architecture: what pattern was chosen, what ADRs were produced, what the C4 diagrams show, what was deliberately excluded and why. Recommend next step: `/tasks` for work breakdown or `/implement` if skipping directly to deployment planning.

## Audience adaptation
- Novice: explain each architectural concept as it's introduced (what is a component? what is a service boundary?); recommend defaults rather than asking the user to choose between patterns they don't know
- Senior: efficient sequence with terse rationale; ADRs for non-obvious decisions; skip concept explanations
