# Cost-of-Defect Model

The empirical justification for why methodology rigor pays for itself — and why over-investing at the wrong stage doesn't. Every command should reference this when the user pushes back on rigor ("isn't this overkill?") or skips a step ("can we just write code?").

## The repair cost curve

The cost to fix a defect grows roughly an order of magnitude with each lifecycle stage it propagates into:

| Stage discovered | Relative repair cost |
| :--- | :--- |
| Requirements analysis | **1×** |
| Architectural design | 5× |
| Active coding | 10× |
| Unit testing | 20× |
| Integration & system testing | 50× |
| Production maintenance | **200×** |

A defect caught in production costs roughly **200 times** what the same defect would cost to fix at the requirements stage.

## Why the curve is exponential

Each downstream stage builds on the assumptions of the previous one. A faulty requirement causes design choices that depend on it, code that depends on those design choices, tests that depend on the code, and integration paths that depend on the tests. By the time the defect surfaces in production:

- The original artifact (requirements doc) is wrong
- The downstream artifacts (design, code, tests, deployment configs) are wrong in dependent ways
- Real users have experienced the defect; you may owe them remediation
- The team has built mental models around the wrong behavior, which now have to be unwound

Each layer of rework compounds.

## How to use the curve in conversation

### When the user is skeptical of methodology rigor

> "Why bother with full acceptance criteria? It's slowing me down."

Reply with the curve, scaled to their tier. For an MVP, an ambiguous user story shipped without ACs typically surfaces as a defect in unit/integration testing (20-50× cost). For a scaling startup with paying customers, the same defect typically surfaces in production (200×).

> "The catch is the cost curve. Writing one Gherkin scenario per story takes ~5 minutes. Tracking down a behavior bug in production averages around 200× that effort once you include incident response, customer comms, postmortem, and the actual fix. The discipline is buying you 200× return at low cost."

### When the user wants to skip the requirements stage entirely

> "I'll just start coding and figure it out."

Two answers depending on tier:

- **Hackathon**: That's actually fine. The whole point of a hackathon is fast iteration with throwaway code; the cost curve doesn't apply because you're not shipping to real users.
- **MVP / scaling**: Skipping the 1× stage means every defect lives at the 10×-200× stages. You're not saving time; you're moving the cost.

### When the user has already produced something and wants to skip ahead

> "I have user stories. Just give me the SRS."

Check if the user stories pass INVEST and the ACs are valid Gherkin. If they do, proceed. If they don't, refining them now (1× cost) is dramatically cheaper than refining them after they've shaped the SRS, the architecture, and partial code (5-10×). Use the soft-warn protocol: name the gap, state the cost, offer to refine before proceeding.

## What the curve does NOT justify

The curve does **not** justify infinite rigor. Three caveats:

1. **Diminishing returns at the top.** Going from "good enough requirements" to "perfect requirements" costs disproportionately more for marginal defect reduction. There's a knee in the curve where additional rigor stops paying back.
2. **Tier matters.** A hackathon's 200× of nothing is still nothing — there are no production users to disappoint, no incidents to respond to. Don't apply scaling-startup rigor to a hackathon.
3. **Rigor in the wrong direction is waste.** Over-specifying *implementation details* in requirements (the "implementation in requirements" anti-pattern) doesn't reduce defects; it adds rework when the implementation choice changes.

The right rigor for the right stage is what pays back. See `maturity-tier-detection.md` for the depth-vs-tier matrix.

## Sources for the cost figures

The 1×-200× relationship is widely cited in software engineering literature, originally derived from defect-tracking studies at IBM, NASA, and other organizations that measured actual repair effort across lifecycle stages. The exact multipliers vary by study and domain (some report 100× rather than 200× for production); the order-of-magnitude shape is consistent across all of them. Use the curve as a directional argument, not a precision instrument.
