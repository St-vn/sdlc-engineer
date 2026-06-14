---
name: audit
description: Main adversarial auditing orchestrator. Chains logic specification verification (audit-spec) and static code red-teaming (audit-code).
---

# /audit — Adversarial Review Orchestrator

This skill acts as the entrypoint for adversarial auditing. It schedules logical requirements checking on design specs and runs AST-based vulnerability scanning on the codebase.

## Required tools

Before running any audit phase, verify deterministic security tools are installed:

```powershell
semgrep --version       # SAST pattern matching (required)
gitleaks --version      # Secret scanning (required)
trivy --version         # CVE scanning (required)

# Or use the verify script
.\skills\tooling\scripts\verify-tools.ps1
```

If any tool is missing, run:
```powershell
.\skills\tooling\scripts\install-tools.ps1 -Categories @("security")
```

Do NOT proceed without these tools — audit gates depend on deterministic tool output.

## 1. Specification Logic Check
* Runs `/audit-spec` against the specification files in `docs/sdlc-engineer/spec/` or `docs/sdlc-engineer/design/`.
* Evaluates using Direct-Indirect Reasoning (DIR).
* Gating: If the logic check fails, it blocks downstream task generation and lists the unhandled system states.

## 2. Code PR Red-Teaming
* Runs `/audit-code` against the git diff/pull request changes.
* Triggers custom Semgrep security rule passes.
* Gating: If a reachable vulnerability is found, it automatically marks the PR check as FAILED.

## 3. Threat Modeling (STRIDE)

Run STRIDE threat modeling on the system's data flow:
1. **Draw the DFD**: identify external entities, processes, data stores, data flows.
2. **Apply STRIDE per element**:
   - Spoofing: who can impersonate?
   - Tampering: who can modify data in transit/at rest?
   - Repudiation: can actions be denied?
   - Information Disclosure: who can read data?
   - Denial of Service: what happens under load?
   - Elevation of Privilege: can auth be bypassed?
3. **Assess risk**: Likelihood × Impact per threat.
4. **Mitigate**: For each valid threat, add a mitigation (input validation, encryption, audit logging, rate limiting, WAF).

Reference: `docs/sdlc-engineer/threat-modeling-methodology.md`

## 4. Static Analysis + Secrets

```bash
# Semgrep (pattern-based SAST)
semgrep --config=auto --error .

# Secret scanning
gitleaks detect --verbose

# Dependency audit
npm audit --audit-level=high
```

Reference: `docs/sdlc-engineer/owasp-standards-reference.md`
Reference: `docs/sdlc-engineer/secrets-management-methodology.md`

## 5. Database Security

- [ ] Verify RLS policies on multi-tenant tables
- [ ] Check for SQL injection in raw queries
- [ ] Verify least-privilege database credentials
- [ ] Check that migrations don't expose sensitive data

Reference: `docs/sdlc-engineer/database-security-rls-methodology.md`

## 6. Compliance Verification

- [ ] GDPR: data deletion flow, consent recording, data inventory
- [ ] SOC2: audit logging, access control, change management
- [ ] HIPAA: PHI encryption, access logs, BAA verification
- [ ] PCI-DSS: card data tokenization, network segmentation

Reference: `docs/sdlc-engineer/compliance-frameworks-reference.md`

## Verification Triage
Reports the combined audit results in `docs/sdlc-engineer/audit-report-YYYY-MM-DD.md`.
* If a failure occurs: Details the logical gaps or reachable vulnerabilities.
* If a pass occurs: Signs off on the specification and diff validity.

## Human Gate

Operations in this skill auto-detect risk level:

- **Low risk** (informational findings, warnings, non-blocking recommendations):
  → Proceed without gate. Report findings on completion.

- **Medium risk** (moderate vulnerabilities, misconfigurations, policy violations):
  → Proceed with gate. Present findings to user. User can approve, deny, or modify scope.
  → Timeout: 5 minutes. On timeout: proceed with documented exceptions.

- **High risk** (critical vulnerabilities, credential exposure, compliance violations):
  → STOP. Present findings with severity, impact, and recommended fix.
  → User must explicitly approve or provide override rationale.
  → Timeout: 10 minutes. On timeout: ABORT. Safe default is to not proceed.

## Anti-rationalization table
| Common Excuse | Why It's Wrong | What to Do Instead |
|---|---|---|
| "I already reviewed the code" | Self-review has blind spots. Audit runs systematic spec contradiction analysis + static analysis. | Run /audit. It catches what you missed. |
| "No vulnerabilities? Must be clean" | Absence of evidence is not evidence of absence. Audit checks what you didn't think to check. | Review the audit report. Pay attention to what was NOT tested. |
| "We'll audit before release" | Post-hoc auditing finds issues that require rewrites. Pre-audit finds issues that are easy to fix. | Audit incrementally. Each task, not just the release. |
