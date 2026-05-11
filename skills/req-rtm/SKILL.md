---
name: req-rtm
description: Builds a Requirements Traceability Matrix (RTM) linking every requirement to its design elements, code artifacts, and tests — in both directions. Use when the user asks for "traceability matrix", "RTM", "requirements traceability", "forward traceability", "backward traceability", "trace requirements to tests", or when a scaling-tier SRS is being finalized. Forward traceability ensures nothing is missed; backward traceability prevents scope creep. Scaling tier only — at MVP tier, this skill produces a minimal link table; at hackathon tier, it skips with a soft warning.
---

# /req-rtm — Requirements Traceability Matrix

Links every requirement to its downstream artifacts. The RTM is the final checkpoint of the requirements phase — if everything traces, the spec is implementable; if things don't trace, gaps surface before they become defects.

## Why both directions matter

| Direction | What it catches |
|:---|:---|
| **Forward** (req → design → code → test) | Missing implementations — requirements that were written but never built or tested |
| **Backward** (test → code → design → req) | Scope creep — code that exists with no requirement justifying it |

A team that only traces forward ships complete features but accumulates dead code. A team that only traces backward catches scope creep but misses requirements. Both directions are necessary.

## Tier-appropriate output

| Tier | Output |
|:---|:---|
| Hackathon | "RTM is overkill at this tier. When you're at MVP stage with real tests, run `/req-rtm`." |
| MVP | Minimal link table: Story ID → Test file/name. Two columns. Informal. |
| Scaling | Full RTM: req ID → design component → code file/module → test ID, in both directions. CI-checkable format. |

## RTM format (scaling tier)

```markdown
| Req ID   | Description (short)     | Design Ref     | Code Module       | Test ID       | Status    |
|:---------|:------------------------|:---------------|:------------------|:--------------|:----------|
| US-001   | Add a habit             | arch-comp §3.2 | habits/service.ts | TC-001, TC-002 | ✅ Traced |
| NFR-PERF-001 | Dashboard p95 < 1.5s | arch-comp §4.1 | api/dashboard.ts  | TC-PERF-001   | ✅ Traced |
| US-007   | Export data as CSV      | —              | —                 | —             | ⚠️ Gap   |
```

Separate backward trace table:

```markdown
| Test ID     | Tests What            | Req ID      | Code Module     |
|:------------|:----------------------|:------------|:----------------|
| TC-001      | Habit creation flow   | US-001      | habits/service  |
| TC-PERF-001 | Dashboard load time   | NFR-PERF-001| api/dashboard   |
```

## Procedure

### Step 1 — Collect
Gather: req IDs from user stories + NFRs, any design refs from `/design` if it has run, any test file names / test IDs the user can provide. Work with whatever is available; mark gaps explicitly rather than papering over them.

### Step 2 — Build forward table
For each requirement: link to design artifact (if `/design` has run), code module (if provided or inferable), test ID. Mark `⚠️ Gap` for anything untraced — gaps are the point of the exercise, not a failure.

### Step 3 — Build backward table
For each test ID or test file mentioned: trace back to the requirement it validates. Flag tests with no linked requirement — these are scope creep candidates.

### Step 4 — Gap report
Summarize: requirements with no test coverage, tests with no requirement, design elements with no requirement. These become action items.

### Step 5 — CI integration note
At scaling tier, recommend wiring the RTM into CI as a lint-style check: any story ID without a corresponding test tag fails the build. Provide a brief example of how to implement this (test file naming convention, or a GitHub Actions step that cross-references test tags against the RTM).

Recommend next step: `/design` (if architecture phase hasn't run yet) or closure of the requirements phase.

## Anti-patterns flagged
- **RTM as a one-time document** — it should be maintained with every sprint, not produced once and abandoned
- **Automated tests with no naming convention** — impossible to trace; recommend a tagging system like `@req:US-001` in test descriptions
- **All ✅ with no audit** — an RTM where everything traces without genuine verification is worse than no RTM (false confidence)

## Audience adaptation
- Novice: explain forward vs backward in plain terms with examples, note why gaps are valuable findings rather than failures
- Senior: produce the tables directly; skip the explainer
