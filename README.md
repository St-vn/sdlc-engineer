# sdlc-engineer

A method-based expertise layer for the software development lifecycle. The plugin gives Claude (and through Claude, the user) the engineering judgment, decision frameworks, and methodological discipline that would otherwise require years of experience or a senior engineer in the room.

## What this is for

You bring an idea and a domain. The plugin brings the engineering judgment.

It handles the **forward-looking, constructive** half of the SDLC — eliciting what you actually want, analyzing feasibility, writing rigorous specs, designing architecture appropriate to your stage, breaking work into tasks, and orchestrating implementation with the right gates. It does *not* do adversarial review or pressure-testing — those are out of scope. Pair this plugin with a review-oriented one (gstack, superpowers, your own) when you want challenge alongside method.

## Who it's for

Anyone, but especially:

- **Non-technical founders, PMs, and domain experts** who have an idea but lack the SE background to specify it rigorously. The plugin teaches the methodology as it produces artifacts — INVEST stories, Gherkin acceptance criteria, NFRs with precise metrics, tier-appropriate SRSs — and explains *why* each discipline matters.
- **Senior engineers** who want consistent rigor and want to skip the boilerplate. The educational layer auto-dials down based on jargon density and constraint specificity. Granular sub-commands (`/req-nfr`, `/arch-c4`, etc.) let you produce specific artifacts without walking the full pipeline.

## Core principles

1. **Method, not review.** Every command produces forward progress. Methodology compliance — INVEST, Gherkin, precise-metric NFRs, SRS semantic+packaging properties — is folded *into* the producers, not bolted on as separate audits. There is no `/audit` command; if you want one, install a review plugin alongside.
2. **Maturity-tier aware.** A hackathon project gets a 3-page brief, not a 40-page SRS. A scaling startup gets a full requirements traceability matrix. Every command consults `shared/maturity-tier-detection.md` before deciding how much rigor is appropriate.
3. **Anti-pattern detection runs everywhere.** Even when you didn't ask, the plugin will flag a Distributed Monolith forming, a "fast" NFR with no metric, a vague user story missing INVEST elements. The catalog (`shared/anti-pattern-catalog.md`) is active diagnostic content, not appendix material.
4. **Educational annotations are present-but-skippable.** When the plugin enforces a discipline, it briefly explains why. For a senior engineer, the verbosity dials down automatically; for a non-technical user, the explanation is the point.
5. **Composable.** This plugin is one method-based piece. It doesn't claim to do review, project management, code generation, or deployment automation — those compose in via other plugins.

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
| `/audit` | **Orchestrator.** Adversarial spec and code auditing sequence: chains logic spec analysis → static code red-teaming checks. |
| `/pressure-test` | **Orchestrator.** Environmental stress validation: load generation (k6) → local container lifecycle & network degradation (Pumba/Toxiproxy). |
| `/ship` | Orchestrator. Shipping sequence after implementation completes: security audit → QA → monitoring → benchmark → deploy → launch-readiness → doc sync. |

### Granular sub-commands (for power users; also work as refiners)

| Domain | Commands |
| :--- | :--- |
| Research | `/research-market`, `/research-tech`, `/research-compliance` |
| Requirements | `/req-user-stories`, `/req-acceptance`, `/req-nfr`, `/req-srs`, `/req-rtm` |
| Architecture | `/arch-use-cases`, `/arch-components`, `/arch-sequence`, `/arch-adr`, `/arch-c4`, `/arch-decompose`, `/arch-complexity` |
| Auditing | `/audit-spec`, `/audit-code` |
| Reliability | `/pressure-test-load`, `/pressure-test-chaos` |
| Deployment | `/deploy-tier`, `/deploy-cicd`, `/deploy-observability`, `/deploy-secrets-audit`, `/deploy-release-check`, `/deploy-rollback` |

Every granular command runs in two modes:
- **Producer mode** — no prior input, generate from scratch.
- **Refiner mode** — prior artifact provided, detect methodology gaps, soft-warn, refine, return improved version with explanation of changes.

---

## Quick Start (Getting Started Guide)

To avoid "vibe coding" and establish procedural discipline, drive the agent using the sequential stages of the Software Development Lifecycle (SDLC):

1. **Initialize**: Run `/configure` to define your stack, security tier, and compliance targets. This generates `.sdlc/project.yml`.
2. **Research**: Run `/research` (or `/research-market`, `/research-tech`, or `/research-compliance` separately) to scan dependencies for CVEs, check regulations, and gather competitor details.
3. **Specify**: Run `/spec` to generate Gherkin (Given-When-Then) Acceptance Criteria and precise Non-Functional Requirements (NFRs).
4. **Design**: Run `/design` to generate system C4 diagrams, sequence diagrams, and ADRs.
5. **Decompose**: Run `/tasks` to generate a failing-test-first TDD task checklist.
6. **Implement**: Run `/implement` to automatically loop through task implementation, context-isolated subagent reviews, and testing.
7. **Audit (Adversarial)**: Run `/audit` to verify specification logic consistency using DIR contradiction proofs and check for codebase vulnerabilities using custom Semgrep patterns.
8. **Pressure Test**: Run `/pressure-test` to stress-test your system using k6 load generators under Pumba and Toxiproxy container/network failures.
9. **Ship & Deploy**: Run `/ship` to run security audits, browser testing, monitor setups, and push code.

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
├── README.md
├── shared/                          ← cross-cutting reference content
│   ├── maturity-tier-detection.md   ← detect hackathon/MVP/scaling, dial rigor
│   ├── anti-pattern-catalog.md      ← active diagnostic content
│   ├── cost-of-defect-model.md      ← 1×→200× repair cost; when to invest in rigor
│   ├── decision-frameworks.md       ← Modular Monolith First, Conway's Law, MoSCoW, etc.
│   └── educational-layer.md         ← verbosity dial, jargon detection, audience modes
├── skills/                          ← one folder per skill, each with SKILL.md
│   ├── configure/                   ← must-run-first project configuration
│   ├── consult/
│   ├── decide/
│   ├── elicit/
│   ├── analyze/
│   ├── research/                    ← live pre-planning research (market/stack/compliance)
│   ├── spec/
│   ├── design/
│   ├── tasks/                       ← TDD work breakdown structure
│   ├── implement/                   ← full implementation orchestrator
│   ├── ship/                        ← shipping orchestrator
│   ├── req-*/                       ← requirements granular skills
│   ├── arch-*/                      ← architecture granular skills
│   └── deploy-*/                    ← deployment granular skills
├── commands/                        ← slash command shortcuts (Claude Code)
│   └── *.md
└── .claude/
    └── settings.json                ← Layer 0 hooks (SessionStart, PreToolUse, Stop)
```

## Status

**v1.1 — active development.** 29 skills and 26 slash commands. Added `/configure`, `/research`, `/ship`; rewrote `/tasks` and `/implement` as full orchestrators; added Layer 0 hooks (`SessionStart`, `PreToolUse`, `Stop`). See `CHANGELOG.md` for the full feature list.

Submit to the official marketplace at `platform.claude.com/plugins/submit` after replacing `your-github-username` in `.claude-plugin/plugin.json` and `README.md` with your actual GitHub username.
