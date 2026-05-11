---
name: req-acceptance
description: Produces or refines acceptance criteria in Gherkin Given-When-Then format for user stories. Use when the user asks for "acceptance criteria", "ACs", "Gherkin scenarios", "Given-When-Then", "test conditions", "definition of done", or has user stories without defined done conditions. Producer mode: takes user stories and generates Gherkin scenarios. Refiner mode: takes existing ACs and improves them (imperative → declarative, missing edge cases, ambiguous conditions). Called by the /spec orchestrator after /req-user-stories.
---

# /req-acceptance — Gherkin acceptance criteria

Adds testable Given-When-Then scenarios to user stories. Every story that ships without ACs fails the **T**estable criterion of INVEST — this skill is what closes that gap.

## Two modes
- **Producer mode** — stories exist, no ACs. Generate scenarios from scratch.
- **Refiner mode** — ACs exist but are poor quality (imperative, vague, missing edge cases). Improve them.

## Gherkin rules (the methodology being enforced)

```
Given <initial state / precondition>
When  <event or action>
Then  <expected observable outcome>
```

Extensions: `And` / `But` chain within same clause. `Background:` for shared setup across scenarios. `Scenario Outline:` + `Examples:` table for parameterized variants.

**Declarative over imperative.** Bad: "click Login, type password, click Submit." Good: "When the user submits valid credentials." Imperative ACs break on UI changes; declarative ones survive refactors.

**At least 3 scenarios per story:** happy path, validation failure, and one edge case (empty state, boundary value, unauthorized access). Tier-adjusts: hackathon gets 1, MVP gets 2-3, scaling gets 3-5.

## Procedure

### Step 1 — Mode detection
Existing ACs → refiner mode. Stories only → producer mode.

### Step 2 — Tier check
Per `sdlc-foundation` maturity-tier-detection:
- Hackathon: 1 happy-path scenario per story; no edge cases required
- MVP: 2-3 scenarios for Must-haves; 1 for Should-haves
- Scaling: 3-5 scenarios per story including boundary, auth, error recovery

### Step 3a — Producer mode
For each story:
1. Extract: who is acting, under what precondition, what they do, what the system must show
2. Write happy path: Given [logged-in user / expected state], When [the action], Then [the confirmation]
3. Write failure path: Given [invalid input / missing permission], When [same action], Then [error state]
4. Write edge case: boundary value, concurrent action, or empty state

### Step 3b — Refiner mode
Flag and fix:
- Imperative steps → rewrite declaratively
- Vague Thens ("success message appears") → precise ("a confirmation banner with 'Payment processed' appears")
- Missing Given ("When user submits form" with no Given state) → add precondition
- Missing failure scenarios → add them
- Explain every change briefly so the user learns the pattern

### Step 4 — Output
Per story: story ID + title header, then numbered scenarios. Each scenario labeled (Happy Path / Validation Failure / Edge Case). Recommend next step: `/req-nfr`.

## Anti-patterns flagged
- **"The system validates"** as a When — validation is a Then. The When is the user's action that triggers it.
- **Overlapping scenarios** that test the same thing — merge or differentiate
- **ACs that test implementation** ("API returns 200") — rewrite to test user-visible behavior ("user sees their dashboard")

## Audience adaptation
- Novice: explain Given-When-Then structure first, annotate which scenario covers which quality attribute
- Senior: clean scenarios, no commentary unless a scenario is non-obvious
