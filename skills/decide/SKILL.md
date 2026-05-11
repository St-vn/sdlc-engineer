---
name: decide
description: Focused decision support for specific engineering choices where the user lacks the expertise to choose confidently. Use when the user asks "monolith or microservices?", "which database?", "REST or GraphQL?", "SQL or NoSQL?", "should I use X or Y?", "what tech stack?", "is X overkill?", "do I need X?", or any direct engineering decision question. Brings the decision framework to the question — maps the user's actual context onto the relevant technical tradeoffs — rather than asking questions the user may not be able to answer. Does not produce artifact pipelines; produces a reasoned recommendation with explicit tradeoffs.
---

# /decide — focused decision support

Produces a reasoned recommendation for a specific engineering decision. The skill brings expertise to the question — the user doesn't need to know the right questions to ask.

## The decision format

Every recommendation follows the same structure:

1. **The actual question** (restated precisely — often the user's framing needs sharpening)
2. **The options** (usually 2-3; don't strawman the alternatives)
3. **The decisive factors** — what context does the recommendation hinge on?
4. **The recommendation** — specific, not "it depends"; name the choice
5. **The tradeoffs you're accepting** — what does this choice cost?
6. **The reversal cost** — if you change your mind later, what does it take?
7. **When to revisit** — what signal would indicate it's time to reconsider?

## Decisions this skill handles (with framework to apply)

### Monolith vs microservices
Framework: Modular Monolith First + Conway's Law (from `sdlc-foundation/decision-frameworks.md`)

Decisive question: "How many independent teams will own the code in 12 months?"
- 1 team: modular monolith, full stop
- 2-3 teams around stable domain boundaries: maybe extract 1-2 services
- 5+ teams across clear bounded contexts: microservices warranted

Default recommendation (vast majority of new systems): modular monolith with Hexagonal Architecture. Flag Distribution Tax explicitly.

### SQL vs NoSQL
Decisive questions: "Do you need transactions across multiple entities? Do your queries need to join data? Do you know your data shape now?"
- Yes to any → SQL (PostgreSQL default)
- Truly document-oriented data, no joins, schema evolves wildly → consider document store
- Pure key-value cache → Redis
- High-throughput time-series → InfluxDB or Timescale

Default recommendation: PostgreSQL. It handles 90% of use cases, and you can add Redis alongside it. NoSQL requires a genuinely distinct access pattern to justify the consistency tradeoffs.

### REST vs GraphQL
Decisive questions: "Do you have multiple clients with wildly different data needs? Do you have a team with GraphQL experience?"
- Multiple clients (web, mobile, third-party) with different data requirements → GraphQL worth evaluating
- Single client or simple data shape → REST
- No GraphQL experience on the team → REST (GraphQL has real operational overhead)

Default: REST. GraphQL's benefits materialize at multiple-client / complex-data scale that most early-stage products don't have yet.

### Build vs buy (external service vs own implementation)
Framework: cost-benefit with reversal cost (from `sdlc-foundation/decision-frameworks.md`)

Decisive questions: "Is this core to your competitive differentiation? What's the build cost vs SaaS cost over 3 years? What's the lock-in if you buy?"
- Core differentiation → build (or at least abstract behind an interface)
- Commodity function (auth, email, payments) → buy; don't rebuild Stripe

### Sync vs async communication
Decisive questions: "Does the caller need the result before proceeding? Can the operation fail silently and be retried?"
- Caller blocks on result → synchronous (HTTP, gRPC)
- Result can be processed later / operation is idempotent → async (message queue, event bus)
- Mixing both → sync for reads/commands that need confirmation; async for notifications and side effects

### Framework / language choices
These are harder to generalize — context matters heavily. Apply:
1. Team expertise > best-in-class: the best framework is one the team knows
2. Ecosystem fit: does it have the libraries needed for the domain?
3. Hiring market: can you hire people who know it?
4. Performance vs productivity tradeoff: calibrated to tier (hackathon: maximize speed; scaling: optimize for ops)

## Procedure

1. **Sharpen the question** — restate precisely; "should I use microservices?" → "given a 2-person founding team building a trading platform MVP, should the system be a modular monolith or distributed microservices?"
2. **Apply the decisive factors** from context: team size, timeline, scale expectations, compliance, existing stack
3. **Map to the relevant framework** above
4. **Produce the recommendation** in the format above — specific, named, defensible
5. **Anti-pattern scan** — if the user is describing a scenario that matches a known anti-pattern, flag it before recommending

## What decide does NOT do
- Does not produce diagrams, ADRs, or artifacts (hand off to `/arch-adr` for the record)
- Does not avoid making a recommendation when context is sufficient — "it depends" is not an answer
- Does not ask more questions than needed to make the decision

## Audience adaptation
- Novice: explain each tradeoff in plain terms; lead with the recommendation, follow with the explanation; never present two options as equally valid if context makes one clearly better
- Senior: terse option comparison, name the recommendation, note reversal cost; skip the framework definitions
