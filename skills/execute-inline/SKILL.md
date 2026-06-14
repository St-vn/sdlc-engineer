---
name: execute-inline
description: Executes a single task from a plan file in the current session. Validates TDD format, writes failing test first, confirms RED, writes minimal implementation, confirms GREEN, checks NFRs, commits. Fallback when Claude Code Task tool is unavailable. Use when /implement routes here, or when user says "execute this task inline".
---

# /execute-inline — single-task inline execution

Executes one task from the plan file in the current session. Used as the fallback when execute-subagent is unavailable (no Claude Code Task tool).

## Input

A single task block from the plan file. The task must have all required TDD fields (see /tasks skill for format).

## Execution steps (mandatory order — no skipping)

1. **Read the task** — verify all required fields are present: AC reference, file set, failing test, RED command, implementation goal, GREEN command
2. **Write the failing test** exactly as specified in the plan (copy verbatim — do not modify)
3. **Run RED command** — confirm the test fails with the expected error
   - If test passes: STOP — report test integrity failure — do not continue
   - If test fails with unexpected error: report the actual error and ask how to proceed
4. **Write minimal implementation** — implement only enough to make the test pass
5. **Run GREEN command** — confirm the test passes
   - If still failing: do NOT attempt a second implementation — invoke /debug first
6. **Run full suite** — confirm no regressions introduced
7. **Check NFRs in scope** — verify the NFRs listed in the task are not violated
8. **Commit**: `feat: Task N — [name] (satisfies [AC reference])`

## File set discipline

Never modify files outside the task's declared file set without flagging it.
If a file not in the declared set needs to change: stop, report it, get confirmation, update the plan file, then proceed.

## Failure modes

- Test fails with unexpected error → report actual error text, ask whether to debug or revise test
- Implementation causes regression → do not commit, invoke /debug with the regression details
- NFR violated → do not commit, flag the violation, ask whether to fix or document as known issue
