---
name: research-tech
description: Programmatic dependency auditing, CVE lookups, SPDX license scans, and Semgrep reachability analysis.
---

# /research-tech — Technical Dependency & CVE Audit

This sub-skill scans libraries and dependencies to ensure they are secure, compliant with licensing rules, and technically healthy.

## Privacy-Preserving Auditing Rules
* Banned: Uploading the complete project lockfile to external servers (npm audit leaks underlying databases, payment systems, and internal package relationships).
* Preferred: Execute isolated REST queries against the OSV API per package (e.g. `pip-audit` pattern) to keep internal architectures obscured.

## Local Dependency and License Audit Commands

### Python (PyPI)
* **CVE check:** `pip-audit -r requirements.txt --format json` (evaluates packages individually against OSV API).
* **License check:** `pip-licenses --format=json --from=all` (extracts setup metadata and Trove classifiers).

### Node.js (NPM)
* **CVE check:** `npm audit --json` (run locally; pipes stdout to `report.json`).
* **License check:** `npx @onebeyond/license-checker scan --allowOnly "MIT OR Apache-2.0" --ignoreRootPackageLicense` (validates all dependencies against SPDX expressions, avoiding failure on root repository).

## Reachability Verification
* If standard checkers flag a CVE, execute **Semgrep Supply Chain** queries.
* Parse the codebase's Abstract Syntax Tree (AST) to verify if the vulnerable package version and execution pattern are actually reachable and imported in active execution paths.
* Flag un-reachable vulns as warnings; block build only if reachable.
