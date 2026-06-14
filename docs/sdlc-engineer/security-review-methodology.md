# Security Review Methodology — Best Practices

## Design Principles

1. **Investigation Over Pattern Matching** — Never report based on pattern matching alone. Trace data flows, understand framework protections, and verify exploitability before flagging.
2. **Confidence-Gated Reporting** — HIGH confidence = report; MEDIUM = "needs verification"; LOW = skip. Only report what you've confirmed after codebase-wide research.
3. **Attacker-Controlled vs Server-Controlled** — Distinguish inputs attackers control (request params, headers, body, cookies) from operator-controlled config (settings, env vars, hardcoded constants). The latter are almost never vulnerabilities.
4. **Framework Context Matters** — Auto-escaping (Django `{{ }}`, React `{ }`), ORM parameterization, and framework middleware mitigate whole vulnerability classes. Investigate the framework before flagging.
5. **Concrete Exploitation Before Reporting** — For every finding, confirm you can construct a step-by-step attack path. If you can't build the exploit, don't report the finding.

## When to Apply

- On every code change in a pull request / branch diff
- When reviewing new API endpoints, data flows, or auth logic
- Before any production release
- When onboarding third-party code or dependencies
- During architecture review of new components

## Process

### Phase 1: Full Input Gathering

1. Get the complete diff: `git diff $(gh repo view --json defaultBranchRef --jq '.defaultBranchRef.name')...HEAD`
2. If truncated, read each changed file individually until every changed line is seen
3. List all files modified in this branch before proceeding

### Phase 2: Detect Context & Load References

Identify the code type and load the appropriate reference:

| Code Type | Load These References |
|-----------|----------------------|
| API endpoints, routes | authorization.md, authentication.md, injection.md |
| Frontend, templates | xss.md, csrf.md |
| File handling, uploads | file-security.md |
| Crypto, secrets, tokens | cryptography.md, data-protection.md |
| Data serialization | deserialization.md |
| External requests | ssrf.md |
| Business workflows | business-logic.md |
| GraphQL, REST design | api-security.md |
| Config, headers, CORS | misconfiguration.md |
| CI/CD, dependencies | supply-chain.md |

Based on file extension or imports, load the language guide:

| Indicators | Guide |
|------------|-------|
| .py, django, flask, fastapi | languages/python.md |
| .js, .ts, express, react, vue, next | languages/javascript.md |
| .go, go.mod | languages/go.md |
| .rs, Cargo.toml | languages/rust.md |
| .java, spring, @Controller | languages/java.md |

### Phase 3: Attack Surface Mapping

For each changed file, identify and list:
- All user inputs (request params, headers, body, URL components)
- All database queries
- All authentication/authorization checks
- All session/state operations
- All external calls
- All cryptographic operations

### Phase 4: Research Before Flagging

For each potential issue, trace the full data flow:
1. Where does this value actually come from? (trace backwards)
2. Is it configured at deployment (settings, env vars) or from user input?
3. Is there validation, sanitization, or allowlisting elsewhere upstream?
4. What framework protections apply? (auto-escaping, parameterized queries, CSRF tokens)
5. Is the code path reachable from an unauthenticated request? (if auth required, note it)

**Do NOT report issues based solely on pattern matching.** Investigate first.

### Phase 5: Verify Exploitability

For each potential finding, confirm:

| Attacker-Controlled (Investigate) | Server-Controlled (Usually Safe) |
|-----------------------------------|----------------------------------|
| request.GET, request.POST, request.args | settings.X, app.config['X'] |
| request.json, request.data, request.body | os.environ.get('X') |
| request.headers (most headers) | Hardcoded constants |
| request.cookies (unsigned) | Internal service URLs from config |
| URL path segments: /users/<id>/ | Database content from admin/system |
| File uploads (content and names) | Signed session data |
| Database content from other users | Framework settings |
| WebSocket messages | |

### Phase 6: Security Checklist (check EVERY item for EVERY file)

- [ ] **Injection**: SQL, command, template, header injection — parameterized queries everywhere
- [ ] **XSS**: All outputs in templates properly escaped? No `dangerouslySetInnerHTML` with user data?
- [ ] **Authentication**: Auth checks on all protected operations? Rate limiting on login?
- [ ] **Authorization/IDOR**: Access control verified for object ownership, not just authentication
- [ ] **CSRF**: State-changing operations protected (double-submit cookie or synchronizer token)?
- [ ] **Race conditions**: TOCTOU in any read-then-write patterns?
- [ ] **Session**: Fixation, expiration, secure flags (HttpOnly, Secure, SameSite)?
- [ ] **Cryptography**: Secure random, proper algorithms, no secrets in logs
- [ ] **Information disclosure**: Error messages, stack traces, verbose debug in production
- [ ] **DoS**: Unbounded operations, missing rate limits, resource exhaustion

### Phase 7: Pre-Conclusion Audit

Before finalizing:
1. List every file reviewed and confirm complete coverage
2. List every checklist item with PASS/FAIL per item
3. List any areas you could NOT fully verify and why
4. Only then provide final findings

### Phase 8: Report Findings

Format:
```markdown
## Security Review: [Component Name]

### Summary
- Findings: X (Y Critical, Z High, ...)
- Risk Level: Critical/High/Medium/Low

### Findings

#### [VULN-001] [Type] (Severity)
- Location: `file.py:123`
- Confidence: High
- Issue: [What the vulnerability is]
- Impact: [What an attacker could do]
- Evidence: [Vulnerable code snippet]
- Fix: [How to remediate with actual code]
- References: [OWASP, CWE, CVE links]

### Needs Verification
[MEDIUM confidence items with explanation]

### Areas Not Reviewed
[Endpoints or flows not covered]
```

## Anti-patterns

- **Reporting server-controlled values as vulnerabilities** — e.g., `settings.API_URL` in an SSRF check. These are deployment config, not attacker inputs.
- **Pattern matching without data flow tracing** — `innerHTML = x` is only a DOM XSS if `x` contains user data.
- **Flagging ORM queries as SQL injection** — `User.objects.filter(id=user_input)` is parameterized by default.
- **Flagging framework-escaped templates** — Django `{{ var }}`, React `{var}` auto-escape.
- **Reporting theoretical issues** — If you can't construct a concrete exploit path, don't report it.
- **Flagging test files for production concerns** — Test code has different trust assumptions.
- **Reporting dead/commented code** — Not runtime-reachable.

## Tools with Install Commands

```bash
# Semgrep — static analysis with thousands of security rules
pip install semgrep
semgrep --config=auto .

# Bandit — Python security linter
pip install bandit
bandit -r .

# npm audit — Node.js dependency audit
npm audit

# cargo audit — Rust dependency audit
cargo install cargo-audit
cargo audit

# Trivy — container and filesystem vulnerability scanner
winget install trivy
trivy fs .

# grype — vulnerability scanner for SBOM
winget install grype
grype .

# GitLeaks — secrets scanning in git history
winget install gitleaks
gitleaks detect -v

# Checkov — IaC security scanning
pip install checkov
checkov -d .
```

## Reference Sources

- Sentry Security Review Skill (research → verify → report methodology)
- Sentry Find Bugs Skill (attack surface mapping + checklist)
- Sentry Django Access Review (IDOR methodology with ownership model tracing)
- Sentry GHA Security Review (workflow exploitation + PoC requirement)
- OWASP Cheat Sheet Series (https://cheatsheetseries.owasp.org/)
- OWASP Top 10 (https://owasp.org/Top10/)
- OWASP ASVS (https://github.com/OWASP/ASVS)
