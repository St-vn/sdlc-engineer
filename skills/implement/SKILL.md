---
name: implement
description: Orchestrator for deployment engineering — produces a CI/CD pipeline definition, observability plan, secrets management policy, release gates, and rollback strategy at the depth appropriate for the maturity tier. Use when the user asks "how do I deploy this?", "set up CI/CD", "what does my pipeline look like?", "how do I monitor this?", "what do I need before going to production?", or has finished spec+design+tasks and wants the deployment layer. Chains /deploy-tier → /deploy-cicd → /deploy-observability → /deploy-secrets-audit → /deploy-release-check → /deploy-rollback at tier-appropriate depth.
---

# /implement — deployment engineering orchestrator

Produces a complete deployment engineering plan by sequencing the granular deployment skills:

```
/deploy-tier → /deploy-cicd → /deploy-observability → /deploy-secrets-audit → /deploy-release-check → /deploy-rollback
```

This is the final phase of the sdlc-engineer lifecycle. The output is a deployment-ready posture: how the system is built, shipped, observed, and recovered.

## Tier-appropriate depth

| Step | Hackathon | MVP | Scaling |
|:---|:---|:---|:---|
| Tier assessment | Confirm hackathon; set low-friction stance | Confirm MVP; basic gates only | Confirm scaling; full gating suite |
| CI/CD | Push to prod is fine; GitHub Actions + deploy step if time allows | PR → build → test → staging → prod | Full 6-phase pipeline with artifact archival and canary |
| Observability | Nothing required | Error tracking (Sentry) + basic uptime monitor | LGTM stack + OpenTelemetry + correlation IDs + SLO dashboards |
| Secrets | Don't commit secrets to git | `.env` files + platform secrets (Vercel, Railway, etc.) | Vault / AWS Secrets Manager + zero secrets in env vars |
| Release check | None | Manual smoke test in staging | Automated smoke + canary + health checks + feature flags |
| Rollback | Redeploy the previous commit | One-click revert in platform | Blue-green or canary with automated health-check-driven rollback |

## Procedure

### Step 1 — Tier check
Run `/deploy-tier` first. This sets the gating strictness for every subsequent step. A hackathon team that runs a full PCI-grade pipeline wastes the weekend; a scaling startup that skips gating ships regressions.

### Step 2 — Sequence the granular skills
Invoke in order, passing tier and stack context forward:
1. `/deploy-cicd` — pipeline definition for the team's stack
2. `/deploy-observability` — three-signal telemetry plan (metrics/logs/traces)
3. `/deploy-secrets-audit` — credential hygiene and extraction plan
4. `/deploy-release-check` — pre-production gate checklist
5. `/deploy-rollback` — rollback strategy and auto-trigger conditions

Between steps: brief summary. User can pause and take the output of any step without completing the full orchestration.

### Step 3 — Stack awareness
The deployment plan must be concrete for the user's actual stack, not generic. Check for stack mentions (Vercel, AWS, GCP, Railway, Fly.io, Kubernetes, GitHub Actions, GitLab CI, etc.). Where no stack is mentioned, recommend the boring, reliable default for the tier:

| Tier | Recommended boring stack |
|:---|:---|
| Hackathon | Vercel / Railway + GitHub Actions |
| MVP | Vercel or Fly.io + GitHub Actions + Postgres on managed host |
| Scaling | AWS/GCP + Kubernetes or ECS + GitHub Actions / GitLab CI + OpenTelemetry + LGTM |

### Step 4 — Anti-pattern scan
Per `sdlc-foundation/anti-pattern-catalog.md`:
- Credentials in source → flag and block on secrets audit
- No rollback plan → flag; every production deploy needs one
- Observability as logs only → flag; add metrics + traces
- Tier-inappropriate gating (hackathon + enterprise pipeline, or scaling + no gates) → correct

### Step 5 — Final output
Complete deployment posture summary: what's in the pipeline, what's observed, how secrets are managed, what gates exist, how rollback works. Where any step was skipped as tier-inappropriate, say so explicitly. Recommend: hand off to implementation team with this document, or wire the CI/CD config into the repository directly.

## Audience adaptation
- Novice: explain what CI/CD means, why observability matters, what rollback is; recommend specific managed services the user can sign up for without deep infrastructure knowledge
- Senior: stack-specific configurations, tool names, concrete pipeline YAML stubs
