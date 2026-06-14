---
name: modify
description: Risk-calibrated file and code modification workflow. Triggers on "modify", "change", "refactor", "update file", "edit code", or when requested to make modifications.
---

# /modify — Risk-calibrated modification workflow

A structured, risk-calibrated process for introducing changes to the codebase.

## Trigger phrases (auto-invoke from chat)
- "modify X" / "change X"
- "refactor X" / "update Y"
- "edit code" / "apply patch"

## Pre-flight
Before making any edits, analyze the proposed modifications:
1. **Change Scope:** Identify what logic or functionality is being added, changed, or removed.
2. **Git Status Check:** Ensure the workspace is clean or understand existing uncommitted changes.
3. **Affected Files:** Map files to edit and trace their importers/dependents to evaluate downstream impacts.
4. **Risk Level:** Classify the risk category: Low, Medium, or High.

---

## Risk-Calibrated Workflow

### 1. Low Risk (Documentation, Comments, Config Files)
*Scope: Markdown files, documentation, configuration tweaks, localized comments.*
- **Step 1:** Perform the change in the target files.
- **Step 2:** Validate the configuration schema or render target format if applicable.
- **Step 3:** Run basic project validation tests (if configured).
- **Step 4:** Commit/save changes.

### 2. Medium Risk (Local Business Logic, UI Elements, Styles)
*Scope: CSS rules, UI components, normal endpoints, utility functions.*
- **Step 1:** Understand existing logic and dependencies.
- **Step 2:** Write a failing test matching the new expected behavior (TDD).
- **Step 3:** Implement the code changes.
- **Step 4:** Verify that the new test passes (GREEN).
- **Step 5:** Run the full test suite to check for regressions.
- **Step 6:** Commit/save changes.

### 3. High Risk (Auth, Payments, Core Database Schema, Secrets)
*Scope: Authentication middleware, payment processing systems, data migrations, critical infrastructure files.*
- **Step 1:** Document the change rationale and potential failure scenarios.
- **Step 2:** Write comprehensive automated test coverage (including negative cases).
- **Step 3:** Design a rollback or backup plan.
- **Step 4:** Implement changes.
- **Step 5:** Perform verification, run security/vulnerability scanners, and perform manual testing.
- **Step 6:** Pause for human verification gate before finalizing.

---

## Anti-rationalization table

| Common Excuse | Why It's Wrong | What to Do Instead |
|---|---|---|
| "This is just a tiny code change, I don't need to write a test." | Tiny changes to logic often break edge cases or violate invariants that tests protect. | Always write a test for logical changes (Medium/High risk). |
| "I'll edit the code first and then see how to test it." | Testing retroactively leads to writing tests that match the implementation instead of requirements. | Write the failing test first to clarify boundaries. |
| "It's just security middleware, I can test it manually." | Manual security checks are non-verifiable and easily slip in subsequent modifications. | Write automated unit and integration checks for authorization/middleware changes. |
