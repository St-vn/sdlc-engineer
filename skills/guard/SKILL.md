---
name: guard
description: Safety guardrails configuration. The actual interception runs via PreToolUse hook in .claude/settings.json — this skill documents the intercept list and manages freeze mode. Use when user says "enable freeze mode", "freeze this path", "disable guard", or to understand what the guard intercepts.
---

# /guard — safety guardrails

Guard operates at the Claude Code harness level via PreToolUse hook — it does not rely on model cooperation. This SKILL.md documents behavior and manages freeze mode.

## What the PreToolUse hook intercepts

The hook fires before every Bash tool call and blocks these patterns:

| Pattern | Risk |
|---|---|
| `rm -rf /` or `rm -rf` outside current working directory | Catastrophic file deletion |
| `git reset --hard` | Irreversible commit loss |
| `git push --force` | Overwrites remote history |
| `DROP TABLE` (case-insensitive) | Irreversible data loss |
| `DELETE FROM <table>;` without WHERE | Full table wipe |
| Writes to `.env`, `*.key`, `secrets.*` | Credential exposure |
| Writes to files outside declared task file set | Scope violation |

On intercept: the hook exits with code 1 and prints:
```
GUARD: Dangerous command intercepted: [command preview]
Confirm explicitly before proceeding.
```

## Freeze mode

`/guard freeze <path>` — blocks all writes outside `<path>` until unfrozen.

When freeze mode is active, any Bash write command targeting a path outside the frozen path is intercepted with:
```
GUARD: Freeze mode active. Writes restricted to [frozen path].
```

To activate freeze mode, the user stores a `.sdlc/freeze` file with the frozen path. The PreToolUse hook checks for this file.

`/guard unfreeze` — removes `.sdlc/freeze`.

## Viewing guard status

```
/guard status
```

Outputs:
- Hook file location and whether it's installed
- Freeze mode: active/inactive + frozen path
- Recent intercepts (from session log if available)

## Implementation note

The guard's blocking logic lives in `.claude/settings.json` PreToolUse hook. This SKILL.md does NOT reimplement the logic — it only documents it and manages freeze mode config. Modifying this file alone does NOT change guard behavior. To change what is intercepted, edit `.claude/settings.json`.
