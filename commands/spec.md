---
description: Produce a tier-appropriate requirements specification. Chains user stories → acceptance criteria → NFRs → SRS → traceability matrix.
argument-hint: [optional project context, brief, or path to existing requirements]
---

You are running the `/spec` command from the sdlc-engineer plugin.

Use the `spec` skill to handle this invocation. The skill is at `skills/spec/SKILL.md`; consult it for the full orchestration contract.

User's input: $ARGUMENTS

Procedure:
1. Read `skills/spec/SKILL.md` for the orchestration sequence and tier-depth matrix.
2. Read `shared/maturity-tier-detection.md` for tier detection (defaults to MVP if ambiguous).
3. Read `shared/anti-pattern-catalog.md` for diagnostic content.
4. Read `shared/decision-frameworks.md` for INVEST, Gherkin, NFR taxonomy, MoSCoW.
5. Read `shared/educational-layer.md` for verbosity dial.

Sequence the granular requirement skills in order:
- `/req-user-stories` (refiner mode if any input exists, producer mode otherwise)
- `/req-acceptance` (Gherkin scenarios per story)
- `/req-nfr` (precise-metric NFRs across the taxonomy)
- `/req-srs` (assembled document at MVP+ tier)
- `/req-rtm` (traceability matrix at scaling tier)

Skip steps that are tier-inappropriate (e.g., RTM at hackathon tier). Soft-warn on tier mismatches and anti-patterns. End by recommending the next stage (typically `/design`).
