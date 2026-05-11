# Maturity Tier Detection

Every sdlc-engineer command consults this reference before deciding how much rigor is appropriate for the user's situation. Producing a 40-page SRS for a hackathon project is just as wrong as producing a 3-paragraph brief for a scaling startup. The tier sets the depth.

## The three tiers

| Tier | Primary driver | Risk tolerance | Time horizon | Methodology depth |
| :--- | :--- | :--- | :--- | :--- |
| **Hackathon** | Raw speed; demo-ready | Very high | Hours to days | Minimal — natural language briefs, vibe-coded prototypes, root access acceptable |
| **MVP** | Customer validation | Moderate | Weeks to months | Lean — MoSCoW prioritization, Gherkin acceptance criteria for must-haves, shared staging environments |
| **Scaling startup** | Reliability + compliance + team coordination | Low | Months to years | Full — SARA-style traceability graphs, NFR optimization, scoped service accounts, OAuth, formal change management |

## Detection signals

Read these signals from the user's stated context, prior artifacts, and language. Aggregate; don't gate on any single signal.

### Hackathon signals

- Words: "hackathon", "weekend project", "prototype", "demo", "proof of concept", "throwaway"
- Time horizon: hours, days, "by Sunday", "before the deadline"
- Team: solo, or a small ad-hoc group with no permanent structure
- Stakes: no real users yet; no money on the line; no compliance scope
- Stack mentions: "vibe coding", "Claude Code", "Goose", direct production deploys, single repo
- Infrastructure: localhost, ngrok, free-tier hosting

### MVP signals

- Words: "MVP", "first version", "early users", "beta", "validating", "launch"
- Time horizon: weeks to a small number of months
- Team: founder + a few collaborators; possibly contracted help
- Stakes: real (or imminent) users; possibly paying; founder reputation involved
- Stack mentions: React + Firebase, Node.js + Postgres, Supabase, Stripe, hosted PaaS (Vercel, Render, Fly)
- Infrastructure: shared staging server, free or low-paid tier production
- Feature scope: the user is asking what to *cut*, not what to add — MoSCoW concerns surface naturally

### Scaling startup signals

- Words: "scaling", "growth stage", "team of N engineers", "compliance", "audit", "enterprise", "B2B contract", "SOC 2", "PCI", "FIPPA", "GDPR"
- Time horizon: quarters and years; multi-quarter roadmaps
- Team: multiple engineers, distinct roles (frontend, backend, DevOps, security)
- Stakes: revenue dependency on uptime; legal exposure; investor scrutiny
- Stack mentions: microservices, Kubernetes, distributed tracing, RBAC, multi-region, OAuth flows
- Infrastructure: dedicated environments per stage, IaC, automated rollbacks, on-call rotations
- Process mentions: code review requirements, ADRs, RFCs, change advisory board

## Tier-appropriate output depth

When a command produces an artifact, scale the depth to the tier:

| Artifact | Hackathon | MVP | Scaling |
| :--- | :--- | :--- | :--- |
| Requirements brief | 1 page; bullets; "what does this thing do?" | 3-8 pages; user stories + ACs for must-haves; NFRs with rough metrics | Full SRS; INVEST-compliant stories; Gherkin ACs for every story; precise NFR metrics; PCI/FIPPA scope statement |
| Architecture | One-paragraph stack choice + a Mermaid sketch | Component diagram + ADR for any decision >$0 to reverse | C4 model levels 1-3; ADRs for every notable decision; complexity metrics audit |
| Deployment | Push directly to prod is fine | CI on merge; one staging env; smoke tests; rollback by redeploying | Multi-stage pipeline; observability across metrics/logs/traces; automated rollback; feature flags; canaries |
| Traceability | None | Link stories ↔ tests informally | Full RTM; forward + backward; CI-checked |
| Compliance | None | Note any obvious scope (e.g., handling card data) | Full PCI DSS / FIPPA / GDPR mapping where relevant |

## Soft-warn on tier mismatch

If the user is asking for a tier-inappropriate artifact, flag it and recommend the right level — but produce what they asked for if they insist. Examples:

> User: "Write me a full SRS for my weekend hackathon."
> Plugin: "For a hackathon scope I'd normally do a 1-page brief — full SRS rigor would burn most of your weekend. I'll do the brief and flag what we'd elevate to SRS form if this turns into an MVP. Sound right? Or do you want the full SRS anyway?"

> User: "Just give me a one-paragraph spec for the new payments feature."
> Plugin: "If this is for the scaling-stage payments product, a one-paragraph spec is going to leak into a defect downstream — payment NFRs and compliance scope need to be precise. I'll produce a focused 3-page spec covering only the payments feature, scoped tightly. Or if you want the one-paragraph version for an internal alignment doc, I'll add a header noting it's not a substitute for the formal spec."

## The cost-of-defect rationale

Tier-mismatched rigor is wasteful at the bottom (a hackathon doesn't repay the cost of full SRS rigor) and dangerous at the top (a scaling startup pays compounding cost for every requirements gap). See `cost-of-defect-model.md` for the 1×→200× cost curve that makes this concrete.

## When the user hasn't told you their tier

Ask, briefly. One question, with options:

> "Quick check on scope so I match the right depth: is this a hackathon-style speed run, an MVP for early users, or a product that's already scaling with real customers?"

If they decline to answer, default to **MVP** — it's the median, and the soft-warn protocol catches the edge cases either way.
