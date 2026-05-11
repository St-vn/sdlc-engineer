---
name: req-user-stories
description: Produces or refines user stories that satisfy INVEST criteria (Independent, Negotiable, Valuable, Estimable, Small, Testable). Use when the user asks for "user stories", "stories for [feature/project]", "convert these requirements/notes/specs into stories", "write the backlog", "what should the stories be for X", or pastes raw notes/briefs/feature lists and wants them structured. Also use when the user has existing stories and wants them improved, validated, or expanded — the skill automatically detects existing input and switches from producer mode to refiner mode. Stays focused on the stories themselves; doesn't drift into acceptance criteria (that's req-acceptance), NFRs (req-nfr), or full SRS assembly (req-srs).
---

# /req-user-stories — INVEST user stories

Produces user stories from raw input (idea, brief, feature list) or refines existing user stories to meet INVEST criteria. Does *only* user stories — does not produce acceptance criteria, NFRs, or downstream artifacts. Other skills handle those.

## Two modes

### Producer mode

User has raw input — an idea, a brief, a feature list, a stakeholder interview transcript, etc. Skill produces a fresh set of user stories.

### Refiner mode

User has existing user stories of variable quality. Skill audits each against INVEST, identifies which letters fail, and produces a refined version with changes explained.

The skill auto-detects mode from the input. If existing stories are present, refiner mode runs first; new stories suggested by the conversation get produced afterward.

## INVEST criteria (the methodology being enforced)

A user story should satisfy six criteria. See `sdlc-foundation/decision-frameworks.md` for the full definition; in brief:

- **I — Independent.** Can be developed and delivered without depending on another story being done first.
- **N — Negotiable.** A starting point for conversation, not a fixed contract.
- **V — Valuable.** Delivers user-visible (or business-visible) value.
- **E — Estimable.** Small and clear enough that the team can size it.
- **S — Small.** Fits in a single sprint comfortably.
- **T — Testable.** Has acceptance criteria you can verify objectively (full ACs come from `/req-acceptance` — for INVEST testability, even one-line testability statement is enough at this stage).

## Story format

Default to the standard format:

```
US-NNN — <short title>
As a <role>,
I want <capability>,
so that <outcome>.

INVEST notes: <one-line summary of how it satisfies each criterion, only mention failures if any>
```

The role-capability-outcome format forces *value* (the "so that" clause) and *user perspective* (the "as a" role) into every story. Stories that struggle to fit this format are usually missing one of those.

## Procedure

### Step 1 — Mode detection

- Existing stories in input → refiner mode (run audit first)
- Raw input only → producer mode
- Mix → refiner on existing + producer on the new ideas

### Step 2 — Tier check

Consult `sdlc-foundation/maturity-tier-detection.md`. Story rigor scales with tier:

| Tier | Story rigor |
| :--- | :--- |
| Hackathon | 3-5 stories, plain English bullets, no INVEST audit; the format is overkill |
| MVP | INVEST-compliant for Must-haves; loose for Should-haves; numbered IDs |
| Scaling | Full INVEST for all; numbered IDs; trace-ready (each story is uniquely referenceable) |

### Step 3a — Refiner mode procedure

For each existing story:

1. **INVEST audit.** Score each letter:
   - **Independent** — Does it depend on another story? If yes, can it be reordered?
   - **Negotiable** — Is the wording locked-down implementation, or open to discussion?
   - **Valuable** — Does it deliver user/business value? "Refactor X" is not a story.
   - **Estimable** — Could a dev size this? If not, what's missing?
   - **Small** — Fits a sprint?
   - **Testable** — Could you write a test that proves done?

2. **Identify failures.** Note specifically which letters fail and why.

3. **Refine.** For each failure, produce a corrected version. Common refinements:
   - Too large (S, E fail) → split into 2-3 stories
   - Implementation in wording (N fails) → strip technology references
   - Internal-only (V fails) → reframe in user-visible terms, or merge into a higher-level story
   - Vague (T fails) → tighten the capability and outcome until testable

4. **Output the refined story** with a brief "what changed and why" note.

### Step 3b — Producer mode procedure

1. **Read the input.** Look for:
   - Stated user roles or personas
   - Capabilities the system is supposed to provide
   - Outcomes / value statements (sometimes implicit)
   - Constraints that are actually NFRs (don't include in stories — flag for `/req-nfr`)

2. **Group capabilities by role.** A trading platform has at least: trader (the end user), admin, possibly anonymous visitor, possibly system (for scheduled jobs).

3. **Draft stories.** One story per capability, in the role-capability-outcome format. Number them US-001, US-002, ...

4. **INVEST self-check.** Before returning, verify each story against INVEST. Don't ship stories that fail their own check.

5. **MoSCoW classification** (at MVP+ tier). Tag each as Must / Should / Could / Won't. Push back if Must-haves exceed ~5-7 for a single MVP cycle (the empirical success rate drops sharply past that).

### Step 4 — Output

For each story:
- Full role-capability-outcome format
- Numbered ID
- INVEST notes (only flag failures, otherwise short summary)
- MoSCoW tag if relevant

For the set as a whole:
- Brief summary: count by MoSCoW tag, any anti-patterns flagged, recommended next step
- The next step is almost always `/req-acceptance` to add Gherkin ACs

## Anti-patterns this skill flags

- **Implementation in the story.** "User logs in via OAuth using Auth0 SDK" → fails Negotiable. Strip to "User authenticates with their existing identity provider before accessing protected resources."
- **Internal-only stories.** "Refactor the database schema" → fails Valuable. Either reframe ("Database supports planned scaling without downtime") or move to a tech-debt track that's not in the user-facing backlog.
- **Compound stories.** "User can sign up, log in, recover password, and update profile" → fails Small and Estimable. Split into 4 stories.
- **Stories without users.** "The system shall persist data" — that's a system requirement, not a user story. Either find the user (whose value depends on persistence?) or move to NFRs.
- **Adjective stories.** "User has a fast experience" → fails Testable. That's an NFR; flag for `/req-nfr`.

## Audience adaptation

- **Novice**: explain what INVEST means inline the first time, annotate each story with why each criterion matters, gloss the role-capability-outcome format, recommend defaults for ambiguous things
- **Default**: clean stories with brief INVEST notes, no inline definitions
- **Senior**: dense stories, INVEST notes only when a criterion fails or is borderline, no MoSCoW tags unless explicitly asked

## Example — refiner mode (default audience)

User input:
```
1. The system should be fast and easy to use
2. We need to integrate with Stripe and Plaid for payments
3. User can log in
4. User can sign up, log in, reset password, update profile, and delete account
5. Refactor the data layer to use Postgres instead of MongoDB
```

Response:

> Audited 5 input items. Two are NFRs (#1) or tech debt (#5), not user stories — flagged for the right home. The rest:
>
> **#1** "The system should be fast and easy to use" — not a user story, this is two NFRs. Flagged for `/req-nfr` (will need precise metrics — "fast" and "easy" are not measurable as written).
>
> **#2** "Integrate with Stripe and Plaid for payments" — implementation leaked into requirement. Refined:
> > **US-001 — Pay for a subscription**
> > As a customer, I want to pay for a subscription using my preferred payment method, so that I can access paid features.
> > *INVEST notes: ✓ all. Stripe/Plaid choice is now an architecture decision belongs in `/arch-adr`.*
>
> **#3** "User can log in" — passes INVEST but is too thin. Refined for clarity:
> > **US-002 — Log in to existing account**
> > As a returning user, I want to authenticate with my registered identity, so that I can access my data.
> > *INVEST notes: ✓ all.*
>
> **#4** Compound story — split into 4:
> > **US-003 — Create an account**
> > As a new user, I want to register with email and password, so that I can save my data and return later.
> > **US-004 — Recover account access**
> > As a user who's forgotten their password, I want to reset it via my registered email, so that I can regain access without contacting support.
> > **US-005 — Update profile information**
> > As a logged-in user, I want to edit my display name and profile details, so that my account reflects my current information.
> > **US-006 — Delete account**
> > As a user leaving the service, I want to permanently delete my account and data, so that I'm no longer a user (and to comply with privacy regulations).
> > *INVEST notes: all ✓; #6 has likely GDPR/CCPA scope, flag in NFRs.*
>
> **#5** "Refactor data layer Postgres → MongoDB" — not a user story (no user value); also reverses what's stated as the original (Postgres FROM MongoDB? or MongoDB FROM Postgres?). Move to a tech-debt track outside the user-facing backlog. If there *is* user value (e.g., enables a query pattern the current DB can't handle), reframe around that user benefit.
>
> **Final set: 6 user stories (US-001 through US-006). Two flagged items moved to other tracks (NFRs, tech debt).**
>
> Next: `/req-acceptance` to add Gherkin scenarios to each story.
