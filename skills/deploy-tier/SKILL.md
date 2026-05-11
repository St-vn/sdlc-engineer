---
name: deploy-tier
description: Assesses the project's deployment maturity tier (hackathon / MVP / scaling) and sets the gating calibration for all other deploy-* commands. Use when starting any deployment-related work, or when the user asks "what kind of deployment do I need?", "how much CI/CD rigor do I need?", "am I over-engineering my deployment?", "what deployment setup makes sense for my stage?". Also invoked as the first step by /implement. The tier assessment drives the depth and strictness of every downstream deploy command.
---

# /deploy-tier — deployment tier assessment

Establishes the deployment maturity tier. Every other deploy-* command consults this tier to calibrate strictness. Running tier assessment before any deployment work avoids two equally bad failure modes: a hackathon project drowning in enterprise process, or a scaling startup with a push-to-prod deploy strategy.

Read `sdlc-foundation/maturity-tier-detection.md` for the full tier detection signal set.

## Tier definitions for deployment

### Hackathon tier

**Goal**: demo-ready, not production-ready.

Acceptable:
- Direct push to main → auto-deploy
- Root access, shared credentials among team
- No staging environment; localhost or single prod environment
- Manual rollback (revert commit + redeploy)
- No formal monitoring (error console is fine)
- No secrets management (`.env` file in the repo is still bad, but a `.env` on the server is acceptable)

Not acceptable even at hackathon:
- Credentials in git history (rotation cost is the same regardless of tier)

### MVP tier

**Goal**: stable enough for real users; recoverable when things break.

Required:
- PR-triggered CI: lint + unit tests must pass before merge
- Separate staging and production environments
- Automated deploy to staging on merge to main
- Manual promotion to production (or auto with a manual approval gate)
- Basic monitoring: uptime check + error rate alert
- Secrets in environment variables (not in code); managed via the platform (Vercel secrets, Railway env, Render env, etc.)
- Basic rollback: one-click redeploy of previous version

### Scaling tier

**Goal**: reliable, auditable, self-healing.

Required:
- Full 6-phase CI/CD pipeline
- Branch protection with required reviewers
- Automated security scanning (SAST + dependency vulnerabilities)
- Immutable artifact archival with checksums
- Multiple environments: dev → staging → production (+ optional canary)
- Canary deploys with automatic rollback on SLO breach
- Three-signal observability: metrics + logs + traces (LGTM stack)
- Secrets management via dedicated secret manager (AWS Secrets Manager, Vault, Doppler)
- RBAC on all infrastructure access; no shared credentials
- Audit log of deploys: who, what, when, outcome

## Output format

```markdown
## Deployment Tier Assessment

**Tier: [Hackathon / MVP / Scaling]**

### Signals detected
- [Signal 1 that drove this assessment]
- [Signal 2]

### What this tier requires
[Brief summary of the required gating at this tier]

### What this tier does NOT require
[Explicit list of things that would be over-engineering at this tier]

### Tier mismatch flag (if applicable)
[If the user's described setup doesn't match their actual tier, flag it here]
```

## Tier mismatch handling

**Under-engineered for tier**: User is at scaling tier but has a push-to-prod deploy.
→ Soft-warn with concrete risk: "At scaling tier with real users and revenue dependency, a production incident without rollback automation means your MTTR is however long it takes a human to notice, debug, and redeploy. That's typically 30-90 minutes. Implementing canary + auto-rollback cuts that to under 5 minutes."

**Over-engineered for tier**: User is at hackathon tier but asking about Kubernetes and multi-region failover.
→ Redirect: "For a hackathon scope, Kubernetes adds 2-4 hours of setup overhead with no user-facing benefit. Ship on Fly.io or Railway — one command to deploy, built-in rollback. You can Kubernetes when you have the team to operate it."

After assessment: recommend `/deploy-cicd` to define the pipeline appropriate to the tier.
