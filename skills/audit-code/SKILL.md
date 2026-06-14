---
name: audit-code
description: Performs static codebase red-teaming, JWT signature verification bypass scanning, and AST pattern matching using Semgrep.
---

# /audit-code — Semantic Vulnerability Code Auditor

This skill runs static security red-teaming against codebase pull requests (PRs) before merging.

## AST-Based Custom Auditing (Semgrep Rules)
* Scan codebase using custom Semgrep yaml rules that map security violations using syntax representations of target code.
* Focus on vulnerabilities that bypass standard CVE checks (such as malicious packages exfiltrating environment variables).

### Example: jwt-simple signature bypass check
```yaml
rules:
  - id: jwt-simple-signature-bypass-audit
    metadata:
      category: security
      cwe: "CWE-347: Improper Verification of Cryptographic Signature"
      severity: ERROR
    languages:
      - javascript
      - typescript
    patterns:
      - pattern-inside: |
          const $JWT = require('jwt-simple');
          ...
      - pattern: $JWT.decode($TOKEN, $SECRET, $ALGORITHM, $NOVERIFY)
      - metavariable-pattern:
          metavariable: $NOVERIFY
          pattern-either:
            - pattern: "true"
            - pattern: '...' # Matches any string literal that disables cryptographic check
```

## Mock Test Embedding
To verify linter accuracy, require the agent to embed mock test cases within target files to assert correctness:
```javascript
// ruleid: jwt-simple-signature-bypass-audit
const bypassedDecoded = jwt.decode(token, secretKey, 'HS256', 'noVerify');

// ok: jwt-simple-signature-bypass-audit
const secureDecoded = jwt.decode(token, secretKey, 'HS256', false);
```

## Validation Gating
* If a vulnerability is flagged, compile AST findings.
* Run targeted dynamic validation scripts to verify if the vulnerability is reachable in the active execution path. If reachable, block the deployment pipeline and generate an automated patch PR.

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
| "No Semgrep findings means no bugs" | Static analysis finds patterns, not logic errors. No findings ≠ correct code. | Review the logic, not just the tool output. |
| "I'll fix the critical findings and ignore the rest" | Warnings are warnings for a reason. They accumulate into technical debt. | Triage every finding. Document why ignored findings are safe. |
| "The code passes review, it's fine" | Code review catches style and obvious bugs. Static analysis catches subtle injection paths. | Run audit-code even after human review. Different coverage. |
