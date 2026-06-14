---
name: elicit
description: Captures stakeholder inputs, domain constraints, and system context through structured elicitation. Use when the user has an idea but hasn't formalized it — phrased as "I want to build X", "here's my idea", "we need a system that...", "let me describe what we're making", or when they paste raw notes, a business brief, meeting transcript, or email chain and want it turned into structured engineering inputs. Produces a raw requirements backlog and domain constraint list that feeds directly into /spec. Explicitly handles the transition from "fuzzy idea" to "things we can write requirements against".
---

# /elicit — stakeholder input capture

Converts fuzzy ideas, raw notes, and informal briefs into structured engineering inputs. The output is a domain-constraint-aware raw requirements backlog that feeds `/spec`. This is the first real step in the requirements lifecycle.

## What elicitation is NOT
- Not requirements (no INVEST, no Gherkin) — that's `/spec`
- Not architecture (no tech choices) — that's `/design`
- Not a spec doc — that's `/req-srs`

Elicitation is *listening*, organizing, and surfacing gaps before the disciplined phases begin.

## Inputs
Any or all of: user's direct description, uploaded documents (notes, briefs, emails, transcripts), prior conversation context.

## Procedure

### Step 1 — Listen and classify
Read all inputs. Classify each piece into:
- **User need** — something a person wants to do or experience (→ becomes a user story)
- **Domain constraint** — a rule the system must respect (regulatory, business, technical, time)
- **Stakeholder concern** — a worry or priority that shapes requirements (performance, cost, timeline)
- **Assumption** — something the user is taking for granted that should be made explicit
- **Out-of-scope signal** — something mentioned that isn't part of this system's responsibility

### Step 2 — Identify stakeholders
Who are the human actors? Common ones missed by first-time founders:
- End users (obvious)
- Admins / operators (often forgotten)
- External systems / APIs acting as stakeholders
- Regulators / auditors (if compliance scope exists)
- The company itself (as beneficiary of data and revenue)

For each stakeholder: name them, describe their primary concern, note if they need to sign off on the requirements.

### Step 3 — Surface assumptions and gaps
Elicitation almost always reveals things the user hasn't thought through. Surface them gently:
- "You mentioned user authentication but not password recovery — is that in scope?"
- "You said 'enterprise customers' but didn't mention multi-tenancy — will multiple orgs share the same deployment?"
- "You described the happy path but not what happens when payment fails."

Produce an **Outstanding Questions** list. These become Section 7.3 of the eventual SRS.

### Step 4 — Anti-pattern scan
Per `sdlc-foundation` anti-pattern-catalog:
- Feature list > 5-7 items at MVP? → MoSCoW pressure
- Tech mentioned before requirements? → flag as premature architecture decision
- "The system should be fast/secure/easy" → flag as NFR needing metrics
- "Microservices from day one" with no team-scaling pressure → premature distribution

### Step 5 — Output
Produce:
1. **Stakeholder map** — who, their concerns, sign-off required?
2. **Raw requirements backlog** — bullet list of user needs (not yet stories), grouped by actor
3. **Domain constraints** — non-negotiable rules the system must respect
4. **Assumptions made explicit** — things taken for granted, now written down
5. **Outstanding questions** — gaps that need resolution before requirements can be finalized
6. **Scope boundary** — brief statement of what IS and IS NOT in scope

Recommend next step: `/spec` to transform the raw backlog into INVEST stories with ACs and NFRs.

## Audience adaptation
- Novice: ask one clarifying question at a time if the picture is unclear; explain why each classification matters; don't overwhelm with SE terminology
- Senior: process the input efficiently; produce the output structure; ask only when genuinely ambiguous

## Anti-rationalization table
| Common Excuse | Why It's Wrong | What to Do Instead |
|---|---|---|
| "I know what the user needs" | You are not the user. Assumptions are the #1 source of rework. | Ask structured questions. Document answers. Validate with stakeholders. |
| "The requirements are in the ticket" | Tickets are summaries, not specifications. They hide context and tradeoffs. | Elicit: who, what, why, when, edge cases, failure modes. |
| "We already discussed this" | Verbal agreements are not requirements. Memory is unreliable. | Write down every decision. Share with stakeholders. Confirm in writing. |
