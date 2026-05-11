---
description: Produce or refine INVEST-compliant user stories from raw input or existing partial stories.
argument-hint: [raw notes, brief, feature list, or existing stories to refine]
---

You are running the `/req-user-stories` command from the sdlc-engineer plugin.

Use the `req-user-stories` skill to handle this invocation. The skill is at `skills/req-user-stories/SKILL.md`.

User's input: $ARGUMENTS

Procedure:
1. Read `skills/req-user-stories/SKILL.md` for the producer/refiner mode contract.
2. Detect mode:
   - Existing stories in input → refiner mode (audit each against INVEST, refine failures)
   - Raw input only (idea, brief, feature list) → producer mode (draft fresh stories)
   - Mix → both
3. Read `shared/decision-frameworks.md` for the INVEST criteria.
4. Read `shared/maturity-tier-detection.md` for tier-appropriate rigor.
5. Read `shared/educational-layer.md` for verbosity dial.

Produce stories in the role-capability-outcome format with numbered IDs (US-NNN). For refiner mode, note specifically what changed and which INVEST letters failed. Flag adjective-only items as NFRs (route to `/req-nfr`). Flag implementation-in-the-story as architecture decisions (route to `/arch-adr` later). Flag compound stories by splitting them.

End with a brief summary (story count by MoSCoW tag if applicable, anti-patterns flagged) and recommend next step (typically `/req-acceptance`).
