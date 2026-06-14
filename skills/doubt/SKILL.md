---
name: doubt
description: Critical self-reflection and assumption attack protocol. Triggers on "doubt", "verify assumptions", "is this correct", "are we sure", "code audit", or when self-checking assertions.
---

# /doubt — Critical assumption attack protocol

A protocol to systematically review code, design decisions, and claims by attempting to prove them false.

## Trigger phrases (auto-invoke from chat)
- "doubt this" / "are we sure"
- "verify assumptions"
- "is this implementation correct"

---

## The Doubt Protocol

### Step 1: CLAIM
*State the belief, claim, or assertion under investigation.*
- Write down what you believe to be true about the code, performance, or behavior.
- *Example:* "This function will handle all date ranges correctly."

### Step 2: EXTRACT
*Show the evidence supporting the claim.*
- Reference specific code snippets, past execution logs, test outcomes, or documentation.
- *Example:* "Tests pass for `2026-06-14` to `2026-06-15`."

### Step 3: DOUBT
*Attack the claim. Attempt to prove the assertion false.*
- Identify edge cases, boundary conditions, hidden assumptions, dependency upgrades, or race conditions.
- Ask: What happens if inputs are empty, null, inverted, formatted differently, or run concurrently?
- *Example:* "What happens if the range crosses daylight saving transitions, or if end date is before start date?"

### Step 4: RECONCILE
*Resolve the discrepancy.*
- If the attack succeeded, implement the fix or defensive checks.
- If the attack failed, document the verification results and explain why the claim holds.

### Step 5: STOP
*Final review.*
- Ensure the fix doesn't introduce side effects and verify that assertions are robustly guarded.

---

## Anti-rationalization table

| Common Excuse | Why It's Wrong | What to Do Instead |
|---|---|---|
| "The tests pass, so the assumptions must be correct." | Tests only verify scenarios developers thought of. Hidden assumptions cause production failures. | Actively look for inputs or conditions not covered by existing tests. |
| "This is standard code, it doesn't need to be doubted." | Standard patterns frequently fail under concurrency, resource exhaustion, or unexpected inputs. | Treat every core path as a candidate for failure. |
| "I don't have time to doubt this." | Debugging production regressions takes vastly more time than verifying assumptions upfront. | Run the 5-step doubt checklist on critical changes. |
