# Changelog

All notable changes to sdlc-engineer are documented here.
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).
Versioning follows [Semantic Versioning](https://semver.org/).

---

## [2.0.0] — 2026-06-14

### Added

**Deterministic methodology skills**
- `/debug` — 4-phase root cause debugging with anti-rationalization table and cross-session learnings.jsonl memory
- `/modify` — risk-calibrated file modification workflow (Low/Medium/High with TDD for Medium+)
- `/doubt` — doubt-driven development protocol (CLAIM → EXTRACT → DOUBT → RECONCILE → STOP)

**Anti-rationalization tables** — 27 custom tables across every existing skill, domain-tailored with specific rebuttals

**UI/UX Design**
- `/ui-design` — 4-phase workflow (Design System Generation → Implementation with a11y → Automated Testing via Playwright/axe/LHCI → Review Report)
- 4 reference files: design system, accessibility, design tokens, testing patterns
- 2 scripts: visual-regression.ps1, a11y-audit.ps1

**Cloud Infrastructure**
- `/cloud` — 6-phase tier-aware orchestration (Architecture → IaC → Containerization → CI/CD → Deployment → Observability)
- 3 reference files: IaC patterns, Docker patterns, deployment strategies

**Specialist Agent Personas**
- `/personas` — 5 specialist personas with yaml constraints: code-reviewer, test-engineer, security-auditor, ux-designer, performance-engineer

**Deterministic Tooling Layer**
- `/tooling` — install, verify, profile-based install from project.yml, MCP management
- `.claude/mcp.json` — Chrome DevTools MCP + Playwright MCP servers
- `stack-tool-matrix.md` — comprehensive stack-to-tools dependency map covering 6 categories across all major stacks
- Pre-flight tool checks in all 5 new skills (block if tool missing)

**Platform Derivation Framework**
- `/platforms` — framework for mapping abstract skills to platform-specific tools
- `platforms/roblox` — full Roblox binding: maps all 5 abstract skills to Roblox Studio MCP + Luau (zero CLI tools, 100% MCP-driven)

**Integration Enhancements**
- Auto-debug on test/build/runtime failure in `/implement`
- Security pipeline (STRIDE threat modeling + SAST + DB + compliance) in `/audit`
- Human gates on 4 high-risk skills (audit, audit-code, audit-spec, deploy-secrets-audit)

**16 Methodology Reference Files** — covering UI/UX (4), cloud/infra (4), testing/debugging (4), security/compliance (4)

**Plugin manifest updated** — v2.0.0 with 63 skills and 48 slash commands; new keywords for marketplace discoverability

### Changed
- `skills/audit/SKILL.md` — expanded from 2 phases to 6 phases (added STRIDE, SAST, secrets, database, compliance)
- `skills/implement/SKILL.md` — added Failure Handling protocol with auto-debug invocation
- `skills/debug/SKILL.md` — Phase 0→"Establish Ground Truth", added anti-rationalization table, reference links to methodology files
- `skills/configure/SKILL.md` — added stack-to-tools mapping, required-tools field in project.yml output

## [1.0.0] — 2026-05-11

### Added

**Plugin infrastructure**
- `.claude-plugin/plugin.json` — marketplace manifest
- `skills/sdlc-foundation/` — internal reference library (maturity-tier-detection, anti-pattern-catalog, cost-of-defect-model, decision-frameworks, educational-layer)
- MIT license

**Top-level orchestrators**
- `/consult` — open-ended entry point; assesses context, tier, and anti-patterns; recommends next step
- `/decide` — focused decision support for architectural/stack choices
- `/elicit` — structured stakeholder input capture
- `/analyze` — feasibility and tradeoff analysis over elicited inputs
- `/spec` — requirements orchestrator (chains user-stories → acceptance → NFRs → SRS → RTM)
- `/design` — architecture orchestrator (chains use-cases → components → sequence → ADRs → C4)
- `/tasks` — work breakdown structure
- `/implement` — deployment orchestrator (chains CI/CD → observability → gating)

**Requirements granular skills**
- `/req-user-stories` — INVEST-compliant stories; producer + refiner mode
- `/req-acceptance` — Gherkin Given-When-Then acceptance criteria
- `/req-nfr` — NFRs with precise metrics across 8-category taxonomy
- `/req-srs` — formal Software Requirements Specification assembly
- `/req-rtm` — Requirements Traceability Matrix (forward + backward)

**Architecture granular skills**
- `/arch-use-cases` — UML use case diagram
- `/arch-components` — component decomposition diagram
- `/arch-sequence` — sequence diagram for critical flows
- `/arch-adr` — Architecture Decision Record
- `/arch-c4` — C4 model levels 1-3 (Mermaid output)
- `/arch-decompose` — Strangler Fig migration plan with vFunction analysis
- `/arch-complexity` — cyclomatic + cognitive + CK Suite metrics audit

**Deployment granular skills**
- `/deploy-tier` — maturity tier assessment; sets gating calibration for all other deploy skills
- `/deploy-cicd` — CI/CD pipeline definition (all 6 phases)
- `/deploy-observability` — LGTM stack + OpenTelemetry plan (metrics/logs/traces)
- `/deploy-secrets-audit` — credential exposure scan and extraction plan
- `/deploy-release-check` — pre-release verification gates (tier-calibrated)
- `/deploy-rollback` — rollback strategy with auto-trigger conditions

**Cross-cutting features**
- Maturity-tier awareness: hackathon/MVP/scaling tiers dial rigor depth on every command
- Anti-pattern detection: fires opportunistically across all commands
- Educational layer: auto-detects audience (novice/default/senior) and dials verbosity
- Producer + refiner mode: every granular skill accepts existing artifacts and refines them to meet methodology standards
- Methodology folded into production: compliance enforcement embedded in artifact generation, not as separate audit commands
