---
name: tasks
description: Produces a TDD-formatted work breakdown structure from spec and design artifacts. Each task specifies the failing test to write first, the RED confirmation command, the implementation goal, and the GREEN confirmation command. Reads cross-session learnings to surface anti-patterns. Use when the user asks "break this into tasks", "what do I implement first?", "create the task plan", or as part of /implement orchestration.
---

# /tasks — TDD work breakdown structure

Converts requirements and architecture into implementable engineering tasks using the TDD task format. The output is a dependency-ordered plan file where every task starts with a failing test.

## Pre-flight

1. Project config in session context? If not, run /configure first.
2. Spec artifacts exist (`docs/sdlc-engineer/spec/`)? If not, prompt to run /spec first.
3. Design artifacts exist (`docs/sdlc-engineer/design/`)? If not, prompt to run /design first.
4. Read `docs/sdlc-engineer/learnings.jsonl` if it exists:
   - Surface entries of type `anti-pattern` relevant to this stack/domain
   - Surface entries of type `failed-approach` to add to task implementation notes as "Avoid: ..."

## Config gates applied

```
auth: none → suppress auth tasks
monetization: none → suppress payment tasks
team-size: solo → sequential task list (no parallel wave assignment)
intent: hackathon → flat list, minimal metadata
intent: production-saas → full dependency graph, parallelization analysis
```

## Task format (mandatory — no exceptions)

Every task MUST include all of the following fields:

```markdown
### Task N: [Name]

**AC reference:** [US-001 AC-003] — which acceptance criterion this satisfies
**NFRs in scope:** [PERF-001, SEC-002] — which NFRs this task must not violate
**Complexity:** XS | S | M | L | XL
**Depends on:** Task N-1, Task N-3 (or "none")
**File set:** exact list of files this task touches (parallelization boundary)

**Failing test to write first:**
```[language]
[complete, runnable test code]
```

**RED command:** `[exact command to run the test]`
**Expected RED output:** [what failure message proves the test is correctly wired]

**Implementation goal:** [one sentence — what the implementation does, not how]

**Minimal implementation:**
```[language]
[complete implementation code]
```

**GREEN command:** `[exact command to confirm tests pass]`
**Verification step:** `[command to run full suite and confirm no regressions]`

**Commit:** `feat: Task N — [name] (satisfies [AC reference])`
```

## Dependency graph

After all tasks are defined:

1. Build the dependency graph (which tasks block which)
2. Topological sort → wave assignments
3. Mark parallelizable tasks (file sets must be disjoint)
4. Identify critical path

```
Wave 0: Task 1, Task 2 (no dependencies)
Wave 1: Task 3 (depends on Task 1), Task 4 (depends on Task 2)
Wave 2: Task 5 (depends on Task 3 and Task 4)
Critical path: Task 1 → Task 3 → Task 5
```

Parallelization note: Tasks are parallelizable iff their file sets are disjoint AND no task depends on another in the same wave.

## Output

Save plan to: `docs/sdlc-engineer/plans/YYYY-MM-DD-[feature].md`

Plan file header:
```markdown
# [Feature] Task Plan
Generated: YYYY-MM-DD
AC coverage: [US-001 through US-004]
NFRs in scope: [list]
Estimated waves: N
Parallelizable tasks: N of M

## Anti-patterns to watch (from learnings.jsonl)
[entries surfaced from learnings, or "none recorded"]

## Tasks
[task list]

## Dependency graph
[wave assignments + critical path]
```

## The RED confirmation rule

If the RED step is skipped, or if the test passes before implementation is written: **STOP**. Flag it as a test integrity failure. Do not continue. Restart the task with a properly failing test.

This is enforced. Persuasion scenarios ("I already know what to implement", "the test is obviously right") do not override this rule.

## Anti-patterns flagged

- Tasks with no AC reference → add it or flag as scope creep
- "Test the above" without actual test code → not a valid task step
- File sets that overlap between tasks assigned to the same wave → move one to next wave
- Implementation written before RED confirmed → flag as test integrity failure
```

## Anti-rationalization table
| Common Excuse | Why It's Wrong | What to Do Instead |
|---|---|---|
| "I'll figure out the steps as I go" | Planning as you go misses dependencies, duplicates work, and forgets edge cases. | Break into tasks first. Each task has one clear RED test. |
| "My tasks are small enough" | "Small enough" is subjective. If a task touches 3+ files, it's too large. | Split until each task touches 1-2 files and has a single behavioral change. |
| "Task breakdown is overhead" | A 10-minute task plan is 1% overhead for a 2-day feature. It eliminates 50% of integration bugs. | Run /tasks. Read the output. Adjust if needed. Don't skip. |
