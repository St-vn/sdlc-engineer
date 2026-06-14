---
name: learn
description: Cross-session learning management. Reads and writes docs/sdlc-engineer/learnings.jsonl. Subcommands: /learn review, /learn prune, /learn export. Other skills (debug, retro, configure, tasks) write to learnings.jsonl automatically — this skill manages the entries. Use when user says "/learn review", "show learnings", "prune old learnings", "export learnings".
---

# /learn — cross-session learning management

Manages `docs/sdlc-engineer/learnings.jsonl` — the project's persistent knowledge base of patterns, failures, and calibrations.

## JSONL schema (authoritative)

Every entry in `learnings.jsonl` is a single JSON line:

```json
{
  "type": "anti-pattern|failed-approach|root-cause|config-correction|nfr-correction|research-gap",
  "date": "YYYY-MM-DD",
  "context": "brief description of where/when this occurred",
  "body": "the learning itself — what was observed",
  "relevant-skills": ["debug", "tasks"],
  "stale": false
}
```

### Type definitions

| Type | Written by | Read by | Description |
|---|---|---|---|
| `anti-pattern` | any skill | /tasks, /debug | A pattern observed that caused problems |
| `failed-approach` | /debug | /execute-subagent, /tasks | An approach that was tried and failed — do not retry |
| `root-cause` | /debug | /debug | A root cause diagnosis with its fix |
| `config-correction` | any skill | /configure | A config field that was wrong and was corrected mid-project |
| `nfr-correction` | /retro, /qa-headless | /req-nfr, /tasks | An NFR threshold that was inaccurate |
| `research-gap` | /retro | /research | A search that would have caught something that was missed |

## Subcommands

### /learn review

Display all learnings sorted by type, then date (newest first):

```
Anti-patterns (N):
  [YYYY-MM-DD] [context]: [body]

Failed approaches (N):
  ...

Config corrections (N):
  ...
```

### /learn prune

Mark specific learnings as stale (they no longer apply):
- Show each entry
- User confirms which to mark stale
- Update `"stale": true` — never delete (audit trail)

### /learn export

Export learnings to shareable format for team onboarding:
```markdown
# Learnings — [project name]
Exported: YYYY-MM-DD

## Anti-patterns
...

## Config corrections
...
```

## Per-skill reading behavior

Skills read ONLY the types relevant to them:

- `/tasks`: reads `anti-pattern`, `failed-approach` relevant to current stack
- `/debug`: reads `failed-approach`, `root-cause` for current symptom
- `/configure`: reads `config-correction` — surfaces before asking questions
- `/req-nfr`: reads `nfr-correction`
- `/research`: reads `research-gap`

Never dump the entire learnings file into context — filter by type and relevance first.

## Writing from any skill

Any skill encountering a noteworthy pattern writes to learnings.jsonl:

```bash
# Append a new learning
echo '{"type":"anti-pattern","date":"2026-05-16","context":"...","body":"...","relevant-skills":["tasks"],"stale":false}' >> docs/sdlc-engineer/learnings.jsonl
```

## Anti-rationalization table
| Common Excuse | Why It's Wrong | What to Do Instead |
|---|---|---|
| "I'll remember this for next time" | You won't. Human memory is unreliable, especially under pressure. | Write it to learnings.jsonl. 30 seconds. Permanent record. |
| "This failure is a one-off, it won't happen again" | One-off failures are the most dangerous — they hide systemic issues. | Log it. If it happens twice, it's a pattern. |
| "Learnings are for juniors" | Senior engineers learn from failures faster because they document and share them. | Lead by example. Write the learning. Your team will follow. |
