---
name: arch-complexity
description: Audits code or architectural complexity using established metrics: Cyclomatic Complexity, Cognitive Complexity, CK Suite (WMC, CBO, LCOM, DIT), and vFunction health scoring. Use when the user asks for "complexity analysis", "code quality metrics", "technical debt measurement", "is this code too complex?", "complexity audit", or when /design needs to establish a baseline before implementation. Can work from pasted code, file descriptions, or architectural descriptions. Produces a complexity report with per-metric scores, threshold violations, and prioritized refactoring recommendations.
---

# /arch-complexity — complexity metrics audit

Measures and interprets code/architectural complexity using the standard metric set. Complexity is technical debt made visible — this skill makes it quantitative.

Read `sdlc-foundation/decision-frameworks.md` for metric definitions and thresholds.

## Metric reference

### Cyclomatic Complexity (McCabe)
Counts decision branches (if/else/switch/loop/catch). Each branch adds 1.

| Score | Interpretation |
| :--- | :--- |
| 1-10 | Simple, low risk |
| 11-20 | Moderate; consider refactoring |
| 21-50 | Complex; high test burden |
| 51+ | Untestable; refactor required |

**Threshold**: flag anything > 10 per function/method; require refactoring above 20.

### Cognitive Complexity (SonarSource)
Measures how hard code is to *understand* (not just how many paths exist). Penalizes nesting, recursion, and control flow breaks more heavily than cyclomatic complexity does.

**Threshold**: > 15 per function/method warrants review.

### CK Suite (Chidamber-Kemerer object-oriented metrics)

| Metric | What it measures | Threshold |
| :--- | :--- | :--- |
| **WMC** (Weighted Methods per Class) | Sum of complexity across all methods | > 50 = class does too much |
| **CBO** (Coupling Between Objects) | How many other classes this class depends on | > 10 = fragile to change |
| **LCOM** (Lack of Cohesion in Methods) | How unrelated the methods in a class are to each other | > 0.7 = split the class |
| **DIT** (Depth of Inheritance Tree) | Inheritance chain length | > 5 = inheritance abuse |

### vFunction Health Score (0.0 - 1.0)
A composite score across six dimensions: Coupling/Cohesion, Cyclomatic Complexity, DIT, LCOM, Afferent/Efferent Coupling, Path Reachability.

- > 0.8: healthy
- 0.6-0.8: moderate technical debt; prioritize
- < 0.6: high debt; refactoring required before scaling

## Procedure

### From provided code

1. For each function/method: calculate cyclomatic and cognitive complexity
2. For each class: calculate WMC, CBO, LCOM, DIT
3. Compute module-level averages
4. Flag threshold violations
5. Rank by severity

### From architectural description (no code provided)

Score qualitatively:
- How many cross-module dependencies are described? → CBO proxy
- Are there "god modules" that everything depends on? → WMC/LCOM proxy
- How many layers of inheritance or abstraction? → DIT proxy
- How frequently does the user describe regressions from changes in one area breaking another? → CBO/coupling indicator

State clearly that these are qualitative estimates, not measurements.

## Output format

```markdown
## Complexity Audit — [Target: function/class/module/system]

### Summary
- Overall health: [High / Moderate / Low]
- Critical violations: [N]
- Warnings: [N]

### Per-metric findings

| Metric | Score | Threshold | Status |
| :--- | :--- | :--- | :--- |
| Cyclomatic (highest function) | [N] | ≤ 10 | ✅ / ⚠️ / 🔴 |
| Cognitive (highest function) | [N] | ≤ 15 | ... |
| WMC (highest class) | [N] | ≤ 50 | ... |
| CBO (highest class) | [N] | ≤ 10 | ... |
| LCOM (highest class) | [N] | ≤ 0.7 | ... |

### Top refactoring priorities

1. **[Function/Class name]** — [Metric]: [Score] — Recommendation: [Extract method / Split class / Reduce nesting / Break dependency]
2. ...

### Baseline note
[If this is a first audit: "Establish this as the baseline. Re-run after each major refactor to track direction."]
```

After the report: if running as part of `/design`, note these metrics should be tracked in CI (SonarQube, CodeClimate, or equivalent) to prevent regression.
