# Anti-Pattern Catalog

This is active diagnostic content. Every command should be running these patterns in the background while the user is talking — when one matches, surface it even if the user didn't ask. The point of an expertise layer is to catch what an experienced engineer would catch automatically.

For each anti-pattern: the **signature** (what makes it visible), the **why-bad** (concrete cost), and the **redirect** (what to do instead). Always lead with the cost when flagging — telling someone "that's an anti-pattern" without explaining why is just gatekeeping.

---

## Requirements anti-patterns

### "Fast" / "easy to use" / "secure" with no metric

- **Signature**: An NFR stated as an adjective without a measurable threshold.
- **Why bad**: An NFR you can't measure is one you can't verify, can't test, and can't disagree about until it's too late. "Fast" to a developer means p95 < 200ms; to a user it might mean "loads before I get bored." These don't match and the gap surfaces in production.
- **Redirect**: Replace with a precise metric — response time at a percentile under defined load, throughput in transactions/second, MTBF in hours, % uptime over a defined window.

### Implementation in requirements

- **Signature**: A user story or requirement that names a specific technology, framework, or class structure ("user logs in via OAuth using Auth0 SDK").
- **Why bad**: Requirements describe *what* the system does and *why*; design and implementation describe *how*. Mixing them locks you into an implementation choice before you've evaluated alternatives, and makes the requirements brittle to tech swaps.
- **Redirect**: Strip the tech reference. "User authenticates with their existing identity provider before accessing protected resources." The how-to-implement decision moves to the architecture/design phase where alternatives can be compared.

### User story without acceptance criteria

- **Signature**: A user story sits in a backlog with no Given-When-Then specifying when it's "done."
- **Why bad**: Without ACs, "done" is a matter of opinion. Stories ship that don't behave the way the PM imagined. Tests can't be written before the code (or even alongside it). The story fails the **T**estable in INVEST.
- **Redirect**: Every story gets at least one Gherkin scenario before it's accepted into a sprint. See `decision-frameworks.md` for INVEST and Gherkin grammar.

### "Just one more feature" creep at MVP stage

- **Signature**: Feature list at MVP stage exceeds 5-7 items; user is adding "just one more" each cycle.
- **Why bad**: Empirical MVP success rates fall sharply with feature count: ~64% success with 3-5 features, ~48% with 6-9, ~31% with 10+. Each added feature multiplies coordination cost and dilutes user signal.
- **Redirect**: Apply MoSCoW (Must/Should/Could/Won't). Cut to Must-haves only for MVP. Park Should/Could in a v2 list.

---

## Architecture anti-patterns

### Premature microservices

- **Signature**: User wants microservices on day one. They're starting from a blank repo or a small codebase. They cite "scalability" or "best practices" rather than a specific organizational or technical pressure.
- **Why bad**: Microservices solve an **organizational** scaling problem (Conway's Law), not a technical performance one. Distributing too early triggers the **Distribution Tax** — every former in-process method call becomes a network hop, requiring outbox patterns, idempotency, retries, circuit breakers, distributed tracing — all to solve problems that didn't exist in the monolith.
- **Redirect**: **Modular Monolith First**. Use Hexagonal Architecture / Ports and Adapters / Clean Architecture / DDD to enforce strict module boundaries inside one deployable. When (if ever) team-scaling pain becomes the dominant cost, extract a domain whose boundaries have stabilized using the Strangler Fig pattern.

### Distributed monolith

- **Signature**: Multiple "microservices" that all deploy together, share a database, and break when one is down.
- **Why bad**: Worst of both worlds. You pay the Distribution Tax (network calls, eventual consistency, complex deployment orchestration) AND you don't get the autonomy benefits (independent deploys, team ownership, isolated failure). Coupling crosses service boundaries, so refactoring is *harder* than it would be inside a monolith.
- **Redirect**: Either (a) collapse back into a modular monolith and re-extract later when boundaries are clear, or (b) audit each cross-service coupling — shared DB tables, synchronous chains of calls, deployment ordering — and break them via outbox patterns, async events, or service consolidation.

### Chatty microservices

- **Signature**: A user request triggers a cascade of N+1 sync calls between services.
- **Why bad**: Latency adds, error rates compound, debugging requires distributed trace skills. Cost grows superlinearly with number of services involved.
- **Redirect**: Aggregate at the gateway (BFF pattern, GraphQL federation), batch upstream calls, push state via async events, or consolidate the chatty services back into one.

### Monolith-in-microservices

- **Signature**: One service is dramatically larger than the others, contains multiple unrelated functional domains, and is the source of most deploys.
- **Why bad**: The "microservice" is a monolith wearing a costume. You've taken on the Distribution Tax for the small services without the autonomy benefits for the big one.
- **Redirect**: Apply vFunction-style domain analysis (Exclusivity, Complexity, Criticality, Technical Debt) to the bloated service. Identify exclusive domains and extract them — but only if their boundaries have stabilized. If not, leave the monolith alone and stop pretending.

### Vendor lock that wasn't a decision

- **Signature**: Architecture depends on a specific managed service in ways that make migration expensive, but the user can't articulate why they chose it over alternatives.
- **Why bad**: Managed services are fine choices when chosen deliberately. They become anti-patterns when chosen by default and the lock-in surfaces during a price hike, an outage, or a compliance shift.
- **Redirect**: Write an ADR retroactively. Document the decision, the alternatives considered, the criteria, and the reversal cost. If the reversal cost is unacceptable for the value gained, abstract behind a port/adapter for future flexibility.

---

## Deployment anti-patterns

### Credentials in source

- **Signature**: API keys, database URLs with passwords, OAuth client secrets, or tokens checked into git history.
- **Why bad**: git history is forever. Even after a force-push purge, someone has likely cloned the repo, the value has likely been indexed by automated scrapers, and the credential is compromised. Rotation is the only fix.
- **Redirect**: Move secrets to environment variables, secret managers (AWS Secrets Manager, Vault, Doppler, GitHub Actions secrets). Use `.env.example` for the *shape* of required env vars without values. Purge history if discovered (`git filter-branch` / BFG Repo-Cleaner) AND rotate the leaked credentials.

### "Works on my machine" deploys

- **Signature**: Production behavior differs from local; "I tested it locally" preceded the bug report.
- **Why bad**: Local environments diverge from production along dozens of axes (OS, dependency versions, environment variables, data state, network conditions). The drift is invisible until it surfaces in production where it's most expensive.
- **Redirect**: Containerize. Use the same Docker image (or equivalent) in CI, staging, and production. Pin dependency versions. Mirror production data shapes in staging. CI is the only legitimate "it works."

### No rollback plan

- **Signature**: Deploy is one-way; reverting requires a hotfix commit and another full pipeline run.
- **Why bad**: Mean-time-to-recovery is dominated by rollback time. If rolling back takes 30 minutes, your worst-case incident is at least 30 minutes long.
- **Redirect**: Keep the previous artifact warm and routable. Blue-green or canary with automated rollback on health-check failure. Database migrations should be backward-compatible across one version (additive changes first, drop columns later).

### Observability as logs only

- **Signature**: When something breaks, the team's first move is to grep production logs.
- **Why bad**: Logs alone make it hard to detect anomalies, hard to correlate cross-service issues, and impossible to see latency distributions. Logs are the *third* signal, not the first.
- **Redirect**: Three telemetry signals — **metrics** (numeric time-series: error rate, latency percentiles, throughput), **logs** (event records with structured fields), and **traces** (end-to-end request paths across services). The LGTM stack (Loki, Grafana, Tempo, Mimir) covers all three with shared correlation IDs. OpenTelemetry as the collection layer.

### Tier-inappropriate gating

- **Signature**: A hackathon project has a 12-step PR review checklist; a scaling startup has merge-to-main with no checks.
- **Why bad**: Both inverted. The hackathon dies of process; the scaling startup dies of regression.
- **Redirect**: Match gating to tier — see `maturity-tier-detection.md`. Hackathon: optional self-review. MVP: PR review + automated tests. Scaling: PR review + tests + security scan + smoke tests + canaries + automatic rollback.

---

## How to surface these in conversation

When you spot a match in the user's description:

1. **Name the pattern briefly.** "What you're describing sounds like a Distributed Monolith forming."
2. **State the concrete cost.** "That means you pay the Distribution Tax — network calls, eventual consistency complexity, deployment orchestration — without getting the autonomy benefit, since the services can't deploy independently."
3. **Offer the redirect.** "Two options: collapse back to a modular monolith and re-extract later when boundaries stabilize, or audit each cross-service coupling and break the offending ones."
4. **Don't lecture.** One paragraph max unless the user asks to dig in. The user has work to do; the anti-pattern flag is a signal, not a course.
