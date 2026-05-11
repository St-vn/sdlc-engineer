---
name: analyze
description: Performs feasibility and tradeoff analysis over elicited inputs or existing requirements. Use when the user asks "is this feasible?", "what are the tradeoffs?", "should we do X or Y?", "is this realistic for our timeline?", "what are the risks?", or when they have a requirements backlog and want to evaluate it before committing to design. Produces a structured analysis: technical feasibility assessment, dependency map, risk register, and prioritized scope recommendation. Sits between /elicit and /spec in the lifecycle but can be invoked independently.
---

# /analyze — feasibility and tradeoff analysis

Evaluates elicited requirements before committing to design. Catches scope, risk, and feasibility problems at the 1× cost stage rather than the 10×-200× stages.

## What analyze produces
1. **Technical feasibility assessment** — can this be built with the team, time, and resources stated?
2. **Dependency map** — what does this depend on that isn't in the team's control?
3. **Risk register** — what could go wrong, how likely, how severe?
4. **Tradeoff analysis** — where the team has meaningful choices, lay them out
5. **Scope recommendation** — given the above, what should be in v1?

## Procedure

### Step 1 — Read the inputs
User stories / backlog from `/elicit`, stated constraints (team size, timeline, budget, tech stack), any prior artifacts in the conversation.

### Step 2 — Feasibility check
For each major feature area, assess three dimensions:
- **Technical feasibility** — does the technology to build this exist and is the team capable of using it?
- **Resource feasibility** — is the required effort achievable in the stated timeline with the stated team?
- **Integration feasibility** — do the required external dependencies (APIs, services, data sources) exist, are they reliable, and are they accessible?

Use a simple RAG rating (🟢 feasible / 🟡 uncertain / 🔴 infeasible) with one-sentence justification per feature.

### Step 3 — Dependency map
List every dependency the system has that isn't in the team's control:
- External APIs / services (payment processors, auth providers, data feeds)
- Third-party libraries with known instability or licensing issues
- Organizational dependencies (stakeholder sign-offs, legal review, infra access)
- Data dependencies (existing databases, migration requirements)

Flag each dependency's risk level: if it's unavailable or unreliable, what feature breaks?

### Step 4 — Risk register

| Risk | Likelihood | Impact | Mitigation |
|:---|:---|:---|:---|
| Third-party API rate limits | Medium | High | Cache aggressively; add fallback |
| Scope creep past MVP | High | High | Lock Must-haves now, park rest |
| Key team member unavailable | Low | Medium | Document architecture early |

### Step 5 — Tradeoff analysis
For any major decision where the backlog implies a choice (build vs buy, monolith vs service, sync vs async), surface it explicitly using the cost-benefit framework from `sdlc-foundation/decision-frameworks.md`:
- What does each option cost (time, money, reversal cost)?
- What does each option gain?
- What does the counterfactual cost?

Do not make the decision for the user unless they're clearly out of their depth — surface the tradeoffs and recommend.

### Step 6 — Scope recommendation
Given the feasibility and risk picture, produce a recommended scope for v1:
- **Proceed as stated** (if all 🟢)
- **Narrow scope** (if too much 🟡 risk for the stated timeline) — specific cuts recommended
- **Redesign required** (if core 🔴 infeasibility) — explain what must change before proceeding

### Anti-pattern scan
Per `sdlc-foundation/anti-pattern-catalog.md`:
- Premature microservices in the feature list → flag
- "Fast" / "secure" in requirements without metrics → flag for `/req-nfr`
- >7 Must-haves at MVP tier → MoSCoW pressure

Recommend next step: `/spec` if scope is confirmed, or back to `/elicit` if major gaps surfaced.

## Audience adaptation
- Novice: explain the RAG system, give context for why each risk matters, make the scope recommendation strongly and explain why
- Senior: table-format output, terse justifications, ask only for information genuinely missing
