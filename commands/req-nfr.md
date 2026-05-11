---
description: Produce or refine non-functional requirements with precise, verifiable metrics across the standard taxonomy.
argument-hint: [project context, vague NFR statements to refine, or empty for full producer mode]
---

You are running the `/req-nfr` command from the sdlc-engineer plugin.

Use the `req-nfr` skill to handle this invocation. The skill is at `skills/req-nfr/SKILL.md`.

User's input: $ARGUMENTS

Procedure:
1. Read `skills/req-nfr/SKILL.md` for the producer/refiner mode contract and the precise-metric rule.
2. Detect mode:
   - Existing NFRs in input → refiner mode (audit each for measurable threshold; replace adjective-only NFRs)
   - Project context but no prior NFRs → producer mode (walk the taxonomy, draft tier-appropriate NFRs)
3. Read `shared/decision-frameworks.md` for the eight-category NFR taxonomy.
4. Read `shared/maturity-tier-detection.md` for tier-appropriate metric defaults.
5. Read `shared/educational-layer.md` for verbosity dial.

Hard rule: no adjective without metric. "Fast" / "secure" / "available" / "scalable" / "easy to use" without measurable thresholds get refined into precise NFRs with percentile-based load conditions and verification methods.

NFR format:
```
NFR-<CATEGORY>-NNN — <title>
The system shall <measurable requirement> under <stated load/conditions>.
Verification: <how this will be tested>
```

Flag conflicting NFRs (e.g., low-latency + high-reliability tradeoffs). Flag compliance scope explicitly (PCI / GDPR / FIPPA / SOC 2 — explicit "in scope" or "out of scope" beats silence).

End with coverage check (which categories covered, which skipped and why) and next step (typically `/req-srs` or back to `/spec`).
