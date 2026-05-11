---
name: deploy-rollback
description: Produces a rollback strategy with explicit trigger conditions, rollback procedure, and recovery time estimate. Use when the user asks about "rollback plan", "how do I roll back", "what if the deploy fails", "incident recovery", "blue-green deployment", or when /implement reaches this step. The rollback strategy should exist before the first production deploy, not be figured out during an incident. Tier-aware: hackathon gets a one-liner; MVP gets a documented procedure; scaling gets automated rollback with SLO-based triggers.
---

# /deploy-rollback — rollback strategy

Defines how to recover from a bad deploy. The rollback strategy is most valuable when it's been written before the incident — because figuring it out during an outage, with pressure and adrenaline, is when mistakes happen.

Read `sdlc-foundation/maturity-tier-detection.md` for tier-appropriate approach.
Read `sdlc-foundation/decision-frameworks.md` — deployment frameworks section.

## Core principle: MTTR is dominated by rollback speed

Mean Time to Recovery = Time to detect + Time to decide to roll back + Time to execute rollback.

The first two are hard to control in the moment. The third is where preparation pays off. A documented, pre-tested rollback procedure cuts execution time from 30+ minutes to under 5.

## Tier-appropriate strategies

### Hackathon

**Strategy**: manual redeploy of previous commit.

```bash
# Roll back to previous deploy
git revert HEAD && git push
# OR
git checkout <previous-commit> && git push --force
```

No SLO trigger, no automation. Human decides; human executes.

### MVP

**Strategy**: documented one-click redeploy with a defined decision threshold.

```markdown
## Rollback Procedure

### Trigger condition
Roll back if, within 30 minutes of deploy:
- Error rate exceeds 5% (measured by uptime monitor / platform metrics)
- Any P0 bug reported by users
- Core functionality broken on manual smoke test

### Rollback steps
1. Go to [deployment platform] dashboard
2. Select previous deployment version
3. Click "Redeploy" / run: [platform-specific rollback command]
4. Verify: smoke test the 3 core flows
5. Post to team channel: "Rolled back [version] due to [reason]"

### Estimated recovery time: 5-10 minutes

### Database note
If this deploy included a migration: [describe if the migration is reversible or not]
```

### Scaling

**Strategy**: automated canary rollback with SLO-based triggers, plus documented manual override.

```markdown
## Rollback Strategy — Scaling

### Automated rollback (canary phase)
During the 10% canary window:
- **Auto-rollback trigger**: error rate on canary > 2× baseline, sustained for 5 minutes
- **Auto-rollback trigger**: p99 latency on canary > 200% baseline, sustained for 5 minutes
- **Auto-rollback trigger**: health check failures > 3 consecutive
- **Mechanism**: load balancer routes all traffic back to previous version; alert fired

### Manual rollback (post-canary / full traffic)
If a problem is detected after full traffic promotion:

1. **Declare incident** — open incident channel, notify on-call
2. **Execute rollback**:
   ```bash
   # Kubernetes
   kubectl rollout undo deployment/[service-name]
   kubectl rollout status deployment/[service-name]

   # Docker Swarm
   docker service rollback [service-name]

   # Serverless (Vercel, Fly.io, etc.)
   [platform-specific rollback command]
   ```
3. **Verify** — run smoke tests; check error rate returns to baseline
4. **Communicate** — update status page; notify stakeholders
5. **Document** — open postmortem ticket before closing incident

### Database rollback
- Migrations in this deploy: [list]
- Reversible: [yes — rollback script at `db/rollback/YYYYMMDD.sql` / no — data loss risk; manual intervention required]
- If not reversible: migration was additive; old code version runs against new schema without errors

### Estimated MTTR
- Auto-rollback (canary): < 5 minutes
- Manual rollback (full traffic): 10-20 minutes
- Manual rollback + DB intervention: 30-60 minutes

### Rollback decision authority
Who can authorize a rollback without escalation: [on-call engineer]
Who must be notified: [engineering lead, product manager]
```

## Procedure

1. Detect tier from context
2. Produce the tier-appropriate rollback strategy document
3. Flag if the current deploy includes database migrations — the database rollback question is the one that catches teams off guard
4. Note the PSI (Linux Pressure Stall Information) metrics available at scaling tier for detecting resource starvation before SLO breach: `cat /proc/pressure/cpu`, `cat /proc/pressure/memory` — these are leading indicators, not lagging ones
5. Recommend adding rollback procedure to runbook; recommend `/deploy-release-check` if pre-release checklist hasn't been done

After rollback strategy is documented: the deployment stack is complete. Confirm the full SDLC loop is closed (requirements → architecture → tasks → implementation → deployment → observability + rollback).
