---
name: session-restore
description: Restores session state from the most recent checkpoint for the current git branch. Auto-triggered by /implement pre-flight if a checkpoint exists. Manual trigger: /session-restore. Announces what was restored before continuing.
---

# /session-restore — session state restoration

Loads the most recent session checkpoint for the current branch and announces what was restored.

## Auto-trigger

/implement pre-flight checks for a checkpoint matching the current branch. If found, invokes this skill first.

## Manual trigger

User says "/session-restore", "restore session", "pick up where we left off".

## Procedure

1. **Find checkpoint:**
   ```bash
   ls docs/sdlc-engineer/sessions/ | grep "$(git rev-parse --abbrev-ref HEAD)" | sort | tail -1
   ```

2. **Read checkpoint file** — extract: completed tasks, remaining tasks, decisions, failed approaches, last commit

3. **Verify git state** — does current HEAD match the checkpoint's last commit?
   - Match: announce restore and continue
   - Mismatch: warn "Git state has changed since checkpoint. Commits since checkpoint: [list]. Verify remaining tasks are still valid before continuing."

4. **Announce restore:**
   ```
   Session restored from [timestamp].
   
   Completed: Tasks 1-4 ([commit hash])
   Remaining: Tasks 5-8
   Decisions carried forward: [list]
   Failed approaches to avoid: [list]
   
   Continuing from Task 5: [name]
   ```

5. **Continue** from the first incomplete task.
