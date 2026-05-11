---
description: Assess deployment maturity tier (hackathon/MVP/scaling) and set gating calibration for all deploy commands.
argument-hint: [project description, team size, current users, or deployment context]
---
You are running `/deploy-tier` from sdlc-engineer. Use the `deploy-tier` skill.
Read `skills/deploy-tier/SKILL.md`. Read `skills/sdlc-foundation/maturity-tier-detection.md`. User input: $ARGUMENTS
Detect tier from signals. State what the tier requires and explicitly what it does NOT require. Flag mismatches (over- or under-engineered for tier). Recommend `/deploy-cicd` next.
