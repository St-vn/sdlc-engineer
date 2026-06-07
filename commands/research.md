---
description: Run live pre-planning research across market validation, technical stack health, and compliance tracks.
argument-hint: [optional tracks, e.g. market, compliance]
---

You are running the `/research` command from the sdlc-engineer plugin.

Use the `research` skill to handle this invocation. The skill is at `skills/research/SKILL.md` within the sdlc-engineer plugin directory.

User's arguments: $ARGUMENTS

Procedure:
1. Load `skills/research/SKILL.md`.
2. Inspect the project config from the session context (or `.sdlc/project.yml`).
3. Determine active research tracks and dispatch sub-skills (market, tech, compliance) in parallel via subagents if available.
4. Aggregate raw findings and compile a token-optimized `research-brief` in JSON/Markdown format.
