---
name: implement
description: Main SDLC execution orchestrator. Runs the full implementation loop: pre-flight checks, optional research subagent, task planning, and per-task TDD execution (write test → RED → implement → GREEN → review-spec → commit). Chains execute-inline / execute-subagent / execute-parallel based on task count and tool availability. Use when the user says "implement this", "build it", "let's start coding", "execute the plan", or after /spec + /design artifacts exist.
---

# /implement — SDLC execution orchestrator

Runs the complete implementation sequence from pre-flight through task execution to CI verification.

## Pre-flight checks (in order)

1. `project.yml` in session context? → if not, invoke /configure first
2. Spec artifacts exist (`docs/sdlc-engineer/spec/`)? → if not, prompt to run /spec first
3. Design artifacts exist (`docs/sdlc-engineer/design/`)? → if not, prompt to run /design first
4. Research brief exists and < 7 days old?
   → if not AND `research-tracks.technical: true` → invoke research subagent
5. Session checkpoint exists for this branch?
   → if yes, invoke session-restore subagent first

## Subagent sequence

### Subagent 0 — research (conditional)
Gate: `research-tracks.technical: true` AND no recent research brief
Produces: technical brief (library health, CVEs, architecture patterns)
Feeds: req-nfr updates, task implementation notes

### Subagent 1 — tasks
Produces: plan file with per-task TDD structure
Gate: always runs (unless plan file already exists and is current)
Config gates: see /tasks skill for full gate list
Reads: learnings.jsonl → surfaces anti-patterns and failed approaches

### Task execution loop

For each task wave (grouped by dependency graph):

**Parallelization decision:**
```
IF task count in wave > 1
AND file sets are disjoint
AND (task count total > 8 OR team-size: small-2-5+)
AND Claude Code Task tool available
→ execute-parallel (all wave tasks simultaneously, each in own worktree)

ELIF Claude Code Task tool available
→ execute-subagent (fresh context per task, sequential)

ELSE
→ execute-inline (current session, sequential, fallback)
```

**Per task (in execute-subagent or execute-parallel):**
1. Write failing test exactly as specified in plan
2. Run RED confirmation
   - If test already passes: STOP — flag test integrity failure — do not continue
3. Write minimal implementation
4. Run GREEN confirmation
   - If still failing: invoke debug subagent immediately
   - Do not attempt second implementation without diagnosis
5. Run full suite — confirm no regressions
6. Check NFRs in scope for this task
7. Commit: `feat: Task N — name (satisfies AC ref)`

**After each task:**
→ review-spec subagent (input: task AC + git diff ONLY — no codebase context)
  - PASS → continue to code quality review
  - FAIL → return to execute-subagent with failure reason
→ quality reviewer subagent (input: diff + ADRs + coding standards ONLY)
  - PASS/WARN → continue
  - BLOCK → return to execute-subagent

**After each wave:**
→ run integration tests before next wave starts

### Context management

Every 3 tasks: checkpoint report (tasks done, tests added, NFR violations, context window %)
If context window approaching limit: trigger session-save before continuing

### After all tasks complete

→ ci-verify subagent
  Gate: branch pushed AND CI config exists AND gh/glab CLI available
  Polls for CI completion (timeout: 10 min)

→ finish-branch subagent
  Pre-flight: all tasks complete + suite green + CI green + spec compliance PASS
  Presents 4 options: merge / PR / keep / discard
