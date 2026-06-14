---
name: spec
description: Orchestrator for producing a tier-appropriate requirements specification. Chains user stories, acceptance criteria, NFRs, the SRS document, and the requirements traceability matrix at the depth appropriate for the user's maturity tier. Use whenever the user wants a "spec", "specification", "requirements", "requirements doc", "SRS", "PRD", or asks any version of "what does this system actually need to do?", "lock down what we're building", "write down the requirements". Also use when the user has partial requirements artifacts (some stories, an informal brief) and wants them brought up to a complete spec. Folds methodology compliance into production — partial inputs are detected, refined to meet INVEST/Gherkin/precise-NFR-metric standards, and then continued into downstream artifacts. The orchestrator does not duplicate the granular skills (req-user-stories, req-acceptance, req-nfr, req-srs, req-rtm) — it sequences them.
---

# /spec — requirements specification orchestrator

Produces a complete requirements specification by sequencing the granular requirement skills:

```
/req-user-stories → /req-acceptance → /req-nfr → /req-srs → /req-rtm
```

The orchestrator's job is sequencing, tier-calibration, and refinement of any partial inputs the user already has. The granular skills do the actual artifact work — call them in sequence.

## Behavior contract

When invoked, the skill:

1. **Detects what's already in the conversation** (user-uploaded artifacts, prior outputs from `/elicit`, anything the user has pasted)
2. **Detects the maturity tier** per `sdlc-foundation/maturity-tier-detection.md`; asks at most one clarifying question if signals are ambiguous
3. **Refines partial inputs** through the relevant granular skill in refiner mode before continuing the sequence
4. **Produces each artifact in order**, with each step's output feeding the next
5. **Adapts depth to tier** — see the depth matrix below
6. **Soft-warns on tier mismatches and anti-patterns** per `sdlc-foundation/anti-pattern-catalog.md`
7. **Adapts verbosity to audience** per `sdlc-foundation/educational-layer.md`

## Tier-appropriate depth matrix

The orchestrator runs differently at each tier. For a hackathon, it produces a single-page brief; for a scaling startup, it produces a full SRS with traceability matrix.

| Step | Hackathon | MVP | Scaling startup |
| :--- | :--- | :--- | :--- |
| User stories | 3-5 bullets, plain English; no INVEST checking | INVEST-compliant for Must-haves; loose for Should-haves | Full INVEST for all; numbered IDs (US-001, US-002...) |
| Acceptance criteria | One sentence per story | Gherkin for Must-haves; informal for Should-haves | Gherkin for every story; multiple scenarios where applicable |
| NFRs | One paragraph total: "fast enough that demos work, secure enough that it doesn't leak credentials" | NFRs for Performance, Availability, Security, with rough metrics | Complete NFR taxonomy (Performance, Availability, Reliability, Scalability, Security, Maintainability, Usability) with precise metrics |
| SRS document | Skip; the brief IS the spec | 3-8 page document; semantic properties enforced; packaging properties relaxed | Full document; all semantic + packaging properties enforced; PCI/FIPPA/GDPR scope where relevant |
| RTM | Skip | Informal: stories link to test files | Full RTM (forward + backward); maintained as part of CI |

**Default to MVP tier** if the user hasn't told you and signals are ambiguous. Soft-warn if the produced output is tier-mismatched ("I'm producing MVP-tier rigor; if this is for a Series B due-diligence document let me know and I'll elevate to scaling-tier depth").

## Procedure

### Step 1 — Read the situation

Check for inputs in this order:
- Files uploaded in the current message (look for `.md`, `.txt`, `.docx` describing the project)
- Prior conversation turns containing user stories, briefs, or specs
- The user's current message itself (often the elicitation lives in the first paragraph)

If you find any partial input, classify it:
- Raw idea / brief / problem statement → goes into `/req-user-stories` as input for *producer* mode
- Existing user stories (any quality) → goes into `/req-user-stories` in *refiner* mode first
- Stories + ACs but no NFRs → skip ahead to `/req-nfr`
- Everything except SRS → skip to `/req-srs`

### Step 2 — Tier check

Apply detection per `sdlc-foundation/maturity-tier-detection.md`. If ambiguous:

> "Quick check on scope: is this a hackathon-style speed run, an MVP for early users, or a product that's already scaling with real customers? It changes how much depth I'll go into."

Default to MVP if no answer.

### Step 3 — Anti-pattern scan

Before starting production, scan the user's existing material against `sdlc-foundation/anti-pattern-catalog.md`. Common ones at this stage:

- 10+ feature list at MVP tier → MoSCoW pressure
- Implementation references in stated requirements ("user logs in via Auth0") → strip them
- Adjective-only NFRs ("fast", "secure") → flag for replacement with precise metrics
- Microservices already named in the requirements → architecture decision leaking into requirements

Surface findings briefly, then continue. Don't block.

### Step 4 — Sequence the granular skills

Invoke each in turn. Each granular skill knows how to handle producer vs refiner mode. Pass forward the previous step's output.

```
1. /req-user-stories  → produces or refines INVEST stories
2. /req-acceptance    → adds Gherkin Given-When-Then to each story
3. /req-nfr           → produces NFR catalog with precise metrics
4. /req-srs           → assembles formal SRS document (skip at hackathon tier)
5. /req-rtm           → produces traceability matrix (skip at hackathon and lean MVP tiers)
```

Between steps, briefly summarize what just got produced and what's next ("Stories drafted — 4 Must-have, 2 Should-have. Adding Gherkin acceptance criteria next."). The user can interrupt at any point.

### Step 5 — Final assembly

After all granular steps complete, produce a final summary:

- Pointer / inline content of each artifact produced
- A "what changed during refinement" section if any inputs were refined (so the user can see what the methodology compliance caught)
- A clear next-step recommendation: typically `/design` for the architecture phase, or `/decide` if a major architectural question is open

## Methodology folded in

This orchestrator is the textbook example of the plugin's "method, not review" principle. It doesn't ever audit or critique; every step produces forward progress. Methodology compliance happens *as a byproduct* of refinement: when a user passes in "the system should be fast," the NFR step refines it to "p95 < 200ms at 1000 concurrent requests" and notes the change. The user gets the rigor whether they knew to ask for it or not.

## Audience adaptation

- **Novice mode**: walk through the steps with explanations of what's happening and why each artifact matters. Annotate generated artifacts inline. Recommend defaults rather than asking the user to decide details.
- **Default mode**: announce each step crisply, produce clean artifacts with brief headers. Ask only when a decision genuinely needs the user.
- **Senior mode**: produce all artifacts with minimal narration. Mention what was refined only if it surprised the methodology check.

## Examples

### MVP-tier from a one-paragraph brief (default mode)

User: "I'm building a habit tracker app. Users add habits, mark them done daily, see streaks, get a weekly summary. Targeting launch in 8 weeks with a 50-person beta."

Response:
> MVP tier — 8 weeks, beta cohort. Running the spec sequence at MVP depth.
>
> **1. User stories drafted (Must-have, INVEST-compliant):**
> - US-001 — Add a habit
> - US-002 — Mark a habit done
> - US-003 — View streak for each habit
> - US-004 — Receive weekly summary
> ... [each with INVEST notes]
>
> **2. Acceptance criteria (Gherkin):**
> - US-001: Given a logged-in user, when they create a new habit with a name and frequency, then the habit appears on their dashboard...
> ... [all Must-haves get full Gherkin; Should-haves get informal ACs]
>
> **3. NFRs:**
> - PERF-001: Dashboard loads p95 < 1.5s under typical load (50 concurrent users)
> - AVAIL-001: 99% uptime over 30-day window (consumer-grade, not banking-grade)
> - SEC-001: User credentials hashed with argon2id; no PII in logs
> ... [tier-appropriate metrics]
>
> **4. SRS (3-page document):** [link or inline]
>
> **5. RTM:** Skipping at this tier — stories will link to test files informally.
>
> No tier-mismatches or anti-patterns detected. **Next step: `/design`** for the architecture (data model, modular monolith for this scope, deployment shape).

### Scaling-tier from existing partial work (senior mode)

User: "Have user stories drafted in this doc [attached]. Need to bring them up to spec for the SOC 2 audit next quarter."

Response:
> Scaling-tier; SOC 2 scope means full rigor. Read 18 stories from the attached doc.
>
> **Refinement pass on existing stories:**
> - 4 stories failed INVEST: 2 too large (split into 5), 1 unestimable, 1 has implementation in the requirement (stripped)
> - 18 stories → 22 stories after split
>
> **Acceptance criteria added (Gherkin, 1-3 scenarios per story).**
>
> **NFR catalog:**
> - Performance, Availability, Reliability, Scalability, Security, Maintainability, Usability — full taxonomy
> - Security NFRs reference SOC 2 CC6 (Logical and Physical Access) and CC7 (System Operations)
>
> **SRS assembled** with semantic + packaging properties enforced. PCI scope statement added (none — clarify if cardholder data is in scope).
>
> **RTM produced** — forward (req → tests) and backward (tests → req). Recommend wiring into CI per `sdlc-foundation/decision-frameworks.md` cost-benefit framing.
>
> Next: `/design` for the architecture-level audit (will spot Distributed Monolith risks if any). Or `/decide` if you have specific open architectural questions ahead of the audit.

Notice how the senior-mode response is denser, skips definitions, and assumes the user knows what SOC 2 CC6/CC7 are.

## Anti-rationalization table
| Common Excuse | Why It's Wrong | What to Do Instead |
|---|---|---|
| "I already know what to build" | Writing it down reveals hidden assumptions and missing stakeholders. | Write user stories. INVEST-check them. Then start coding. |
| "Requirements will change anyway, why document?" | Changing documented requirements is traceable. Changing undocumented assumptions is chaos. | Document current understanding. Update when things change. |
| "This is obvious, it doesn't need acceptance criteria" | "Obvious" means different things to different people. ACs are the definition of done. | Write Given-When-Then for every story. |
