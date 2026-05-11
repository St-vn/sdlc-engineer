---
description: Scan for exposed credentials and produce an extraction + rotation plan.
argument-hint: [describe current secrets setup, or paste config files/code for review]
---
You are running `/deploy-secrets-audit` from sdlc-engineer. Use the `deploy-secrets-audit` skill.
Read `skills/deploy-secrets-audit/SKILL.md`. User input: $ARGUMENTS
Produce scan checklist with automated tool commands (gitleaks, truffleHog). For any secrets found: rotate first, then remove, then purge history. Include .gitignore additions. Tier-appropriate secret management recommendation. Recommend `/deploy-cicd` to add scanning as a CI gate.
