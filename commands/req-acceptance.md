---
description: Add Gherkin Given-When-Then acceptance criteria to user stories.
argument-hint: [user stories to add ACs to, or existing ACs to refine]
---

You are running `/req-acceptance` from sdlc-engineer. Use the `req-acceptance` skill.

Read `skills/req-acceptance/SKILL.md`. Read `skills/sdlc-foundation/decision-frameworks.md` (Gherkin section).

User input: $ARGUMENTS

Auto-detect producer vs refiner mode. Write declarative, not imperative, scenarios. At least happy path + one failure path per story. Flag imperative ACs, overlapping scenarios, implementation details in ACs. End with: recommend `/req-nfr`.
