---
name: audit
description: Main adversarial auditing orchestrator. Chains logic specification verification (audit-spec) and static code red-teaming (audit-code).
---

# /audit — Adversarial Review Orchestrator

This skill acts as the entrypoint for adversarial auditing. It schedules logical requirements checking on design specs and runs AST-based vulnerability scanning on the codebase.

## 1. Specification Logic Check
* Runs `/audit-spec` against the specification files in `docs/sdlc-engineer/spec/` or `docs/sdlc-engineer/design/`.
* Evaluates using Direct-Indirect Reasoning (DIR).
* Gating: If the logic check fails, it blocks downstream task generation and lists the unhandled system states.

## 2. Code PR Red-Teaming
* Runs `/audit-code` against the git diff/pull request changes.
* Triggers custom Semgrep security rule passes.
* Gating: If a reachable vulnerability is found, it automatically marks the PR check as FAILED.

## Verification Triage
Reports the combined audit results in `docs/sdlc-engineer/audit-report-YYYY-MM-DD.md`.
* If a failure occurs: Details the logical gaps or reachable vulnerabilities.
* If a pass occurs: Signs off on the specification and diff validity.

## Anti-rationalization table
| Common Excuse | Why It's Wrong | What to Do Instead |
|---|---|---|
| "I already reviewed the code" | Self-review has blind spots. Audit runs systematic spec contradiction analysis + static analysis. | Run /audit. It catches what you missed. |
| "No vulnerabilities? Must be clean" | Absence of evidence is not evidence of absence. Audit checks what you didn't think to check. | Review the audit report. Pay attention to what was NOT tested. |
| "We'll audit before release" | Post-hoc auditing finds issues that require rewrites. Pre-audit finds issues that are easy to fix. | Audit incrementally. Each task, not just the release. |
