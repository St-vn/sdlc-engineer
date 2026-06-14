# sdlc-engineer

A method-based expertise layer for the software development lifecycle. The plugin gives Claude (and through Claude, the user) the engineering judgment, decision frameworks, and methodological discipline that would otherwise require years of experience or a senior engineer in the room.

## What this is for

You bring an idea and a domain. The plugin brings the engineering judgment — and the deterministic tools to make it verifiable.

Covers the full SDLC: eliciting requirements, analyzing feasibility, writing specs, designing architecture, breaking into tasks, implementing with TDD, testing with deterministic tools (Playwright, axe-core, Lighthouse CI, Semgrep, Gitleaks, Trivy), cloud infrastructure orchestration, UI/UX with visual regression + a11y, and deploying with rollback plans. All methodology is backed by CLI tools and MCP servers — no LLM-generated imaginary test results.

## Who it's for

Anyone, but especially:

- **Non-technical founders, PMs, and domain experts** who have an idea but lack the SE background to specify it rigorously. The plugin teaches the methodology as it produces artifacts — INVEST stories, Gherkin acceptance criteria, NFRs with precise metrics, tier-appropriate SRSs — and explains *why* each discipline matters.
- **Senior engineers** who want consistent rigor and want to skip the boilerplate. The educational layer auto-dials down based on jargon density and constraint specificity. Granular sub-commands (`/req-nfr`, `/arch-c4`, etc.) let you produce specific artifacts without walking the full pipeline.

## Core principles

1. **Deterministic, not probabilistic.** Every skill has a Required Tools section. Every verification gate runs a real CLI command or MCP tool — not an LLM imagining what the output might be. If the tool isn't installed, the skill blocks and tells you to run `/tooling install`.
2. **Maturity-tier aware.** A hackathon project gets a 3-page brief, not a 40-page SRS. A scaling startup gets full traceability. Every command consults `maturity-tier-detection.md` before deciding depth.
3. **Anti-pattern detection runs everywhere.** Even when you didn't ask, the plugin flags Distributed Monolith forming, "fast" NFRs with no metric, vague stories missing INVEST. The anti-rationalization tables in every skill challenge the common excuses.
4. **Educational annotations are present-but-skippable.** Methodology discipline is explained for novices, summarized for seniors. The educational layer dials verbosity based on jargon density.
5. **Composable with platform bindings.** Abstract skills (`/ui-design`, `/cloud`, `/audit`) compose with platform-specific bindings (`/platforms/roblox`) that map methodology to concrete tools. Bring your own stack — the framework adapts.

## Slash commands

### Top-level orchestrators (the SDLC workflow)

| Command | Purpose |
| :--- | :--- |
| `/navigator` | **Start here.** Opens the master SDLC blueprint, outlines the lifecycle loop, and details behavioral rules. |
| `/configure` | **Run first.** Captures project intent in ≤8 questions and writes `.sdlc/project.yml`. Gates all downstream skill behavior (security tier, launch tier, research tracks). |
| `/consult` | Open-ended entry point. "I have an idea, where do I start?" Assesses your context (maturity tier, what you have, what you need) and recommends a next step. |
| `/decide` | Focused decision support. "Monolith or microservices?" "Which database?" "REST vs GraphQL?" Brings the framework, not just interrogation. |
| `/elicit` | Captures stakeholder inputs and domain constraints. The disciplined version of "what do we want this thing to do?" |
| `/analyze` | Feasibility, tradeoff evaluation, dependency mapping over elicited inputs. |
| `/research` | Live pre-planning research across three tracks: market validation, technical stack health, and compliance. Never answers from training data — every claim cites a live result. |
| `/spec` | Orchestrator. Chains user stories → acceptance criteria → NFRs → SRS → traceability matrix at tier-appropriate depth. |
| `/design` | Orchestrator. Chains use cases → components → sequence → ADRs → C4 diagrams. |
| `/tasks` | TDD work breakdown structure: from spec+design to dependency-ordered tasks, each with a failing test and RED/GREEN confirmation commands. |
| `/implement` | Orchestrator. Full implementation loop: pre-flight → research → task planning → per-task TDD execution → CI verification. |
| `/debug` | 4-phase root cause debugging. Establish ground truth → isolate → hypothesize → verify. Writes to learnings.jsonl for cross-session memory. |
| `/modify` | Risk-calibrated code changes: Low (docs/config) → Medium (logic/UI with TDD) → High (auth/payments with human gate). |
| `/doubt` | Doubt-driven development protocol: CLAIM → EXTRACT → DOUBT → RECONCILE → STOP. Adversarial self-review. |
| `/ui-design` | 4-phase UI workflow: design system → accessible implementation → automated testing (Playwright/axe/LHCI) → review report. |
| `/cloud` | 6-phase tier-aware infrastructure: architecture → IaC → containers → CI/CD → deploy → observability. |
| `/personas` | 5 specialist agent personas: code-reviewer, test-engineer, security-auditor, ux-designer, performance-engineer. |
| `/tooling` | Deterministic tool management: install, verify, profile-based setup, MCP server config. Stack-to-tools matrix. |
| `/platforms` | Platform derivation framework. Bind abstract skills to concrete tools per platform (Roblox, web, etc.). |
| `/audit` | **Orchestrator.** Adversarial spec and code auditing: logic contradiction → STRIDE threat model → SAST + secrets → DB security → compliance verification. |
| `/pressure-test` | **Orchestrator.** Environmental stress validation: load generation (k6) → local container lifecycle & network degradation (Pumba/Toxiproxy). |
| `/ship` | Orchestrator. Shipping sequence: security audit → QA → monitoring → benchmark → deploy → launch-readiness → doc sync. |

### Granular sub-commands (for power users; also work as refiners)

| Domain | Commands |
| :--- | :--- |
| Research | `/research-market`, `/research-tech`, `/research-compliance` |
| Requirements | `/req-user-stories`, `/req-acceptance`, `/req-nfr`, `/req-srs`, `/req-rtm` |
| Architecture | `/arch-use-cases`, `/arch-components`, `/arch-sequence`, `/arch-adr`, `/arch-c4`, `/arch-decompose`, `/arch-complexity` |
| Auditing | `/audit-spec`, `/audit-code` |
| Reliability | `/pressure-test-load`, `/pressure-test-chaos` |
| Deployment | `/deploy-tier`, `/deploy-cicd`, `/deploy-observability`, `/deploy-secrets-audit`, `/deploy-release-check`, `/deploy-rollback` |
| Platform | `/platforms/roblox` — Roblox-specific bindings for all abstract skills |

Every granular command runs in two modes:
- **Producer mode** — no prior input, generate from scratch.
- **Refiner mode** — prior artifact provided, detect methodology gaps, soft-warn, refine, return improved version with explanation of changes.

---

## Quick Start (Getting Started Guide)

To avoid "vibe coding" and establish procedural discipline, drive the agent using the sequential stages of the Software Development Lifecycle (SDLC):

1. **Initialize**: Run `/configure` to define your stack, security tier, and compliance targets. Generates `.sdlc/project.yml`.
2. **Install tools**: Run `/tooling install` to install deterministic tools matching your stack. Verify with `/tooling verify`.
3. **Research**: Run `/research` (or `/research-market`, `/research-tech`, `/research-compliance` separately) for CVE scans, regulations, competitors.
4. **Specify**: Run `/spec` to generate Gherkin Acceptance Criteria and precise NFRs.
5. **Design**: Run `/design` for C4 diagrams, sequence diagrams, ADRs.
6. **Decompose**: Run `/tasks` for TDD task checklist with RED/GREEN per task.
7. **Implement**: Run `/implement` for TDD loop with auto-debug on test failure.
8. **Debug failing tests**: Run `/debug` (or auto-invoked by implement) for 4-phase root cause analysis.
9. **Modify existing code**: Run `/modify` for risk-calibrated surgical changes.
10. **Doubt your assumptions**: Run `/doubt` for CLAIM→EXTRACT→DOUBT→RECONCILE→STOP adversarial self-review.
11. **Audit**: Run `/audit` for spec contradiction analysis + STRIDE threat model + SAST + DB + compliance.
12. **Pressure Test**: Run `/pressure-test` for k6 load generation under Pumba/Toxiproxy chaos.
13. **Ship**: Run `/ship` for security audit → QA → monitoring → benchmark → deploy → launch-readiness → doc sync.
14. **UI/UX**: Run `/ui-design` for design systems, accessible implementation, automated testing (Playwright/axe/LHCI).
15. **Cloud/Infra**: Run `/cloud` for tier-aware infrastructure, Docker, CI/CD, deploy, observability.
16. **Agent personas**: Run `/personas <name>` for specialist review (code-reviewer, test-engineer, etc.).

> [!TIP]
> If you or the agent ever lose track of the workflow, run `/navigator` to open the interactive cheat sheet and behavioral guidelines.

---


## Installation

Install the skills and commands based on your agent environment:

### Claude Code
Copy the skills, commands, and shared references either to the project root directory or globally:
```bash
# Option A: Project scope
cp -r sdlc-engineer/skills/* .claude/skills/
cp -r sdlc-engineer/commands/* .claude/commands/
cp -r sdlc-engineer/shared .claude/skills/sdlc-engineer-shared

# Option B: User global scope
cp -r sdlc-engineer/skills/* ~/.claude/skills/
cp -r sdlc-engineer/commands/* ~/.claude/commands/
cp -r sdlc-engineer/shared ~/.claude/skills/sdlc-engineer-shared
```

### Codex CLI
1. Clone the repository to your local directory.
2. Link the skills directory to your local configuration:
```bash
codex link --skills ./skills --commands ./commands
```

### OpenCode
For OpenCode environments, add the plugin definition to your `.opencode` config directory:
```bash
cp -r sdlc-engineer/skills/* .opencode/skills/
cp -r sdlc-engineer/commands/* .opencode/commands/
```

### Antigravity IDE
1. Open Settings → Plugins.
2. Choose "Install local plugin" and point to the `sdlc-engineer` root directory, or link the `skills/` directory to the app data workspace:
```powershell
Copy-Item -Recurse -Force .\skills\* C:\Users\<Username>\.gemini\antigravity-ide\mcp\sdlc-engineer\skills\
```

### Claude.ai (Web Interface)
Package each skill folder under `skills/` as a `.skill` file (zip the folder) and upload via **Settings → Skills**. Since `shared/` content is referenced via relative paths, for web installs, inline the contents of the relevant `shared/*.md` files into the `SKILL.md` before packaging, or upload `shared/` as an auxiliary skill.

---

## Repository layout

```
sdlc-engineer/
├── .claude-plugin/plugin.json       ← marketplace manifest (63 skills, 48 commands)
├── .claude/mcp.json                 ← Chrome DevTools MCP + Playwright MCP
├── .claude/settings.json            ← Layer 0 hooks (SessionStart, PreToolUse, Stop)
├── .gitignore
├── docs/sdlc-engineer/              ← 16 methodology reference files + plans
│   ├── ui-ux-*-methodology.md       ← design system, a11y, tokens, testing
│   ├── *-methodology.md             ← debugging, TDD, browser-testing, security, threat-modeling
│   ├── *-best-practices.md          ← IaC, Docker, deployment strategies, CI/CD patterns
│   ├── *-reference.md               ← OWASP, compliance, secrets, RLS, testing-frameworks
│   └── plans/                       ← v1 + v2 plans and tool research
├── skills/                          ← 65 skill directories
│   ├── implement/ design/ spec/     ← orchestrators
│   ├── audit/ pressure-test/ ship/  ← quality gates
│   ├── deploy-*/ req-*/ arch-*/     ← granular skills
│   ├── debug/ modify/ doubt/        ← methodology skills (v2)
│   ├── ui-design/ cloud/            ← domain skills (v2)
│   ├── personas/                    ← agent personas (v2)
│   ├── tooling/                     ← deterministic tool management (v2)
│   │   ├── scripts/                 ← install-tools.ps1, verify-tools.ps1
│   │   └── references/              ← stack-tool-matrix.md, tool-inventory.md
│   └── platforms/                   ← platform derivation (v2)
│       ├── SKILL.md                 ← derivation framework
│       └── roblox/                  ← Roblox Studio MCP + Luau binding
└── skills/sdlc-foundation/          ← internal reference library
```

## Status

**v2.0.0 — deterministic engineering layer.** 63 skills, 48 slash commands. Added `/debug`, `/modify`, `/doubt`, `/ui-design`, `/cloud`, `/personas`, `/tooling`, `/platforms`; deterministic tooling with install/verify/MCP; 27 anti-rationalization tables across all skills; platform derivation framework with Roblox binding; auto-debug in `/implement`; security pipeline (STRIDE + SAST + DB + compliance) in `/audit`; human gates on high-risk operations. See `CHANGELOG.md` for the full list.

Submit to the official marketplace at `platform.claude.com/plugins/submit` after replacing `your-github-username` in `.claude-plugin/plugin.json` and `README.md` with your actual GitHub username.
