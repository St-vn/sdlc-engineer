---
name: retro
description: Project retrospective. Reads all methodology artifacts (plan files, debug logs, learnings.jsonl, RTM, CI results, test coverage delta, research brief) and produces a structured retrospective. Writes calibration entries back to learnings.jsonl. Use when user says "/retro", "retrospective", "what did we learn", "post-mortem".
---

# /retro — project retrospective

Closes the methodology improvement loop. Reads artifacts, analyzes what worked and what didn't, writes calibration entries so the next project starts smarter.

## Input artifacts (read all that exist)

```bash
ls docs/sdlc-engineer/plans/*.md         # plan files (estimates vs actual)
ls docs/sdlc-engineer/sessions/*.md      # debug and session logs
cat docs/sdlc-engineer/learnings.jsonl   # existing learnings
ls docs/sdlc-engineer/retros/            # prior retros
# RTM: docs/sdlc-engineer/spec/rtm.md
# Research brief: docs/sdlc-engineer/research-brief-*.md
# CI results: via gh run list or gitlab CI history
# Test coverage: from most recent test run output
```

## Analysis checklist

### Plan accuracy
- Estimated task count vs actual task count
- Estimated complexity (XS/S/M/L/XL) vs actual time per task
- Tasks that were added mid-flight (scope creep? missed AC?)
- Tasks that were split or merged (incorrect granularity?)

### AC quality
- ACs that were ambiguous or required clarification during implementation
- ACs that were missing a scenario that only appeared during QA
- ACs that were too strict (caused over-engineering) or too loose (allowed under-engineering)

### NFR accuracy
- NFR thresholds that were too tight (prevented shipping) or too loose (shipped with performance issues)
- NFRs that were missing entirely (discovered during qa-headless or benchmark)

### Debug patterns
- Most common failure type (null checks? async ordering? wrong type?)
- Average time from failure to fix
- Failed approaches (that went into learnings.jsonl) — was the approach rational?

### Anti-patterns caught
- How many anti-patterns did guard/review-spec/review catch that would have shipped?
- Were any anti-patterns missed that appeared in production?

### CI failures
- What percentage of CI failures were caught by local test runs first?
- Infrastructure failures vs test failures vs environment failures

### Research accuracy
- Did the research brief correctly identify library risks?
- Were there CVEs or breaking changes not caught by research?
- Did market research inform any spec decisions?

### Config accuracy
- Were config-corrections written to learnings.jsonl?
- Would those corrections change the config for the next project of this type?

## Output

Write to `docs/sdlc-engineer/retros/YYYY-MM-DD-[feature].md`:

```markdown
# Retrospective — [feature name]
Date: YYYY-MM-DD
Plan file: [path]

## Summary
[2-3 sentences: what went well, what needs improvement]

## Plan accuracy
[findings]

## AC quality
[findings]

## NFR accuracy
[findings]

## Patterns
[debug patterns, anti-patterns caught/missed]

## What to calibrate next time
[specific changes to make]
```

## Write calibration entries to learnings.jsonl

After analysis, append entries:

```json
{"type":"nfr-correction","date":"YYYY-MM-DD","context":"[feature]","body":"PERF-001 threshold was 200ms but actual p95 was 45ms — next project: set to 100ms for this stack","relevant-skills":["req-nfr"],"stale":false}
{"type":"research-gap","date":"YYYY-MM-DD","context":"[feature]","body":"Library X had a breaking change in v3 that research brief missed — add 'breaking changes last 6 months' to research checklist","relevant-skills":["research"],"stale":false}
{"type":"config-correction","date":"YYYY-MM-DD","context":"[feature]","body":"security-tier was standard but PII was found in data model — escalate to hardened when user table has profile fields","relevant-skills":["configure"],"stale":false}
```

## Create retros directory

```bash
mkdir -p docs/sdlc-engineer/retros
```

## Anti-rationalization table
| Common Excuse | Why It's Wrong | What to Do Instead |
|---|---|---|
| "We don't have time for a retro" | Not retroing guarantees repeating the same mistakes. The time cost is exponential. | Run a 15-min retro. Focus on 1 thing to improve. |
| "Nothing went wrong, no need to retro" | If nothing went wrong, you missed something. Every project has learning opportunities. | Run a "what went well" retro. Document positive patterns too. |
| "Retros are just blame sessions" | Bad retros are blame sessions. Good retros are system improvement. | Focus on process, not people. "What in our system allowed this?" |
