---
description: Run live market research, competitor landscape audits, and Reddit/Product Hunt scans.
argument-hint: [optional domain or product name]
---

You are running the `/research-market` command from the sdlc-engineer plugin.

Use the `research-market` skill to handle this invocation. The skill is at `skills/research-market/SKILL.md` within the sdlc-engineer plugin directory.

User's arguments: $ARGUMENTS

Procedure:
1. Read `skills/research-market/SKILL.md` for the search protocols and GraphQL queries.
2. Execute the Reddit listening loop and Product Hunt V2 GraphQL queries based on the provided product/domain.
3. Save competitor profiles and TAM/SAM/SOM SWOT outputs to the session context and write them under `docs/sdlc-engineer/`.
