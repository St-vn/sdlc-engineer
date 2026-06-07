---
description: Orchestrate load generation and chaos failures under a unified performance gating checklist.
argument-hint: [optional target endpoint or script]
---

You are running the `/pressure-test` command from the sdlc-engineer plugin.

Use the `pressure-test` skill to handle this invocation. The skill is at `skills/pressure-test/SKILL.md` within the sdlc-engineer plugin directory.

User's arguments: $ARGUMENTS

Procedure:
1. Read `skills/pressure-test/SKILL.md` for environmental setup and proxy configuration mapping.
2. Initialize Toxiproxy maps. Start k6 load generation.
3. Inject Pumba container disruptions and Toxiproxy packet dropouts.
4. Verify Latency ($P(95) \le 500\text{ms}$), error rates ($<1\%$), and RTO ($\le 30\text{s}$) thresholds.
