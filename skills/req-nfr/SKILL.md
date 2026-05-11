---
name: req-nfr
description: Produces or refines non-functional requirements (NFRs) with precise, verifiable metrics across the standard taxonomy — Performance, Throughput, Availability, Reliability, Scalability, Security, Maintainability, Usability. Use when the user asks for "NFRs", "non-functional requirements", "performance requirements", "quality attributes", "SLAs", "SLOs", or pastes vague quality statements ("must be fast", "highly available") and wants them turned into measurable specifications. Also use when the user has existing NFRs and wants them validated, refined, or expanded — refiner mode auto-detects and converts adjective-only NFRs into precise, percentile-based metric specifications. Tier-aware: hackathon NFRs are a single paragraph, MVPs get rough metrics for the most important categories, scaling startups get the full taxonomy with stricter thresholds.
---

# /req-nfr — non-functional requirements with precise metrics

Produces or refines NFRs across the standard taxonomy. The single most important rule of this skill: **no adjectives without metrics**. "Fast" is not an NFR; "p95 < 200ms at 1000 concurrent requests" is.

## The taxonomy

Eight categories, each with a precise-metric pattern. Full reference in `sdlc-foundation/decision-frameworks.md`; brief restatement here:

| Category | Metric pattern | Example |
| :--- | :--- | :--- |
| Performance | Response time at percentile under load | p95 < 200ms at 1000 concurrent requests |
| Throughput | Operations per unit time | ≥ 5000 transactions/second sustained |
| Availability | Uptime % over a window | 99.9% over rolling 30 days |
| Reliability | MTBF and MTTR | MTBF ≥ 30 days, MTTR ≤ 15 min |
| Scalability | Capacity headroom + scaling behavior | Linear scaling from 100 → 10,000 concurrent users with no architecture change |
| Security | Specific compliance, attack surface, encryption | All data at rest AES-256; PCI DSS Level 2 |
| Maintainability | Code quality metrics, change cost | Cyclomatic complexity < 15 per function; coverage ≥ 80% |
| Usability | Task success, time-on-task | New user signup completes in < 2 min; 95% task success rate |

## Two modes

### Producer mode

User has the system context (from prior elicitation, user stories, brief) but no NFRs yet. Skill produces a tier-appropriate NFR catalog.

### Refiner mode

User has existing NFRs of variable quality. Skill audits each for precise-metric compliance, identifies adjective-only NFRs, and produces refined versions with measurable thresholds.

The skill auto-detects mode from input.

## NFR format

```
NFR-<CATEGORY>-NNN — <short title>
The system shall <measurable requirement> under <stated load/conditions>.

Verification: <how this will be tested>
```

Example:
```
NFR-PERF-001 — Trade execution latency
The system shall execute and confirm trade orders within 500ms at the 95th percentile under sustained load of 100 concurrent users.

Verification: Load test with 100 simulated traders submitting orders at peak rate (10/sec); measure p95 of order-submit-to-confirm latency over 60-minute test.
```

The `Verification` field is what makes an NFR genuinely *Verifiable* per the SRS semantic properties. Without it, the NFR is a wish.

## Procedure

### Step 1 — Mode detection

- Existing NFRs in input → refiner mode (audit each for metric compliance)
- No prior NFRs but project context exists → producer mode
- Mix → refiner on existing + producer for missing categories

### Step 2 — Tier check

| Tier | NFR depth |
| :--- | :--- |
| Hackathon | One paragraph total: "fast enough that demos work, secure enough that nothing leaks" — no metric rigor |
| MVP | NFRs for Performance, Availability, Security; rough metrics; other categories optional |
| Scaling | Full taxonomy; precise metrics; verification methods documented; compliance (PCI/FIPPA/GDPR) explicitly scoped |

### Step 3a — Refiner mode procedure

For each existing NFR:

1. **Metric audit.** Does it contain a specific, measurable threshold? Look for:
   - **Numbers** (response time, throughput, %, count)
   - **Time windows** (over what period the metric applies)
   - **Load conditions** (under what stress)
   - **Percentiles or aggregates** (p95, p99, mean, max)

2. **Identify failures.** Common ones:
   - Adjective only ("fast", "secure", "reliable", "scalable")
   - Number without context ("99% available" — over what window? what counts as available?)
   - Vague threshold ("acceptable", "industry-standard")
   - Mixing categories (one "NFR" that conflates performance, availability, and security)

3. **Refine.** For each failure, produce a measurable replacement. Tier-appropriate thresholds:

| Adjective | Hackathon | MVP default | Scaling default |
| :--- | :--- | :--- | :--- |
| "fast" | "responsive enough for demo" | p95 < 1s at typical load | p95 < 200ms at peak load with verification load test |
| "available" | "doesn't crash during demo" | 99% over 30 days | 99.9% over 30 days, with SLI/SLO definitions |
| "secure" | "no obvious exploits" | Basic auth, HTTPS, no plaintext secrets | Specific compliance scope (PCI Level N, SOC 2 controls), encryption at rest + in transit, threat model |
| "scalable" | n/a | "supports planned 10× user growth without architecture change" | Specific scaling behavior (linear / sub-linear) across defined load range |
| "easy to use" | n/a | "new user signup completes in < 5 min" | Specific task success rates, time-on-task targets, accessibility (WCAG 2.1 AA) |

4. **Note what changed.** When refining "the system should be fast" into a precise NFR, briefly explain the choice of percentile, load, and threshold so the user understands they can override.

### Step 3b — Producer mode procedure

1. **Read the project context.** Look for cues that drive metric choice:
   - User scale ("50 beta users" → low concurrency targets; "thousands of paying customers" → higher)
   - Domain ("trading" → latency-sensitive; "blogging platform" → less so; "medical" → reliability-critical; "consumer" → usability-critical)
   - Compliance scope (any mention of credit cards → PCI; any mention of EU users → GDPR; healthcare → HIPAA; Quebec → FIPPA)
   - Stated SLAs / customer commitments (these become NFRs verbatim)

2. **Walk the taxonomy.** For each category, ask: "Is there a meaningful, tier-appropriate NFR here?" Skip categories that don't apply (e.g., a CLI tool may have minimal Availability requirements; a static site has minimal Scalability concerns).

3. **Set tier-appropriate defaults.** When the user hasn't specified, use the defaults table above. Annotate the NFR so the user knows what they can adjust.

4. **Cross-check NFRs against each other.** Common conflicts:
   - High availability + low cost (adds redundancy = adds expense)
   - Low latency + high reliability (retry logic adds latency; absent retries reduce reliability)
   - High security + high usability (auth friction)
   - High scalability + low consistency requirements (CAP-style tradeoffs)
   When two NFRs conflict, surface the tradeoff explicitly so the user can choose. See cost-benefit framing in `sdlc-foundation/decision-frameworks.md`.

5. **Verification methods.** Every NFR gets a `Verification` line stating how it will be tested. Without it, the NFR is unverifiable, which violates the SRS semantic property of *Verifiable*.

### Step 4 — Output

For each NFR:
- Numbered ID with category prefix (NFR-PERF-001, NFR-AVAIL-001, NFR-SEC-001, etc.)
- Full statement with measurable threshold and conditions
- Verification method
- For producer mode: brief annotation explaining the chosen threshold (so the user can adjust)

For the set as a whole:
- Coverage check: which categories are covered, which were skipped and why
- Cross-NFR tradeoffs flagged
- Compliance scope noted (PCI? GDPR? FIPPA? SOC 2?) — explicit "in scope" or "out of scope" beats silence
- Recommend next step: typically `/req-srs` to assemble into the formal document, or back to `/spec` if running as part of the orchestrator

## Anti-patterns this skill flags

- **Adjective-only NFRs.** "The system should be fast" — refine.
- **Aspirational NFRs without verification.** "99.999% uptime" but the team has one engineer and no on-call → not achievable, lower the target or add the resources.
- **Conflicting NFRs.** Caught in cross-check; flag for resolution.
- **Compliance-by-mention.** "We need to be GDPR compliant" without scope → ask which user populations, which data flows, which articles apply.
- **NFRs that should be requirements.** "User can log in via SSO" is a functional requirement (US-NNN), not an NFR. Move it.

## Audience adaptation

- **Novice**: explain why precise metrics matter (cite cost-of-defect curve), define percentiles inline, recommend defaults strongly, don't ask the user to choose between thresholds they don't have intuition for
- **Default**: lead with the NFR, follow with rationale and verification; only ask for input on numbers when the project context doesn't constrain them
- **Senior**: produce the NFRs in compact form; skip percentile definitions; assume the user can challenge specific thresholds

## Example — refiner mode (novice audience)

User input:
```
- The app should be fast
- It should be secure
- 99% uptime
- Easy to use for non-technical people
```

Response:

> All four of these need precise metrics — that's the difference between an NFR and a wish. Let me explain what's missing for each, then refine.
>
> **Why metrics matter:** an NFR you can't measure is one you can't verify. "Fast" to a developer might mean 200ms; to a user it might mean "loads before I get bored" (around 3 seconds for most people). If we don't write the number down, we're guaranteed to disagree about whether we hit the goal.
>
> **Refined:**
>
> ```
> NFR-PERF-001 — Page load latency
> The system shall load the dashboard within 1.5 seconds at the 95th percentile under typical load (50 concurrent users, MVP scope).
>
> Verification: Load test with 50 simulated users; measure p95 of dashboard-load time over 30 minutes.
> ```
>
> *Why this threshold: 1.5 seconds is comfortable for consumer-facing apps; faster (under 1s) is great but expensive; slower starts hurting engagement. p95 means 95% of loads must be within the threshold — we accept the slowest 5% may be slower because some users have slow internet, that's not our system's fault.*
>
> ```
> NFR-SEC-001 — Credential storage
> The system shall hash all user passwords using argon2id with the OWASP-recommended parameters; passwords shall never be logged, displayed, or transmitted in plaintext.
>
> Verification: Code review for password handling paths; SAST scan for plaintext credential references; manual log inspection during smoke tests.
> ```
>
> *"Secure" alone is meaningless — there are dozens of security properties. I picked the most fundamental one (password storage) since you didn't specify scope. If you're handling payments, accepting health data, or operating in the EU, we'll need more security NFRs.*
>
> ```
> NFR-AVAIL-001 — System availability
> The system shall maintain 99% availability measured over a rolling 30-day window. Availability is defined as the percentage of HTTP requests to the dashboard endpoint that return a 2xx or 3xx response within 5 seconds.
>
> Verification: External uptime monitor (StatusCake / UptimeRobot / Pingdom) hitting the dashboard endpoint every 60 seconds; monthly availability report generated from monitor logs.
> ```
>
> *99% over 30 days = roughly 7 hours of allowed downtime per month. If that feels like a lot for a paid product, we can tighten to 99.9% (43 minutes/month) — but that requires real on-call coverage and incident-response infrastructure, which is a big jump in operational cost.*
>
> ```
> NFR-USE-001 — Onboarding completion
> A new user shall be able to complete the signup flow and add their first habit within 3 minutes from the landing page; 90% of new users in usability testing shall complete this without assistance.
>
> Verification: Moderated usability test with 10 representative users; record time-to-first-habit and number who require help.
> ```
>
> *"Easy to use" was the hardest to make measurable — it's inherently subjective. The metric I chose (time + success rate in usability testing) is the standard way to make it concrete. If you want a stricter or looser target, the numbers are tunable.*
>
> **What I noticed:** you didn't mention the size of your user base, payment handling, or compliance scope. If any of those apply (especially payments or EU users), let me know — they bring additional NFRs around scalability, PCI, GDPR. Otherwise, ready to move to `/req-srs` to assemble the spec document.
