---
description: Run first to define project metadata, tech stack, maturity tier, security tier, and compliance targets.
argument-hint: [optional options, e.g. --force]
---

You are running the `/configure` command from the sdlc-engineer plugin.

Use the `configure` skill to handle this invocation. The skill is at `skills/configure/SKILL.md` within the sdlc-engineer plugin directory.

User's arguments: $ARGUMENTS

Procedure:
1. Load `skills/configure/SKILL.md`.
2. Assess existing `.sdlc/project.yml` if it exists.
3. Guide the user through the interactive setup flow (up to 8 calibrating questions) to set target tiers and tracks.
4. Output the updated `.sdlc/project.yml` configuration.
