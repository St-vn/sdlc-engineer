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
