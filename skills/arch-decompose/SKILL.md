---
name: arch-decompose
description: Produces a Strangler Fig migration plan for extracting services from a monolith, guided by vFunction-style domain analysis. Use when the user has an existing monolith and wants to migrate toward a service-oriented architecture: "extract this service", "break up the monolith", "migrate to microservices", "refactor the architecture", "we need to decompose X". Always checks whether decomposition is actually warranted before designing the migration — premature extraction is worse than staying monolithic.
---

# /arch-decompose — Strangler Fig migration planning

Plans the extraction of domains from a monolith using the Strangler Fig pattern, guided by vFunction-style domain analysis. Before planning any migration, verifies the preconditions for decomposition — because the wrong answer to "should we decompose?" is more expensive than no migration at all.

Read `sdlc-foundation/decision-frameworks.md` — Modular Monolith First, Strangler Fig, vFunction, Distribution Tax.
Read `sdlc-foundation/anti-pattern-catalog.md` — premature microservices, distributed monolith.

## Step 0 — Should you decompose at all?

This is the first question, not an assumption. Decomposition is warranted when:

1. **Team scaling pain is real** — multiple teams are blocked by each other's deployment cadence. Conway's Law applies; services are the org chart made concrete.
2. **Domain boundaries have stabilized** — the target domain's interfaces haven't changed significantly in 3+ months. Extracting a domain with unstable boundaries makes refactoring across service lines infinitely more painful.
3. **The Distribution Tax is worth paying** — the domain in question has availability, scaling, or release-cadence requirements that genuinely diverge from the rest of the monolith.

If none of these are true: recommend staying in the modular monolith and focus on improving module boundaries instead. That's the right answer, and saying so is what a senior engineer does.

## vFunction domain analysis

Score each candidate domain on four dimensions to prioritize extraction order:

| Dimension | What it measures | High score = extract first |
| :--- | :--- | :--- |
| **Exclusivity** | How independent is this domain from the rest? (low cross-cutting) | High exclusivity → cleaner extraction |
| **Complexity** | How deep are its dependencies? | Lower complexity → safer to extract |
| **Criticality** | Impact on availability if it fails or lags | High criticality → invest in isolation sooner |
| **Technical Debt** | Maintenance vs innovation ratio in this domain | High debt → extraction as a reset opportunity |

Extract domains that score: high exclusivity + manageable complexity + high criticality + high debt. Leave tightly coupled, low-debt domains in the monolith.

## The Strangler Fig pattern

Named after the strangler fig tree, which gradually replaces a host tree from the outside in.

```
1. Identify bounded context with stable boundaries
2. Build new service alongside monolith (don't fork — parallel implementation)
3. Route a slice of traffic to the new service via API gateway / proxy layer
4. Gradually shift traffic percentage (10% → 50% → 100%)
5. Verify at each step — metrics, error rates, latency
6. Decommission the old code path once traffic is fully migrated
7. Remove the routing logic
```

**Never big-bang rewrite.** Every intermediate state must be shippable. The migration should take weeks or months, not a single sprint.

## Migration plan format

```markdown
## Decomposition Plan: [Monolith Name]

### Precondition check
- Team scaling pain: [yes/no — explain]
- Boundary stability: [stable/unstable — explain]
- Distribution Tax justified: [yes/no — explain]

**Verdict: [Proceed / Defer / Abandon with explanation]**

### Domain analysis

| Domain | Exclusivity | Complexity | Criticality | Tech Debt | Priority |
| :--- | :--- | :--- | :--- | :--- | :--- |
| [Domain A] | High | Low | High | High | Extract first |
| [Domain B] | Medium | High | Medium | Low | Defer |

### Extraction sequence

**Phase 1 — [Domain A]** (weeks 1-4)
- Current location: [module/package in monolith]
- Extraction boundary: [what interface does this domain expose?]
- Routing strategy: [API gateway header / feature flag / path-based]
- Traffic ramp: [10% week 1 → 50% week 2 → 100% week 3 → decommission week 4]
- Rollback trigger: [error rate > X% or latency > Yms]

**Phase 2 — [Domain B]** (weeks 5-10)
...

### Monitoring during migration
- Error rate delta: monolith vs new service per-phase
- Latency baseline: established before extraction, compared after
- Rollback plan: repoint routing back to monolith path
```

After plan: recommend producing an ADR for the decomposition decision (`/arch-adr`) and updating the C4 diagrams (`/arch-c4`) to show the target state architecture.
