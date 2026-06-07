---
description: Run headless k6 load generation and parsing scripts.
argument-hint: [optional script path or VUs count]
---

You are running the `/pressure-test-load` command from the sdlc-engineer plugin.

Use the `pressure-test-load` skill to handle this invocation. The skill is at `skills/pressure-test-load/SKILL.md` within the sdlc-engineer plugin directory.

User's arguments: $ARGUMENTS

Procedure:
1. Read `skills/pressure-test-load/SKILL.md` for k6 command patterns and JSON streaming JQ filters.
2. Execute the load script. Check request latencies and transaction failure rates.
3. Terminate with exit code 99 if thresholds are violated.
