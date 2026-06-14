---
name: ship
description: Orchestrates the shipping phase: security audit, QA (headless + browser), monitoring setup, benchmarking, deployment, launch readiness verification, and doc sync. Run after /implement completes all tasks. Chains audit-security → qa-headless → qa-browser → monitor → benchmark → deploy cluster → launch-readiness → sync-docs.
---

# /ship — shipping orchestrator

Runs the full shipping sequence after all implementation tasks are complete and CI is green.

## Pre-flight

- All /implement tasks complete
- Full test suite green
- CI green (if CI exists)
- finish-branch PASS

## Sequence

```
subagent 1  → audit-security   (always, depth = security-tier)
subagent 2  → qa-headless      (always, depth = intent)
subagent 3  → qa-browser       (gate: intent != hackathon AND @playwright/mcp installed)
subagent 4  → monitor          (gate: intent: mvp or production-saas)
subagent 5  → benchmark        (gate: intent: production-saas)
subagents 6-11 → deploy cluster (gate: deployment-target != local-only)
  → deploy-tier
  → deploy-cicd
  → deploy-observability
  → deploy-secrets-audit
  → deploy-release-check
  → deploy-rollback
subagent 12 → launch-readiness (gate: launch-tier: standard or full)
subagent 13 → sync-docs        (always)
```

See invocation-map.md for full gate conditions and depth calibration per intent tier.

## Anti-rationalization table
| Common Excuse | Why It's Wrong | What to Do Instead |
|---|---|---|
| "Let's ship fast and fix later" | "Fix later" becomes "fix in production under pressure." Quality is not optional. | Run the full ship pipeline. If it finds issues, fix them before shipping. |
| "Security audit is overkill for this release" | Minor releases can introduce major vulnerabilities. Every release is a security boundary. | Run security audit. It's automated, it's fast, it's non-negotiable. |
| "QA already tested this" | QA tests correctness. Ship runs additional gates: security, monitoring, benchmark, launch readiness. | Let ship run. If QA already covered something, the gate will pass fast. |
