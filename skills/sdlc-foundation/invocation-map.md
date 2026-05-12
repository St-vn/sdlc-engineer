# sdlc-engineer Skill Invocation Map

*Complete mapping of every invocation relationship across the 48-skill surface:
hooks, auto-invokes, orchestrators, sub-skills, and circumstance gates.*

---

## Layer 0 — Hooks (Always Active, Outside Token Budget)

These fire at the Claude Code harness level, not as skills:

### SessionStart hook
```
→ reads .sdlc/project.yml + ~/.sdlc/user.yml
→ injects both into session context as first user message
→ if no project.yml exists: surfaces warning, recommends /configure
```

### PreToolUse hook  (guard)
```
→ fires before EVERY bash call
→ intercepts: rm -rf outside task scope, git reset --hard,
              git push --force, DROP TABLE, DELETE FROM without WHERE,
              writes to .env / *.key / secrets.*, writes outside task file set
→ requires explicit confirmation before proceeding
→ freeze mode: if /freeze <path> active, blocks all writes outside that path
```

### Stop hook  (session-save)
```
→ fires when session ends for any reason
→ writes session checkpoint to docs/sdlc-engineer/sessions/
→ records: completed tasks, remaining tasks, decisions made, failed approaches, git state
```

---

## Layer 1 — Auto-Invoked from Chat

### consult
```
triggers: "I have an idea", "where do I start", "should I build X",
          "what's the best approach to", "I want to make a..."
then invokes:
  → /configure         if .sdlc/project.yml doesn't exist
  → /decide            if a blocking architectural choice surfaces
  → /spec              if requirements need to be captured
  → /design            if architecture is the next needed step
  → /implement         if spec+design artifacts already exist
```

### decide
```
triggers: "should I use X or Y", "monolith or microservices",
          "which database", "REST vs GraphQL", "X vs Y"
then invokes:
  → arch-adr subagent  if decision warrants a formal ADR
  → /design            if decision has downstream architecture implications
```

### debug
```
triggers: "this test is failing", "getting an error", "it's broken",
          "why isn't X working", "it crashed", "exception", "undefined"
runs:
  → phase 0: reproduce (confirm failure is consistent)
  → phase 1: isolate (binary search — which commit, which input, which layer)
  → phase 2: hypothesize (root cause candidates, ranked by likelihood)
  → phase 3: verify fix (run RED → GREEN confirmation)
after completion:
  → writes to docs/sdlc-engineer/learnings.jsonl
    {"type": "failed-approach", ...} or {"type": "root-cause", ...}
```

---

## Layer 2 — Orchestrators and What They Invoke

### /configure

```
no sub-skills invoked — runs inline
asks ≤ 8 questions (must-ask set)
infers silently (stack, test runner, CI, database) with soft confirmation
derives: security-tier, launch-tier, research-tracks, sub-skill-gates
writes: .sdlc/project.yml (committed), ~/.sdlc/user.yml (local)
reads first: docs/sdlc-engineer/learnings.jsonl
  → surfaces any prior config corrections before asking questions
gate: runs before any other orchestrator; all others check for project.yml first
```

---

### /spec

```
pre-flight: project.yml exists? → if not, invoke /configure first

dispatches subagents in sequence:

subagent 1 → elicit
  input: raw idea + project config
  produces: stakeholder inputs, domain constraints, pain points
  reads: research brief (if exists) → surfaces validated pain points
  gate: always runs

subagent 2 → req-user-stories
  input: elicit output
  produces: INVEST-compliant user stories
  gate: always runs

subagent 3 → req-acceptance
  input: user stories
  produces: Gherkin AC (Given/When/Then) per story
  gate: always runs

subagent 4 → req-nfr
  input: elicit output + research brief (technical track, if exists)
  produces: NFRs with precise metrics (no vague "fast" NFRs)
  gate: always runs
  config gates applied:
    auth: none → suppress auth NFRs
    monetization: none → suppress payment NFRs
    audience: eu-consumers → require GDPR NFRs
    regulated: hipaa → require audit trail NFRs
    security-tier: standard+ → require HSTS, CSP, RLS, RBAC NFRs

subagent 5 → req-srs
  input: user stories + AC + NFRs
  produces: SRS at tier-appropriate depth
    intent: hackathon → 3-page brief
    intent: production-saas → full SRS with semantic+packaging properties
  gate: always runs

subagent 6 → req-rtm
  input: all req-* outputs
  produces: requirements traceability matrix
  gate: always runs
```

---

### /design

```
pre-flight: /spec artifacts exist? → if not, prompt to run /spec first

dispatches subagents in sequence:

subagent 1 → analyze
  input: spec artifacts + project config
  produces: feasibility assessment, tradeoff evaluation, dependency mapping
  gate: always runs

subagent 2 → arch-complexity
  input: analyze output + spec
  produces: complexity tier (simple / moderate / distributed)
  gate: always runs — gates arch-decompose below
  runs alongside analyze, not after (parallel where possible)

subagent 3 → arch-use-cases
  input: elicit output + user stories
  produces: use case diagrams and actor maps
  gate: always runs

subagent 4 → arch-components
  input: use cases + tech stack (from config)
  produces: component diagram, data model, API surface
  config gates applied:
    auth: email+ → require cookie consent mechanism component
    intent: production-saas → require error monitoring component
    audience: eu-consumers → require cookie consent banner component
  gate: always runs

subagent 5 → arch-sequence
  input: components + use cases
  produces: sequence diagrams for critical paths
  gate: always runs

subagent 6 → arch-adr
  input: any major decision from arch-components or arch-sequence
  produces: one ADR per major decision
  gate: fires for each decision point — may produce multiple ADRs
  also invoked by: /decide when decision warrants formal record

subagent 7 → arch-c4
  input: components + sequence
  produces: C4 context/container/component diagrams
  gate: always runs

subagent 8 → arch-decompose
  input: arch-complexity output + components
  gate: ONLY if arch-complexity flags distributed system risk
    intent: hackathon or mvp + simple complexity → suppressed
    intent: production-saas + distributed complexity → runs
```

---

### /implement

```
pre-flight checks (in order):
  1. project.yml exists? → if not, invoke /configure first
  2. spec artifacts exist? → if not, prompt to run /spec first
  3. design artifacts exist? → if not, prompt to run /design first
  4. research brief exists and < 7 days old?
     → if not AND research-tracks.technical: true → invoke research subagent
  5. session checkpoint exists for this branch?
     → if yes, invoke session-restore subagent first

subagent 0 → research  (conditional)
  input: project config, spec artifacts, intended stack
  gate: research-tracks.technical: true AND no recent research brief
  produces: technical brief (library health, CVEs, architecture patterns)
  mandatory searches (live, not training knowledge):
    - current version/status of each candidate library
    - open CVEs for intended dependencies
    - documented failure modes of intended architecture
    - newer alternatives to planned approach
  feeds: req-nfr (NFRs updated from actual platform limits)

subagent 1 → tasks
  input: spec + design artifacts + research brief (if exists) + learnings.jsonl
  produces: plan file with per-task structure:
    AC reference, NFRs in scope, complexity, dependency graph,
    file set, failing test (write this first), RED command,
    implementation goal, GREEN command, verification step
  config gates applied:
    auth: none → suppress auth tasks
    monetization: none → suppress payment tasks
    team-size: solo → sequential task list
    intent: hackathon → flat list, minimal metadata
    intent: production-saas → full dependency graph, parallelization analysis
  reads: learnings.jsonl → surfaces anti-patterns to watch for

task execution loop:
  for each task wave (grouped by dependency graph):

    parallelization decision:
      IF task count in wave > 1
      AND file sets are disjoint
      AND (task count total > 8 OR team-size: small-2-5+)
      AND Claude Code Task tool available
      → execute-parallel (dispatches all wave tasks simultaneously, each in own worktree)
      ELSE IF Claude Code Task tool available
      → execute-subagent (fresh context per task, sequential)
      ELSE
      → execute-inline (current session, sequential, fallback)

    per task (inside execute-subagent or execute-parallel):
      step 1: write failing test exactly as specified in plan
      step 2: run RED confirmation
        → if test already passes: STOP — flag as test integrity failure — do not continue
      step 3: write minimal implementation
      step 4: run GREEN confirmation
        → if still failing: invoke debug subagent immediately
        → do not attempt second implementation without diagnosis
      step 5: run full suite — confirm no regressions
      step 6: check NFRs in scope
      step 7: commit (feat: Task N — name (satisfies AC ref))

    after each task → review-spec subagent
      input: task AC + git diff ONLY (no codebase context — isolation principle)
      produces: PASS / FAIL / WARN
      on FAIL: return to execute-subagent with failure reason
      on PASS: continue to code quality review
      → then quality reviewer subagent
        input: diff + ADRs + coding standards ONLY
        produces: PASS / WARN / BLOCK
        on BLOCK: return to execute-subagent

    after each wave:
      → run integration tests before next wave starts

after all tasks complete:
  subagent → ci-verify
    gate: branch pushed AND (.github/workflows/ OR .gitlab-ci.yml OR Jenkinsfile OR .circleci/ exists)
    AND (gh CLI OR glab CLI available — else skip + log warning + output branch URL)
    polls for CI completion (timeout: 10 min)
    on failure: surfaces specific step that failed + log output
      → test failure → actionable, return to debug
      → infrastructure failure → retry recommended

  subagent → finish-branch
    pre-flight: all tasks complete + full suite green + CI green + spec compliance PASS + no quality BLOCKs
    presents 4 options:
      merge to main → squash WIP commits, merge, delete branch and worktrees
      open PR → auto-populate description from methodology artifacts
      keep branch → trigger session-save, commit checkpoint
      discard → confirm explicitly, worktree remove, branch -D

context management throughout:
  every 3 tasks: checkpoint report (tasks done, tests added, NFR violations, context window %)
  if context window approaching limit: trigger session-save before continuing
```

---

### /ship

```
pre-flight: all /implement tasks complete, CI green, finish-branch PASS

subagent 1 → audit-security
  always runs, depth gated on security-tier:

  security-tier: minimal (hackathon)
    → 5-minute grep pass only:
      SQL string concatenation, hardcoded credentials,
      unescaped innerHTML, missing auth middleware

  security-tier: standard (mvp/internal)
    → OWASP Top 10 grep scan (scoped to detected stack)
    → STRIDE threat model against arch-components + arch-c4
    → standard hardening checklist
    → confidence gate: 8/10+ before flagging finding

  security-tier: hardened (production-saas/regulated)
    → full OWASP + STRIDE
    → comprehensive hardening checklist
    → secrets archaeology:
        git log --all --full-history -- "*.env" "*.key" "*.pem"
        git grep -i "password|secret|api_key|token" $(git rev-list --all)
    → confidence gate: 2/10 — everything surfaced for human triage

subagent 2 → qa-headless
  always runs, depth gated on intent:
  intent: hackathon → health checks + critical path only
  intent: mvp → health checks + API contract + auth enforcement
  intent: production-saas → full suite:
    health checks, API contract, auth enforcement,
    NFR verification (curl -w "%{time_total}"),
    error handling, integration paths
  derives test cases mechanically from Gherkin AC
    Given/When/Then → HTTP request sequences

subagent 3 → qa-browser
  gate: intent ≠ hackathon AND @playwright/mcp installed
  if not installed: skip + log warning "install @playwright/mcp for browser QA"
  runs: auth flows, form submissions, JavaScript-rendered content,
        visual regression candidates, session/cookie behavior
  uses accessibility snapshots (lower token cost than raw DOM)

subagent 4 → monitor
  gate: intent: mvp or production-saas
  intent: mvp → minimal: health endpoint + error monitoring active
  intent: production-saas → full: uptime, latency, error rate, alert configuration

subagent 5 → benchmark
  gate: intent: production-saas
  runs: curl-based load simulation, Lighthouse (if Node available)
  produces: benchmark JSON committed for history + before/after comparison

deploy cluster (subagents 6-11):
  gate: deployment-target ≠ local-only

  subagent 6 → deploy-tier
    gate: always runs if deployment target exists
    produces: tier-appropriate deployment configuration

  subagent 7 → deploy-cicd
    gate: .github/workflows/ or .gitlab-ci.yml exists
    produces: CI/CD pipeline definition or validation

  subagent 8 → deploy-observability
    gate: intent: production-saas
    produces: observability plan (metrics, logs, traces, alerts)

  subagent 9 → deploy-secrets-audit
    gate: security-tier: standard or hardened
    cross-references: secrets in code vs. secret manager vs. .env.example

  subagent 10 → deploy-release-check
    gate: always runs if deployment target exists
    produces: release checklist status before any deploy action

  subagent 11 → deploy-rollback
    gate: intent: production-saas
    produces: rollback plan and runbook

subagent 12 → launch-readiness
  gate: launch-tier: standard or full
  launch-tier: minimal (hackathon) → suppressed entirely
  checklist items gated on config:
    auth: email+ → auth + session checklist
    audience: eu-consumers → GDPR/cookie consent checklist
    monetization: subscription+ → payment lifecycle checklist
    intent: production-saas or mvp+public → SEO/discoverability checklist
    intent: mvp or production-saas → feedback loop checklist
  proactive verification:
    every checklist item was ALREADY REQUIRED by /spec or /tasks
    this subagent VERIFIES — it does not discover for the first time

subagent 13 → sync-docs
  gate: always runs at end
  updates: README, ARCHITECTURE.md, CONTRIBUTING.md, CHANGELOG.md
  marks plan file as SHIPPED with date
  updates RTM implementation status
  drift detection:
    implemented things not in spec → flag for removal or document
    specced things not in diff → flag as TODO or remove from RTM
    ADR decisions overridden without new ADR → create retrospective ADR
```

---

### /retro

```
runs standalone — no sub-skills dispatched
reads all artifacts:
  plan files (estimates vs actual), debug logs, learnings.jsonl,
  RTM, CI results, test coverage delta, research brief
analyzes:
  plan accuracy, AC quality, NFR accuracy, debug patterns,
  anti-patterns caught, CI failures, research accuracy, config accuracy
produces: docs/sdlc-engineer/retros/YYYY-MM-DD-<feature>.md
after completion:
  → writes calibration entries to learnings.jsonl:
    NFR threshold corrections, config corrections to apply next project,
    research gaps (searches that would have caught what was missed)
    new anti-patterns to add to catalog
```

---

## Cross-Cutting Invocations (Happen Inside Any Skill)

```
ANY skill encounters anti-pattern
  → writes to docs/sdlc-engineer/learnings.jsonl
    {"type": "anti-pattern", "pattern": ..., "context": ..., "relevant_skills": [...]}

ANY skill encounters mid-project config correction
  (e.g., discovers PII in data model, config had security-tier: standard)
  → writes: {"type": "config-correction", "field": ..., "was": ..., "corrected-to": ..., "reason": ...}
  → re-derives affected sub-skill-gates

/debug completion (from any trigger)
  → writes: {"type": "root-cause", ...} and/or {"type": "failed-approach", ...}

/implement task execution — execute-subagent calls debug
  → debug writes to learnings.jsonl
  → learnings.jsonl available to next task's subagent

/configure (on any invocation)
  → reads learnings.jsonl FIRST
  → surfaces prior config corrections before asking questions
  → pre-populates suggested values from correction history

/tasks (on invocation)
  → reads learnings.jsonl
  → surfaces anti-patterns relevant to this codebase
  → surfaces failed approaches to avoid in task implementation notes

/learn [subcommands — explicit user invocation]
  /learn review  → show all learnings sorted by type
  /learn prune   → mark learnings as stale
  /learn export  → export to shareable format for team onboarding
```

---

## Session Persistence Invocations

```
session-save
  auto-trigger: Stop hook (end of every session)
  auto-trigger: /implement context window checkpoint (every 3 tasks)
  auto-trigger: /implement context window approaching limit
  manual: /session-save
  manual: finish-branch "keep branch" option

session-restore
  auto-trigger: /implement pre-flight (if checkpoint exists for current branch)
  manual: /session-restore
  reads: most recent checkpoint for current branch
  announces: what was restored before continuing
```

---

## Gate Summary (All Conditions in One Place)

```
config.intent
  hackathon → suppress: research market+compliance tracks, execute-parallel,
              qa-browser, monitor full, launch-readiness, STRIDE,
              hardening checklist full, secrets archaeology, arch-decompose,
              deploy-observability, deploy-rollback
  mvp       → enable: most things at reduced depth
  production-saas → enable everything at full depth

config.team-size
  solo      → suppress: coordinate, PR workflow in finish-branch
  small-2-5 → enable: coordinate, execute-parallel default-on
  team-6+   → enable: all coordination features

config.auth
  none      → suppress: auth tasks in /tasks, auth NFRs in req-nfr,
              auth flows in qa-headless, auth section in launch-readiness
  email+    → enable all of the above

config.monetization
  none      → suppress: payment lifecycle in launch-readiness, payment tasks in /tasks
  subscription+ → enable payment lifecycle, webhook testing

config.audience
  eu-consumers → require: GDPR items in launch-readiness, cookie consent in arch-components,
                  compliance research track in research, GDPR NFRs in req-nfr

config.regulated
  hipaa    → escalate security-tier to hardened, require audit trail NFRs
  pci-dss  → escalate security-tier to hardened, require PCI items in launch-readiness

config.security-tier (derived)
  minimal  → audit-security: grep only, no STRIDE
  standard → audit-security: OWASP + STRIDE, confidence 8/10
  hardened → audit-security: full suite + secrets archaeology, confidence 2/10

config.launch-tier (derived)
  minimal  → launch-readiness suppressed
  standard → launch-readiness: auth + legal + feedback sections
  full     → launch-readiness: all sections

tool availability
  Claude Code Task tool missing → execute-subagent → execute-inline
  @playwright/mcp missing       → qa-browser skipped + warning
  gh/glab CLI missing           → ci-verify skipped + warning + branch URL
  web search tool missing       → research fails with clear error (not silent fallback)

artifact existence
  .sdlc/project.yml missing     → hard gate: /configure required before anything
  research brief < 7 days old   → skip research subagent in /implement
  research brief missing        → run research if research-tracks.technical: true
  session checkpoint exists     → session-restore runs first in /implement
  learnings.jsonl exists        → surface relevant entries in /configure, /tasks, /debug
```
