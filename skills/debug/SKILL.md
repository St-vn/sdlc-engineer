---
name: debug
description: 4-phase root cause debugging process. Triggers on "this test is failing", "getting an error", "it's broken", "why isn't X working", "it crashed", "exception", "undefined", or when /execute-inline or /execute-subagent gets a failing GREEN step. Writes findings to learnings.jsonl after completion.
---

# /debug — 4-phase root cause process

Systematic debugging using a 4-phase root cause methodology. No guessing. No second implementation attempts without diagnosis.

## Required tools

```bash
git --version   # git bisect for regression debugging (required)
```

## Trigger phrases (auto-invoke from chat)

- "this test is failing"
- "getting an error"
- "it's broken" / "it crashed"
- "why isn't X working"
- "exception" / "undefined" / "null pointer"
- Invoked by execute-inline or execute-subagent when GREEN step fails

## Phase 0 — Establish Ground Truth

Confirm the failure is consistent before doing anything else. Obtain exact reproduction steps, input parameters, and environment state.

```bash
# Run the failing command exactly as reported
[failing command]
```

- If failure is NOT reproducible: report this — intermittent failures are a different problem class (race condition, network dependency, environment-specific).
- If reproducible: proceed to Phase 1.

> [!NOTE]
> For expanded guidance and standard sub-workflows on test failures, build failures, and runtime crashes, consult [debugging-methodologies.md](file:///c:/Users/megas/Documents/GitHub/sdlc-engineer/docs/sdlc-engineer/debugging-methodologies.md) for addyosmani's 6-Step Triage.
> For integration with Chrome DevTools MCP and browser debugging workflows, consult [browser-testing-devtools.md](file:///c:/Users/megas/Documents/GitHub/sdlc-engineer/docs/sdlc-engineer/browser-testing-devtools.md).

## Phase 1 — Isolate

Binary search to find the minimal reproduction case.

Techniques (apply in order):
1. **Which commit introduced it?** `git bisect` if failure is recent regression.
2. **Which input triggers it?** Simplify the input until the failure disappears, then add back.
3. **Which layer?** Unit test the components in isolation — does the failure exist at the function level or only at integration?
4. **Which environment?** Does it fail locally but not in CI, or vice versa?

Output: minimal reproduction case — the smallest input/state that reliably triggers the failure.

## Phase 2 — Hypothesize

Generate root cause candidates, ranked by likelihood. Do not investigate all of them — start with the most likely.

For each candidate:
- What would explain the observed failure?
- What evidence would confirm or deny it?

Common root cause categories (check in this order):
1. Wrong assumption about input shape or type
2. Missing null/undefined check at a boundary
3. Off-by-one or incorrect range
4. Race condition / async ordering issue
5. Environment variable missing or wrong value
6. Import/dependency version mismatch
7. Stale cache or test state leaked between runs

## Phase 3 — Verify

Write the fix. Then:

1. Run the originally failing test — confirm GREEN.
2. Run the full suite — confirm no regressions.
3. If the fix reveals a gap in test coverage: add a test that would have caught this failure earlier.

## Anti-rationalization table

| Common Excuse | Why It's Wrong | What to Do Instead |
|---|---|---|
| "I know what the bug is, I'll just change code and try again." | Guessing leads to random code changes, hidden side effects, and wasted time. | Establish ground truth by reproducing the error first, then isolate. |
| "The test is flaky, let's just run it again until it passes." | Flakiness is a symptom of race conditions or state pollution that will hit production. | Isolate the test run and check for state leaks or timing dependencies. |
| "I'll just add a null check here to fix the crash." | Fixing symptoms leaves the invalid state path open, which will crash downstream. | Ask "why?" to trace where the null/undefined value originated from. |

## After completion — write to learnings.jsonl

Append to `docs/sdlc-engineer/learnings.jsonl`:

```json
{"type": "root-cause", "date": "YYYY-MM-DD", "symptom": "...", "root-cause": "...", "fix": "...", "relevant-skills": ["execute-inline"]}
```

And if a failed approach was tried:
```json
{"type": "failed-approach", "date": "YYYY-MM-DD", "approach": "...", "why-failed": "...", "relevant-skills": ["debug"]}
```

## Anti-patterns

- Writing a second implementation without diagnosing the first failure → blocked
- "Fixing" the test to make it pass without understanding the failure → blocked
- Committing a fix without running the full suite → blocked
