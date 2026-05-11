---
description: Deployment orchestrator — CI/CD, observability, secrets, release gates, rollback.
argument-hint: [project context, stack, deployment target]
---

You are running `/implement` from sdlc-engineer. Use the `implement` skill.

Read `skills/implement/SKILL.md`. Read `skills/sdlc-foundation/maturity-tier-detection.md`.

User input: $ARGUMENTS

Sequence: /deploy-tier → /deploy-secrets-audit → /deploy-cicd → /deploy-observability → /deploy-release-check → /deploy-rollback. Calibrate all gating to detected tier. End by confirming the full SDLC loop is closed.
