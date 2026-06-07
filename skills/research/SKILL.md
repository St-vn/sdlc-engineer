---
name: research
description: Orchestrates modular pre-planning research by running market, tech stack, and compliance sub-skills. All searches are LIVE.
---

# /research — Pre-Planning Research Orchestrator

This skill coordinates the execution of the three granular research sub-skills, aggregates their findings, and outputs a compacted, token-optimized research brief.

## Pre-flight
1. Check `docs/sdlc-engineer/` for an existing research brief. If it exists and is < 7 days old, ask if a refresh is needed.
2. Read project config from session context (injected by `SessionStart` hook).
3. Determine which sub-skills to trigger based on `research-tracks` in `.sdlc/project.yml`:
   * `research-tracks.market: true` -> Trigger `research-market` subagent.
   * `research-tracks.compliance: true` -> Trigger `research-compliance` subagent.
   * `research-tracks.technical: true` -> Trigger `research-tech` subagent.

## Subagent Orchestration
* If the Claude Code Task tool is available, dispatch the matching sub-skills in parallel waves (e.g., executing `research-market`, `research-tech`, and `research-compliance` simultaneously).
* Gather the outputs from each subagent.

## Token Compaction Schema
To prevent context window bloat in downstream tasks, aggregate the raw findings into `docs/sdlc-engineer/research-brief-YYYY-MM-DD.md` using the following compacted JSON/Markdown format:

```json
{
  "project_meta": {
    "engine_version": "1.1.0",
    "timestamp": "YYYY-MM-DDTHH:MM:SSZ"
  },
  "dependency_risk": {
    "vulnerabilities": [
      { "package": "name", "cve": "CVE-YYYY-XXXX", "severity": "HIGH", "reachable": true }
    ],
    "licensing": {
      "restricted_found": ["AGPL-3.0"],
      "action_required": "Refactor or isolate dependencies if AGPL-3.0 is found."
    }
  },
  "regulatory_gaps": {
    "gdpr": ["PII logs detected"],
    "apple_511": ["Non-essential form field validation needs optional tag"],
    "stripe": ["Time format AM/PM needs space (e.g. 3:25 PM)"]
  },
  "market_signals": {
    "competitors": [
      { "name": "billing-bot", "rating": 4.2, "votes": 1280, "weakness": "Fails on connection drops" }
    ],
    "tam_sam_som": { "tam": "$10B", "sam": "$1B", "som": "$10M" }
  }
}
```
Followed by a brief Markdown outline highlighting **Red Flags** (critical issues blocking specification/implementation) and **NFR Inputs** (metrics that must be added to `/spec` requirements).
