# Compliance Frameworks Reference — Best Practices

## Design Principles

1. **Compliance is a floor, not a ceiling** — Meeting regulatory minimums doesn't mean the system is secure. Use compliance frameworks as the starting point for security design.
2. **Map requirements to actionable controls** — Each compliance requirement must translate to specific technical controls (code, config, process) that can be verified.
3. **Data classification drives everything** — Before applying any framework, classify data assets (public, internal, sensitive, regulated) — this determines compliance scope.
4. **Prove it or it didn't happen** — All compliance frameworks require evidence. Design systems that produce audit trails by default, not as an afterthought.
5. **Tier your compliance effort** — Hackathon: no formal compliance. MVP: SOC 2 Type I readiness. Scaling: full compliance portfolio based on data types handled.

## When to Apply

- SOC 2: Any SaaS handling customer data (most software companies)
- GDPR: Any system with users in the EU/EEA (regardless of company location)
- HIPAA: Any system handling Protected Health Information (PHI)
- PCI-DSS: Any system storing, processing, or transmitting cardholder data
- SAMM: When building or evaluating an application security program
- NIST CSF: When establishing enterprise cybersecurity risk management

## Process

### Phase 1: Determine Applicable Frameworks

Based on data types and business context:

| If your system handles... | Apply these frameworks |
|--------------------------|----------------------|
| Customer data (any) | SOC 2 |
| EU resident data | GDPR |
| Health information | HIPAA + SOC 2 |
| Payment cards | PCI-DSS + SOC 2 |
| Government systems | NIST CSF + FedRAMP |
| No regulated data | SAMM (program improvement) |

### Phase 2: SOC 2 Trust Services Criteria

The five trust service criteria with technical controls:

| Category | What It Means | Technical Controls to Verify |
|----------|---------------|------------------------------|
| **Security** | Protected against unauthorized access | AuthN/AuthZ, encryption, WAF, IDS/IPS, patch management |
| **Availability** | Available for operation and use | Redundancy, failover, monitoring, incident response, SLA tracking |
| **Processing Integrity** | Processing is complete, valid, accurate | Input validation, transaction logging, reconciliation, error handling |
| **Confidentiality** | Confidential information is protected | Encryption at rest + in transit, access controls, data classification, masking |
| **Privacy** | PII collected/used/retained/disposed according to commitments | Consent management, data minimization, retention policies, deletion capabilities |

**SOC 2 verification commands:**
```bash
# Verify encryption at rest (check for TDE, EBS encryption, RDS encryption)
# Verify TLS everywhere
curl -sI https://api.example.com | findstr "Strict-Transport-Security"

# Verify access logging
grep -r "audit\|logger.info\|console.log" --include="*.py" --include="*.js"
# Check: are auth events, data mutations, and admin actions logged?

# Verify backup/DR
# Check backup scripts, RTO/RPO documentation, restore tests
```

### Phase 3: GDPR Key Articles

| Article | Requirement | Technical Control |
|---------|-------------|-------------------|
| Art. 5 | Principles: lawfulness, fairness, transparency, purpose limitation, data minimization, accuracy, storage limitation, integrity, accountability | Document data flows, maintain records of processing activities |
| Art. 17 | Right to erasure ("Right to be forgotten") | `DELETE /api/users/{id}` that cascades to all user data; verify no residual data |
| Art. 25 | Data protection by design and default | Privacy impact assessment (PIA) before feature development; minimize data collection |
| Art. 32 | Security of processing | Encryption, pseudonymization, access controls, incident response plan, regular testing |
| Art. 33 | Breach notification to supervisory authority within 72 hours | Monitoring + alerting + on-call rotation + incident response playbook |

**GDPR verification commands:**
```bash
# Check for data deletion implementation
grep -r "delete\|anonymize\|purge\|erase\|gdpr" --include="*.py" --include="*.js"

# Check for cookie consent
grep -r "cookie\|consent\|opt-in\|opt-out" --include="*.js" --include="*.html"

# Check for data minimization
grep -r "SELECT \*\|\.all\(\)" --include="*.py"
# Flag: SELECT * queries that may return more data than needed
```

### Phase 4: HIPAA Privacy Rule, Security Rule, Breach Notification

| Rule | Requirement | Technical Control |
|------|-------------|-------------------|
| Privacy Rule | Use/disclosure of PHI limited to minimum necessary | Access controls on PHI, role-based access, audit trails |
| Security Rule - Administrative | Risk analysis, training, contingency plan | Documented risk assessment, security awareness program, DR plan |
| Security Rule - Physical | Facility access, workstation security | MFA, device encryption, access badges |
| Security Rule - Technical | Access control, audit controls, integrity, transmission security | Unique user IDs, automatic logoff, encryption, integrity controls |
| Breach Notification | Notification to affected individuals + HHS + media | Incident detection, notification procedures, documentation |

**HIPAA technical verification:**
```bash
# Check for PHI logging (should NOT log PHI or should be encrypted)
grep -r "log\|print\|console" --include="*.py" --include="*.js"
# Check: do logs contain patient identifiers, SSNs, medical data?

# Check for unique user identification
grep -r "login\|authenticate\|signin" --include="*.py" --include="*.js"
# Check: is there individual user accountability or shared accounts?

# Check for automatic logoff
grep -r "timeout\|expire\|session.*max\|inactivity" --include="*.py" --include="*.js"
```

### Phase 5: PCI-DSS 12 Requirements

| # | Requirement | Technical Control | Verification |
|---|-------------|-------------------|--------------|
| 1 | Install firewalls | Network segmentation, firewall rules | `nmap -sn` for unauthorized open ports |
| 2 | Change vendor defaults | Change default passwords, disable unnecessary services | Review server config, container images |
| 3 | Protect stored cardholder data | Encryption, truncation, hashing, tokenization | Check DB schema: PAN must be encrypted or tokenized |
| 4 | Encrypt transmission | TLS 1.2+ for all cardholder data in transit | `curl -vI` — verify TLS version and cipher |
| 5 | Protect against malware | Anti-malware, vulnerability scanning | Run antivirus, trivy scans |
| 6 | Secure systems | Patching, secure coding, code review | `npm audit`, `pip-audit`, dependency scan |
| 7 | Restrict access by need-to-know | Least privilege, RBAC, access reviews | Audit IAM roles, database users |
| 8 | Identify and authenticate | Unique IDs, MFA, strong passwords | Review auth implementation |
| 9 | Restrict physical access | Physical security controls | N/A for digital; check cloud DC certifications |
| 10 | Track and monitor | Audit trails, log monitoring | Centralized logging (SIEM, ELK), log retention ≥ 12 months |
| 11 | Test security | Quarterly scans, annual penetration tests | Run SAST/DAST, schedule pen test |
| 12 | Information security policy | Policy, risk assessment, training | Document security policies |

### Phase 6: OWASP SAMM (Software Assurance Maturity Model)

SAMM measures maturity across 5 business functions with 3 practices each:

| Business Function | Practice | Stream A (Governance) | Stream B (Technical) |
|-------------------|----------|----------------------|----------------------|
| **Governance** | Strategy & Metrics | Security policy, metrics program | Compliance audits, risk classification |
| **Governance** | Policy & Compliance | Security requirements, compliance verification | Policy automation, enforcement |
| **Governance** | Education & Guidance | Security training, role-based curriculum | Secure coding standards, security champions |
| **Design** | Threat Assessment | Threat modeling, attack surface analysis | Architecture analysis, design review |
| **Design** | Security Requirements | Requirements definition, risk-driven | Requirements verification, traceability |
| **Design** | Secure Architecture | Architecture validation, reference architecture | Technology standards, design patterns |
| **Implementation** | Secure Build | Build process security, dependency management | Build integrity, signing |
| **Implementation** | Secure Deployment | Deployment process, environment hardening | Configuration management, secrets mgmt |
| **Implementation** | Defect Management | Bug tracking, severity classification | Root cause analysis, fix review |
| **Verification** | Architecture Assessment | Architecture review, design review | Automated assessment, pen testing |
| **Verification** | Requirements-Driven Testing | Security test cases, regression testing | Automated security tests, fuzzing |
| **Verification** | Security Testing | SAST integration, DAST scanning | Dynamic testing, IAST, RASP |
| **Operations** | Incident Management | Incident response plan, detection | Response execution, forensics |
| **Operations** | Environment Management | Environment hardening, patching | Monitoring, configuration drift |
| **Operations** | Operational Management | Data protection, backup/restore | Secrets rotation, access reviews |

**SAMM assessment command:**
```bash
# SAMM self-assessment spreadsheet
# Download: https://github.com/owaspsamm/core/releases/download/v2.0.3/SAMM_spreadsheet.xlsx

# Quick maturity audit:
# For each practice, score 0-3 (0=none, 1=ad-hoc, 2=standardized, 3=optimized)
# Current gap: practices scored < 2 need attention
```

### Phase 7: NIST Cybersecurity Framework (CSF 2.0)

The six functions with categories:

| Function | Categories | Verification |
|----------|------------|-------------|
| **Govern (GV)** | Context, Risk Strategy, Roles, Policy, Oversight, Supply Chain | Security policies documented, risk register exists |
| **Identify (ID)** | Asset Management, Risk Assessment, Improvement | Asset inventory, data classification, risk register |
| **Protect (PR)** | Identity Management, Awareness, Data Security, Platform Security, Technology Infrastructure | MFA, training, encryption, patching, backups |
| **Detect (DE)** | Continuous Monitoring, Adverse Event Analysis | SIEM, logging, anomaly detection |
| **Respond (RS)** | Incident Management, Analysis, Communications, Mitigation | Incident response plan, playbooks, communication templates |
| **Recover (RC)** | Incident Recovery, Communications | DR plan, backups, RTO/RPO defined, restore testing |

**NIST CSF quick audit:**
```bash
# Check: do we know what's running?
# Asset inventory - review config management, cloud resource lists

# Check: can we detect incidents?
# SIEM/config - verify centralized logging

# Check: can we recover?
# Backup scripts exist? Restore tested? RTO/RPO documented?
```

## Anti-patterns

- **Audit first, fix later** — Compliance findings that aren't tracked and remediated are wasted effort. Run compliance checks in CI.
- **Treating compliance as a checkbox** — SOC 2 Type II (operating effectively for 6+ months) requires sustained compliance, not a point-in-time snapshot.
- **Storing more data than needed** — The most regulated data is data you don't have. Data minimization is the cheapest compliance strategy.
- **Ignoring supply chain compliance** — Your compliance posture includes your vendors. Third-party risk assessment is required by SOC 2, HIPAA, PCI-DSS.
- **Manual evidence collection** — Compliance evidence should be automated. Tests produce evidence logs; don't compile screenshots manually.
- **Separating compliance from security** — Compliance controls ARE security controls. Build once, satisfy multiple frameworks.

## Tools with Install Commands

```bash
# OpenSCAP — NIST-certified security compliance scanning
winget install openscap
oscap xccdf eval --profile xccdf_org.ssgproject.content_profile_cis \
  --results results.xml /usr/share/xml/scap/ssg/ssg-almalinux8-xccdf.xml

# InSpec — compliance as code (Chef)
gem install inspec
inspec exec https://github.com/dev-sec/linux-baseline

# Checkov — IaC compliance scanning
pip install checkov
checkov -d . --framework terraform,cloudformation,kubernetes

# OWASP SAMM spreadsheet
# Download: https://github.com/owaspsamm/core/releases/download/v2.0.3/SAMM_spreadsheet.xlsx

# GDPR checklist generator
# Use OWASP Top 10 Privacy Risks project

# Compliance Buddy — NIST CSF + SOC 2 automation
# Use the CSF 2.0 Tool: https://csrc.nist.gov/Projects/cybersecurity-framework/Filters#/csf/filters
```
