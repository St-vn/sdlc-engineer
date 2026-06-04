---
name: research
description: Mandatory pre-planning research across three tracks: market validation, technical stack health, and compliance requirements. All searches are LIVE — this skill never answers from training knowledge. Use when the user says "research this", "look into X before we build", or when /implement pre-flight finds no recent research brief. Gated by research-tracks config fields.
---

# /research — pre-planning research orchestrator

Executes live research before any planning begins. Produces a research brief that feeds /spec NFRs and /implement task planning. NEVER answers from training knowledge — every claim must cite a live search result.

## Pre-flight

1. Check `docs/sdlc-engineer/` for an existing research brief < 7 days old. If found, surface it and ask if a refresh is needed. If the brief is current, skip.
2. Read project config from session context (injected by SessionStart hook). If no config, run /configure first.
3. Determine which tracks to run based on `research-tracks` in project config.

## Track 1 — Market research
**Gate:** `research-tracks.market: true` (intent != hackathon)

Mandatory live searches:
- "competitor analysis [product category] [year]"
- "user pain points [domain] [year]"
- "[product category] market size [year]"
- Top 3 competitors — feature matrix, pricing, reviews

Produces:
- Competitor landscape (3-5 players)
- User pain points validated by community evidence (Reddit, ProductHunt, G2 reviews)
- Market size estimate with source
- Differentiation opportunities

## Track 2 — Technical research
**Gate:** always runs (if tech stack not empty)

Mandatory live searches for EACH planned dependency:
- Current version and release date
- Open CVEs (check NVD or GitHub Security Advisory)
- Known breaking changes in last 6 months
- Community health (stars, last commit, open issues)

Additionally:
- Architecture patterns for the intended stack
- Known failure modes of the planned approach
- Newer alternatives worth evaluating

Fails with clear error if no web search tool is available. Does NOT silently fall back to training knowledge.

## Track 3 — Compliance research
**Gate:** `research-tracks.compliance: true` (regulated != none OR eu-consumers: true)

Mandatory live searches:
- Specific regulation requirements for the product category
- Data residency requirements for target audience geography
- Platform-specific limits (payment processor rules, app store policies if applicable)
- Recent enforcement actions or updates to relevant regulations

Produces: compliance NFR inputs that flow directly into /spec req-nfr.

## Output format

Write to `docs/sdlc-engineer/research-brief-YYYY-MM-DD.md`:

```markdown
# Research Brief — [Project Name]
Generated: YYYY-MM-DD
Tracks run: market | technical | compliance

## Market Track
[findings with citations]

## Technical Track
### Dependency: [name]
- Current version: X.X.X (released YYYY-MM-DD)
- CVEs: none found / [CVE-YYYY-XXXXX: description]
- Breaking changes: [none / list]
- Community health: [active / maintenance / deprecated]

### Architecture patterns
[findings]

## Compliance Track
[findings with citations]

## NFR inputs
[specific metrics/requirements that should become NFRs]

## Red flags
[anything that should change the plan]
```

## Search failure behavior

If web search tool is unavailable:
```
ERROR: /research requires live web search capability.
No search tool detected in this session.
Cannot proceed — training knowledge is not a substitute for live research.
Options:
  1. Install a web search MCP and retry
  2. Run /implement without research (not recommended for production-saas)
```

Do not silently omit searches. Do not use training knowledge as a fallback.
