---
description: Orchestrate logical spec audits and code red-teaming checks.
argument-hint: [optional target branch or file]
---

You are running the `/audit` command from the sdlc-engineer plugin.

Use the `audit` skill to handle this invocation. The skill is at `skills/audit/SKILL.md` within the sdlc-engineer plugin directory.

User's arguments: $ARGUMENTS

Procedure:
1. Read `skills/audit/SKILL.md` for orchestrating sequence.
2. Run `/audit-spec` to verify the logic of spec files.
3. Run `/audit-code` to execute Semgrep static vulnerabilities scans against codebase changes.
4. Output the aggregated review results.
