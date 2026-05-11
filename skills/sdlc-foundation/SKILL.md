---
name: sdlc-foundation
description: INTERNAL. Reference library for the sdlc-engineer plugin. Contains shared knowledge bases used by all sdlc-engineer skills. Do not invoke directly — this skill is not intended for user interaction. Other sdlc-engineer skills reference its files as needed.
---

# sdlc-foundation — internal reference library

This is not a user-facing skill. It is the shared knowledge base that all other sdlc-engineer skills depend on. When another skill instructs Claude to consult a foundation reference, that file is here.

## Contents

| File | Purpose | Used by |
| :--- | :--- | :--- |
| `maturity-tier-detection.md` | Detect hackathon/MVP/scaling tier; dial rigor accordingly | Every skill |
| `anti-pattern-catalog.md` | Active diagnostic content; fire opportunistically when patterns match | Every skill |
| `cost-of-defect-model.md` | 1×→200× repair cost curve; economic justification for rigor | consult, spec, req-* |
| `decision-frameworks.md` | INVEST, Gherkin, NFR taxonomy, MoSCoW, Modular Monolith First, Conway's Law, etc. | Every skill |
| `educational-layer.md` | Audience-mode dial (novice/default/senior); jargon detection; verbosity calibration | Every skill |

## How other skills reference this library

Other sdlc-engineer skills include instructions like:

> "Read the `sdlc-foundation` skill for maturity tier detection before proceeding."

When Claude Code encounters this instruction, it reads the relevant file from the co-installed `sdlc-foundation` skill directory. All skills in the sdlc-engineer plugin are installed to the same skills directory, so the reference resolves at runtime.

If Claude cannot locate a foundation file during a skill execution, it should apply reasonable defaults:
- Maturity tier: default to MVP
- Anti-pattern detection: apply common patterns from training
- Educational layer: default mode (some explanation, but not exhaustive)
- Decision frameworks: apply standard engineering judgment

## Maintenance note

When updating the shared knowledge bases (e.g., adding a new anti-pattern, updating decision frameworks), edit the files in this directory. Changes propagate to all skills that reference them at runtime — no per-skill updates needed.
