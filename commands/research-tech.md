---
description: Run live technical dependency scans, CVE verification, and license policy audits.
argument-hint: [optional packages or requirements file]
---

You are running the `/research-tech` command from the sdlc-engineer plugin.

Use the `research-tech` skill to handle this invocation. The skill is at `skills/research-tech/SKILL.md` within the sdlc-engineer plugin directory.

User's arguments: $ARGUMENTS

Procedure:
1. Read `skills/research-tech/SKILL.md` for local dependency checking commands (pip-audit, npm audit, pip-licenses, license-checker).
2. Scan the current lockfile or requirements list. Match findings against Semgrep reachability logic.
3. Output a structured JSON vulnerability list to `docs/sdlc-engineer/`.
