---
name: audit-security
description: Security audit at depth calibrated to security-tier config. Minimal: 5-minute grep pass. Standard: OWASP Top 10 + STRIDE threat model. Hardened: full OWASP + STRIDE + secrets archaeology. Invoked by /ship. Confidence gate varies by tier.
---

# /audit-security — security audit

Depth calibrated to `security-tier` from project config.

## security-tier: minimal (hackathon)

5-minute grep pass only:

```bash
# SQL injection via string concatenation
grep -r "query.*+.*req\." --include="*.js" --include="*.ts" --include="*.py"

# Hardcoded credentials
grep -r "password\s*=\s*['\"]" --include="*.js" --include="*.ts" --include="*.py" --include="*.go"

# Unescaped innerHTML
grep -r "innerHTML\s*=" --include="*.js" --include="*.ts" --include="*.jsx" --include="*.tsx"

# Missing auth middleware on routes
grep -r "router\.\(get\|post\|put\|delete\)" --include="*.js" --include="*.ts"
```

Confidence gate: only flag findings with >8/10 confidence. At hackathon tier, prefer false negatives over false positives.

## security-tier: standard (mvp/internal)

OWASP Top 10 scan + STRIDE threat model:

**OWASP Top 10 grep scan (scoped to detected stack):**

```bash
# A01 Broken Access Control
grep -r "isAdmin\|hasPermission\|authorize" --include="*.ts" --include="*.js"
# Look for: routes without auth middleware, direct object references without ownership check

# A02 Cryptographic Failures
grep -r "md5\|sha1\|Math.random\(\)" --include="*.ts" --include="*.js"
# Look for: weak hashing, predictable tokens, HTTP (not HTTPS) URLs in config

# A03 Injection
grep -r "exec\|spawn\|eval\|Function(" --include="*.ts" --include="*.js"
# Look for: unsanitized user input in shell commands, dynamic code execution

# A05 Security Misconfiguration
grep -r "debug.*true\|NODE_ENV.*development" --include="*.ts" --include="*.js" --include="*.json"
# Look for: debug mode in production config, verbose error messages

# A07 Auth Failures
grep -r "session\|cookie\|jwt" --include="*.ts" --include="*.js"
# Look for: missing httpOnly, missing secure flag, weak secret
```

**STRIDE threat model** (against arch-components + arch-c4 artifacts):
- **S**poofing: can a user impersonate another user or system component?
- **T**ampering: can a user modify data they shouldn't be able to?
- **R**epudiation: can a user deny performing an action?
- **I**nformation Disclosure: can a user read data they shouldn't?
- **D**enial of Service: can a user make the system unavailable?
- **E**levation of Privilege: can a user gain permissions they shouldn't have?

**Standard hardening checklist:**
- [ ] RLS (Row Level Security) enabled on all user-data tables
- [ ] RBAC enforced at the API layer (not just UI)
- [ ] Refresh token rotation implemented
- [ ] HttpOnly + Secure cookies for session tokens
- [ ] HSTS header set
- [ ] CSP header configured
- [ ] Rate limiting on auth endpoints

Confidence gate: only flag findings with >8/10 confidence.

## security-tier: hardened (production-saas/regulated)

Full OWASP + STRIDE + secrets archaeology:

```bash
# Secrets archaeology — search all git history
git log --all --full-history -- "*.env" "*.key" "*.pem"
git grep -i "password\|secret\|api_key\|token\|private_key" $(git rev-list --all) 2>/dev/null | head -50
```

**Comprehensive hardening checklist** (all standard items plus):
- [ ] SQL injection: parameterized queries everywhere — no string concatenation in queries
- [ ] XSS: output encoding in all template contexts
- [ ] CSRF: double-submit cookie or synchronizer token
- [ ] Dependency audit: `npm audit` / `pip-audit` / `cargo audit` with zero HIGH/CRITICAL
- [ ] Secret manager: no secrets in env vars — all in Vault/AWS Secrets Manager/GCP Secret Manager
- [ ] Audit log: all privileged actions logged with user ID + timestamp + action
- [ ] Data encryption at rest: PII fields encrypted
- [ ] TLS 1.2+ enforced, TLS 1.0/1.1 disabled

Confidence gate: flag at 2/10 — surface everything for human triage. False positives are acceptable at this tier.

## Output format

```markdown
## Security Audit — [YYYY-MM-DD]
Security tier: [minimal/standard/hardened]

### Findings
| Severity | Category | File | Line | Description | Confidence |
|---|---|---|---|---|---|
| HIGH | A03 Injection | src/api/users.ts | 42 | Unsanitized user input in query | 9/10 |

### Hardening checklist
[checklist with PASS/FAIL/NA per item]

### Verdict
[PASS / PASS-WITH-WARNINGS / FAIL]
[On FAIL: list specific items that must be fixed before /ship continues]
```
