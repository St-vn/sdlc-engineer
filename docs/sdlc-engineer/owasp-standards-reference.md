# OWASP Standards Reference — Best Practices

## Design Principles

1. **The OWASP Top 10 is the starting point, not the finish** — It's an awareness document. For implementation rigor, use ASVS levels which provide verifiable requirements.
2. **ASVS levels calibrate depth** — Level 1 (opportunistic attacks) for all apps; Level 2 (most apps including sensitive data); Level 3 (high-value/regulated).
3. **API security is distinct from web security** — APIs expose endpoints and object identifiers directly, creating a wider attack surface for BOLA and mass assignment.
4. **Preventive controls beat detection** — The OWASP Proactive Controls (parameterized queries, access control, encoding) eliminate vulnerability classes at the source.
5. **Verifiable requirements over guidelines** — ASVS requirements are testable pass/fail statements, not vague recommendations.

## When to Apply

- OWASP Top 10: Every code review and design phase
- ASVS Level 1: All applications (automated scanning + manual verification)
- ASVS Level 2: Applications handling PII, financial data, or healthcare data
- ASVS Level 3: Applications with regulatory compliance mandates (HIPAA, PCI-DSS, SOC 2)
- API Security Top 10: When reviewing or designing REST, GraphQL, or WebSocket APIs

## Process

### Phase 1: OWASP Top 10 Score (Awareness Pass)

Check every category for known vulnerabilities in the codebase:

| ID | Category | What to Check | Verification Command |
|----|----------|---------------|---------------------|
| A01 | Broken Access Control | Routes without auth middleware, IDOR in object lookups, privilege escalation paths | `grep -r "router\.\(get\|post\|put\|delete\)"` + check middleware |
| A02 | Cryptographic Failures | Weak hashes (MD5, SHA1), HTTP URLs, hardcoded keys | `grep -r "md5\|sha1\|Math.random\(\)"` |
| A03 | Injection | Unsanitized input in SQL, commands, templates | `grep -r "exec\|spawn\|eval\|raw("` |
| A04 | Insecure Design | Missing rate limits, lack of threat modeling, unvalidated redirects | Review architecture docs |
| A05 | Security Misconfiguration | Debug mode, CORS wildcards, default creds, verbose errors | `grep -r "debug\|CORS\|Access-Control-Allow-Origin:\s*\*"` |
| A06 | Vulnerable Components | Outdated deps with known CVEs | `npm audit; pip-audit; cargo audit` |
| A07 | Auth Failures | Weak password policies, no MFA, session fixation, JWT none algorithm | `grep -r "jwt\|session\|cookie"` |
| A08 | Integrity Failures | Unsigned updates, untrusted CDN, CI/CD without supply chain security | Review CI/CD config |
| A09 | Logging & Monitoring | Missing audit logs, no alerting on auth failures | Check logging config |
| A10 | SSRF | User-controlled URLs in server-side fetches | `grep -r "requests\.get\|fetch\|axios\.get"` |

### Phase 2: ASVS Level Selection

Determine ASVS target level based on data sensitivity:

| Level | Calibration | Coverage | Target |
|-------|-------------|----------|--------|
| L1 | Automated scans + manual verification | All ASVS V1-V14 baseline | Every application |
| L2 | Full verification including defense-in-depth | All L1 + sensitive data protections | Most apps |
| L3 | In-depth verification, all controls | All L2 + advanced protections | Regulated/High-value |

For an AI agent reviewing code: target ASVS Level 2 by default. Level 3 only when the project config indicates a regulated industry (healthcare, finance, government).

### Phase 3: ASVS Chapter Coverage

Map each ASVS chapter to actionable checks:

| Chapter | Key Requirements to Verify |
|---------|---------------------------|
| V1: Architecture | Security requirements documented, threat model exists, secure design principles applied |
| V2: Authentication | MFA for privileged users, password strength, credential recovery security, rate limiting |
| V3: Session Mgmt | HttpOnly+Secure cookies, session timeout, refresh token rotation |
| V4: Access Control | Principle of least privilege, deny-by-default, object-level authorization |
| V5: Input Validation | Parameterized queries, input sanitization, allowlist validation |
| V6: Cryptography | Modern algorithms only (AES-256, SHA-256+, RSA-2048+), proper key management |
| V7: Error Handling | Generic error messages, no stack traces in production |
| V8: Data Protection | Encryption at rest for sensitive data, TLS for transit, data classification |
| V9: Communications | TLS 1.2+, HSTS, certificate pinning for critical services |
| V10: Malicious Code | No backdoors, no eval with user data, integrity checks |
| V11: Business Logic | Rate limits per user/IP, anti-automation, workflow integrity |
| V12: File Uploads | Size limits, type validation (content-type + magic bytes), virus scanning |
| V13: API | BOLA checks, mass assignment protection, rate limiting, schema validation |
| V14: Configuration | Security config hardened, debug disabled, CORS restricted, CSP set |

### Phase 4: API Security Top 10 Pass

When reviewing APIs (REST/GraphQL), check each API-specific category:

| API# | Category | What to Verify |
|------|----------|---------------|
| API1 | Broken Object Level Auth | Can User A access User B's records by changing IDs? Check every object lookup. |
| API2 | Broken Authentication | Is auth required? Weak token generation? No MFA for sensitive operations? |
| API3 | Broken Object Property Level | Does the API expose more fields than needed (excessive data)? Can user modify fields they shouldn't (mass assignment)? |
| API4 | Unrestricted Resource Consumption | Are there pagination limits? Rate limiting? File size limits? |
| API5 | Broken Function Level Auth | Can regular users access admin endpoints? Check role-based access on each route. |
| API6 | Unrestricted Sensitive Business Flows | Can a script buy all tickets? Post spam comments at scale? |
| API7 | SSRF | Does the API fetch URLs from user input without validation? |
| API8 | Security Misconfiguration | CORS, TLS config, debug endpoints, default API keys |
| API9 | Improper Inventory | Old API versions still running? Unknown endpoints? Missing docs? |
| API10 | Unsafe Consumption of APIs | Does the app trust 3rd-party API responses without validation? |

### Phase 5: OWASP Proactive Controls Implementation

For each proactive control, verify implementation:

| Control | Verification |
|---------|-------------|
| C1: Parameterized Queries | All database queries use placeholders (?, $1, %s with params), not string concatenation |
| C2: Input Validation | Allowlist validation on all user-supplied input (type, length, range, format) |
| C3: Output Encoding | Context-appropriate encoding (HTML entity, URL, JS, CSS) on all user data output |
| C4: Access Control | Enforce at server-side API layer (not just UI), deny by default |
| C5: Cryptography | Use modern crypto libraries, never implement custom crypto |
| C6: Error Handling | Custom error pages, no stack traces, log with context |
| C7: Logging | Audit all auth events, data changes, admin actions with user ID + timestamp |
| C8: Data Protection | Classify data, encrypt PII at rest and in transit, minimize data collection |
| C9: Communication Security | TLS everywhere, HSTS, secure ciphers |
| C10: Database Security | Least privilege database accounts, RLS policies, encrypted connections |

## Anti-patterns

- **Treating OWASP Top 10 as a pass/fail checklist** — It's an awareness document, not a verification standard. Use ASVS for pass/fail.
- **ASVS Level 1 only** — Level 1 covers only automated scanning. Without Level 2 (manual verification), authorization and business logic flaws are missed.
- **API security treated same as web security** — API attacks are different: BOLA, mass assignment, and property-level flaws are API-specific.
- **No threat model for design decisions** — The Top 10 and ASVS are verification tools, not design tools. Threat modeling happens first.
- **Checking ASVS once at release** — ASVS should be integrated into CI/CD and checked on every change.
- **Relying on input validation alone** — Injection prevention requires context-aware output encoding AND parameterized queries, not just input validation.

## Tools with Install Commands

```bash
# OWASP ZAP — full-featured DAST scanner
winget install zap
# or: docker run -it ghcr.io/zaproxy/zaproxy

# OWASP Dependency-Check — SCA for known vulnerabilities
pip install dependency-check
dependency-check --scan .

# OWASP Threat Dragon — threat modeling tool
npm install -g threat-dragon
# or use the web version at threatdragon.org

# OWASP ASVS requirements in CSV/JSON format
# Download: https://github.com/OWASP/ASVS/tree/v5.0.0/5.0/docs_en

# OWASP Cheat Sheet Series (offline)
git clone https://github.com/OWASP/CheatSheetSeries.git

# Checkov — verify IaC against ASVS-inspired rules
pip install checkov

# OWASP ZAP API scan
docker run -t owasp/zap2docker-weekly zap-api-scan.py \
  -t https://example.com/openapi.json -f openapi
```
