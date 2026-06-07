---
name: audit-spec
description: Runs requirements logical contradiction analysis, unhandled state detection, and compliance violations using Direct-Indirect Reasoning (DIR).
---

# /audit-spec — Specification Logic Auditor

This skill executes formal logical validation of specification documents (`SPEC.md` or `SRS.md`) to catch contradictions, gaps, and policy violations *before* any code is generated.

## Execution Method: Direct-Indirect Reasoning (DIR)
Instead of simply asking Claude if the document "looks correct", apply proof by contradiction and contrapositive logic:
1. Identify each key specification claim, interface boundary, and architectural fact.
2. For each claim $C$, assume its negation ($\neg C$) is the true running state of the system.
3. Combine $\neg C$ with the surrounding facts, database schemas, and platform constraints.
4. Try to derive a valid system execution path.
5. If a path is derived without error, **a logical gap or unhandled edge case is identified.**
6. If a path triggers a clear system error or design conflict, **the requirement $C$ is logically validated.**

## Audit Prompts & Rubrics
* **Scoring Rubric:** Scale is binary (Pass/Fail) or 3-point (Fail, Partial-Pass, Pass). Any single contradiction triggers an automatic Fail.
* **Domain-Specific Criteria:** Banned vague scoring. Look specifically for:
  * `CONTRADICTION:MUTUAL_EXCLUSION`: State transitions that cannot co-exist.
  * `GAP:UNHANDLED_EXCEPTION`: Missing error or rollback paths for external API calls, rate limits, or db timeouts.
  * `VIOLATION:PLATFORM_GATE`: Structural violations of App Store Guideline 5.1.1 or Stripe UDAAP guidelines.

## Output Format
Write a JSON payload containing the scorecard:
```json
{
  "audit_passed": false,
  "enumerated_constraints": ["Rule 1", "Rule 2"],
  "contradictions": [
    { "type": "MUTUAL_EXCLUSION", "details": "State A and B overlap." }
  ],
  "structural_gaps": [
    { "location": "payment_flow", "unhandled_condition": "Stripe webhook failure rollback" }
  ],
  "score": 0
}
```
If the specification passes validation, save it as verified. If it fails, report gaps to the developer and block code implementation.
