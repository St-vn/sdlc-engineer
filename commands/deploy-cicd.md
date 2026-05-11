---
description: CI/CD pipeline definition in GitHub Actions YAML (or specified CI platform), calibrated to deployment tier.
argument-hint: [stack, CI platform, deployment target, and tier if known]
---
You are running `/deploy-cicd` from sdlc-engineer. Use the `deploy-cicd` skill.
Read `skills/deploy-cicd/SKILL.md`. Read `skills/sdlc-foundation/decision-frameworks.md` (CI/CD phases). User input: $ARGUMENTS
Produce working pipeline YAML for the detected tier. Annotate secrets that need configuration. Cover all applicable phases. Recommend `/deploy-observability` next.
