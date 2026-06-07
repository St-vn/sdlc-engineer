---
description: Run live regulatory (GDPR, HIPAA, SOC2) and platform gate (Stripe, App Store Guideline 5.1.1) compliance checks.
argument-hint: [optional rules or target regulations]
---

You are running the `/research-compliance` command from the sdlc-engineer plugin.

Use the `research-compliance` skill to handle this invocation. The skill is at `skills/research-compliance/SKILL.md` within the sdlc-engineer plugin directory.

User's arguments: $ARGUMENTS

Procedure:
1. Read `skills/research-compliance/SKILL.md` for UI guidelines (12-hour AM/PM rules, month formats, ITAR custom crypto rules, UDAAP blacklists, Apple signup optionality).
2. Scan the current project state, Cloud settings, and UI components.
3. Save detected compliance gaps to `docs/sdlc-engineer/`.
