# Decision Frameworks

The engine of recommendations. When a command needs to evaluate a user story, refine an NFR, choose between architectures, or prioritize features, it leans on these frameworks. They are how the plugin generates *judgment*, not just artifacts.

Frameworks are grouped by lifecycle stage. Each entry is concise — the goal is enough content to drive a recommendation, not a full textbook chapter.

---

## Requirements frameworks

### INVEST (user story quality)

A user story should satisfy six criteria:

- **I — Independent.** The story can be developed and delivered without depending on another story being done first. Dependencies create coordination cost and block parallel work.
- **N — Negotiable.** The story is a starting point for conversation, not a fixed contract. Implementation details emerge from collaboration between PM, dev, and designer.
- **V — Valuable.** The story delivers user-visible (or business-visible) value. "Refactor the auth module" is not a story; "User stays logged in across browser restarts" is.
- **E — Estimable.** The story is small and clear enough that the team can size it. If it's not estimable, it's too vague or too big.
- **S — Small.** Fits in a single sprint comfortably. Stories that need to be split across sprints almost always have hidden complexity that should be exposed first.
- **T — Testable.** Has acceptance criteria you can verify objectively. If you can't write a test that proves the story is done, the story is malformed.

When evaluating an existing story against INVEST: name which letters fail and why, and offer a concrete refinement.

### Gherkin (acceptance criteria grammar)

Acceptance criteria use the **Given-When-Then** structure:

```
Given <some initial state>
When <an action occurs>
Then <an observable outcome>
```

Optional extensions:
- `And` / `But` to chain multiple Givens, Whens, or Thens
- `Background` for shared setup across multiple scenarios
- `Scenario Outline` with `Examples` table for parameterized variants

A good Gherkin scenario is **declarative**, not imperative. Bad: "click the login button, type the password, click submit." Good: "When the user submits valid credentials." Imperative ACs become brittle to UI changes; declarative ones survive refactors.

### NFR taxonomy

NFRs describe the *quality attributes* of the system — how it performs, not what it does. Every NFR must have a precise metric, otherwise it's an opinion.

| Category | Metric pattern | Example |
| :--- | :--- | :--- |
| **Performance** | Response time at percentile under load | p95 < 200ms at 1000 concurrent requests |
| **Throughput** | Operations per unit time | ≥ 5000 transactions per second sustained |
| **Availability** | Uptime % over a window | 99.9% over rolling 30 days |
| **Reliability** | Mean Time Between Failures, Mean Time To Recovery | MTBF ≥ 30 days, MTTR ≤ 15 minutes |
| **Scalability** | Capacity headroom + scaling behavior | Linear scaling from 100 to 10,000 concurrent users with no architecture change |
| **Security** | Specific compliance, attack surface, encryption | All data at rest AES-256; PCI DSS Level 2 compliant |
| **Maintainability** | Code quality metrics, change cost | Cyclomatic complexity < 15 per function; 80%+ test coverage |
| **Usability** | Task success rate, time-on-task | New user can complete signup in < 2 minutes; 95% task success rate |

When refining an NFR with no metric, replace the adjective with a measurable threshold relevant to the user's tier (see `maturity-tier-detection.md` for tier-appropriate thresholds).

### SRS quality properties

A formal Software Requirements Specification must satisfy two property sets:

**Semantic properties** (about meaning):
- **Complete** — defines all acceptable implementations
- **Implementation Independent** — no design or code decisions unless imposed as constraints
- **Unambiguous** — exactly one interpretation per requirement
- **Consistent** — no requirements conflict with each other
- **Precise** — defined boundaries and timing for testability
- **Verifiable** — each requirement can be objectively confirmed

**Packaging properties** (about structure):
- **Modifiable** — organized to localize change impact
- **Readable** — accessible to technical and non-technical stakeholders
- **Referenceable** — structured for quick retrieval (numbered sections, indices, glossaries)

When assembling an SRS, check both sets. A common failure mode: the document is semantically rigorous but structurally a wall of text, which means no one reads it.

### MoSCoW (feature prioritization)

When the feature list is too long for the available time/budget:

- **Must have** — non-negotiable; failure to deliver = failure of the project
- **Should have** — important but not vital; can be deferred if forced
- **Could have** — nice; deferred without significant impact
- **Won't have (this time)** — explicitly out of scope; documented to prevent re-litigation

For MVPs especially, the empirical success rates favor narrow scope: ~64% with 3-5 features, ~48% with 6-9, ~31% with 10+. Push back when Must-have lists exceed ~5 items.

### Goal Concept (resolving the NFDR Paradox)

Non-functional Deployment Requirements (NFDRs) — like memory limits, container constraints, network policies — emerge late in design but feel like they should have been requirements all along. The Goal Concept resolves this:

- **Functional Hard Goals** — specific actions the system must perform
- **Non-Functional Hard Goals** — precise constraints (e.g., "service must restart if memory exceeds 2GB")
- **Soft Goals** — qualitative preferences (e.g., "high usability") with a documented satisficing condition
- **Claims** — documented rationale for how a design satisfies a goal

When a deployment constraint surfaces late, classify it: Hard goal (mandatory) or Soft goal (preference)? Document the Claim that links the design choice back to the goal.

---

## Architecture frameworks

### Modular Monolith First

The default architectural choice for any new system. A single deployable with strict module boundaries enforced by the language and architecture (Hexagonal / Ports and Adapters / Clean Architecture / Domain-Driven Design).

Why default-monolith:
- One codebase, one deploy, one process to debug
- In-process method calls instead of network hops
- Refactoring across module boundaries is a compiler-checked code change, not a multi-service migration
- You can re-extract a module into a service later if and when the *organizational* (not technical) need arises

Microservices solve **organizational scaling problems** — Conway's Law. They are not a performance pattern; they are a team-coordination pattern. Adopting them before you have the team-coordination problem they solve is paying the **Distribution Tax** for nothing.

### Conway's Law

> "Any organization that designs a system... will produce a design whose structure is a copy of the organization's communication structure." — Melvin Conway

Practical implications:
- Software architecture *will* mirror the team structure, whether you plan it or not
- If you have one team, you'll ship a monolith naturally
- If you have multiple teams, microservice boundaries that don't match team boundaries will be miserable
- **Inverse Conway maneuver**: design the team structure you want first, then let the architecture emerge

When a user is debating microservices vs monolith, the decisive question is "how many independent teams will own the code in 12 months?" Not "how big do we expect this to scale?"

### Distribution Tax

The cumulative cost of distributing a system that didn't have to be distributed:

- **Network failures** — every former in-process call is now a potential timeout, retry, or partial failure
- **Eventual consistency** — operations that were ACID transactions become async events with outbox patterns and saga orchestration
- **Distributed tracing** — debugging requires correlating spans across services
- **Deployment orchestration** — versioning, contract testing, rollout coordination
- **Idempotency** — every receiver must handle duplicate messages gracefully
- **Operational surface area** — N services means N service discovery entries, N CI pipelines, N on-call runbooks

The tax is *real* and *worth it* when the underlying problem (team scaling, isolated failure domains, independent release cadence) is real. It's pure waste when applied prematurely.

### Strangler Fig pattern

When migrating from a monolith to microservices (or any architectural transition):

1. Identify a bounded context with stable boundaries inside the monolith
2. Build the new service alongside the monolith
3. Route a portion of traffic to the new service via a routing layer (gateway, proxy)
4. Gradually shift more traffic until the old code path is dead
5. Remove the dead code

The pattern is named after the strangler fig, which gradually replaces a host tree from the outside. The discipline is *gradual replacement* — never a big-bang rewrite, always shipping intermediate states.

### vFunction analysis (decomposition criteria)

When deciding whether to extract a domain from a monolith into a service, evaluate four dimensions:

- **Exclusivity** — how independent is this domain from the rest of the codebase? Cross-cutting domains shouldn't be extracted.
- **Complexity** — how deep are its dependencies? Highly entangled domains will fight extraction.
- **Criticality** — what's the impact on system availability if this domain fails? High criticality = invest in resilience patterns.
- **Technical Debt** — what's the ratio of maintenance to innovation in this domain? Extraction is a chance to reset; high-debt domains benefit most.

Extract domains that are high-exclusivity, high-criticality, manageable-complexity, and high-debt. Leave the rest in the monolith.

### C4 model (architectural diagrams)

Four levels of architectural abstraction:

1. **System Context** — your system as one box, surrounded by external actors and systems
2. **Container** — major deployable units (web app, API, mobile app, database)
3. **Component** — major code units inside one container (controllers, services, repositories)
4. **Code** — class diagrams, only when needed for a specific complex area

Levels 1-3 are usually all you need. Level 4 is rarely worth the maintenance cost — code itself is the source of truth.

---

## Deployment frameworks

### CI/CD pipeline phases

Standard six-phase shape:

1. **Source Control** — commits trigger pipeline; branch protection, signed commits
2. **Build Automation** — compilation, dependency resolution, license scanning
3. **Automated Testing** — unit, integration, contract, security; coverage gates
4. **Artifact Archival** — immutable artifact (container, binary) with checksum, vulnerability scan
5. **Delivery / Deployment** — promotion to environments with health checks and smoke tests
6. **Observability** — metrics/logs/traces flowing into central pipeline; auto-rollback on anomaly

The pipeline shape is the same across tiers; what changes is the *strictness* of each phase (see `maturity-tier-detection.md`).

### Three telemetry signals

Operating any non-trivial system requires:

- **Metrics** — numeric time-series (CPU, memory, error rate, latency percentiles, throughput). Used for dashboards, alerts, capacity planning.
- **Logs** — structured event records. Used for incident investigation, audit trails, debugging.
- **Traces** — end-to-end request paths across services with timing. Used for understanding latency, finding chatty services, debugging distributed bugs.

A correlation ID (W3C Trace Context) flowing through all three lets you pivot from a metric anomaly to the relevant traces to the underlying logs.

### LGTM stack

A common open-source observability stack from Grafana Labs:

- **L**oki — log aggregation
- **G**rafana — visualization across all signals
- **T**empo — distributed tracing backend
- **M**imir — metrics storage at scale

Pairs with **OpenTelemetry** as the vendor-neutral collection layer. Adopting OpenTelemetry first lets you swap backends later without re-instrumenting.

### Tier-appropriate gating

| Tier | Required pre-merge gates |
| :--- | :--- |
| Hackathon | Optional self-review |
| MVP | PR review (1+ approver), all unit tests pass, no obvious secrets in diff |
| Scaling | PR review (2+ approvers across teams), all tests, security scan (SAST + dependency vulnerabilities), build artifact, smoke tests in staging, canary deploy, automated rollback on health-check failure |

---

## Cross-cutting frameworks

### Forward and backward traceability

The Requirements Traceability Matrix (RTM) links requirements to their downstream artifacts both ways:

- **Forward traceability** — every requirement maps to design elements, code, tests. Ensures nothing is missing.
- **Backward traceability** — every design element / code change / test maps back to a requirement. Prevents scope creep ("why does this feature exist?" should always have an answer).

Both directions are necessary. Forward-only catches gaps; backward-only catches creep; both catch both.

### Cost-benefit framing for decisions

When the user is weighing two options, frame the comparison as:

- **Cost** of choosing this option (time, money, reversal cost, complexity)
- **Benefit** of choosing this option (capability gained, risk reduced, optionality preserved)
- **Counterfactual** — what does the alternative cost / gain?

The framework prevents the common failure mode of evaluating one option in isolation. Decisions are always relative.
