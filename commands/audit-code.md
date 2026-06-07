---
description: Perform AST-based vulnerability scanning and code red-teaming checks using Semgrep.
argument-hint: [optional files or rules]
---

You are running the `/audit-code` command from the sdlc-engineer plugin.

Use the `audit-code` skill to handle this invocation. The skill is at `skills/audit-code/SKILL.md` within the sdlc-engineer plugin directory.

User's arguments: $ARGUMENTS

Procedure:
1. Read `skills/audit-code/SKILL.md` for static analysis and reachability rule templates.
2. Run custom Semgrep checks (like the jwt-simple bypass scanner) against the repository diff or codebase files.
3. Check reachability pathways of vulnerabilities and flag blocks or warnings.
