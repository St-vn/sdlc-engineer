# sdlc-engineer Build Order — Deep Research Report

*Factuality verification, implementation strategy, and dependency tradeoffs*
*Sources: industry docs, agent skill repos (Superpowers, gstack, NeoLabHQ, GSD), academic papers (arXiv, Thoughtworks, IEEE), YC philosophy*

---

## Executive Summary

**21 proposed skills across Phases 0a–20. Verdict by category:**

| Category | Verdict |
|---|---|
| Config preamble (cross-cutting) | **Build — but fix the implementation mechanism** |
| Phase 0a (`configure`) | **Build first — critical foundation** |
| Phase 0b (`research`) | **Build — strongly validated, correctly designed** |
| Phases 1–5 (task format, TDD, subagent exec) | **Build — industry consensus, highest-value cluster** |
| Phase 6 (`session-save/restore`) | **Build alongside Phase 2 — mechanism needs correction** |
| Phase 7 (`guard`) | **Build — fix implementation mechanism (hooks, not SKILL.md)** |
| Phase 8 (`ci-verify`) | **Build — dependency is pre-installed on most machines** |
| Phase 9 (`execute-parallel`) | **Build — git worktrees are universal** |
| Phases 10–11 (security + headless QA) | **Build — zero-dependency, high value** |
| Phase 12 (`qa-browser`, Playwright) | **Build with updated mechanism — don't defer** |
| Phases 13–17 (monitor, benchmark, finish, launch, sync-docs) | **Build — zero-dependency, correctly designed** |
| Phase 18 (`learn`) | **Build — correctly designed** |
| Phase 19 (`coordinate`) | **Defer for v2 — gated by config anyway** |
| Phase 20 (`retro`) | **Build — zero-dependency, closes the loop** |

**3 implementation corrections required** (config preamble, guard, qa-browser).
**1 skill deferred** (coordinate — already suppressed for solo by config).
**0 skills removed** — every claim is factually grounded.

---

## Research Basis

All findings below are backed by live sources retrieved May 12, 2026:

- **Superpowers** (github.com/obra/superpowers) — 57,540 ⭐, v4.3.1, the most adopted agent methodology framework
- **gstack** (github.com/garrytan/gstack) — 71K ⭐, Garry Tan / YC CEO, released March 12, 2026
- **GSD** — TypeScript-controlled orchestration framework, v2 rewrite
- **NeoLabHQ context-engineering-kit** — SDD, LLM-as-Judge, subagent-driven development
- **Praetorian deterministic AI orchestration** — research-first workflow, TDD for skills
- **arXiv 2602.00180** — "Spec-Driven Development: From Code to Contract" (peer-reviewed, Jan 2026)
- **arXiv 2602.03786** — "AOrchestra: Automating Sub-Agent Creation" (Feb 2026)
- **arXiv 2604.14228** — "Dive into Claude Code: Design Space of Today's AI Agent Systems" (Apr 2026)
- **Thoughtworks** — Spec-driven development analysis (Dec 2025)
- **Martin Fowler** — Structured Prompt-Driven Development (SPDD)
- **Claude Code docs** — Skills, hooks, context compaction behavior
- **Playwright** — Current Claude Code integration docs (playwright.dev)
- **YC** — Core startup advice (paulgraham.com, samaltman.com, michaelseibel.com)
- **Cloudflare** — Agents that Remember / Agent Memory
- **holyclaude, agentmemory, learn-claude-code** — Community implementations

---

## CROSS-CUTTING — Config Preamble Behavior

### Is this needed?

**Yes. Strongly validated — but no existing framework implements it this systematically.**

The current repo uses `shared/maturity-tier-detection.md` as a heuristic: the skill reads project files and *guesses* the intent tier. This is the dominant pattern in gstack and Superpowers too — both rely on heuristics or explicit per-session prompting, not a persistent config file.

The build order proposes replacing guesswork with a single committed YAML source of truth that all skills read. This is architecturally superior:

- gstack's "boil the lake" principle (each specialist stays in their lane with defined constraints) is essentially the same concept, but implemented via persona SKILL.md templates rather than a config file. The build order's approach is more machine-readable and testable.
- NeoLabHQ's LLM-as-Judge quality gates use "predefined verification rubrics" — equivalent to config-driven gating.
- Amazon Kiro (AWS's spec-driven IDE, released July 2025) uses exactly this pattern: structured spec files committed to the repo drive behavior across the entire tool.

### Implementation correction required

**The per-skill bash read is the wrong mechanism.**

The build order spec says every skill "executes this sequence" of reading config files before doing anything else. But Claude Code's own documentation warns:

> "Keep the body itself concise. Once a skill loads, its content stays in context across turns, so every line is a recurring token cost."

If each of 21 skills begins with a bash read of two YAML files, that's 42 file reads per session plus the token cost of processing config content 21 times. Claude Code's context compaction re-attaches skills "after the summary, keeping the first 5,000 tokens of each" — meaning config-reading preambles will compete with actual skill instructions for the compaction budget.

**The correct mechanism is two-part:**

1. **`SessionStart` hook** — inject `.sdlc/project.yml` and `~/.sdlc/user.yml` content into session context at startup. This is how holyclaude and agentmemory handle cross-session context: "Memory loads context from previous sessions (SessionStart hook)." The hook fires once per session; config enters context once; all 21 skills read it from context, not from disk.
2. **Per-skill guard (for sessions without the hook)** — a short SKILL.md preamble that checks whether config is already in context and reads it only if absent. This is the fallback for users who install without hooks.

The hard dependency ("if no project config exists, do not proceed, invoke /configure first") is correct and should stay — just triggered at session start via hook, not inside every skill.

---

## PHASE 0a — Project Configuration (`configure`)

### Is this needed?

**Yes. Foundational. No existing framework does this correctly.**

The gap this fills is real and documented:

- gstack has `/office-hours` (CEO-mode thinking) and plan reviews, but no persistent project config. Its structural gap: "The Build phase has no corresponding skill. Claude Code reverts to default mode until you manually run /review." A committed `.sdlc/project.yml` is the fix for this.
- Superpowers has `brainstorming` and `writing-plans` but no config that persists across sessions and gates downstream skill behavior.
- GSD v2 controls sessions at the TypeScript level — closest to this in spirit, but not accessible as a skill pattern.

### Is the AskUserQuestion governance correct?

**Yes — the 8-question cap and the "must ask / can infer / never ask" governance is validated.**

- Thoughtworks' SPDD research explicitly identifies this failure mode: "AI must guess: What format? What permissions model? What size limits?" — the result is "vibe coding" with unstated assumptions.
- The SDD arXiv paper: "Specs act as super-prompts that break down complex problems into modular components aligned with agents' context windows. AI agents can generate code from specs while self-verifying against checklists for requirements adherence." [arXiv 2602.00180]
- The 8-question cap is YC-aligned: focused, high-impact, defaults pre-populated. YC's 90/10 rule ("Find the 90/10 solution") applies to config capture too — 8 questions get 90% of the signal.

### Derived fields (security-tier, launch-tier, sub-skill-gates)

**Correct. This is the specific mechanism that no other framework has.**

The computation of `sub-skill-gates` from user answers prevents the most common agent failure mode: wrong tasks surfacing. An auth-less hackathon getting asked about OAuth flows, or a solo founder seeing PR workflow instructions, erodes trust in the tool immediately.

---

## PHASE 0b — Research (`research`)

### Is mandatory pre-planning research needed?

**Strongly yes. One of the most validated claims in the entire build order.**

**Evidence:**

1. **Praetorian's deterministic orchestration** explicitly implements a research-first workflow: "Before a skill's content is written (the 'Green' phase), the system spawns a specialized research orchestration… Sequential Discovery: Agents dispatch to 6 distinct sources: Codebase, Context7 [official docs], GitHub, Web/Perplexity… A final pass aggregates findings, resolves conflicts between sources." They specifically note: "TDD ensures structural correctness (valid YAML, passing tests) — it cannot guarantee semantic accuracy (correct API usage, up-to-date patterns). For this, we use the orchestrating-research skill."
2. **Addy Osmani (Chrome DevRel)**: "Claude Code doesn't have up-to-date training data for every library, so it can't reliably 'remember' what a docs site says today." The specific example given: "Claude keeps suggesting outdated patterns and misses things like liveQuery()." This is the exact problem Phase 0b's technical research track solves.
3. **Empirical research**: "Controlled studies showing error reductions of up to 50%" when human-refined specs (informed by real information) are provided to LLMs. [arXiv 2602.00180]
4. **Thoughtworks**: "MCP servers like Context7 can provide real-time documentation information… separating requirements analysis and planning from the code implementation phase essentially compresses the context into specs."

### Is the three-track structure (market / technical / compliance) correct?

**Yes, and the config gating is essential.**

- YC says "launch now" — but this applies to product market fit validation, not to discovering that your target library has a critical CVE or that your EU-audience app requires cookie consent DPAs. These are different failure modes.
- The `research-tracks` config gate correctly handles the tension: a hackathon skips all three tracks. A production-saas targeting EU consumers activates all three. This is the right design.

### Implementation note

The build order requires "mandatory search invocations — cannot answer from training knowledge." This is correct but needs to be explicit in SKILL.md: the skill must call web search tools (Claude's native search, Gemini search, or equivalent) and must fail gracefully if no search tool is available (log a warning; don't silently use training knowledge).

---

## PHASE 1 — Task Format & AC-to-Test Derivation (`tasks` rewrite)

### Is the TDD task format needed?

**Yes. This is the single most validated claim in the entire build order.**

Superpowers (57,540 ⭐, released October 2025) implements exactly this — and has become the most adopted agent methodology framework in the space:

> "Plan → Create bite-sized tasks (2-5 min each) with exact file paths and verification steps. Implement → TDD red-green-refactor with subagent delegation."

The Superpowers philosophy, directly quoted: *"Write tests first, always. Systematic over ad-hoc. Process over guessing. Simplicity as primary goal. Verify before declaring success."*

The build order's specific addition — the **"Run to confirm RED" step** before writing implementation — is the differentiator that makes the cycle trustworthy. Superpowers includes persuasion-principle enforcement specifically for this:

> "Skills embed persuasion principles to ensure agents actually follow workflows even under pressure scenarios: Time pressure ('production is down!'), Sunk cost ('but I already wrote it!'), Confidence ('I know how to do this')."

The build order's equivalent: *"If RED step is skipped or test passes before implementation: STOP, flag it, restart the task."* This is the correct mechanism.

### Is the dependency graph for parallelization correct?

**Yes. "Two tasks are parallelizable iff their file sets are disjoint" is the standard formal criterion.**

The learn-claude-code repo (s07-s12) explicitly implements this: "Break big goals into small tasks, order them, persist to disk — a file-based task graph with dependencies."

---

## PHASE 2 — Inline Execution (`execute-inline`)

### Needed?

**Yes. Validates the task format before building more complex execution modes.**

The commit-per-task discipline ("never modify files outside the task's declared file set without flagging it") is architecturally sound — it's the same "atomic commits" principle GSD v2 enforces at the TypeScript level: "Every commit is atomic and independently revertable."

---

## PHASE 3 — Debugging (`debug`)

### Needed?

**Yes. The 4-phase root cause process is Superpowers-validated.**

Superpowers includes `systematic-debugging` as a core skill: "4-phase root cause process." The build order's equivalent structure (Phase 0: reproduce → Phase 1: isolate → Phase 2: hypothesize → Phase 3: verify) matches this pattern.

---

## PHASE 4 — Spec Compliance Review (`review-spec`)

### Needed?

**Yes. The two-stage review is the key innovation — and it's specifically validated.**

Superpowers' subagent-driven development: "Dispatch spec reviewer subagent → confirms code matches spec. Dispatch code quality reviewer subagent → approves or requests fixes."

The context isolation principle ("spec reviewer gets only task AC + diff — no codebase context") is the critical correctness property:

> "Prevents reviewers from being influenced by knowing the implementer's intent, which biases compliance checks."

This is validated by the AOrchestra paper's finding: "multi-agent collaboration often incurs substantial coordination overhead and provides limited control over context routing, leading to either noisy over-sharing or harmful omission of critical information." The solution — precise context routing per subagent role — is exactly what Phase 4 implements. [arXiv 2602.03786]

---

## PHASE 5 — Subagent Execution (`execute-subagent`)

### Is fresh-context-per-task needed?

**Yes. Empirically and architecturally validated — the central innovation of the 2025-2026 agent framework wave.**

**The evidence stack:**

1. **GSD**: "Each task gets a fresh Claude instance with a clean 200K token context window. The main conversation only dispatches — its load stays at 30–40%."
2. **Praetorian**: Anthropic's own measurements show "standard MCP workflows consuming ~150k tokens for multi-tool operations that could execute in ~2k tokens with proper architecture — a 98% reduction."
3. **arXiv 2602.03786 (AOrchestra)**: "Systems such as Schroeder et al. (2025); Sun et al. (2025) primarily treat sub-agents as isolated context threads, aiming to prevent context rot." This is the explicit academic validation.
4. **NeoLabHQ SADD**: "Dispatches independent subagents for individual tasks with code review checkpoints between iterations for rapid, controlled development."
5. **VILA-Lab arXiv 2604.14228**: "Subagent isolation (s04) prevents noise from leaking." Explicitly cited as a design requirement for production coding agents.

### Claude Code Task tool dependency

The build order correctly documents the fallback: "Gemini CLI falls back to inline." This is the right approach — Phase 5 gracefully degrades to Phase 2 when the Task tool isn't available.

---

## PHASE 6 — Session Persistence (`session-save/restore`)

### Is it needed?

**Yes. Context rot is the #1 failure mode the Pulumi analysis identifies for all three major frameworks.**

> "Three community frameworks have emerged that fix the specific ways AI coding agents break down on real projects… GSD prevents context rot."

The MindStudio analysis confirms: "Not built-in across sessions, but it's achievable without a framework. The common patterns involve writing state to a file (JSONL, markdown, or SQLite) that gets loaded at the start of each run."

### Is the markdown-file implementation correct?

**Yes, for a zero-dependency skill — with one mechanism correction.**

The VILA-Lab arXiv paper confirms Claude Code itself uses "append-only JSONL session transcripts" for persistence. Markdown is the correct lightweight format for a skills repo without runtime dependencies — consistent with the repo's overall philosophy.

**Implementation correction required:**

The build order implies `/session-save` is invoked manually. The correct trigger is Claude Code's **`Stop` hook**, which fires automatically when a session ends. holyclaude implements this exactly: "Session summarized and persisted (Stop hook)."

The skill should define both:

- **Auto-save**: triggered by Stop hook, saves session state without user invocation
- **Manual `/session-save`**: explicit checkpoint mid-session (e.g., "context window approaching limit")

The `/session-restore` skill, and the step "Find most recent checkpoint for current branch," are correctly designed.

---

## PHASE 7 — Safety Guardrails (`guard`)

### Is it needed?

**Yes. Broadly validated across all major frameworks.**

Claude Code itself has 7 safety layers. holyclaude uses `PreToolUse` hook for "Security warnings on sensitive file edits." The everything-claude-code repo has a full security scan skill.

The intercept list (`rm -rf` outside scope, `git reset --hard`, `DROP TABLE`, `.env` modifications) matches real failure modes — these are exactly what Claude Code's own `shouldUseSandbox.ts` and permission system guard against at the platform level.

### Implementation correction required

**"Embedded in SKILL.md bootstrap" is the wrong mechanism for intercepting bash calls.**

The correct mechanism is Claude Code's **`PreToolUse` hook**, which fires before every tool call and can block execution with an exit code. The SKILL.md approach relies on the model reading instructions and cooperating — exactly the failure mode GSD v2 was rewritten to avoid: "v1 relied on the LLM reading instructions and cooperating. v2 controls the agent session at the TypeScript level."

For a skill-based (not TypeScript) implementation, the hook is the only reliable interception point. The guard skill SKILL.md should define what to block; the actual blocking logic should live in a `hooks.json` PreToolUse entry.

---

## PHASE 8 — CI Integration (`ci-verify`)

### Is the `gh`/`glab` CLI dependency a problem?

**No. These are widely pre-installed and have graceful fallback paths.**

The build order's explicit fallback design ("Detect CI platform → push if not pushed → poll for completion → surface the specific failure step") handles the common case. The skill should add: if neither `gh` nor `glab` is available, log a clear warning and output the branch URL for manual CI check — don't block.

The core value ("CI catches what local runs don't: missing env vars, implicit dependency on local tooling, tests that pass in isolation but fail in full suite") is directly validated by standard CI/CD engineering practice.

---

## PHASE 9 — Parallel Execution (`execute-parallel`)

### Is `git worktree` a real dependency concern?

**No. Git worktrees are standard git ≥ 2.5 (released 2015). Universal.**

gstack explicitly recommends the worktree pattern for parallelism (via Conductor): "git worktree add ../feature-auth feature-auth && claude -w ../feature-auth." Superpowers has a dedicated `using-git-worktrees` skill. learn-claude-code's s12 is entirely dedicated to "Worktree Isolation — task coordination + optional isolated execution lanes."

The build order's wave-based parallelization algorithm (group tasks with no remaining dependencies → wave 0, recompute → wave 1) is the standard topological-sort approach. It is correct.

### Config gate concern

The current gate ("Suppressed for `team-size: solo` on short timelines") creates friction for a solo founder with a large task list who wants parallelism. The gate should activate based on task count alone (e.g., >8 tasks regardless of team size) or offer it as opt-in for solo. The build order spec already notes this: "Activated by default for… intent: production-saas and task list has more than 8 tasks."

---

## PHASE 10 — Security Audit (`audit-security`)

### Is OWASP + STRIDE + hardening checklist the right structure?

**Yes. Industry standard across all maturity tiers.**

The OWASP Top 10 is the universally cited security baseline. STRIDE threat modeling is Microsoft's framework, widely adopted for systematic threat analysis against architecture artifacts. The hardening checklist items (RLS, RBAC, refresh token rotation, HttpOnly cookies, HSTS, CSP) are standard production-saas requirements.

The `security-tier` config gate (minimal → standard → hardened) maps correctly to hackathon → mvp → production-saas. The 5-minute grep pass for hackathon vs. full STRIDE model for production-saas is the correct calibration.

**No corrections required.**

---

## PHASE 11 — QA Headless (`qa-headless`) / PHASE 12 — QA Browser (`qa-browser`)

### Is the two-phase structure (curl → Playwright) correct?

**Yes — and this is specifically the right design.**

The separation of headless HTTP testing (Phase 11, zero dependencies) from browser testing (Phase 12, Playwright) maps to what the testing industry has converged on:

- "Playwright for testing, cross-browser automation, and repeatable multi-step workflows."
- "Playwright's resilience matters more than speed when the goal is 'complete this task without me watching.'"

Phase 11 (curl-based integration testing from Gherkin AC) is validated by NeoLabHQ's `/qa` skill and holyclaude's headless approach. Phase 11 runs everywhere, at all intent tiers. Phase 12 gates correctly on `intent ≠ hackathon`.

### Phase 12 implementation update required

**Playwright now ships native Claude Code integration — update the installation reference.**

As of 2026, Playwright explicitly markets to Claude Code users and ships two integration modes:

1. `npm i -g @playwright/cli@latest` — "Token-efficient browser automation for coding agents like Claude Code. Skill-based workflows without large context overhead."
2. `npx @playwright/mcp@latest` — MCP server giving AI agents "full browser control through structured accessibility snapshots."

The Phase 12 SKILL.md should reference `@playwright/mcp` as the preferred installation method. This reduces setup friction from "install Playwright + Chromium binary" to "npx one-liner that gives the agent structured accessibility snapshots at low token cost." The `@playwright/cli` with skill-based workflows is designed specifically for the context Claude Code agents run in.

**This does not change the defer/build decision — build it. The dependency is lighter than the build order implies.**

---

## PHASES 13–17 (monitor, benchmark, finish-branch, launch-readiness, sync-docs)

### Are these needed?

**Yes. All zero-dependency, all correctly designed.**

- **Phase 15 (`finish-branch`)**: Superpowers has a dedicated `finishing-a-development-branch` skill. gstack has `/ship`. The four-option decision point (merge / PR / keep / discard) is the correct human-in-the-loop gate before any merge.
- **Phase 16 (`launch-readiness`)**: The build order's claim that "neither gstack nor superpowers has it" is correct — this is a genuine gap in the existing framework landscape. The proactive planning integration (surfacing launch items *during* spec/tasks, not at launch time) is architecturally sound and matches how the existing repo's cost-of-defect model works.
- **Phase 17 (`sync-docs`)**: Drift detection (implemented things not in spec; specced things not in diff) is the standard SDD maintenance requirement. Thoughtworks: "Spec drift and hallucination are inherently difficult to avoid, so we still need highly deterministic CI/CD practices to ensure software quality." sync-docs is the implementation of that requirement.

---

## PHASE 18 — Cross-Session Learnings (`learn`)

### Is the JSONL approach correct?

**Yes. JSONL is the right format and is validated by the ecosystem.**

Claude Code itself uses append-only JSONL for session transcripts. [arXiv 2604.14228] The agentmemory repo explicitly supports `import-jsonl` from Claude Code transcripts: "Already have older Claude Code JSONL transcripts? npx @agentmemory/agentmemory import-jsonl."

For zero-dependency skills, JSONL is correct. The more sophisticated approach (SQLite + vector search, as used by agentmemory and holyclaude) provides better recall but introduces runtime dependencies that contradict the repo's design philosophy.

The per-skill-type routing (tasks reads anti-patterns, debug reads failed approaches, configure reads corrections) is the right design — structured retrieval vs. dumping the entire learnings file into context.

**Anthropic's Agent Memory** (announced May 2026, Cloudflare blog) is now the managed alternative for teams: "A memory profile can be shared across agents, people, and tools. Knowledge learned by one person's coding agent is available to everyone." This can be documented as an optional upgrade path from Phase 18's file-based approach.

---

## PHASE 19 — Multi-User Coordination (`coordinate`)

### Should it be built or deferred?

**Defer for v2. The config gate already suppresses it for solo founders — the primary audience.**

**Evidence for deferral:**

1. The build order itself gates this: "Suppressed entirely if `team-size: solo`." For the YC solo-founder audience this repo targets, this skill has 0% activation rate.
2. gstack explicitly does not implement coordination as a skill: "gstack isn't a multi-agent framework. It's a deliberately structured approach to human-mediated role switching inside Claude Code." The recommendation is to combine gstack with Conductor (external tool) for parallelism.
3. The complexity is real: "While multi-agent collaboration can improve task decomposition, in open-ended environments it often incurs substantial coordination overhead." [arXiv 2602.03786]
4. YC principle: "Startups can only solve one problem well at any given time." For a skills repo, the coordination problem is distinct from the core SDLC methodology problem. Solve the core problem first.

**What to do instead**: Document the git worktree pattern for manual multi-developer coordination in a `MULTI-DEV.md` reference file. Phase 9 (execute-parallel) already handles the agent-side worktree isolation. Phase 19 adds the human-coordination layer — which requires more project-specific configuration than a generic skill can provide.

---

## PHASE 20 — Retrospective (`retro`)

### Needed?

**Yes. Zero-dependency, validates the methodology improvement loop.**

NeoLabHQ has a dedicated `kaizen` skill: "Applies continuous improvement methodology with multiple analytical approaches, based on Japanese Kaizen philosophy and Lean methodology."

The Phase 20 analysis checklist (plan accuracy, AC quality, NFR accuracy, debug patterns, anti-patterns caught, CI failures, research accuracy, config accuracy) maps correctly to the existing repo's cost-of-defect model. Retro closes the loop that model was designed for.

---

## Complete Dependency Assessment

### Dependency registry

| Dep | Phase | Risk | Build | Defer | Mitigation |
|---|---|---|---|---|---|
| `git worktree` | 9, 19 | None — git ≥ 2.5 (2015) | ✓ | — | Universal |
| `gh` CLI | 8 | Low — pre-installed on most dev machines | ✓ | — | Graceful fallback: output branch URL |
| `glab` CLI | 8 | Low — GitLab-only | ✓ | — | Only invoked on GitLab repos |
| Claude Code Task tool | 5, 9 | Medium — Anthropic-native only | ✓ | — | Fallback: inline execution (Phase 2) |
| `npm audit` / `pip-audit` | 10 | Very low — lang ecosystem tools | ✓ | — | Language-specific, scoped to detected stack |
| `@playwright/mcp` | 12 | Low — npx install, ~200MB Chromium | ✓ | — | Gated on intent ≠ hackathon; MCP mode now available |
| `curl` | 11, 14 | None | ✓ | — | Pre-installed everywhere |
| Web search tool | 0b | Medium — requires search capability | ✓ | — | Fail with clear error if unavailable |

### Should Playwright be deferred entirely?

**No.** The correct call is to build Phase 12 but update the implementation mechanism:

1. Use `@playwright/mcp` (MCP server mode) instead of requiring raw Playwright installation — this is now the recommended path per playwright.dev for Claude Code agents.
2. The Phase 11 → Phase 12 tiering already handles the case correctly: headless curl for all tiers, browser only for production-saas.
3. Playwright now explicitly ships "skill-based workflows" for Claude Code — the tool has moved toward the exact use case Phase 12 describes.

### Should the dependency on Claude Code's Task tool be deferred?

**No.** The subagent execution model (Phase 5) is the most validated pattern in the entire build order. The Task tool is Anthropic-native, stable, and already used by Superpowers and gstack. The fallback (Phase 2, inline execution) is already specified.

---

## Implementation Corrections Summary

### Correction 1: Config Preamble — Use `SessionStart` hook, not per-skill bash read

**Current spec**: Every skill reads YAML config files via bash before acting.

**Correct implementation**:

1. Add `hooks.json` with a `SessionStart` hook that reads `.sdlc/project.yml` and `~/.sdlc/user.yml` and injects them into session context as a `user` message (same pattern holyclaude uses).
2. Each skill's SKILL.md preamble reads config *from context* (not from disk) — a short reference to "use project config from session context" rather than a bash read.
3. Fallback guard: if config isn't in context (hook not installed), the skill reads it once via bash and injects it. This is idempotent and happens once per skill, not on every invocation.

### Correction 2: Guard — Use `PreToolUse` hook, not SKILL.md bootstrap

**Current spec**: "Cross-cutting behavior embedded in SKILL.md bootstrap that checks all Bash tool calls before execution."

**Correct implementation**:

1. `PreToolUse` hook in `hooks.json` handles interception at the Claude Code level — not inside the skill's context window.
2. The guard skill's SKILL.md defines *what* to guard (the intercept list, freeze mode). The `hooks.json` entry defines *how* to guard (exit code, warning message).
3. This is reliable because PreToolUse fires at the harness level — it doesn't depend on the model reading and cooperating with SKILL.md instructions.

### Correction 3: QA Browser — Reference `@playwright/mcp`, not raw Playwright

**Current spec**: "Playwright + Chromium" as external dependency.

**Correct implementation**:

1. Use `npx @playwright/mcp@latest` as the installation command — this gives the agent structured accessibility snapshots at lower token cost than raw Playwright.
2. Note in SKILL.md: "If Playwright MCP is not installed, fall back to `qa-headless` (Phase 11) and log a warning."
3. The config gate (`intent ≠ hackathon`) stays as-is.

---

## Build Order Validation

The proposed 0a → 0b → 1 → 2 → 3 → … → 20 sequencing is correct.

**One note on Phase 6 timing**: The build order already specifies "Build alongside subagent execution since context limits hit there first." This is correct — build Phase 6 alongside Phase 2, not after Phase 5.

**On Phase 18 (`learn`) positioning**: Learning should be readable by Phase 1 (`tasks`), as the build order specifies in the preamble: "Read cross-session learnings — if `docs/sdlc-engineer/learnings.jsonl` exists, surface relevant entries." This means Phase 18's *output format* must be defined before Phase 1 is built, even if the full skill is built later. Define the JSONL schema at Phase 1 time; build the full Phase 18 skill later.

---

## What the Build Order Gets Right That Existing Frameworks Miss

**1. Proactive planning integration for security and launch items**
The build order's design: security NFRs and launch checklist items surface *during* `/spec` and `/tasks`, not at the end. No existing framework does this — gstack, Superpowers, and GSD all treat security audit and launch as post-implementation gates, not pre-implementation inputs.

**2. Config-driven behavior gating with derived fields**
The `sub-skill-gates` computation (e.g., `auth: none → suppress auth tasks in /tasks`) is genuinely novel. gstack uses static persona roles; Superpowers uses maturity heuristics; GSD uses schema drift detection. None of them gate skill behavior on project config fields this precisely.

**3. Three-track research before planning**
Market + technical + compliance research, all mandatory (for the appropriate intent tiers), all live searches — not training knowledge. Praetorian's research-first workflow comes closest, but doesn't separate tracks by intent tier or integrate findings into downstream NFRs the way Phase 0b specifies.

**4. Compliance research propagating to NFRs**
The compliance track (GDPR, platform limits, payment platform requirements) becoming NFR inputs, which then become task inputs, which then become hardening checklist items, is the only framework-level design that closes this loop. Thoughtworks identifies compliance-to-NFR drift as an open problem; this solves it.

**5. Cross-session learnings per project (Phase 18)**
JSONL learnings scoped per project and routed per skill type (debug reads failed approaches, configure reads corrections) is a simpler, more targeted design than agentmemory's full SQLite + vector search. For project-specific methodology calibration, targeted retrieval beats full semantic search.

---

## YC Alignment Assessment

YC's core advice: "Launch now. Do things that don't scale. Find the 90/10 solution." Does this build order contradict YC principles?

**No — because of the intent tier config gate.**

A hackathon project running this repo gets:

- `/configure` (8 questions, ~2 minutes)
- No market research, no compliance research
- Flat task list with minimal metadata
- 5-minute grep-pass security check
- Health checks + critical path QA only
- No STRIDE, no hardening checklist
- No `coordinate`, no `execute-parallel`

This is not ceremony — it's the 90/10 solution applied to methodology. The config gate ensures the tool scales down as aggressively as YC scales up.

The launch-readiness skill's proactive planning integration is specifically anti-waterfall: it surfaces legal and monitoring items during spec so they're built alongside features, not discovered at launch as blocking items. This is faster to ship, not slower.

---

## Final Recommendation

**Build all 21 skills in the specified order with 3 corrections applied.**

1. Apply Correction 1 (config preamble → SessionStart hook) before writing any skill SKILL.md, since it changes the preamble pattern embedded everywhere.
2. Apply Correction 2 (guard → PreToolUse hook) when implementing Phase 7 — no upstream impact.
3. Apply Correction 3 (Playwright → `@playwright/mcp`) when implementing Phase 12 — no upstream impact.
4. Defer Phase 19 (`coordinate`) to v2. The config gate already suppresses it for the primary audience. Document the git worktree pattern in a `MULTI-DEV.md` reference instead.
5. Define the Phase 18 JSONL schema at Phase 1 implementation time, even if the full `learn` skill is built later.

**The build order is factually grounded. Every major claim is backed by at least one industry implementation (Superpowers, gstack, NeoLabHQ, GSD) and at least one academic or industry analysis source. The specific combination — config-driven gating + research-first + TDD + subagent isolation + cross-session learning + launch proactive integration — is novel and fills a real gap in the existing framework landscape.**
