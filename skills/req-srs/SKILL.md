---
name: req-srs
description: Assembles a formal Software Requirements Specification from existing user stories, acceptance criteria, and NFRs. Use when the user asks for "SRS", "requirements document", "spec doc", "PRD", "software requirements specification", or wants to package requirements into a formal deliverable. Tier-aware: produces a 1-page brief for hackathon, 3-8 page structured document for MVP, full SRS with semantic+packaging properties enforced for scaling. Enforces SRS quality properties (Complete, Implementation-Independent, Unambiguous, Consistent, Precise, Verifiable, Modifiable, Readable, Referenceable) as it assembles. Called by /spec orchestrator after /req-nfr.
---

# /req-srs — Software Requirements Specification

Packages user stories, ACs, and NFRs into a formal SRS document. The SRS is the authoritative design contract — it is what developers implement against, testers verify against, and stakeholders sign off on.

## SRS quality properties (what this skill enforces)

**Semantic properties** (correctness of content):
- **Complete** — all acceptable behaviors defined; no TBDs on must-have items
- **Implementation-Independent** — describes *what*, never *how*, unless a technology is an explicit external constraint
- **Unambiguous** — one possible interpretation per requirement
- **Consistent** — no requirements contradict each other
- **Precise** — defined boundaries and timing; no adjectives without metrics
- **Verifiable** — every requirement has a corresponding AC or NFR metric that can be objectively tested

**Packaging properties** (usability of the document):
- **Modifiable** — numbered sections and IDs so changes can be made without ripple editing
- **Readable** — plain-language summaries alongside technical content; accessible to non-technical stakeholders
- **Referenceable** — table of contents, numbered requirements, glossary; developers and testers can find anything quickly

## Tier-appropriate scope

| Tier | Output |
|:---|:---|
| Hackathon | Skip. Return: "At hackathon tier, your spec is the brief from `/elicit`. An SRS would burn time you need to build." |
| MVP | 3-8 page document: executive summary, stakeholder list, feature scope table, user stories with ACs, key NFRs, open issues list |
| Scaling | Full SRS: all sections below, compliance scope, glossary, data dictionary, integration points, security roles, logging config, RTM reference |

## Document structure (MVP+)

```
1. Introduction
   1.1 Purpose and scope
   1.2 Stakeholders and their concerns
   1.3 Definitions and abbreviations

2. System Overview
   2.1 Current situation / problem being solved
   2.2 New system assumptions
   2.3 Constraints (regulatory, technical, resource)

3. Functional Requirements
   3.1 User stories (INVEST-compliant, with IDs)
   3.2 Acceptance criteria (Gherkin, per story)
   3.3 Use case summary (if design phase has run)

4. Non-Functional Requirements
   4.1 Performance
   4.2 Availability and reliability
   4.3 Security
   4.4 Scalability
   4.5 Maintainability
   4.6 Usability
   [Add compliance scope here: PCI DSS / GDPR / FIPPA / SOC 2 / HIPAA]

5. Integration Points
   5.1 External services and APIs
   5.2 Data flows in/out

6. Data Requirements
   6.1 Data retention policies
   6.2 PII handling
   6.3 Backup and recovery requirements

7. Constraints and Assumptions
   7.1 Technical constraints
   7.2 Business assumptions
   7.3 Outstanding issues / open questions

8. Appendix
   A. Glossary
   B. References
   C. Traceability matrix reference (→ /req-rtm)
```

## Procedure

### Step 1 — Collect inputs
Gather from conversation: user stories (numbered IDs), ACs (Gherkin), NFR catalog (numbered IDs). Note any missing pieces — a complete SRS cannot be assembled with TBDs on must-haves.

### Step 2 — Semantic property check
Before assembly:
- Any two requirements contradict? → flag as Inconsistency, resolve before assembling
- Any NFR without a metric? → flag; don't embed it without a metric
- Any story without a "so that" (value missing)? → flag; not Complete without it
- Any TBDs? → list in Section 7.3 (Outstanding Issues); acceptable if they're non-blocking

### Step 3 — Assemble the document
Produce the document at tier-appropriate depth. For MVP: focus on Sections 1-4. For scaling: all eight sections.

### Step 4 — Output note on format
Default: markdown. If the user needs `.docx`, invoke the docx skill and note the file will be produced as a Word document suitable for stakeholder sign-off. State: "If you need this as a Word document for formal review or client delivery, I can produce a `.docx` version — let me know."

Recommend next step: `/req-rtm` for scaling tier; `/design` for MVP tier.

## Anti-patterns flagged
- **Embedding design decisions** ("The system shall use PostgreSQL to store user records") → strip the technology choice; move to an ADR
- **Unreviewable walls of text** — section everything; a 40-page wall means no one reads it
- **Version 1.0 of everything** — if this is a first spec, mark open issues explicitly rather than papering over them

## Audience adaptation
- Novice: produce the SRS with annotated comments explaining what each section is for; offer to produce a plain-English summary alongside the technical document
- Senior: clean document, no annotations, dense structure
