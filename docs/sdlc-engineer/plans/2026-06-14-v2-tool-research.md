# sdlc-engineer v2 — Tool Research & Gap Analysis

> **Date:** 2026-06-14 (updated with deep research)
> **Context:** Evaluating external tools to determine what to steal/adapt for sdlc-engineer v2. Goal: maximize sdlc-engineer's capabilities — debugging, auditing, implementing features, rigorous testing with tool use, UI/UX with testing phases, cloud/infra/Docker.

---

## 1. awesome-claude-skills (ComposioHQ)

**URL:** https://github.com/ComposioHQ/awesome-claude-skills
**Stars:** 64.5k (forked from 59k original: actually 64.3k)
**Type:** Curated directory (1000+ skills)

### Actual Coverage (from repo tree, not just description)
- **11 major categories** with 40+ sub-skills each:
  - Document Processing (docx, pdf, pptx, xlsx, legal)
  - Development & Code Tools (artifacts-builder, aws-skills, changelog-generator, chrome-relay, ffuf, iOS Simulator, jules, LangSmith, MCP Builder, OpenWeb, overkill, Playwright, prompt-engineering, skill-creator, test-driven-development, webapp-testing, git-worktrees)
  - Data & Analysis (CSV Summarizer, deep-research, postgres, recursive-research, root-cause-tracing)
  - Business & Marketing (Brand Build Skills, brand-guidelines, competitive-ads, domain-name-brainstormer, internal-comms, lead-research)
  - Communication & Writing (article-extractor, brainstorming, content-research, meeting-insights, notebooklm, twitter-algorithm)
  - Creative & Media (anydesign, canvas-design, imagen, image-enhancer, slack-gif-creator, theme-factory, video-downloader, youtube-transcript, swiftui-design)
  - Productivity & Organization (file-organizer, invoice-organizer, kaizen, n8n, raffle-winner, solo-skills, resume-generator)
  - Collaboration & Project Management (git-pushing, google-workspace, mercury-mcp, outline, review-implementing, test-fixing)
  - Security & Systems (computer-forensics, file-deletion, metadata-extraction, threat-hunting-with-sigma-rules)
  - Assistive Technology (ASD-AuDHD-PAI-Skills)
  - App Automation (78 SaaS apps via Composio: CRM, PM, Communication, Email, Code & DevOps, HR, Marketing, Support, Analytics, Productivity, Finance, HR)
- **Security skills exist:** threat-hunting, computer-forensics
- **Testing skills exist:** webapp-testing (Playwright), test-driven-development
- **DevOps skills exist:** via app automation (CircleCI, Datadog, GitHub, GitLab, PagerDuty, Sentry, Render)

### Key Skills We Already Have (overlap)
- brainstorming, mcp-builder, skill-creator, theme-factory, internal-comms, brand-guidelines, changelog-generator
- These are copied FROM anthropics/skills into sdlc-engineer

### What to Steal
- Playwright browser automation pattern (webapp-testing skill)
- Root cause tracing skill (from obra/superpowers)
- Chrome Relay pattern (real Chrome session debugging)

### Verdict
Bigger than I initially thought. Has 1000+ skills but they're API wrappers, not methodologies. Useful as pattern reference for Playwright testing and Chrome debugging. Not competitive with sdlc-engineer's depth.

---

## 2. great_cto (avelikiy/great_cto)

**URL:** https://github.com/avelikiy/great_cto
**Stars:** 39
**Type:** ~~Claude Code SDLC pipeline~~ → **PIVOTED to "AI autopilots for business"**

### Critical Update: This project has pivoted
The project is no longer primarily a Claude Code SDLC plugin. It's now **"AI autopilots for business"** — 25 service-autopilot verticals (medical coding, legal docs, procurement, accounting, tax, KYC/AML, etc.). The SDLC pipeline is now just the "under the hood" section. The main product is business process automation with human-in-the-loop signing.

### What Still Exists (under the hood)
- 83 specialist agents, 26 archetypes, 12 jurisdictions
- Human gates, memory, cost tracking
- The SDLC pipeline still runs underneath

### What Changed
- Pivoted to business autopilots (not engineering SDLC)
- 25 verticals: Medical-coding, Managed-IT, Legal-document, Bookkeeping, Tax-prep, Source-to-pay, Prior-authorization, KYC/AML, SOC, Claims, Mortgage, Title, Credentialing, Debt-collection, Freight, Clinical-trials, Customs, SOX ITGC, Pharmacovigilance, Immigration, Appraisal, Payroll, Workers-comp, Estate, Patent
- 22 live connectors (FHIR, ICD-10, X12 837P, DocuSign, Plaid, OFAC, etc.)
- Operator console for human signers
- Cost: ~$34/month for typical solo-CTO

### What to Steal (engineering side only)
1. **Specialist subagents pattern** — still valid architecture
2. **Human gates** — configurable checkpoints
3. **Jurisdiction/compliance mapping** — 12 jurisdictions, 45+ frameworks
4. **Spec critic + Schema critic** — parallel review before implementation

### Verdict
**No longer directly comparable to sdlc-engineer.** It pivoted to business autopilots. The engineering SDLC pipeline is secondary. Only steal: subagents pattern, human gates, jurisdiction mapping, spec/schema critics. sdlc-engineer's 48 skills with deeper methodology are still superior for engineering SDLC.

---

## 3. ui-ux-pro-max-skill (nextlevelbuilder)

**URL:** https://github.com/nextlevelbuilder/ui-ux-pro-max-skill
**Stars:** 91.5k (9.6k forks)
**Type:** Design intelligence engine (Python-based)

### Actual Coverage (from repo inspection)
- **67 UI styles** (not 57) — General (49), Landing Page (8), Dashboard (10)
- **161 color palettes** (not 95) — 1:1 with product types
- **57 font pairings** (same as before)
- **25 chart types** (not 24)
- **15 tech stacks** (not 8) — React, Next.js, Astro, Vue, Nuxt.js, Nuxt UI, Svelte, SwiftUI, React Native, Flutter, HTML+Tailwind, shadcn/ui, Jetpack Compose, Angular, Laravel
- **99 UX guidelines** (same, priority-ordered)
- **161 reasoning rules** (NEW in v2.0) — Industry-specific design system generation
- **Design System Generator** — AI reasoning engine that generates complete design system from product type

### Architecture
```
src/ui-ux-pro-max/
├── data/*.csv          → Database files (styles, palettes, fonts, charts, UX guidelines)
├── scripts/*.py        → Search engine & design system generator
└── templates/          → Platform-specific templates
cli/                    → uipro-cli (npm package)
```

### Design System Generator Flow
```
User Request → Multi-Domain Search (5 parallel searches)
  → Product type matching (161 categories)
  → Style recommendations (67 styles)
  → Color palette selection (161 palettes)
  → Landing page patterns (24 patterns)
  → Typography pairing (57 font combos)
→ Reasoning Engine (BM25 ranking, anti-pattern filter, decision rules)
→ Complete Design System: Pattern + Style + Colors + Typography + Effects + Anti-patterns + Checklist
```

### What to Steal
1. **Entire design database** — 67 styles, 161 palettes, 57 fonts, 25 charts, 15 stacks, 99 guidelines, 161 rules
2. **Design System Generator reasoning engine** — industry-matching algorithm
3. **Priority-based UX guidelines** — Critical → High → Medium → Low
4. **Pre-delivery checklist** — validates against anti-patterns

### Gaps (still)
- **No UI testing** — zero Playwright/Cypress
- **No visual regression**
- **No accessibility testing** — guidelines yes, automated audits no
- **No performance testing** — Lighthouse CI not integrated
- **No testing feedback loops**

### Verdict
**91.5k stars is the real deal.** The design database is massive and directly importable. Need to pair it with a testing pipeline. The Python search engine + CLI makes it easy to integrate as reference files.

---

## 4. Security Skills — Updated Findings

### getsentry/skills (the canonical security skill)
**URL:** https://github.com/getsentry/skills
**Stars:** 796
**Type:** Sentry's internal engineering skills

### Skills Inventory (27 skills)
- `security-review` — Security code review for vulnerabilities
- `code-review` — Perform code reviews following Sentry engineering practices
- `find-bugs` — Find bugs, security vulnerabilities, and code quality issues
- `gha-security-review` — GitHub Actions security review for workflow exploitation vulnerabilities
- `skill-scanner` — Scan agent skills for security issues
- `django-access-review` — Django access control and IDOR security review
- `django-perf-review` — Django performance code review
- Plus: commit, create-branch, pr-writer, iterate-pr, pr-link-issue, blog-writing, doc-coauthoring, document-api-endpoint, agents-md, claude-settings-audit, code-simplifier, prompt-optimizer, replay-ux-research, presentation-creator, sred-*, triage-frontend-issues, typing-exclusion-worker, skill-writer

### Subagents: code-simplifier, senpai (senior engineer mentor)

### getsentry/warden (PR review bot)
**URL:** https://github.com/getsentry/warden
**Stars:** 332
PR review bot that runs skills on PRs — `npx @sentry/warden` + `npx @sentry/warden add security-review`

### getsentry/sentry-agent-skills (Sentry integration skills)
**Stars:** 19
Skills for Sentry integration: sentry-fix-issues, sentry-pr-code-review, sentry-create-alert

### What to Steal from getsentry
1. **security-review methodology** — teaches *how to think* about security
2. **Warden pattern** — CLI + GitHub Action that runs skills on PR diffs
3. **Django-specific reviews** — access control (IDOR) and performance patterns
4. **gha-security-review** — GitHub Actions specific (pinned tags, script injections, etc.)

### Additional Security Skills Found
- `security-audit` (4.9k stars): 8 categories, 148 checks — now integrated into warden ecosystem
- `VibeSec-Skill` (from BehiSecc): Web app security skill for Claude Code
- `threat-hunting-with-sigma-rules`: Sigma rule detection patterns

### Verdict
sdlc-engineer's existing `audit-code` (Semgrep) + `audit-spec` (DIR reasoning) is still more sophisticated. But getsentry's `security-review` methodology and `warden` CLI pattern are worth stealing.

---

## 5. addyosmani/agent-skills

**URL:** https://github.com/addyosmani/agent-skills
**Stars:** 59.1k (6.4k forks, 240 commits)
**Type:** Production-grade engineering skills plugin

### Full Structure Revealed
```
agent-skills/
├── skills/                            # 24 skills
│   ├── using-agent-skills/            # Meta: which skill applies
│   ├── interview-me/                  # Define
│   ├── idea-refine/                   # Define
│   ├── spec-driven-development/       # Define
│   ├── planning-and-task-breakdown/   # Plan
│   ├── incremental-implementation/    # Build
│   ├── context-engineering/           # Build
│   ├── source-driven-development/     # Build
│   ├── doubt-driven-development/      # Build
│   ├── frontend-ui-engineering/       # Build
│   ├── test-driven-development/       # Build
│   ├── api-and-interface-design/      # Build
│   ├── browser-testing-with-devtools/ # Verify
│   ├── debugging-and-error-recovery/  # Verify
│   ├── code-review-and-quality/       # Review
│   ├── code-simplification/           # Review
│   ├── security-and-hardening/        # Review
│   ├── performance-optimization/      # Review
│   ├── git-workflow-and-versioning/   # Ship
│   ├── ci-cd-and-automation/          # Ship
│   ├── deprecation-and-migration/     # Ship
│   ├── documentation-and-adrs/        # Ship
│   ├── observability-and-instrumentation/ # Ship
│   └── shipping-and-launch/           # Ship
├── agents/                            # 4 specialist personas
│   ├── code-reviewer.md               # Senior Staff Engineer
│   ├── test-engineer.md               # QA Specialist
│   ├── security-auditor.md            # Security Engineer
│   └── web-performance-auditor.md     # Web Performance Engineer
├── references/                        # 4 supplementary checklists
│   ├── testing-patterns.md
│   ├── security-checklist.md
│   ├── performance-checklist.md
│   └── accessibility-checklist.md
├── hooks/                             # Session lifecycle hooks
├── .claude/commands/                  # 7 slash commands
├── .gemini/commands/                  # 7 slash commands (cross-platform)
├── commands/                          # 8 slash commands (Antigravity CLI)
├── plugin.json                        # Antigravity plugin manifest
└── docs/                              # Setup guides (11 platforms)
```

### 7 Slash Commands
| Command | What it does | Key principle |
|---------|-------------|---------------|
| `/spec` | Define what to build | Spec before code |
| `/plan` | Plan how to build it | Small, atomic tasks |
| `/build` | Build incrementally | One slice at a time |
| `/build auto` | Auto-generate plan + implement all | Approve plan, then autonomous |
| `/test` | Prove it works | Tests are proof |
| `/review` | Review before merge | Improve code health |
| `/code-simplify` | Simplify the code | Clarity over cleverness |
| `/ship` | Ship to production | Faster is safer |

### Key Design Philosophy
- **Process, not prose.** Skills are workflows agents follow, not reference docs
- **Anti-rationalization tables.** Every skill includes excuses + rebuttals
- **Verification is non-negotiable.** Evidence requirements at end of every skill
- **Progressive disclosure.** SKILL.md is entry point; references load on demand (<100 tokens per skill at startup)

### What to Steal (confirmed)
1. **Anti-rationalization tables** — Apply to every sdlc-engineer skill
2. **Doubt-driven development** — CLAIM → EXTRACT → DOUBT → RECONCILE → STOP
3. **Browser testing with DevTools** — Chrome DevTools MCP
4. **4 agent personas** — code-reviewer, test-engineer, security-auditor, web-perf-auditor
5. **debugging-and-error-recovery** — 5-step triage
6. **Cross-platform support** — patterns for Claude Code, Gemini CLI, Cursor, Antigravity, OpenCode, etc.

### Verdict
Highest impact external input. anti-rationalization tables + doubt-driven development are unique innovations. 4 agent personas + browser testing fill gaps sdlc-engineer has.

---

## 6. Cloud / Infrastructure / Docker Skills Landscape

### Key Findings
Cloud/Infra/DevOps has rich ecosystem of dedicated skills. No single aggregator — fragmented across individual skill authors.

### Major Cloud/Infra Skills Found

| Skill | Author | Stars | What it Covers |
|-------|--------|-------|----------------|
| **terraform-skill** | antonbabenko | 2k | Terraform Testing, Modules, CI/CD, State Mgmt, Security (AWS/Azure/GCP) |
| **aws-skills** | zxkane | 133 | AWS CDK, Cost Optimization, Serverless, Event-Driven Architecture |
| **Cloud & DevOps Mastery** | MCP Market | — | AWS, Docker, Kubernetes, Terraform, CI/CD |
| **Infrastructure Engineer** | MCP Market | — | DevOps, IaC (Terraform), K8s/EKS, Observability |
| **AWS Cloud Infrastructure** | MCP Market | — | Terraform on AWS, security best practices |
| **tf-snap** | Praneethvvs | — | Convert POC to production Terraform |
| **dirien/claude-skills** | dirien | — | Pulumi TypeScript, ESC, OIDC, ComponentResource |
| **awesomeskill.ai** | Community | — | 111+ cloud infrastructure skills catalogued |

### Official Plugins
| Plugin | Provider | What it covers |
|--------|----------|---------------|
| `terraform` | Claude Plugins Official | Terraform ecosystem, IaC |
| `aws-core` | AWS Agent Toolkit | General AWS application and infrastructure |
| `aws-serverless` | AWS Agent Plugins | Lambda, API Gateway, serverless |

### DevOps Skills on awesome-claude-skills
The 64.5k-star repo lists cloud-adjacent skills:
- `aws-skills` — AWS CDK, cost optimization, serverless
- `webapp-testing` — Playwright integration
- `ci-cd-and-automation` (from addyosmani)
- `git-workflow-and-versioning` (from addyosmani)
- `observability-and-instrumentation` (from addyosmani)

### Dedicated DevOps Skills Directory
- `derisk-ai/awesome-devops-skills` — 46 repos collected (Kubernetes, CI/CD, IaC, Monitoring, Security)
- `awesomeskill.ai/category/devops-cicd` — 30+ DevOps/CI-CD skills
- `awesomeskill.ai/category/cloud-infrastructure` — 111+ cloud infrastructure skills

### Key Gaps in the Ecosystem
1. **No unified cloud skill** — Each cloud provider has separate skills (AWS vs Azure vs GCP)
2. **No Docker-specific skill** — Dockerfile generation, multi-stage builds, compose patterns
3. **No deployment pipeline skill** — Most are IaC-only (Terraform/Pulumi), not deployment workflows
4. **No multi-cloud orchestration** — No skill handles hybrid/multi-cloud decisions
5. **No infrastructure testing skill** — No dedicated skill for testing infrastructure

### What sdlc-engineer Should Build for Cloud/Infra
- **`/cloud` skill** — Multi-cloud design, deployment, Docker, hosting, CI/CD integration
- Covers: AWS, Azure, GCP basics + Docker + Terraform patterns + deployment strategies
- Not replacing terraform-skill or aws-skills — providing the orchestration layer on top
- Tier-aware: hackathon (simple deploy) → MVP (Docker + CI/CD) → scaling (multi-region, K8s)

---

## Cross-Tool Comparison Matrix (UPDATED)

| Capability | awesome-claude-skills | great_cto | ui-ux-pro-max | getsentry | addyosmani | sdlc-engineer |
|---|---|---|---|---|---|---|
| Debugging workflow | ❌ | ❌ | ❌ | ✅ | ✅ | ❌ (planned) |
| Security audit | ✅ | ✅ | ❌ | ✅ | ✅ | ✅ |
| Feature implementation | ❌ | ✅ | ❌ | ✅ | ✅ | ✅ |
| Rigorous testing | ✅ | ✅ | ❌ | ✅ | ✅ | ✅ |
| UI/UX design | ❌ | ❌ | ✅(91k★) | ❌ | ✅ | ❌ |
| UI testing tooling | ✅ | ❌ | ❌ | ❌ | ✅ | ❌ |
| Orchestration pipeline | ❌ | ✅ | ❌ | ❌ | ❌ | ✅ |
| Maturity tier awareness | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ |
| Anti-rationalization | ❌ | ❌ | ❌ | ❌ | ✅ | ❌ |
| Doubt-driven dev | ❌ | ❌ | ❌ | ❌ | ✅ | ❌ |
| Agent personas | ❌ | ✅ | ❌ | ✅ | ✅ | ❌ |
| Human gates | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ |
| Compliance mapping | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ |
| Cross-session memory | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ |
| Parallel execution | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ |
| Subagent dispatch | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ |
| Cloud/Infra/Docker | ✅ | ✅ | ❌ | ❌ | ✅ | ❌ (planned) |

---

## Gaps Summary (UPDATED — 14 items)

| # | Gap | Source | Severity | Effort |
|---|---|---|---|---|
| 1 | `/debug` skill (4-phase root cause) | addyosmani | Critical | Medium |
| 2 | UI/UX design + testing pipeline | ui-ux-pro-max + addyosmani | Critical | Large |
| 3 | `/modify` surgical changes | User feedback (hi-2.json) | High | Small |
| 4 | Anti-rationalization tables | addyosmani | High | Small |
| 5 | Doubt-driven development | addyosmani | High | Medium |
| 6 | Agent personas | addyosmani + getsentry | Medium | Medium |
| 7 | Human gates at critical decisions | great_cto (pre-pivot) | Medium | Small |
| 8 | Compliance/jurisdiction mapping | great_cto (pre-pivot) | Medium | Medium |
| 9 | Cross-session memory (learnings.jsonl) | great_cto (pre-pivot) | Medium | Small |
| 10 | Integration: auto-debug on test failure | Design gap | High | Small |
| 11 | Integration: security pipeline (RLS, threat model) | Design gap | Medium | Medium |
| 12 | Integration: UI testing into existing skills | Design gap | Medium | Small |
| **13** | **`/cloud` skill — cloud/infra/Docker design & deployment** | **Ecosystem gap (new)** | **Medium** | **Large** |
| **14** | **Playwright/Chrome DevTools MCP integration** | **addyosmani + ecosystem** | **High** | **Medium** |

---

## Key Decisions (UPDATED)

1. **Do NOT replace** sdlc-engineer's core methodology — it's superior
2. **Steal** anti-rationalization tables and doubt-driven development from addyosmani
3. **Steal** agent personas pattern from addyosmani
4. **Steal** design database from ui-ux-pro-max-skill (91.5k stars — massive)
5. **Steal** security-review methodology from getsentry
6. **Ignore** great_cto post-pivot — no longer relevant for engineering SDLC (steal only pre-pivot ideas: human gates, jurisdiction, spec critics)
7. **Build** `/debug`, `/modify`, `/ui-design`, `/doubt`, `/cloud` skills
8. **Add** Playwright + Chrome DevTools MCP integration to audit pipeline
9. **Phase approach**: Foundation (debug, modify, anti-rationalization) → UI/UX → Cloud/Infra → Quality gates → Integration

---

## Cloud/Infra Skill Domain (NEW SECTION)

### What a `/cloud` Skill Should Cover

```
/cloud — Cloud Infrastructure, Deployment & DevOps

Phase 1: Architecture Design
- Cloud provider selection (AWS/Azure/GCP)
- Service selection (compute, database, storage, networking)
- Multi-region / HA design
- Cost estimation

Phase 2: Infrastructure as Code
- Terraform module patterns (from antonbabenko/terraform-skill)
- CDK patterns (from aws-skills)
- State management
- Environment separation

Phase 3: Containerization
- Dockerfile best practices (multi-stage, security)
- Docker Compose for local dev
- Container registry setup
- Image tagging and versioning

Phase 4: CI/CD Pipeline
- GitHub Actions / GitLab CI generation
- Build → Test → Deploy workflow
- Environment promotion (dev → staging → prod)
- Rollback strategies

Phase 5: Deployment
- Cloud-specific deployment (ECS, EKS, Lambda, App Runner, Cloud Run)
- Docker deployment
- Database migration deployment
- DNS / SSL / CDN setup

Phase 6: Observability
- Logging, metrics, tracing
- Monitoring and alerting
- Cost monitoring and optimization

Anti-rationalization table:
| "Kubernetes is always the answer" | Use the simplest thing that works |
| "Docker in production is enough" | You need orchestration for >1 server |
| "I'll fix security later" | Security in IaC is cheaper at design time |
```

### Existing Resources to Reference
- `antonbabenko/terraform-skill` (2k stars) — Testing, modules, CI/CD, state management, security
- `zxkane/aws-skills` (133 stars) — CDK, cost optimization, serverless
- `dirien/claude-skills` — Pulumi TypeScript patterns
- `derisk-ai/awesome-devops-skills` — 46 DevOps repos catalogued

---

## Gemini Session Exports (Cross-Reference)

Three session exports (`hi-1.json`, `hi-2.json`, `hi-3.json`) contain prior work:

- **hi-1.json** (5870 lines): Security & UI/UX capabilities discussion; user asked if Gherkin ACs enough for UI/UX; specifically mentioned RLS; NFR acceptance criteria gaps
- **hi-2.json** (1956 lines): Surgical code changes discussion; user concerned AI can't make targeted modifications; system feels too linear/waterfall; ideas for `/modify`, `/refactor`, `/patch`
- **hi-3.json** (3261 lines): Debugging tools verification; `/debug` skill referenced in plans but not implemented; 4-phase root cause debugging process; `learnings.jsonl` cross-session learning

These confirm the gaps identified above and validate the priority ordering.
