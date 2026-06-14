---
name: session-save
description: Saves session state to a markdown checkpoint file. Auto-triggered by Stop hook at session end, by /implement every 3 tasks, and when context window approaches limit. Manual trigger: /session-save. Writes to docs/sdlc-engineer/sessions/<branch>-<timestamp>.md.
---

# /session-save — session checkpoint

Writes a session checkpoint that /session-restore can load in a fresh session.

## Triggers

- **Auto (Stop hook):** fires at session end — already wired in .claude/settings.json
- **Auto (/implement):** fires every 3 tasks, and when context window > 80%
- **Manual:** user invokes /session-save explicitly ("save session", "checkpoint")

## What to capture

```markdown
# Session checkpoint
Branch: [git rev-parse --abbrev-ref HEAD]
Timestamp: [ISO timestamp]
Plan file: [path to active plan file]

## Completed tasks
[list of task IDs with commit hashes]

## Remaining tasks
[list of task IDs not yet started or in progress]

## Decisions made this session
[any architectural or implementation decisions not in plan]

## Failed approaches (do not retry)
[brief notes on approaches that didn't work]

## Git state
Last commit: [git log -1 --oneline]
Branch status: [git status --short]

## Context at save
[current task if interrupted mid-task, what step it was on]
```

## Write location

`docs/sdlc-engineer/sessions/[branch]-[YYYY-MM-DD-HHMMSS].md`

Always use branch name + timestamp — never overwrite a checkpoint.
