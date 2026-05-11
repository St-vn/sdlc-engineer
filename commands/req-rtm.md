---
description: Build a Requirements Traceability Matrix linking requirements to design, code, and tests.
argument-hint: [requirements list and any known test/design artifacts]
---

You are running `/req-rtm` from sdlc-engineer. Use the `req-rtm` skill.

Read `skills/req-rtm/SKILL.md`. Read `skills/sdlc-foundation/decision-frameworks.md` (RTM section).

User input: $ARGUMENTS

Produce both forward (req → test) and backward (test → req) traceability. Scaling tier only with full rigor; MVP gets a minimal link table; soft-warn and skip at hackathon. Flag any requirements without test coverage. Recommend wiring into CI.
