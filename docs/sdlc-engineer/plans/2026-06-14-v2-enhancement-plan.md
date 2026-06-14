# sdlc-engineer v2 — Enhancement Plan

> **Date:** 2026-06-14
> **Status:** Planning (read-only)
> **Next Step:** Research best practices documentation → Create implementation plan → Execute via anti-gravity
> **Prerequisites:** Research findings in `2026-06-14-v2-tool-research.md`
> **Sub-skill gate:** `arch-decompose: false` (no microservice extraction needed)

---

## Overview

**Goal:** Fill 14 identified gaps in sdlc-engineer v1 across 5 phases.

**Architecture:** Each enhancement is a standalone SKILL.md file (sdlc-engineer skill format), with optional reference/ subdirectory for supporting materials. No changes to existing hooks or project config needed — new skills are triggered by user command, same as all existing skills.

**Naming convention:**
- Skills go in `skills/<name>/SKILL.md`
- References go in `skills/<name>/references/`
- Planning docs go in `docs/sdlc-engineer/plans/`

---

## Phase 1: Foundation (Critical Gaps)

### 1.1 `/debug` Skill — 4-Phase Root Cause Debugging

**Trigger:** User says "this test is failing", "getting an error", "it's broken", "why isn't X working", or `/implement` gets a failing GREEN step.

**File:** `skills/debug/SKILL.md`

**Structure:**
```yaml
---
name: debug
description: 4-phase root cause debugging process. Triggers on test failure, error, crash, or unexpected behavior. Always diagnose before fixing.
---

# /debug — 4-Phase Root Cause Process

## Phase 0: Establish Ground Truth
- Exact reproduction steps
- Capture error output, stack trace, logs
- Document expected vs actual behavior
- Identify environment

## Phase 1: Isolate
- Binary search the problem space
- Check git log/git diff for recent changes
- Add logging/probes
- Find minimal reproduction

## Phase 2: Hypothesize
- Form 2-3 hypotheses from evidence
- Rank by likelihood
- Design experiment per hypothesis
- Check learnings.jsonl for similar past issues

## Phase 3: Verify
- Fix root cause (not symptom)
- Write regression test first
- Verify no collateral breakage
- Document in learnings.jsonl

## Anti-rationalization table
| Excuse | Rebuttal |
|--------|----------|
| "I'll just try this fix" | Diagnose first. Guessing wastes time. |
| "It worked before" | Something changed. Find what. |
| "Must be a library bug" | Check your code first. 90% are in user code. |
| "I don't need to reproduce" | You can't fix what you can't see. |
```

**Files to create:**
- `skills/debug/SKILL.md`
- `skills/debug/references/common-patterns.md`

**Integration:**
- Auto-invoke from `/implement` when GREEN step fails
- Read/write `learnings.jsonl` for cross-session memory

---

### 1.2 `/modify` Skill — Surgical Code Changes

**Trigger:** User wants to refactor, fix bug, make small feature, or change config without full SDLC overhead.

**File:** `skills/modify/SKILL.md`

**Structure:**
```yaml
---
name: modify
description: Targeted code changes without full /implement pipeline. Risk-aware: low (config/docs) → medium (logic/UI) → high (auth/payments/data).
---

# /modify — Surgical Code Changes

## Pre-flight
1. Understand change scope
2. Check git status
3. Identify affected files
4. Assess risk level

## Workflow by Risk
- **Low:** Make change → Run relevant tests → Commit
- **Medium:** Understand current behavior → Write failing test → Implement → Verify → Full suite → Commit
- **High:** Document rationale → Comprehensive tests → Implement with rollback plan → Security review → Commit

## Anti-rationalization table
| Excuse | Rebuttal |
|--------|----------|
| "Too small to test" | Small changes cause big bugs. |
| "I'll just fix it fast" | Speed without test = debt. |
| "Old code was broken anyway" | Prove it. Document it. |
```

**Files to create:**
- `skills/modify/SKILL.md`

---

### 1.3 Anti-Rationalization Tables (All Existing Skills)

**Action:** Add an anti-rationalization table section to every existing SKILL.md file.

**Template:**
```markdown
## Anti-rationalization table
| Common Excuse | Why It's Wrong | What to Do Instead |
|---------------|----------------|-------------------|
| "I'll add tests later" | Later never happens | Write test first, then implement |
| "It's too complex" | Complexity needs testing most | Break into testable units |
| "I'm confident it works" | Confidence ≠ correctness | Run the tests |
| "Requirements are unclear" | Don't assume. Ask. | Clarify before coding |
| "No time for security" | No time for breach either | Security is not optional |
```

**Files to modify (all existing skills):**
- `skills/implement/SKILL.md`
- `skills/spec/SKILL.md`
- `skills/design/SKILL.md`
- `skills/audit/SKILL.md`
- `skills/audit-spec/SKILL.md`
- `skills/audit-code/SKILL.md`
- `skills/analyze/SKILL.md`
- `skills/decide/SKILL.md`
- `skills/tasks/SKILL.md`
- `skills/ship/SKILL.md`
- Plus all `req-*`, `deploy-*`, `arch-*` skills

---

## Phase 2: UI/UX (High Impact)

### 2.1 `/ui-design` Skill — Design + Implementation + Testing

**Trigger:** User building user interfaces, dashboards, landing pages, or any frontend work.

**File:** `skills/ui-design/SKILL.md`

**Structure:**
```yaml
---
name: ui-design
description: Full-stack UI/UX workflow — design system generation, implementation with a11y, automated testing (visual regression, a11y audit, performance).
---

# /ui-design — Design → Build → Test → Review

## Phase 1: Design System Generation
- Detect tech stack (React/Vue/Svelte/etc.)
- Query design reference files:
  - Style recommendations (57+ styles)
  - Color palettes (95, industry-specific)
  - Typography pairings (57, with Google Fonts)
  - UX guidelines (99, priority-ordered)
- Generate design tokens

## Phase 2: Implementation
- Component architecture
- WCAG 2.1 AA (contrast 4.5:1, touch targets 44x44)
- Keyboard navigation + screen reader support
- Loading states: skeleton screens, progressive loading, optimistic updates
- Responsive (mobile-first)

## Phase 3: Automated Testing
1. Visual regression (Playwright screenshot comparison)
2. Accessibility audit (axe-core)
3. Performance (Lighthouse, Core Web Vitals)
4. Interaction testing (Playwright user flows)

## Phase 4: Review
- Design consistency
- Accessibility report
- Performance report
- Cross-browser verification
```

**Files to create:**
- `skills/ui-design/SKILL.md`
- `skills/ui-design/references/design-styles.md` (from uiuxpromax)
- `skills/ui-design/references/color-palettes.md` (from uiuxpromax)
- `skills/ui-design/references/typography.md` (from uiuxpromax)
- `skills/ui-design/references/ux-guidelines.md` (from uiuxpromax)
- `skills/ui-design/references/testing-patterns.md` (Playwright patterns)
- `skills/ui-design/scripts/visual-regression.ps1`
- `skills/ui-design/scripts/a11y-audit.ps1`

---

## Phase 3: Cloud / Infrastructure (Medium Impact)

### 3.1 `/cloud` Skill — Cloud Infrastructure, Deployment & DevOps

**Trigger:** User deploying to production, setting up infrastructure, writing Dockerfiles, configuring CI/CD, or choosing between cloud providers.

**File:** `skills/cloud/SKILL.md`

**Structure:**
```yaml
---
name: cloud
description: Multi-cloud infrastructure design, Docker containerization, CI/CD pipeline setup, and deployment automation. Tier-aware: hackathon → MVP → scaling.
---

# /cloud — Cloud Infrastructure, Deployment & DevOps

A tier-calibrated workflow for cloud infrastructure. Not replacing terraform-skill or aws-skills — providing the orchestration layer that selects the right patterns and tools for the maturity level.

## Tier Detection
- **Hackathon:** Single server, simple deploy (Vercel/Railway/Fly.io), no containers
- **MVP:** Docker + CI/CD + managed database + CDN
- **Scaling:** Multi-region, K8s, IaC (Terraform/Pulumi), observability

## Phase 1: Architecture Design
- Cloud provider selection (AWS/Azure/GCP)
- Service selection (compute, database, storage, networking)
- Multi-region / HA design
- Cost estimation (reference: Well-Architected Framework)

## Phase 2: Infrastructure as Code
- Terraform module patterns (reference: antonbabenko/terraform-skill)
- CDK for AWS (reference: zxkane/aws-skills)
- Pulumi patterns (reference: dirien/claude-skills)
- State management and environment separation

## Phase 3: Containerization
- Dockerfile best practices (multi-stage, security, distroless)
- Docker Compose for local dev parity
- Container registry setup
- Image tagging and versioning strategy

## Phase 4: CI/CD Pipeline
- GitHub Actions generation (tier-appropriate complexity)
- Build → Test → Deploy workflow
- Environment promotion (dev → staging → prod)
- Rollback strategies (blue-green, canary, feature flags)

## Phase 5: Deployment
- Cloud-specific: ECS, EKS, Lambda, App Runner, Cloud Run, Azure Container Apps
- Database migrations in deployment pipeline
- DNS/SSL/CDN setup
- Secrets management (OIDC, Secrets Manager, parameter store)

## Phase 6: Observability
- Structured logging
- Metrics and dashboards
- Distributed tracing
- Cost monitoring and budgeting

## Anti-rationalization table
| Excuse | Rebuttal |
|--------|----------|
| "Kubernetes is always the answer" | Use the simplest thing that works for your scale |
| "Docker in production is enough" | You need orchestration for >1 server |
| "I'll fix security later" | IaC security is cheaper at design time |
| "Manual deploy is fine" | Every manual deploy is a future incident |
| "We don't need monitoring" | You don't know what you don't know |
```

**Files to create:**
- `skills/cloud/SKILL.md`
- `skills/cloud/references/terraform-patterns.md` (key patterns from antonbabenko)
- `skills/cloud/references/docker-best-practices.md`
- `skills/cloud/references/deployment-strategies.md`

---

## Phase 4: Quality Gates (Medium Impact)

### 4.1 `/doubt` Skill — Doubt-Driven Development

**Trigger:** High-stakes decisions (production, security, irreversible), unfamiliar code, or when confident output needs adversarial review.

**File:** `skills/doubt/SKILL.md`

**Structure:**
```yaml
---
name: doubt
description: Adversarial fresh-context review using CLAIM → EXTRACT → DOUBT → RECONCILE → STOP loop. Use when stakes are high or confidence is unchecked.
---

# /doubt — CLAIM → EXTRACT → DOUBT → RECONCILE → STOP

## Step 1: CLAIM
State what you believe to be true.

## Step 2: EXTRACT
Show evidence: code, tests, data flow.

## Step 3: DOUBT
Attack the claim:
- What could go wrong?
- What edge cases are missing?
- What assumptions are we making?
- What is NOT tested?

## Step 4: RECONCILE
- Valid doubt → fix it
- Invalid doubt → document why
- Uncertain → escalate to user

## Step 5: STOP
- Review all reconciliations
- Verify fixes don't introduce new issues
- Document decision

## Anti-rationalization table
| Excuse | Rebuttal |
|--------|----------|
| "I'm confident" | Confidence ≠ correctness. Verify. |
| "I already checked" | Check again with fresh eyes. |
| "Tests pass" | Tests can be wrong too. |
```

**Files to create:**
- `skills/doubt/SKILL.md`

---

### 4.2 Agent Personas

**Structure:** Pre-defined persona prompts that set context, constraints, and role for specialist agents.

**Files to create:**
- `skills/personas/SKILL.md`
- `skills/personas/references/code-reviewer.yaml`
- `skills/personas/references/test-engineer.yaml`
- `skills/personas/references/security-auditor.yaml`
- `skills/personas/references/ux-designer.yaml`
- `skills/personas/references/performance-engineer.yaml`

**Example persona (code-reviewer):**
```yaml
role: Code Reviewer
focus: Correctness, security, performance, maintainability, test coverage
constraints:
  - Do NOT suggest implementation — only review
  - Flag every bug, not just the first N
  - Distinguish: "must fix" vs "should fix" vs "nice to have"
  - Verify tests actually test what they claim
anti-rationalization:
  - "Mostly correct" → "Mostly correct" means partially wrong
  - "Edge cases are unlikely" → Unlikely ≠ impossible
```

---

## Phase 5: Integration (Pipeline Orchestration)

### 5.1 Auto-Debug on `/implement` Test Failure

**Modification:** `skills/implement/SKILL.md`

**Add to task execution loop:**
```yaml
## Failure Handling
- Test failure → Capture error → Invoke /debug → Do NOT re-implement without diagnosis
- Build failure → Parse error → Check common causes → Invoke /debug if unclear
- Runtime error → Capture stack trace → Check logs → Invoke /debug
- Always write root cause to learnings.jsonl
```

### 5.2 Security Pipeline Enhancement

**Modification:** `skills/audit/SKILL.md`

**Add phases:**
```yaml
## Phase 1: Threat Modeling (STRIDE/DREAD)
## Phase 2: Static Analysis (Semgrep) + Secret Detection
## Phase 3: Dependency Audit (CVE + License)
## Phase 4: Database Security (RLS verification, data leakage)
## Phase 5: Runtime Verification (Chrome DevTools MCP)
```

### 5.3 Human Gates Integration

**Modification:** Add optional human gate configuration to all high-risk operations.

**Pattern:**
```yaml
## Human Gate
- Risk: high/medium/low (auto-detected)
- Gate: If high risk, pause and present findings to user
- User can: approve, deny, or modify scope
- If no response within timeout, abort (safe default)
```

---

## Implementation Roadmap

| Phase | What | Files | Est. Effort |
|---|---|---|---|---|
| **1a** | `/debug` skill | 2 new files | 1 session |
| **1b** | `/modify` skill | 1 new file | 0.5 session |
| **1c** | Anti-rationalization tables | ~27 existing files modified | 1 session |
| **2a** | `/ui-design` skill | 1 new file | 1 session |
| **2b** | Design reference files (67 styles, 161 palettes, 57 fonts, 99 guidelines) | 4 reference files | 1 session |
| **2c** | Testing scripts | 2 scripts | 0.5 session |
| **3a** | `/cloud` skill | 1 new file | 1 session |
| **3b** | Cloud reference files (terraform, docker, deployment) | 3 reference files | 0.5 session |
| **4a** | `/doubt` skill | 1 new file | 0.5 session |
| **4b** | Agent personas | 6 new files | 1 session |
| **5a** | Auto-debug in `/implement` | 1 file modified | 0.5 session |
| **5b** | Security pipeline | 1 file modified | 0.5 session |
| **5c** | Human gates | All high-risk skills | 1 session |

**Total: ~10 sessions**

---

## Pre-Execution Checklist

Before anti-gravity executes:

- [ ] Research best practices documentation (deep dive into each tool's methodology)
- [ ] Review `/debug` 4-phase process against addyosmani's debugging-and-error-recovery skill
- [ ] Review `/modify` risk levels against sdlc-engineer's existing patterns
- [ ] Extract design reference files from ui-ux-pro-max-skill (67 styles, 161 palettes, 57 fonts, 99 guidelines)
- [ ] Extract cloud reference files from antonbabenko/terraform-skill (testing, modules, CI/CD, security patterns)
- [ ] Design anti-rationalization tables for each existing skill (customized per domain)
- [ ] Define agent persona prompt templates (reference: addyosmani's 4 personas + getsentry's 2 subagents)
- [ ] Design `learnings.jsonl` schema for cross-session memory
- [ ] Review getsentry/security-review methodology (teaches thinking, not checklist)
- [ ] Final implementation plan with per-task TDD specs

---

## Research Needed (Before Implementation)

The following need deeper research before anti-gravity executes. Research results should be saved to `docs/sdlc-engineer/plans/` as reference files.

### From addyosmani/agent-skills (59k stars)
1. Full text of `debugging-and-error-recovery` skill (5-step triage: reproduce, localize, reduce, fix, guard)
2. Full text of `browser-testing-with-devtools` skill (Chrome DevTools MCP: DOM, console, network, performance)
3. Full text of `doubt-driven-development` skill (CLAIM → EXTRACT → DOUBT → RECONCILE → STOP)
4. Agent persona prompt structures (code-reviewer, test-engineer, security-auditor, web-perf-auditor)
5. Anti-rationalization table patterns across all 24 skills (any domain-specific variants)
6. reference/checklist files (testing-patterns, security, performance, accessibility)

### From ui-ux-pro-max-skill (91.5k stars)
1. Export all 67 design styles (49 general + 8 landing page + 10 dashboard) as reference files
2. Export all 161 color palettes (1:1 with product types) as reference files
3. Export all 57 font pairings as reference files
4. Export all 99 UX guidelines (priority-ordered: Critical → High → Medium → Low) as reference files
5. Export all 161 reasoning rules (industry-specific design system generation)
6. Python search engine scripts (BM25 ranking, anti-pattern filter, decision rules)

### From getsentry/skills (796 stars)
1. Full text of `security-review` skill (how-to-think methodology, not checklist)
2. Full text of `gha-security-review` skill (GitHub Actions specific vulns)
3. Full text of `django-access-review` skill (IDOR patterns)
4. Full text of `find-bugs` skill
5. Warden CLI pattern (runs skills on PR diffs via `npx @sentry/warden`)
6. Subagent definitions (code-simplifier, senpai)

### From antonbabenko/terraform-skill (2k stars)
1. Testing framework patterns (native tests vs Terratest decision matrix)
2. Module development conventions (naming, structure, versioning)
3. CI/CD workflow patterns (GitHub Actions with Terraform)
4. State management patterns (remote backends, locking, migration)
5. Security patterns (Trivy, Checkov, policy-as-code)

### From cloud/infra ecosystem
1. Dockerfile best practices (multi-stage, security, distroless images)
2. Deployment strategy patterns (blue-green, canary, rolling, feature flags)
3. aws-skills / zxkane patterns (CDK, cost optimization, serverless)
4. Pulumi patterns from dirien/claude-skills (ESC, OIDC, ComponentResource)

### Best practices (general)
1. Playwright visual regression patterns (screenshot comparison, thresholds)
2. axe-core a11y audit commands (integration patterns)
3. Lighthouse CI integration (threshold configuration)
4. Chrome DevTools MCP protocol (available commands)
