---
name: research-compliance
description: Maps codebase structure and architectures to regulatory directives (GDPR, HIPAA, SOC2) and platform gateways (Stripe, App Store Guideline 5.1.1).
---

# /research-compliance — Regulatory & Platform Gate Auditor

This sub-skill verifies that system design and user interfaces adhere to international compliance regulations and platform store policies.

## 1. Compliance Standard Checklists

### GDPR Mapping
* Verify personal data maps document which countries/servers process data.
* Enforce data minimization.
* Decouple PII from transaction state records and link to automated right-to-be-forgotten deletion workflows.

### HIPAA SECURE Configurations
* Enforce Protected Health Information (PHI) storage in encrypted volumes.
* Require multi-factor authentication (MFA).
* Record access requests to an immutable, audit-ready log table.

### SOC 2 safeguarding
* Verify that repositories mandate branch protection, require signed commits, and keep audit trails for deprovisioning.

### EU AI Act Risk Grading
* Check if app utilizes biometric tracking, autonomous scoring, or emotion analysis. Grade as "High Risk" and mandate logging and human-in-the-loop oversight.

## 2. Platform Gate Auditing

### Stripe Apps & Capital Quality Rules
* **Time/Date format:** UI times must use 12-hour layouts with capitalized AM/PM separated by space (e.g., `3:25 PM`). Month abbreviations must use exactly three letters with no trailing period (e.g., `Jan`, `Feb`). Dates with years require a separating comma (`Jan 3, 2021`); month-year only strings must NOT have a comma (`Jan 2021`).
* **ITAR cryptography boundaries:** Custom cryptographic implementations are banned. Require standard, well-vetted libraries (OpenSSL, WebCrypto API).
* **UDAAP marketing checks:** Scan UI/pricing texts against trigger words: `unfair, misleading, bait and switch, deceptive, predatory, discriminate`.

### App Store Guideline 5.1.1 (Apple)
* Forms must NOT require non-essential personal information (such as requiring state or birthdate when not needed for age checks). Non-essential input fields must be marked as optional (e.g. `City (optional)`).
* Biometric sharing: If sharing biometric scans with third-party APIs, verify app gets explicit permission via a custom "Continue" modal.
