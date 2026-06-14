---
name: deploy-release-check
description: Produces a pre-release verification checklist calibrated to the deployment tier. Use when the user is about to deploy to production and wants to verify readiness: "are we ready to ship?", "pre-release checklist", "production readiness", "release gates", "what should I check before going live?", or when /implement reaches this step. Not a replacement for automated CI gates — it's the human-review layer that catches what automation misses.
---

# /deploy-release-check — pre-release verification

The last human checkpoint before production. Automated CI catches regressions; this checklist catches the things CI doesn't know to check — compliance sign-offs, runbook existence, stakeholder communication, rollback readiness.

Read `sdlc-foundation/maturity-tier-detection.md` for tier-appropriate gate strictness.

## Tier-calibrated checklists

### Hackathon release checklist

```markdown
## Release Checklist — Hackathon

- [ ] Does it run? (local smoke test)
- [ ] Are there obvious crashes on the critical path?
- [ ] Is there anything credential-related in the diff? (rotate before pushing if so)

That's it. Ship it.
```

### MVP release checklist

```markdown
## Release Checklist — MVP

### Code quality
- [ ] All CI checks passing (lint, tests, build)
- [ ] PR reviewed by at least one other person (or self-reviewed with 24h cool-off)
- [ ] No TODO/FIXME comments on the critical path
- [ ] No debug logging left in (console.log passwords, request bodies with PII)

### Security
- [ ] Secrets in environment variables, not in code
- [ ] No new third-party packages with known vulnerabilities (npm audit / pip check)
- [ ] Auth checked on all new routes/endpoints

### Testing
- [ ] Happy path tested (manually if not automated)
- [ ] At least one failure path tested
- [ ] Core flows work on mobile (if applicable)

### Deployment
- [ ] Staging deploy completed and verified
- [ ] Database migrations tested on staging first
- [ ] Rollback plan identified (what version to redeploy if this one fails)
- [ ] Deployment time noted (avoid deploying Friday afternoons)

### Communication
- [ ] Beta users notified of changes (if applicable)
- [ ] Known issues documented
```

### Scaling release checklist

```markdown
## Release Checklist — Scaling

### Automated gates (CI must show ✅)
- [ ] All unit, integration, and contract tests pass
- [ ] Code coverage ≥ threshold
- [ ] SAST scan: no critical/high vulnerabilities
- [ ] Dependency audit: no known CVEs above severity threshold
- [ ] Build artifact archived with checksum

### Manual verification
- [ ] Staging smoke tests completed by QA or developer
- [ ] Performance test run on staging: NFRs met under target load
- [ ] Database migrations: backward-compatible (old version runs against new schema)
- [ ] Feature flags configured correctly (new feature behind flag if incremental rollout)

### Security and compliance
- [ ] No PII in logs (verified via log sampling)
- [ ] Auth + authz tested on all new endpoints
- [ ] Compliance-relevant changes reviewed (PCI, GDPR, FIPPA scoped items)
- [ ] RBAC changes reviewed and approved

### Deployment readiness
- [ ] Canary strategy configured (10% traffic split; health check thresholds set)
- [ ] Rollback plan documented (target version, rollback command, expected recovery time)
- [ ] On-call notified of deploy window
- [ ] Runbook updated for any new failure modes introduced

### Communication
- [ ] Internal stakeholders notified
- [ ] Status page updated (if applicable)
- [ ] Customer-facing changelog updated (if user-visible changes)

### Post-deploy verification
- [ ] Metrics baseline established before deploy (15-minute pre-deploy window)
- [ ] Error rate monitored for 30 minutes post-deploy
- [ ] Rollback decision point: [TIME] — if error rate > threshold at this time, roll back
```

## Procedure

1. Detect tier from context or ask
2. Produce the tier-appropriate checklist as a markdown checklist the user can paste into a PR, Notion, or Linear
3. Flag any items that look pre-failed based on context (e.g., "you mentioned you haven't tested on staging — that's on the checklist")
4. After producing: recommend `/deploy-rollback` to ensure the rollback strategy is explicit before shipping

## Anti-rationalization table
| Common Excuse | Why It's Wrong | What to Do Instead |
|---|---|---|
| "We'll check everything during the deploy" | During-deploy checking is rushed, incomplete, and stressful. You'll miss things. | Run the checklist before the deploy window. Fix issues before Go time. |
| "The checklist is too long" | A long checklist means too many things can go wrong. Shorten it by automating checks. | Move automated checks to CI. Keep the checklist for things only humans can verify. |
| "We deployed last time without issues" | Last time's success doesn't tell you about this time's changes. Different code, different risks. | Run the full checklist every time. No exceptions. |
