# Changelog

All notable changes to sdlc-engineer are documented here.
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).
Versioning follows [Semantic Versioning](https://semver.org/).

---

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
