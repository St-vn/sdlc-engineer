---
description: Orchestrate the shipping phase after implementation tasks are complete.
argument-hint: [optional parameters]
---

You are running the `/ship` command from the sdlc-engineer plugin.

Use the `ship` skill to handle this invocation. The skill is at `skills/ship/SKILL.md` within the sdlc-engineer plugin directory.

User's arguments: $ARGUMENTS

Procedure:
1. Load `skills/ship/SKILL.md`.
2. Verify pre-flight checks (all tasks complete, tests green, CI green, branch verification).
3. Coordinate the shipping sequence (security audit, QA, monitoring, benchmarking, deployment, launch readiness, doc sync) according to maturity, security, and intent tiers.
