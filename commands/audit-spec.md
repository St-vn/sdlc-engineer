---
description: Perform Direct-Indirect Reasoning logical validation on specification and design files.
argument-hint: [optional design file path]
---

You are running the `/audit-spec` command from the sdlc-engineer plugin.

Use the `audit-spec` skill to handle this invocation. The skill is at `skills/audit-spec/SKILL.md` within the sdlc-engineer plugin directory.

User's arguments: $ARGUMENTS

Procedure:
1. Read `skills/audit-spec/SKILL.md` for logical validation rubrics and proof by contradiction guidelines.
2. Scan spec/design documents for unhandled states, conflicts, and regulatory violations.
3. Save findings to a logical contradiction JSON scorecard.
