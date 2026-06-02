# sdlc-engineer v1 — Full Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use `subagent-driven-development` (recommended) or `executing-plans` to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the complete sdlc-engineer v1 skill surface: 3 hooks + /configure + /research + rewire existing orchestrators + 14 new skills covering TDD execution, session persistence, safety guardrails, CI, parallel execution, security audit, QA, monitoring, benchmarking, branch finishing, launch readiness, doc sync, cross-session learning, and retrospective.

**Architecture:** Three-layer design — Layer 0 (hooks.json, fires outside token budget), Layer 1 (auto-invoked skills from chat), Layer 2 (orchestrator skills that dispatch subagents). Config preamble pattern: SessionStart hook injects YAML config once per session; skills read from context, not disk. Guard pattern: PreToolUse hook intercepts at harness level, not in SKILL.md.

**Tech Stack:** Claude Code skills (SKILL.md files), Claude Code hooks (settings.json), YAML config files (.sdlc/project.yml, ~/.sdlc/user.yml), JSONL for session persistence and learnings.

**Reference files:**
- `skills/sdlc-foundation/build-order-research.md` — factual validation + 3 corrections
- `skills/sdlc-foundation/invocation-map.md` — complete invocation spec for every skill

---

## Discovery Phase

### Task 0: Audit existing state

**Files:**
- Read: `skills/*/SKILL.md` (all 27 existing skills)
- Read: `.claude/settings.json` (if exists)
- Produces: gap list used in Tasks 1-30

- [ ] **Step 1: Check for existing hooks config**

```bash
ls -la .claude/settings.json 2>/dev/null && cat .claude/settings.json || echo "NO HOOKS FILE"
```

Expected: either existing JSON to merge into, or "NO HOOKS FILE" (create fresh).

- [ ] **Step 2: Inventory existing skills against invocation-map**

List which skills from the invocation-map already exist in `skills/`:

Already exist (from `ls skills/`):
- `analyze`, `arch-adr`, `arch-c4`, `arch-complexity`, `arch-components`, `arch-decompose`, `arch-sequence`, `arch-use-cases`
- `consult`, `decide`, `design`, `elicit`, `implement`, `spec`
- `req-acceptance`, `req-nfr`, `req-rtm`, `req-srs`, `req-user-stories`
- `deploy-cicd`, `deploy-observability`, `deploy-release-check`, `deploy-rollback`, `deploy-secrets-audit`, `deploy-tier`
- `tasks`, `sdlc-foundation`

Missing (to create):
- `configure` (Phase 0a)
- `research` (Phase 0b)
- `execute-inline` (Phase 2)
- `debug` (Phase 3)
- `review-spec` (Phase 4)
- `execute-subagent` (Phase 5)
- `session-save`, `session-restore` (Phase 6)
- `guard` (Phase 7)
- `ci-verify` (Phase 8)
- `execute-parallel` (Phase 9)
- `audit-security` (Phase 10)
- `qa-headless` (Phase 11)
- `qa-browser` (Phase 12)
- `monitor` (Phase 13)
- `benchmark` (Phase 14)
- `finish-branch` (Phase 15)
- `launch-readiness` (Phase 16)
- `sync-docs` (Phase 17)
- `learn` (Phase 18)
- `retro` (Phase 20)

Existing skills that need patching (diverge from invocation-map):
- `tasks` — current SKILL.md is generic WBS; needs TDD task format + AC-to-test derivation + dependency graph + learnings.jsonl read
- `implement` — current SKILL.md is deploy orchestrator; invocation-map says it's the main SDLC orchestrator (spec → design → tasks → execute loop)
- `spec` — needs project.yml pre-flight gate + config-driven subagent gating
- `design` — needs project.yml pre-flight gate + config-driven subagent gating
- `consult` — needs project.yml awareness + /configure routing

- [ ] **Step 3: Commit discovery notes**

```bash
git add docs/sdlc-engineer/plans/2026-05-16-sdlc-engineer-v1.md
git commit -m "docs: add sdlc-engineer v1 implementation plan"
```

---

## Layer 0 — Hooks

### Task 1: Create hooks config (SessionStart + PreToolUse + Stop)

**Files:**
- Create: `.claude/settings.json`

The SessionStart hook reads `.sdlc/project.yml` and `~/.sdlc/user.yml` and injects them into session context. PreToolUse hook intercepts dangerous bash calls. Stop hook triggers session-save.

- [ ] **Step 1: Create `.claude/` directory and `settings.json`**

```bash
mkdir -p .claude
```

- [ ] **Step 2: Write hooks config**

Create `.claude/settings.json` with this content:

```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "node -e \"\nconst fs = require('fs');\nconst os = require('os');\nconst path = require('path');\nconst projectConfig = path.join(process.cwd(), '.sdlc', 'project.yml');\nconst userConfig = path.join(os.homedir(), '.sdlc', 'user.yml');\nlet msg = '### sdlc-engineer session context\\n';\nif (fs.existsSync(projectConfig)) {\n  msg += '\\n**Project config (.sdlc/project.yml):**\\n```yaml\\n' + fs.readFileSync(projectConfig, 'utf8') + '\\n```\\n';\n} else {\n  msg += '\\n> WARNING: No .sdlc/project.yml found. Run /configure before any other sdlc-engineer skill.\\n';\n}\nif (fs.existsSync(userConfig)) {\n  msg += '\\n**User config (~/.sdlc/user.yml):**\\n```yaml\\n' + fs.readFileSync(userConfig, 'utf8') + '\\n```\\n';\n}\nprocess.stdout.write(msg);\n\""
          }
        ]
      }
    ],
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "node -e \"\nconst input = require('fs').readFileSync('/dev/stdin', 'utf8');\nlet data;\ntry { data = JSON.parse(input); } catch(e) { process.exit(0); }\nconst cmd = (data.tool_input && data.tool_input.command) || '';\nconst dangerous = [\n  /rm\\s+-rf\\s+\\//, \n  /git\\s+reset\\s+--hard/,\n  /git\\s+push\\s+--force/,\n  /DROP\\s+TABLE/i,\n  /DELETE\\s+FROM\\s+\\w+\\s*;/i,\n  />\\.env$/,\n  />\\.env\\./,\n  />\\.key$/,\n  /secrets\\./\n];\nconst matched = dangerous.find(r => r.test(cmd));\nif (matched) {\n  process.stderr.write('GUARD: Dangerous command intercepted: ' + cmd.substring(0, 80) + '\\nConfirm explicitly before proceeding.');\n  process.exit(1);\n}\nprocess.exit(0);\n\""
          }
        ]
      }
    ],
    "Stop": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "node -e \"\nconst fs = require('fs');\nconst path = require('path');\nconst { execSync } = require('child_process');\nconst dir = path.join(process.cwd(), 'docs', 'sdlc-engineer', 'sessions');\nif (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });\nlet branch = 'unknown';\ntry { branch = execSync('git rev-parse --abbrev-ref HEAD', {encoding:'utf8'}).trim(); } catch(e) {}\nconst ts = new Date().toISOString().replace(/[:.]/g, '-').slice(0,19);\nconst file = path.join(dir, branch + '-' + ts + '.md');\nconst content = '# Session checkpoint\\n\\nBranch: ' + branch + '\\nTime: ' + new Date().toISOString() + '\\n\\n_Auto-saved by Stop hook. Restore with /session-restore._\\n';\nfs.writeFileSync(file, content);\n\"\n"
          }
        ]
      }
    ]
  }
}
```

- [ ] **Step 3: Verify hooks file is valid JSON**

```bash
node -e "JSON.parse(require('fs').readFileSync('.claude/settings.json','utf8')); console.log('valid JSON')"
```

Expected: `valid JSON`

- [ ] **Step 4: Test SessionStart hook manually**

```bash
node -e "
const fs = require('fs');
const os = require('os');
const path = require('path');
const projectConfig = path.join(process.cwd(), '.sdlc', 'project.yml');
const userConfig = path.join(os.homedir(), '.sdlc', 'user.yml');
let msg = '### sdlc-engineer session context\n';
if (fs.existsSync(projectConfig)) {
  msg += '\n**Project config:**\n' + fs.readFileSync(projectConfig, 'utf8') + '\n';
} else {
  msg += '\n> WARNING: No .sdlc/project.yml found.\n';
}
console.log(msg);
"
```

Expected: WARNING message (no project.yml exists yet — correct at this stage).

- [ ] **Step 5: Commit**

```bash
git add .claude/settings.json
git commit -m "feat: add Layer 0 hooks (SessionStart, PreToolUse, Stop)"
```

---

## Phase 0a — /configure

### Task 2: Create /configure skill

**Files:**
- Create: `skills/configure/SKILL.md`

Per invocation-map: runs inline (no subagents), ≤8 questions, derives security-tier/launch-tier/sub-skill-gates, writes `.sdlc/project.yml` (committed) and `~/.sdlc/user.yml` (local), reads learnings.jsonl first.

- [ ] **Step 1: Create skills/configure/ directory**

```bash
mkdir -p skills/configure
```

- [ ] **Step 2: Write SKILL.md**

Create `skills/configure/SKILL.md`:

```markdown
---
name: configure
description: Captures project configuration through ≤8 questions and writes .sdlc/project.yml. Must run before any other sdlc-engineer skill. Derives security-tier, launch-tier, and sub-skill-gates from answers. Use when .sdlc/project.yml doesn't exist, when the user says "configure this project", "set up sdlc-engineer", "start a new project", or when any other skill gates on missing config.
---

# /configure — project configuration

Captures project intent in ≤8 questions and writes the config files that gate all downstream skill behavior. No subagents. Runs inline.

## Pre-flight

Before asking questions, check for `docs/sdlc-engineer/learnings.jsonl`. If it exists:
- Read entries of type `config-correction`
- Surface any corrections before asking questions: "Last time, you corrected [field] from [was] to [corrected-to] because [reason]. I'll pre-populate that."
- Pre-populate suggested values from correction history

## Must-ask questions (≤8 total)

Ask these in a single AskUserQuestion call where possible. Pre-populate defaults.

1. **Intent** — What best describes this project?
   - `hackathon` — weekend project, demo, prototype
   - `mvp` — early users, validating product-market fit
   - `production-saas` — live customers, revenue, compliance matters

2. **Audience** — Who are the primary users?
   - `personal` — just me
   - `internal` — team/company only
   - `public` — anyone; and sub-question: `eu-consumers` (triggers GDPR)?

3. **Team size** — How many developers?
   - `solo` — just me
   - `small-2-5` — small team
   - `team-6+` — larger team

4. **Auth** — Does the app have user accounts?
   - `none` — no auth
   - `email` — email/password or magic link
   - `oauth` — social login
   - `enterprise` — SSO/SAML

5. **Monetization** — Does it handle money?
   - `none` — free
   - `one-time` — single purchase
   - `subscription` — recurring billing (Stripe etc.)

6. **Regulated** — Any compliance requirements?
   - `none`
   - `hipaa` — health data
   - `pci-dss` — payment card data
   - `gdpr` — EU personal data (also set if audience: eu-consumers)

7. **Deployment target** — Where does it run?
   - `local-only` — never deployed
   - `cloud` — deployed to cloud host

8. **Stack** (infer from package.json/Gemfile/pyproject.toml/go.mod if present; soft-confirm only):
   - Detected: [show detected stack]
   - Confirm or correct

## Silent inference (never ask)

- `test-runner` — detect from package.json scripts, pytest.ini, etc.
- `ci-platform` — detect from .github/workflows/, .gitlab-ci.yml, Jenkinsfile
- `database` — detect from ORM config, connection strings in .env.example

## Derived fields (compute from answers, don't ask)

```
security-tier:
  if regulated: hipaa or pci-dss → hardened
  elif intent: production-saas OR audience: eu-consumers → standard
  else → minimal

launch-tier:
  if intent: hackathon → minimal
  elif intent: mvp → standard
  else → full

research-tracks:
  market: intent != hackathon
  technical: true (always)
  compliance: regulated != none OR audience: eu-consumers

sub-skill-gates:
  execute-parallel: intent == production-saas OR task-count > 8
  coordinate: team-size != solo
  qa-browser: intent != hackathon
  audit-security-depth: security-tier
  launch-readiness: launch-tier != minimal
  arch-decompose: intent == production-saas
  deploy-observability: intent in [mvp, production-saas]
  deploy-rollback: intent == production-saas
```

## Output format

Write `.sdlc/project.yml` (commit this):

```yaml
# sdlc-engineer project config
# Generated by /configure on YYYY-MM-DD

intent: mvp
audience: public
eu-consumers: false
team-size: solo
auth: email
monetization: none
regulated: none
deployment-target: cloud
stack:
  language: typescript
  framework: next.js
  database: postgres
  test-runner: vitest
  ci: github-actions

# Derived fields (do not edit manually)
security-tier: standard
launch-tier: standard
research-tracks:
  market: true
  technical: true
  compliance: false

sub-skill-gates:
  execute-parallel: false
  coordinate: false
  qa-browser: true
  launch-readiness: true
  arch-decompose: false
  deploy-observability: true
  deploy-rollback: false
```

Write `~/.sdlc/user.yml` (local only, gitignored):

```yaml
# sdlc-engineer user preferences
# Not committed — personal settings only

preferred-verbosity: default  # default | terse | verbose
learnings-path: docs/sdlc-engineer/learnings.jsonl
sessions-path: docs/sdlc-engineer/sessions/
```

## Post-config

After writing both files:
1. Tell the user what was configured and what was derived
2. Recommend next step based on what exists:
   - No spec artifacts → "Run /spec to capture requirements"
   - Spec exists, no design → "Run /design"
   - All artifacts exist → "Run /implement"

## Hard gate

If this skill is invoked by another skill's pre-flight check (not directly by the user), surface the warning and halt: "No .sdlc/project.yml found. Run /configure before continuing."
```

- [ ] **Step 3: Verify file created**

```bash
cat skills/configure/SKILL.md | head -5
```

Expected: frontmatter with `name: configure`

- [ ] **Step 4: Create .sdlc/ directory with .gitkeep and gitignore**

```bash
mkdir -p .sdlc
echo "user.yml" > .sdlc/.gitignore
echo "# .sdlc/ holds project config. user.yml is gitignored (personal preferences)." > .sdlc/README.md
```

- [ ] **Step 5: Create ~/.sdlc/ directory**

```bash
mkdir -p ~/.sdlc
```

- [ ] **Step 6: Commit**

```bash
git add skills/configure/ .sdlc/
git commit -m "feat: add /configure skill (Phase 0a) + .sdlc/ config directory"
```

---

## Phase 0b — /research

### Task 3: Create /research skill

**Files:**
- Create: `skills/research/SKILL.md`

Per invocation-map: three tracks (market/technical/compliance), mandatory live searches (no training knowledge), config-gated, feeds req-nfr + implement pre-flight.

- [ ] **Step 1: Create skills/research/ directory**

```bash
mkdir -p skills/research
```

- [ ] **Step 2: Write SKILL.md**

Create `skills/research/SKILL.md`:

```markdown
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
```

- [ ] **Step 3: Commit**

```bash
git add skills/research/
git commit -m "feat: add /research skill (Phase 0b) — three-track pre-planning research"
```

---

## Existing Skill Patches

### Task 4: Patch /tasks skill

**Files:**
- Modify: `skills/tasks/SKILL.md`

Current SKILL.md: generic WBS producer. Invocation-map requires: TDD task format with AC reference, NFR-in-scope, complexity, dependency graph, file set, failing test (write first), RED command, implementation goal, GREEN command, verification step. Also reads learnings.jsonl, applies config gates.

- [ ] **Step 1: Read current SKILL.md to understand delta**

```bash
cat skills/tasks/SKILL.md
```

- [ ] **Step 2: Replace SKILL.md content**

Write new `skills/tasks/SKILL.md`:

```markdown
---
name: tasks
description: Produces a TDD-formatted work breakdown structure from spec and design artifacts. Each task specifies the failing test to write first, the RED confirmation command, the implementation goal, and the GREEN confirmation command. Reads cross-session learnings to surface anti-patterns. Use when the user asks "break this into tasks", "what do I implement first?", "create the task plan", or as part of /implement orchestration.
---

# /tasks — TDD work breakdown structure

Converts requirements and architecture into implementable engineering tasks using the TDD task format. The output is a dependency-ordered plan file where every task starts with a failing test.

## Pre-flight

1. Project config in session context? If not, run /configure first.
2. Spec artifacts exist (`docs/sdlc-engineer/spec/`)? If not, prompt to run /spec first.
3. Design artifacts exist (`docs/sdlc-engineer/design/`)? If not, prompt to run /design first.
4. Read `docs/sdlc-engineer/learnings.jsonl` if it exists:
   - Surface entries of type `anti-pattern` relevant to this stack/domain
   - Surface entries of type `failed-approach` to add to task implementation notes as "Avoid: ..."

## Config gates applied

```
auth: none → suppress auth tasks
monetization: none → suppress payment tasks
team-size: solo → sequential task list (no parallel wave assignment)
intent: hackathon → flat list, minimal metadata
intent: production-saas → full dependency graph, parallelization analysis
```

## Task format (mandatory — no exceptions)

Every task MUST include all of the following fields:

```markdown
### Task N: [Name]

**AC reference:** [US-001 AC-003] — which acceptance criterion this satisfies
**NFRs in scope:** [PERF-001, SEC-002] — which NFRs this task must not violate
**Complexity:** XS | S | M | L | XL
**Depends on:** Task N-1, Task N-3 (or "none")
**File set:** exact list of files this task touches (parallelization boundary)

**Failing test to write first:**
```[language]
[complete, runnable test code]
```

**RED command:** `[exact command to run the test]`
**Expected RED output:** [what failure message proves the test is correctly wired]

**Implementation goal:** [one sentence — what the implementation does, not how]

**Minimal implementation:**
```[language]
[complete implementation code]
```

**GREEN command:** `[exact command to confirm tests pass]`
**Verification step:** `[command to run full suite and confirm no regressions]`

**Commit:** `feat: Task N — [name] (satisfies [AC reference])`
```

## Dependency graph

After all tasks are defined:

1. Build the dependency graph (which tasks block which)
2. Topological sort → wave assignments
3. Mark parallelizable tasks (file sets must be disjoint)
4. Identify critical path

```
Wave 0: Task 1, Task 2 (no dependencies)
Wave 1: Task 3 (depends on Task 1), Task 4 (depends on Task 2)
Wave 2: Task 5 (depends on Task 3 and Task 4)
Critical path: Task 1 → Task 3 → Task 5
```

Parallelization note: Tasks are parallelizable iff their file sets are disjoint AND no task depends on another in the same wave.

## Output

Save plan to: `docs/sdlc-engineer/plans/YYYY-MM-DD-[feature].md`

Plan file header:
```markdown
# [Feature] Task Plan
Generated: YYYY-MM-DD
AC coverage: [US-001 through US-004]
NFRs in scope: [list]
Estimated waves: N
Parallelizable tasks: N of M

## Anti-patterns to watch (from learnings.jsonl)
[entries surfaced from learnings, or "none recorded"]

## Tasks
[task list]

## Dependency graph
[wave assignments + critical path]
```

## The RED confirmation rule

If the RED step is skipped, or if the test passes before implementation is written: **STOP**. Flag it as a test integrity failure. Do not continue. Restart the task with a properly failing test.

This is enforced. Persuasion scenarios ("I already know what to implement", "the test is obviously right") do not override this rule.

## Anti-patterns flagged

- Tasks with no AC reference → add it or flag as scope creep
- "Test the above" without actual test code → not a valid task step
- File sets that overlap between tasks assigned to the same wave → move one to next wave
- Implementation written before RED confirmed → flag as test integrity failure
```

- [ ] **Step 3: Verify**

```bash
head -5 skills/tasks/SKILL.md
```

Expected: frontmatter with updated description.

- [ ] **Step 4: Commit**

```bash
git add skills/tasks/SKILL.md
git commit -m "feat: rewrite /tasks skill with TDD task format + dependency graph + learnings integration"
```

---

### Task 5: Patch /implement skill

**Files:**
- Modify: `skills/implement/SKILL.md`

Critical: current implement is the deploy orchestrator. Invocation-map says /implement is the MAIN SDLC orchestrator (the big one that runs the full execute loop). The deploy cluster is under /ship in the invocation-map. Need to check what /ship skill exists vs what the deploy skills are mapped to.

- [ ] **Step 1: Check current deploy skill landscape**

```bash
ls skills/deploy-* skills/ship 2>/dev/null
```

Note: the deploy-* skills exist but there's no /ship skill. The invocation-map puts the QA+security+deploy+launch cluster under `/ship`, not `/implement`. The current `/implement` SKILL.md describes the deploy orchestrator. Need to:

1. Rename current implement to ship (or create ship that chains deploy-*)
2. Rewrite implement to be the SDLC execution orchestrator

- [ ] **Step 2: Create /ship skill (wrapping existing deploy skills)**

```bash
mkdir -p skills/ship
```

Create `skills/ship/SKILL.md`:

```markdown
---
name: ship
description: Orchestrates the shipping phase: security audit, QA (headless + browser), monitoring setup, benchmarking, deployment, launch readiness verification, and doc sync. Run after /implement completes all tasks. Chains audit-security → qa-headless → qa-browser → monitor → benchmark → deploy cluster → launch-readiness → sync-docs.
---

# /ship — shipping orchestrator

Runs the full shipping sequence after all implementation tasks are complete and CI is green.

## Pre-flight

- All /implement tasks complete
- Full test suite green
- CI green (if CI exists)
- finish-branch PASS

## Sequence

```
subagent 1  → audit-security   (always, depth = security-tier)
subagent 2  → qa-headless      (always, depth = intent)
subagent 3  → qa-browser       (gate: intent != hackathon AND @playwright/mcp installed)
subagent 4  → monitor          (gate: intent: mvp or production-saas)
subagent 5  → benchmark        (gate: intent: production-saas)
subagents 6-11 → deploy cluster (gate: deployment-target != local-only)
  → deploy-tier
  → deploy-cicd
  → deploy-observability
  → deploy-secrets-audit
  → deploy-release-check
  → deploy-rollback
subagent 12 → launch-readiness (gate: launch-tier: standard or full)
subagent 13 → sync-docs        (always)
```

See invocation-map.md for full gate conditions and depth calibration per intent tier.
```

- [ ] **Step 3: Rewrite /implement SKILL.md**

Replace `skills/implement/SKILL.md` content:

```markdown
---
name: implement
description: Main SDLC execution orchestrator. Runs the full implementation loop: pre-flight checks, optional research subagent, task planning, and per-task TDD execution (write test → RED → implement → GREEN → review-spec → commit). Chains execute-inline / execute-subagent / execute-parallel based on task count and tool availability. Use when the user says "implement this", "build it", "let's start coding", "execute the plan", or after /spec + /design artifacts exist.
---

# /implement — SDLC execution orchestrator

Runs the complete implementation sequence from pre-flight through task execution to CI verification.

## Pre-flight checks (in order)

1. `project.yml` in session context? → if not, invoke /configure first
2. Spec artifacts exist (`docs/sdlc-engineer/spec/`)? → if not, prompt to run /spec first
3. Design artifacts exist (`docs/sdlc-engineer/design/`)? → if not, prompt to run /design first
4. Research brief exists and < 7 days old?
   → if not AND `research-tracks.technical: true` → invoke research subagent
5. Session checkpoint exists for this branch?
   → if yes, invoke session-restore subagent first

## Subagent sequence

### Subagent 0 — research (conditional)
Gate: `research-tracks.technical: true` AND no recent research brief
Produces: technical brief (library health, CVEs, architecture patterns)
Feeds: req-nfr updates, task implementation notes

### Subagent 1 — tasks
Produces: plan file with per-task TDD structure
Gate: always runs (unless plan file already exists and is current)
Config gates: see /tasks skill for full gate list
Reads: learnings.jsonl → surfaces anti-patterns and failed approaches

### Task execution loop

For each task wave (grouped by dependency graph):

**Parallelization decision:**
```
IF task count in wave > 1
AND file sets are disjoint
AND (task count total > 8 OR team-size: small-2-5+)
AND Claude Code Task tool available
→ execute-parallel (all wave tasks simultaneously, each in own worktree)

ELIF Claude Code Task tool available
→ execute-subagent (fresh context per task, sequential)

ELSE
→ execute-inline (current session, sequential, fallback)
```

**Per task (in execute-subagent or execute-parallel):**
1. Write failing test exactly as specified in plan
2. Run RED confirmation
   - If test already passes: STOP — flag test integrity failure — do not continue
3. Write minimal implementation
4. Run GREEN confirmation
   - If still failing: invoke debug subagent immediately
   - Do not attempt second implementation without diagnosis
5. Run full suite — confirm no regressions
6. Check NFRs in scope for this task
7. Commit: `feat: Task N — name (satisfies AC ref)`

**After each task:**
→ review-spec subagent (input: task AC + git diff ONLY — no codebase context)
  - PASS → continue to code quality review
  - FAIL → return to execute-subagent with failure reason
→ quality reviewer subagent (input: diff + ADRs + coding standards ONLY)
  - PASS/WARN → continue
  - BLOCK → return to execute-subagent

**After each wave:**
→ run integration tests before next wave starts

### Context management

Every 3 tasks: checkpoint report (tasks done, tests added, NFR violations, context window %)
If context window approaching limit: trigger session-save before continuing

### After all tasks complete

→ ci-verify subagent
  Gate: branch pushed AND CI config exists AND gh/glab CLI available
  Polls for CI completion (timeout: 10 min)

→ finish-branch subagent
  Pre-flight: all tasks complete + suite green + CI green + spec compliance PASS
  Presents 4 options: merge / PR / keep / discard
```

- [ ] **Step 4: Commit**

```bash
git add skills/implement/SKILL.md skills/ship/
git commit -m "feat: rewrite /implement as SDLC orchestrator + add /ship for deploy/QA cluster"
```

---

### Task 6: Patch /spec and /design pre-flight gates

**Files:**
- Modify: `skills/spec/SKILL.md`
- Modify: `skills/design/SKILL.md`

Both need: (1) project.yml pre-flight gate, (2) config-driven subagent gating (e.g., auth: none → suppress auth NFRs, audience: eu-consumers → require GDPR NFRs).

- [ ] **Step 1: Add pre-flight gate to spec/SKILL.md**

Find the "Procedure" / "Step 1" section in `skills/spec/SKILL.md` and prepend:

```markdown
## Pre-flight

Read project config from session context (injected by SessionStart hook).
If no config in context, check for `.sdlc/project.yml` directly.
If neither exists: "No project config found. Run /configure before /spec."

## Config gates applied to req-nfr subagent

```
auth: none → suppress auth NFRs
monetization: none → suppress payment NFRs
audience: eu-consumers → require GDPR NFRs
regulated: hipaa → require audit trail NFRs
security-tier: standard+ → require HSTS, CSP, RLS, RBAC NFRs
```
```

- [ ] **Step 2: Add pre-flight gate to design/SKILL.md**

Add before "Procedure" section:

```markdown
## Pre-flight

Read project config from session context.
If no config: check `.sdlc/project.yml`. If neither: run /configure first.
Spec artifacts must exist before design runs. If missing: "Run /spec first."

## Config gates applied

```
auth: email+ → require cookie consent mechanism component
intent: production-saas → require error monitoring component
audience: eu-consumers → require cookie consent banner component
arch-decompose gate: ONLY if arch-complexity flags distributed system risk
  AND intent: production-saas + distributed complexity
```
```

- [ ] **Step 3: Commit**

```bash
git add skills/spec/SKILL.md skills/design/SKILL.md
git commit -m "feat: add project.yml pre-flight gates and config-driven NFR gating to /spec and /design"
```

---

### Task 7: Patch /consult skill

**Files:**
- Modify: `skills/consult/SKILL.md`

Add: project.yml awareness (read config from context, route to /configure if missing).

- [ ] **Step 1: Add config awareness to Step 1 of consult**

Find the "Step 1 — Assess" section and add:

```markdown
- **Config state?** Is project config in session context (injected by SessionStart hook)? If not and `.sdlc/project.yml` doesn't exist → recommend /configure as the first step before anything else.
```

- [ ] **Step 2: Commit**

```bash
git add skills/consult/SKILL.md
git commit -m "feat: add project config awareness to /consult"
```

---

## Phase 2 — /execute-inline

### Task 8: Create /execute-inline skill

**Files:**
- Create: `skills/execute-inline/SKILL.md`

Per invocation-map: validates task format, single-session execution, commit-per-task discipline, never touches files outside declared file set.

- [ ] **Step 1: Create directory and SKILL.md**

```bash
mkdir -p skills/execute-inline
```

Create `skills/execute-inline/SKILL.md`:

```markdown
---
name: execute-inline
description: Executes a single task from a plan file in the current session. Validates TDD format, writes failing test first, confirms RED, writes minimal implementation, confirms GREEN, checks NFRs, commits. Fallback when Claude Code Task tool is unavailable. Use when /implement routes here, or when user says "execute this task inline".
---

# /execute-inline — single-task inline execution

Executes one task from the plan file in the current session. Used as the fallback when execute-subagent is unavailable (no Claude Code Task tool).

## Input

A single task block from the plan file. The task must have all required TDD fields (see /tasks skill for format).

## Execution steps (mandatory order — no skipping)

1. **Read the task** — verify all required fields are present: AC reference, file set, failing test, RED command, implementation goal, GREEN command
2. **Write the failing test** exactly as specified in the plan (copy verbatim — do not modify)
3. **Run RED command** — confirm the test fails with the expected error
   - If test passes: STOP — report test integrity failure — do not continue
   - If test fails with unexpected error: report the actual error and ask how to proceed
4. **Write minimal implementation** — implement only enough to make the test pass
5. **Run GREEN command** — confirm the test passes
   - If still failing: do NOT attempt a second implementation — invoke /debug first
6. **Run full suite** — confirm no regressions introduced
7. **Check NFRs in scope** — verify the NFRs listed in the task are not violated
8. **Commit**: `feat: Task N — [name] (satisfies [AC reference])`

## File set discipline

Never modify files outside the task's declared file set without flagging it.
If a file not in the declared set needs to change: stop, report it, get confirmation, update the plan file, then proceed.

## Failure modes

- Test fails with unexpected error → report actual error text, ask whether to debug or revise test
- Implementation causes regression → do not commit, invoke /debug with the regression details
- NFR violated → do not commit, flag the violation, ask whether to fix or document as known issue
```

- [ ] **Step 2: Commit**

```bash
git add skills/execute-inline/
git commit -m "feat: add /execute-inline skill (Phase 2)"
```

---

## Phase 3 — /debug

### Task 9: Create /debug skill

**Files:**
- Create: `skills/debug/SKILL.md`

Per invocation-map: 4-phase root cause process (reproduce → isolate → hypothesize → verify), writes to learnings.jsonl after completion.

- [ ] **Step 1: Create directory and SKILL.md**

```bash
mkdir -p skills/debug
```

Create `skills/debug/SKILL.md`:

```markdown
---
name: debug
description: 4-phase root cause debugging process. Triggers on "this test is failing", "getting an error", "it's broken", "why isn't X working", "it crashed", "exception", "undefined", or when /execute-inline or /execute-subagent gets a failing GREEN step. Writes findings to learnings.jsonl after completion.
---

# /debug — 4-phase root cause process

Systematic debugging using a 4-phase root cause methodology. No guessing. No second implementation attempts without diagnosis.

## Trigger phrases (auto-invoke from chat)

- "this test is failing"
- "getting an error"
- "it's broken" / "it crashed"
- "why isn't X working"
- "exception" / "undefined" / "null pointer"
- Invoked by execute-inline or execute-subagent when GREEN step fails

## Phase 0 — Reproduce

Confirm the failure is consistent before doing anything else.

```bash
# Run the failing command exactly as reported
[failing command]
```

- If failure is NOT reproducible: report this — intermittent failures are a different problem class (race condition, network dependency, environment-specific)
- If reproducible: proceed to Phase 1

## Phase 1 — Isolate

Binary search to find the minimal reproduction case.

Techniques (apply in order):
1. **Which commit introduced it?** `git bisect` if failure is recent regression
2. **Which input triggers it?** Simplify the input until the failure disappears, then add back
3. **Which layer?** Unit test the components in isolation — does the failure exist at the function level or only at integration?
4. **Which environment?** Does it fail locally but not in CI, or vice versa?

Output: minimal reproduction case — the smallest input/state that reliably triggers the failure.

## Phase 2 — Hypothesize

Generate root cause candidates, ranked by likelihood. Do not investigate all of them — start with the most likely.

For each candidate:
- What would explain the observed failure?
- What evidence would confirm or deny it?

Common root cause categories (check in this order):
1. Wrong assumption about input shape or type
2. Missing null/undefined check at a boundary
3. Off-by-one or incorrect range
4. Race condition / async ordering issue
5. Environment variable missing or wrong value
6. Import/dependency version mismatch
7. Stale cache or test state leaked between runs

## Phase 3 — Verify fix

Write the fix. Then:

1. Run the originally failing test — confirm GREEN
2. Run the full suite — confirm no regressions
3. If the fix reveals a gap in test coverage: add a test that would have caught this failure earlier

## After completion — write to learnings.jsonl

Append to `docs/sdlc-engineer/learnings.jsonl`:

```json
{"type": "root-cause", "date": "YYYY-MM-DD", "symptom": "...", "root-cause": "...", "fix": "...", "relevant-skills": ["execute-inline"]}
```

And if a failed approach was tried:
```json
{"type": "failed-approach", "date": "YYYY-MM-DD", "approach": "...", "why-failed": "...", "relevant-skills": ["debug"]}
```

## Anti-patterns

- Writing a second implementation without diagnosing the first failure → blocked
- "Fixing" the test to make it pass without understanding the failure → blocked
- Committing a fix without running the full suite → blocked
```

- [ ] **Step 2: Create learnings.jsonl directory**

```bash
mkdir -p docs/sdlc-engineer
touch docs/sdlc-engineer/.gitkeep
```

- [ ] **Step 3: Commit**

```bash
git add skills/debug/ docs/sdlc-engineer/
git commit -m "feat: add /debug skill (Phase 3) + docs/sdlc-engineer/ artifact directory"
```

---

## Phase 4 — /review-spec

### Task 10: Create /review-spec skill

**Files:**
- Create: `skills/review-spec/SKILL.md`

Per invocation-map: context isolation principle (only sees task AC + git diff, no codebase context), produces PASS/FAIL/WARN, then routes to quality reviewer subagent.

- [ ] **Step 1: Create directory and SKILL.md**

```bash
mkdir -p skills/review-spec
```

Create `skills/review-spec/SKILL.md`:

```markdown
---
name: review-spec
description: Spec compliance reviewer. Receives ONLY the task acceptance criteria and git diff — no codebase context. Produces PASS, FAIL, or WARN verdict. Context isolation is the core correctness property: the reviewer cannot be biased by knowing the implementer's intent. Invoked after each task by /implement.
---

# /review-spec — spec compliance review

Verifies that the implementation satisfies the task's acceptance criteria. Context isolation is mandatory.

## Context contract (enforced)

Input contains ONLY:
- The task's AC reference (Gherkin Given/When/Then)
- The git diff for this task

Does NOT receive:
- Full codebase
- Implementation plan
- Prior conversation context
- The implementer's explanation of what they did

This isolation prevents the most common review failure: approving an implementation because the reviewer understood the intent, not because the code satisfies the acceptance criterion.

## Review procedure

For each Given/When/Then in the task's AC:

1. **Find the implementation** in the diff that handles this scenario
2. **Check the "Given" (precondition)** — is the required state established?
3. **Check the "When" (action)** — is the triggering action handled?
4. **Check the "Then" (outcome)** — does the implementation produce the specified outcome?

## Verdicts

**PASS:** All Given/When/Then scenarios are satisfied by the diff. Implementation matches AC exactly.

**WARN:** The AC is satisfied, but the reviewer notes a potential issue that doesn't block (e.g., edge case not covered by AC but likely to matter, or implementation is more complex than the AC requires). Provide specific note.

**FAIL:** One or more Given/When/Then scenarios are NOT satisfied. Specify which AC clause fails and what the diff does instead.

On FAIL: return to execute-subagent with:
```
FAIL: AC clause [Given/When/Then text] not satisfied.
Diff shows: [what the code actually does]
Expected: [what the AC requires]
```

## After PASS — quality review

Invoke quality reviewer subagent with:
- Input: git diff + ADRs + coding standards ONLY (no codebase context)
- Verdicts: PASS / WARN / BLOCK
- On BLOCK: return to execute-subagent with specific issue
```

- [ ] **Step 2: Commit**

```bash
git add skills/review-spec/
git commit -m "feat: add /review-spec skill (Phase 4) — context-isolated spec compliance review"
```

---

## Phase 5 — /execute-subagent

### Task 11: Create /execute-subagent skill

**Files:**
- Create: `skills/execute-subagent/SKILL.md`

Per invocation-map: fresh Claude instance per task, clean 200K token context, main conversation only dispatches. Falls back to execute-inline if Task tool unavailable.

- [ ] **Step 1: Create directory and SKILL.md**

```bash
mkdir -p skills/execute-subagent
```

Create `skills/execute-subagent/SKILL.md`:

```markdown
---
name: execute-subagent
description: Dispatches each task to a fresh Claude subagent with a clean context window. Each subagent gets only its task + file context — no accumulated session noise. Falls back to /execute-inline if Claude Code Task tool is unavailable. Use when /implement routes sequential subagent execution.
---

# /execute-subagent — fresh-context task execution

Dispatches tasks to fresh Claude subagents. Each task gets a 200K token context with no pollution from prior tasks.

## Why fresh context per task

"Context rot" is the #1 failure mode in long implementation sessions: accumulated decisions, failed approaches, and implementation details from previous tasks pollute the model's judgment. A fresh subagent starts clean.

Main conversation token load stays at 30-40% — it dispatches and reviews, does not implement.

## Dispatch protocol

For each task:

1. **Prepare subagent context:**
   ```
   You are implementing Task N: [name]
   
   AC reference: [Gherkin AC]
   NFRs in scope: [list]
   File set: [exact files to touch]
   
   Task:
   [full task block from plan file]
   
   Learnings to avoid (from learnings.jsonl):
   [relevant anti-patterns and failed approaches]
   ```

2. **Dispatch via Claude Code Task tool**

3. **Receive output:** commit hash + GREEN confirmation + any NFR warnings

4. **Route to review-spec:** pass AC + git diff

5. **On review-spec FAIL:** re-dispatch subagent with failure reason and instruction to fix

## Fallback

If Claude Code Task tool is not available in this session:
- Log: "Task tool unavailable — falling back to execute-inline"
- Route to /execute-inline for current-session sequential execution

## Context budget

Subagent context contains:
- Task block (~500 tokens)
- AC and NFRs (~200 tokens)
- Relevant files (variable)
- Learnings entries (~100 tokens)

Do NOT include: prior tasks, full codebase, session history.
```

- [ ] **Step 2: Commit**

```bash
git add skills/execute-subagent/
git commit -m "feat: add /execute-subagent skill (Phase 5) — fresh-context per-task execution"
```

---

## Phase 6 — /session-save and /session-restore

### Task 12: Create /session-save and /session-restore skills

**Files:**
- Create: `skills/session-save/SKILL.md`
- Create: `skills/session-restore/SKILL.md`
- Create: `docs/sdlc-engineer/sessions/` directory

Per invocation-map: auto-save via Stop hook (already wired in Task 1), manual /session-save for mid-session checkpoints, /session-restore reads most recent checkpoint for current branch.

- [ ] **Step 1: Create directories**

```bash
mkdir -p skills/session-save skills/session-restore docs/sdlc-engineer/sessions
echo "# Session checkpoints" > docs/sdlc-engineer/sessions/.gitkeep
```

- [ ] **Step 2: Write session-save SKILL.md**

Create `skills/session-save/SKILL.md`:

```markdown
---
name: session-save
description: Saves session state to a markdown checkpoint file. Auto-triggered by Stop hook at session end, by /implement every 3 tasks, and when context window approaches limit. Manual trigger: /session-save. Writes to docs/sdlc-engineer/sessions/<branch>-<timestamp>.md.
---

# /session-save — session checkpoint

Writes a session checkpoint that /session-restore can load in a fresh session.

## Triggers

- **Auto (Stop hook):** fires at session end — already wired in .claude/settings.json
- **Auto (/implement):** fires every 3 tasks, and when context window > 80%
- **Manual:** user invokes /session-save explicitly ("save session", "checkpoint")

## What to capture

```markdown
# Session checkpoint
Branch: [git rev-parse --abbrev-ref HEAD]
Timestamp: [ISO timestamp]
Plan file: [path to active plan file]

## Completed tasks
[list of task IDs with commit hashes]

## Remaining tasks
[list of task IDs not yet started or in progress]

## Decisions made this session
[any architectural or implementation decisions not in plan]

## Failed approaches (do not retry)
[brief notes on approaches that didn't work]

## Git state
Last commit: [git log -1 --oneline]
Branch status: [git status --short]

## Context at save
[current task if interrupted mid-task, what step it was on]
```

## Write location

`docs/sdlc-engineer/sessions/[branch]-[YYYY-MM-DD-HHMMSS].md`

Always use branch name + timestamp — never overwrite a checkpoint.
```

- [ ] **Step 3: Write session-restore SKILL.md**

Create `skills/session-restore/SKILL.md`:

```markdown
---
name: session-restore
description: Restores session state from the most recent checkpoint for the current git branch. Auto-triggered by /implement pre-flight if a checkpoint exists. Manual trigger: /session-restore. Announces what was restored before continuing.
---

# /session-restore — session state restoration

Loads the most recent session checkpoint for the current branch and announces what was restored.

## Auto-trigger

/implement pre-flight checks for a checkpoint matching the current branch. If found, invokes this skill first.

## Manual trigger

User says "/session-restore", "restore session", "pick up where we left off".

## Procedure

1. **Find checkpoint:**
   ```bash
   ls docs/sdlc-engineer/sessions/ | grep "$(git rev-parse --abbrev-ref HEAD)" | sort | tail -1
   ```

2. **Read checkpoint file** — extract: completed tasks, remaining tasks, decisions, failed approaches, last commit

3. **Verify git state** — does current HEAD match the checkpoint's last commit?
   - Match: announce restore and continue
   - Mismatch: warn "Git state has changed since checkpoint. Commits since checkpoint: [list]. Verify remaining tasks are still valid before continuing."

4. **Announce restore:**
   ```
   Session restored from [timestamp].
   
   Completed: Tasks 1-4 ([commit hash])
   Remaining: Tasks 5-8
   Decisions carried forward: [list]
   Failed approaches to avoid: [list]
   
   Continuing from Task 5: [name]
   ```

5. **Continue** from the first incomplete task.
```

- [ ] **Step 4: Commit**

```bash
git add skills/session-save/ skills/session-restore/ docs/sdlc-engineer/sessions/
git commit -m "feat: add /session-save and /session-restore skills (Phase 6)"
```

---

## Phase 7 — /guard

### Task 13: Create /guard skill

**Files:**
- Create: `skills/guard/SKILL.md`

Per invocation-map + Correction 2: SKILL.md defines what to guard. PreToolUse hook in settings.json does the actual interception (already wired in Task 1). Also handles freeze mode.

- [ ] **Step 1: Create directory and SKILL.md**

```bash
mkdir -p skills/guard
```

Create `skills/guard/SKILL.md`:

```markdown
---
name: guard
description: Safety guardrails configuration. The actual interception runs via PreToolUse hook in .claude/settings.json — this skill documents the intercept list and manages freeze mode. Use when user says "enable freeze mode", "freeze this path", "disable guard", or to understand what the guard intercepts.
---

# /guard — safety guardrails

Guard operates at the Claude Code harness level via PreToolUse hook — it does not rely on model cooperation. This SKILL.md documents behavior and manages freeze mode.

## What the PreToolUse hook intercepts

The hook fires before every Bash tool call and blocks these patterns:

| Pattern | Risk |
|---|---|
| `rm -rf /` or `rm -rf` outside current working directory | Catastrophic file deletion |
| `git reset --hard` | Irreversible commit loss |
| `git push --force` | Overwrites remote history |
| `DROP TABLE` (case-insensitive) | Irreversible data loss |
| `DELETE FROM <table>;` without WHERE | Full table wipe |
| Writes to `.env`, `*.key`, `secrets.*` | Credential exposure |
| Writes to files outside declared task file set | Scope violation |

On intercept: the hook exits with code 1 and prints:
```
GUARD: Dangerous command intercepted: [command preview]
Confirm explicitly before proceeding.
```

## Freeze mode

`/guard freeze <path>` — blocks all writes outside `<path>` until unfrozen.

When freeze mode is active, any Bash write command targeting a path outside the frozen path is intercepted with:
```
GUARD: Freeze mode active. Writes restricted to [frozen path].
```

To activate freeze mode, the user stores a `.sdlc/freeze` file with the frozen path. The PreToolUse hook checks for this file.

`/guard unfreeze` — removes `.sdlc/freeze`.

## Viewing guard status

```
/guard status
```

Outputs:
- Hook file location and whether it's installed
- Freeze mode: active/inactive + frozen path
- Recent intercepts (from session log if available)

## Implementation note

The guard's blocking logic lives in `.claude/settings.json` PreToolUse hook. This SKILL.md does NOT reimplement the logic — it only documents it and manages freeze mode config. Modifying this file alone does NOT change guard behavior. To change what is intercepted, edit `.claude/settings.json`.
```

- [ ] **Step 2: Commit**

```bash
git add skills/guard/
git commit -m "feat: add /guard skill (Phase 7) — documents PreToolUse hook, manages freeze mode"
```

---

## Phase 8 — /ci-verify

### Task 14: Create /ci-verify skill

**Files:**
- Create: `skills/ci-verify/SKILL.md`

Per invocation-map: detects CI platform, pushes if needed, polls for completion, surfaces specific failure step. Graceful fallback if gh/glab unavailable.

- [ ] **Step 1: Create directory and SKILL.md**

```bash
mkdir -p skills/ci-verify
```

Create `skills/ci-verify/SKILL.md`:

```markdown
---
name: ci-verify
description: Pushes the current branch, polls CI for completion, and surfaces specific failure steps. Detects GitHub Actions (gh CLI) or GitLab CI (glab CLI). Graceful fallback if no CLI available. Invoked by /implement after all tasks complete.
---

# /ci-verify — CI integration verification

Ensures CI passes before finish-branch runs.

## Pre-flight

1. Check if branch has been pushed:
   ```bash
   git status -sb | head -1
   ```
   If not tracking remote: push first.

2. Detect CI platform:
   ```bash
   ls .github/workflows/ 2>/dev/null && echo "github"
   ls .gitlab-ci.yml 2>/dev/null && echo "gitlab"
   ls Jenkinsfile 2>/dev/null && echo "jenkins"
   ls .circleci/ 2>/dev/null && echo "circleci"
   ```

3. Check CLI availability:
   ```bash
   which gh 2>/dev/null && echo "gh available"
   which glab 2>/dev/null && echo "glab available"
   ```

## GitHub Actions flow (gh CLI available)

```bash
# Push if needed
git push -u origin HEAD

# Wait for CI (10 min timeout)
gh run watch --exit-status

# If fails, get the specific step
gh run view --log-failed
```

## GitLab CI flow (glab CLI available)

```bash
git push -u origin HEAD
glab ci status --wait
glab ci view  # on failure
```

## No CLI available (fallback)

```
CI CLI not available (gh/glab not installed).
CI verification skipped.

Branch URL: [git remote get-url origin + branch path]
Check CI status manually before merging.
```

Do NOT block execution — log warning and continue to finish-branch.

## Failure handling

On CI failure:
- Surface the specific step that failed (not just "CI failed")
- Categorize failure:
  - **Test failure** → actionable: "Test X failed in step Y. Return to debug."
  - **Build failure** → actionable: "Build failed: [error]. Fix the compilation error."
  - **Infrastructure failure** → retry recommended: "Runner out of resources. Retry the workflow."
  - **Timeout** → "CI timed out. Check for infinite loops or slow tests."

## Timeout

Poll for max 10 minutes. If still running after 10 min:
```
CI still running after 10 minutes.
Branch URL: [url]
Continue polling manually or check the CI dashboard.
```
```

- [ ] **Step 2: Commit**

```bash
git add skills/ci-verify/
git commit -m "feat: add /ci-verify skill (Phase 8) — CI platform detection + graceful fallback"
```

---

## Phase 9 — /execute-parallel

### Task 15: Create /execute-parallel skill

**Files:**
- Create: `skills/execute-parallel/SKILL.md`

Per invocation-map: git worktree per task, wave-based parallelization, file-set disjointness check. Config gate: task count > 8 OR team-size small-2-5+.

- [ ] **Step 1: Create directory and SKILL.md**

```bash
mkdir -p skills/execute-parallel
```

Create `skills/execute-parallel/SKILL.md`:

```markdown
---
name: execute-parallel
description: Executes multiple tasks simultaneously using git worktrees — one worktree per task. Tasks must have disjoint file sets. Uses wave-based topological sort from the dependency graph. Requires Claude Code Task tool. Activated when task count > 8 or team-size is small-2-5+.
---

# /execute-parallel — wave-based parallel task execution

Executes tasks in parallel using git worktrees for isolation. Each task runs in its own worktree with a fresh Claude subagent.

## Prerequisites

- Git ≥ 2.5 (worktrees available)
- Claude Code Task tool available
- Tasks have disjoint file sets (verified before dispatch)

## Wave algorithm

```
Input: task list with dependency graph

Wave 0: tasks with no dependencies
Wave 1: tasks whose dependencies are all in Wave 0
Wave N: tasks whose dependencies are all in Waves 0 through N-1

Execute all tasks in Wave N in parallel.
Wait for Wave N to complete before starting Wave N+1.
Run integration tests between waves.
```

## Worktree setup per task

```bash
# Create isolated worktree for each task in the wave
git worktree add ../[project]-task-[N] [current-branch]
```

Each worktree:
- Starts from the same commit as the current branch
- Has its own working directory (no file conflicts)
- Gets its own fresh Claude subagent via Task tool

## Dispatch protocol

For each task in the current wave:
```
Task tool input:
  Working directory: ../[project]-task-[N]
  Context: task block + AC + file set + learnings
  Instruction: execute-inline procedure (write test → RED → implement → GREEN → commit)
```

## Merge protocol

After all tasks in a wave complete:

```bash
# For each worktree, in dependency order:
git checkout [current-branch]
git merge ../[project]-task-[N]/[branch] --no-ff -m "merge: Task N — [name]"
git worktree remove ../[project]-task-[N]
```

Conflict resolution: if merge conflict arises (file sets should be disjoint, so this indicates a planning error), halt and report: "File conflict during merge of Task N and Task M — their file sets were not truly disjoint. Resolve manually."

## File set validation

Before dispatching any wave, verify disjointness:

```python
# Pseudocode — run before dispatch
for task_a, task_b in combinations(wave_tasks, 2):
    overlap = set(task_a.file_set) & set(task_b.file_set)
    if overlap:
        error(f"Tasks {task_a.id} and {task_b.id} share files: {overlap}")
        error("Assign one to next wave. Do not dispatch.")
```

## Config gate

Activated when ANY of:
- Total task count > 8
- `team-size: small-2-5` or `team-6+`
- `intent: production-saas` AND wave has > 1 task

Solo + short task list → execute-subagent (sequential). Don't force parallelism where it doesn't help.
```

- [ ] **Step 2: Commit**

```bash
git add skills/execute-parallel/
git commit -m "feat: add /execute-parallel skill (Phase 9) — git worktree wave-based execution"
```

---

## Phase 10 — /audit-security

### Task 16: Create /audit-security skill

**Files:**
- Create: `skills/audit-security/SKILL.md`

Per invocation-map: three depths (minimal/standard/hardened), OWASP Top 10 + STRIDE, secrets archaeology for hardened tier. Invoked by /ship.

- [ ] **Step 1: Create directory and SKILL.md**

```bash
mkdir -p skills/audit-security
```

Create `skills/audit-security/SKILL.md`:

```markdown
---
name: audit-security
description: Security audit at depth calibrated to security-tier config. Minimal: 5-minute grep pass. Standard: OWASP Top 10 + STRIDE threat model. Hardened: full OWASP + STRIDE + secrets archaeology. Invoked by /ship. Confidence gate varies by tier.
---

# /audit-security — security audit

Depth calibrated to `security-tier` from project config.

## security-tier: minimal (hackathon)

5-minute grep pass only:

```bash
# SQL injection via string concatenation
grep -r "query.*+.*req\." --include="*.js" --include="*.ts" --include="*.py"

# Hardcoded credentials
grep -r "password\s*=\s*['\"]" --include="*.js" --include="*.ts" --include="*.py" --include="*.go"

# Unescaped innerHTML
grep -r "innerHTML\s*=" --include="*.js" --include="*.ts" --include="*.jsx" --include="*.tsx"

# Missing auth middleware on routes
grep -r "router\.\(get\|post\|put\|delete\)" --include="*.js" --include="*.ts"
```

Confidence gate: only flag findings with >8/10 confidence. At hackathon tier, prefer false negatives over false positives.

## security-tier: standard (mvp/internal)

OWASP Top 10 scan + STRIDE threat model:

**OWASP Top 10 grep scan (scoped to detected stack):**

```bash
# A01 Broken Access Control
grep -r "isAdmin\|hasPermission\|authorize" --include="*.ts" --include="*.js"
# Look for: routes without auth middleware, direct object references without ownership check

# A02 Cryptographic Failures
grep -r "md5\|sha1\|Math.random\(\)" --include="*.ts" --include="*.js"
# Look for: weak hashing, predictable tokens, HTTP (not HTTPS) URLs in config

# A03 Injection
grep -r "exec\|spawn\|eval\|Function(" --include="*.ts" --include="*.js"
# Look for: unsanitized user input in shell commands, dynamic code execution

# A05 Security Misconfiguration
grep -r "debug.*true\|NODE_ENV.*development" --include="*.ts" --include="*.js" --include="*.json"
# Look for: debug mode in production config, verbose error messages

# A07 Auth Failures
grep -r "session\|cookie\|jwt" --include="*.ts" --include="*.js"
# Look for: missing httpOnly, missing secure flag, weak secret
```

**STRIDE threat model** (against arch-components + arch-c4 artifacts):
- **S**poofing: can a user impersonate another user or system component?
- **T**ampering: can a user modify data they shouldn't be able to?
- **R**epudiation: can a user deny performing an action?
- **I**nformation Disclosure: can a user read data they shouldn't?
- **D**enial of Service: can a user make the system unavailable?
- **E**levation of Privilege: can a user gain permissions they shouldn't have?

**Standard hardening checklist:**
- [ ] RLS (Row Level Security) enabled on all user-data tables
- [ ] RBAC enforced at the API layer (not just UI)
- [ ] Refresh token rotation implemented
- [ ] HttpOnly + Secure cookies for session tokens
- [ ] HSTS header set
- [ ] CSP header configured
- [ ] Rate limiting on auth endpoints

Confidence gate: only flag findings with >8/10 confidence.

## security-tier: hardened (production-saas/regulated)

Full OWASP + STRIDE + secrets archaeology:

```bash
# Secrets archaeology — search all git history
git log --all --full-history -- "*.env" "*.key" "*.pem"
git grep -i "password\|secret\|api_key\|token\|private_key" $(git rev-list --all) 2>/dev/null | head -50
```

**Comprehensive hardening checklist** (all standard items plus):
- [ ] SQL injection: parameterized queries everywhere — no string concatenation in queries
- [ ] XSS: output encoding in all template contexts
- [ ] CSRF: double-submit cookie or synchronizer token
- [ ] Dependency audit: `npm audit` / `pip-audit` / `cargo audit` with zero HIGH/CRITICAL
- [ ] Secret manager: no secrets in env vars — all in Vault/AWS Secrets Manager/GCP Secret Manager
- [ ] Audit log: all privileged actions logged with user ID + timestamp + action
- [ ] Data encryption at rest: PII fields encrypted
- [ ] TLS 1.2+ enforced, TLS 1.0/1.1 disabled

Confidence gate: flag at 2/10 — surface everything for human triage. False positives are acceptable at this tier.

## Output format

```markdown
## Security Audit — [YYYY-MM-DD]
Security tier: [minimal/standard/hardened]

### Findings
| Severity | Category | File | Line | Description | Confidence |
|---|---|---|---|---|---|
| HIGH | A03 Injection | src/api/users.ts | 42 | Unsanitized user input in query | 9/10 |

### Hardening checklist
[checklist with PASS/FAIL/NA per item]

### Verdict
[PASS / PASS-WITH-WARNINGS / FAIL]
[On FAIL: list specific items that must be fixed before /ship continues]
```
```

- [ ] **Step 2: Commit**

```bash
git add skills/audit-security/
git commit -m "feat: add /audit-security skill (Phase 10) — OWASP + STRIDE + secrets archaeology"
```

---

## Phase 11 — /qa-headless

### Task 17: Create /qa-headless skill

**Files:**
- Create: `skills/qa-headless/SKILL.md`

Per invocation-map: curl-based HTTP testing from Gherkin AC, zero dependencies, depth gated on intent.

- [ ] **Step 1: Create directory and SKILL.md**

```bash
mkdir -p skills/qa-headless
```

Create `skills/qa-headless/SKILL.md`:

```markdown
---
name: qa-headless
description: Headless HTTP integration testing using curl. Derives test cases mechanically from Gherkin acceptance criteria. Zero external dependencies. Depth gated on intent tier. Invoked by /ship after audit-security.
---

# /qa-headless — headless HTTP QA

Derives and executes HTTP test cases from the Gherkin AC in the SRS. No browser. No dependencies beyond curl (pre-installed everywhere).

## Test case derivation

For each Gherkin Given/When/Then:

```
Given [state] → setup: create required state via API or direct DB call
When [HTTP action] → request: curl command with headers, body, method
Then [outcome] → assertion: check HTTP status code + response body
```

Example:
```gherkin
Given a user is logged in
When they POST /api/habits with name="Exercise" and frequency="daily"
Then the response is 201 Created with the habit ID
```

Becomes:
```bash
# Setup: get auth token
TOKEN=$(curl -s -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"testpass"}' \
  | jq -r '.token')

# Test
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST http://localhost:3000/api/habits \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"name":"Exercise","frequency":"daily"}')

HTTP_CODE=$(echo "$RESPONSE" | tail -1)
BODY=$(echo "$RESPONSE" | head -1)

# Assert
[ "$HTTP_CODE" = "201" ] || echo "FAIL: expected 201, got $HTTP_CODE"
echo "$BODY" | jq '.id' > /dev/null || echo "FAIL: response missing habit ID"
```

## Depth calibration

**intent: hackathon**
- Health checks only: `curl http://localhost:3000/health`
- Critical path (1-2 happy path flows only)

**intent: mvp**
- Health checks
- API contract (all endpoints return expected status codes)
- Auth enforcement (protected endpoints return 401 without token)

**intent: production-saas**
- Full suite:
  - Health checks
  - API contract
  - Auth enforcement
  - NFR verification: `curl -w "%{time_total}" -o /dev/null -s [url]` (compare against PERF NFRs)
  - Error handling (malformed input returns 400, not 500)
  - Integration paths (multi-step flows from Gherkin AC)

## Output format

```markdown
## QA Headless — [YYYY-MM-DD]
Intent tier: [hackathon/mvp/production-saas]
Tests run: N
Tests passed: N
Tests failed: N

### Failures
[test name + expected vs actual + curl command that failed]

### NFR verification
[PERF-001: target < 200ms, actual: 145ms ✓]

### Verdict: PASS / FAIL
```
```

- [ ] **Step 2: Commit**

```bash
git add skills/qa-headless/
git commit -m "feat: add /qa-headless skill (Phase 11) — curl-based AC-derived HTTP testing"
```

---

## Phase 12 — /qa-browser

### Task 18: Create /qa-browser skill

**Files:**
- Create: `skills/qa-browser/SKILL.md`

Per invocation-map + Correction 3: use @playwright/mcp (not raw Playwright), gate on intent != hackathon AND @playwright/mcp installed.

- [ ] **Step 1: Create directory and SKILL.md**

```bash
mkdir -p skills/qa-browser
```

Create `skills/qa-browser/SKILL.md`:

```markdown
---
name: qa-browser
description: Browser-based QA using Playwright MCP for accessibility-snapshot testing. Tests auth flows, form submissions, JavaScript-rendered content, and session/cookie behavior. Gated on intent != hackathon AND @playwright/mcp installed. Uses structured accessibility snapshots (lower token cost than raw DOM).
---

# /qa-browser — browser QA via Playwright MCP

Browser testing using @playwright/mcp — gives the agent structured accessibility snapshots rather than raw DOM, dramatically reducing token cost.

## Gate check

```bash
# Check if @playwright/mcp is available
npx @playwright/mcp@latest --version 2>/dev/null && echo "available" || echo "not installed"
```

If not installed:
```
qa-browser: @playwright/mcp not installed.
Skipping browser QA.
To enable: npx @playwright/mcp@latest
Intent: [current intent] — browser QA would add: [list of test types skipped]
```

If intent == hackathon:
```
qa-browser: suppressed for hackathon intent tier.
```

## Test types (when gate passes)

### Auth flows
- Sign up with valid email
- Sign up with duplicate email → error shown
- Sign in with correct credentials → dashboard visible
- Sign in with wrong credentials → error shown, not redirected
- Session persists across page refresh
- Sign out → redirected to login, protected routes inaccessible

### Form submissions
For each form in the AC:
- Valid submission → success state visible
- Required field empty → validation error shown
- Invalid format → format error shown (not server error)

### JavaScript-rendered content
- Critical content visible without JavaScript disabled (SSR check)
- Dynamic content loads after page load
- Loading states shown during async operations

### Session and cookie behavior
- Auth cookie: httpOnly flag set (verify via network panel snapshot)
- Cookie expires correctly on sign out
- CSRF token present on forms with POST actions

## Accessibility snapshot usage

Use `browser_snapshot` from @playwright/mcp — returns structured accessibility tree, not raw HTML. Parse for:
- Visible text content (check expected text is present)
- Interactive elements (buttons, inputs — verify they exist and are accessible)
- Navigation state (URL, page title)

## Output format

```markdown
## QA Browser — [YYYY-MM-DD]
Tests run: N
Passed: N
Failed: N

### Failures
[test name]
Expected: [what should be visible/happen]
Actual: [what snapshot shows]
Screenshot: [if taken]

### Verdict: PASS / FAIL
```
```

- [ ] **Step 2: Commit**

```bash
git add skills/qa-browser/
git commit -m "feat: add /qa-browser skill (Phase 12) — Playwright MCP browser testing"
```

---

## Phase 13 — /monitor

### Task 19: Create /monitor skill

**Files:**
- Create: `skills/monitor/SKILL.md`

Per invocation-map: gated on intent mvp or production-saas, two depth levels.

- [ ] **Step 1: Create directory and SKILL.md**

```bash
mkdir -p skills/monitor
```

Create `skills/monitor/SKILL.md`:

```markdown
---
name: monitor
description: Produces a monitoring setup plan calibrated to intent tier. MVP: minimal health endpoint + error monitoring active. Production-saas: full uptime, latency, error rate, alert configuration. Gated on intent: mvp or production-saas. Invoked by /ship.
---

# /monitor — observability setup

Produces monitoring configuration at tier-appropriate depth.

## Gate

```
intent: hackathon → suppressed (no monitoring needed)
intent: mvp → minimal monitoring
intent: production-saas → full monitoring
```

## intent: mvp — minimal

Checklist:
- [ ] Health endpoint exists: `GET /health` returns `{"status": "ok"}` with HTTP 200
- [ ] Health endpoint checked: `curl http://[host]/health` returns 200
- [ ] Error monitoring active: Sentry (or equivalent) DSN configured, test error confirms delivery
- [ ] Deployment notification: Slack/email/webhook fires on successful deploy

Verify:
```bash
curl http://localhost:3000/health
# Expected: {"status":"ok"} with 200
```

## intent: production-saas — full

**Uptime monitoring:**
- External uptime monitor (Better Uptime, UptimeRobot, or platform-native) pinging health endpoint every 60 seconds
- Alert: SMS/PagerDuty on 3 consecutive failures
- Target: 99.9% uptime (43.8 min downtime/month)

**Latency monitoring:**
- p50, p95, p99 response time tracked per endpoint
- Alert: p95 > [PERF-001 threshold × 1.5]
- Dashboard: latency graph last 24h

**Error rate:**
- Error rate tracked (5xx / total requests)
- Alert: error rate > 1% over 5-minute window
- Sentry: error grouping, release tracking, performance monitoring

**Alert configuration matrix:**
| Signal | Threshold | Severity | Channel |
|---|---|---|---|
| Health check fail | 3 consecutive | P1 | PagerDuty |
| p95 latency > 2× SLO | 5 min sustained | P2 | Slack |
| Error rate > 1% | 5 min sustained | P2 | Slack |
| Error rate > 5% | 1 min sustained | P1 | PagerDuty |

## Output

Produces: `docs/sdlc-engineer/monitoring-plan.md` with configuration steps and verification commands.
```

- [ ] **Step 2: Commit**

```bash
git add skills/monitor/
git commit -m "feat: add /monitor skill (Phase 13) — tier-calibrated observability setup"
```

---

## Phase 14 — /benchmark

### Task 20: Create /benchmark skill

**Files:**
- Create: `skills/benchmark/SKILL.md`

Per invocation-map: gated on intent production-saas, curl-based load simulation, Lighthouse if Node available, commits benchmark JSON for history.

- [ ] **Step 1: Create directory and SKILL.md**

```bash
mkdir -p skills/benchmark
```

Create `skills/benchmark/SKILL.md`:

```markdown
---
name: benchmark
description: Performance benchmarking via curl load simulation and Lighthouse (if Node available). Gated on intent: production-saas. Commits benchmark results as JSON for before/after comparison. Invoked by /ship.
---

# /benchmark — performance benchmarking

Runs performance benchmarks and commits results for longitudinal comparison.

## Gate

```
intent: hackathon or mvp → suppressed
intent: production-saas → runs
```

## curl-based load simulation

```bash
# Warmup (not measured)
for i in {1..10}; do curl -s http://localhost:3000/health > /dev/null; done

# Measure p50, p95, p99 for critical endpoints
measure_endpoint() {
  local url=$1
  local n=100
  local times=()
  for i in $(seq 1 $n); do
    t=$(curl -s -o /dev/null -w "%{time_total}" "$url")
    times+=($t)
  done
  # Sort and extract percentiles
  printf '%s\n' "${times[@]}" | sort -n | awk "NR==int($n*0.50) || NR==int($n*0.95) || NR==int($n*0.99)"
}

measure_endpoint "http://localhost:3000/api/[critical-endpoint]"
```

## Lighthouse (if Node available)

```bash
which npx && npx lighthouse http://localhost:3000 \
  --output json \
  --output-path docs/sdlc-engineer/benchmarks/lighthouse-$(date +%Y%m%d).json \
  --chrome-flags="--headless"
```

Extracts: Performance score, LCP, FCP, TBT, CLS.

## Output format

Commit `docs/sdlc-engineer/benchmarks/YYYY-MM-DD.json`:

```json
{
  "date": "YYYY-MM-DD",
  "commit": "[git rev-parse HEAD]",
  "endpoints": {
    "/api/[endpoint]": {
      "p50_ms": 45,
      "p95_ms": 120,
      "p99_ms": 310
    }
  },
  "lighthouse": {
    "performance": 94,
    "lcp_ms": 1200,
    "fcp_ms": 800,
    "tbt_ms": 45,
    "cls": 0.01
  },
  "nfr_comparison": {
    "PERF-001": {"target": "p95 < 200ms", "actual": "120ms", "status": "PASS"}
  }
}
```

```bash
git add docs/sdlc-engineer/benchmarks/
git commit -m "perf: benchmark YYYY-MM-DD — p95=[actual]ms (target=[nfr]ms)"
```

## Before/after comparison

If a prior benchmark exists:
```bash
ls docs/sdlc-engineer/benchmarks/ | sort | tail -2
# Compare current vs previous
```

Surface regressions: any endpoint where p95 increased > 20% from previous benchmark.
```

- [ ] **Step 2: Create benchmarks directory**

```bash
mkdir -p docs/sdlc-engineer/benchmarks
echo "# Benchmark results" > docs/sdlc-engineer/benchmarks/.gitkeep
```

- [ ] **Step 3: Commit**

```bash
git add skills/benchmark/ docs/sdlc-engineer/benchmarks/
git commit -m "feat: add /benchmark skill (Phase 14) — curl load simulation + Lighthouse + historical JSON"
```

---

## Phase 15 — /finish-branch

### Task 21: Create /finish-branch skill

**Files:**
- Create: `skills/finish-branch/SKILL.md`

Per invocation-map: 4-option gate (merge/PR/keep/discard), human-in-the-loop, pre-flight requirements.

- [ ] **Step 1: Create directory and SKILL.md**

```bash
mkdir -p skills/finish-branch
```

Create `skills/finish-branch/SKILL.md`:

```markdown
---
name: finish-branch
description: Human-in-the-loop gate for completing a development branch. Presents 4 options: merge to main, open PR, keep branch, or discard. Pre-flight: all tasks complete + suite green + CI green + spec compliance PASS + no quality BLOCKs. Invoked by /implement after ci-verify.
---

# /finish-branch — development branch completion

The last gate before a branch is merged or published. Human decides — the skill presents options and executes the choice.

## Pre-flight (hard gates — do not proceed if any fail)

- [ ] All tasks in plan file marked complete
- [ ] Full test suite: green
- [ ] CI: green (or skipped with documented reason)
- [ ] review-spec: all tasks PASS
- [ ] Quality review: no BLOCK verdicts outstanding

If any pre-flight fails: "Pre-flight failed: [reason]. Fix before finishing branch."

## 4 options

Present these options to the user:

---

**Option 1: Merge to main**
- Squash WIP commits into one clean commit per task (or one per feature)
- Merge to main
- Delete branch and any associated worktrees
- Trigger session-save (checkpoint this branch as complete)

```bash
git checkout main
git merge --squash [branch]
git commit -m "[feature summary from plan]"
git branch -d [branch]
```

---

**Option 2: Open PR**
- Auto-populate PR description from methodology artifacts:
  - Title: from plan file feature name
  - Body: AC coverage, NFRs verified, test coverage delta, security audit verdict, benchmark comparison
  - Labels: from intent tier and security tier

```bash
git push -u origin [branch]
gh pr create \
  --title "[feature name]" \
  --body "[auto-generated from artifacts]" \
  --label "[intent-tier]"
```

---

**Option 3: Keep branch**
- Trigger session-save: write checkpoint with current state
- Commit checkpoint to branch
- Branch remains open for continuation in next session

---

**Option 4: Discard**
- Confirm explicitly: "Type 'discard' to confirm deletion of branch [name] and all worktrees"
- On confirm:
```bash
git worktree list | grep [branch] | awk '{print $1}' | xargs -I{} git worktree remove {}
git checkout main
git branch -D [branch]
```

## PR description template

```markdown
## What this PR does
[1-3 sentences from plan goal]

## AC coverage
[table: story ID → Gherkin AC → implemented: yes/no]

## NFRs verified
[table: NFR ID → target → actual → status]

## Test coverage
Lines: [before]% → [after]%

## Security audit
Tier: [minimal/standard/hardened]
Verdict: [PASS/PASS-WITH-WARNINGS]
Findings: [count] ([severity breakdown])

## Benchmark
[before/after comparison if production-saas]
```
```

- [ ] **Step 2: Commit**

```bash
git add skills/finish-branch/
git commit -m "feat: add /finish-branch skill (Phase 15) — 4-option human-in-the-loop branch gate"
```

---

## Phase 16 — /launch-readiness

### Task 22: Create /launch-readiness skill

**Files:**
- Create: `skills/launch-readiness/SKILL.md`

Per invocation-map: gated on launch-tier standard or full, proactive verification (every item was already required by /spec or /tasks — this skill VERIFIES, does not discover).

- [ ] **Step 1: Create directory and SKILL.md**

```bash
mkdir -p skills/launch-readiness
```

Create `skills/launch-readiness/SKILL.md`:

```markdown
---
name: launch-readiness
description: Pre-launch verification checklist. Every checklist item was already required by /spec or /tasks — this skill verifies, does not discover for the first time. Gated on launch-tier: standard or full (hackathon: suppressed). Invoked by /ship.
---

# /launch-readiness — pre-launch verification

This skill verifies that all launch requirements (previously captured in /spec and planned in /tasks) are actually implemented. Nothing new is discovered here — if something appears new, it's a /spec gap.

## Gate

```
launch-tier: minimal (hackathon) → suppressed entirely
launch-tier: standard → auth + legal + feedback sections
launch-tier: full → all sections
```

## Proactive integration note

Items in this checklist SHOULD have already been surfaced during /spec (as NFRs or ACs) and /tasks (as implementation tasks). If this checklist reveals something new: flag it as a spec gap and add it as a task before launch.

## launch-tier: standard — checklist

**Auth and session (gate: auth: email+)**
- [ ] Signup flow: email verification required before access
- [ ] Password reset: works end-to-end (email delivered, link valid, token expires)
- [ ] Session timeout: enforced (configurable, not infinite)
- [ ] "Remember me": cookie expiry correct
- [ ] Auth errors: no credential enumeration (same error for "user not found" and "wrong password")

**Legal (gate: intent: mvp or production-saas)**
- [ ] Privacy policy: linked from footer, content appropriate for data collected
- [ ] Terms of service: linked from signup flow, must-accept gate
- [ ] Cookie consent: banner shown on first visit (gate: audience: eu-consumers)
- [ ] Data deletion: user can delete their account and all associated data

**Feedback loop**
- [ ] Error reporting: user-facing errors are friendly (not stack traces)
- [ ] Feedback mechanism: at minimum, an email address or form users can contact
- [ ] Analytics: basic page view tracking configured (if opted into)

## launch-tier: full — additional sections

**GDPR/privacy (gate: audience: eu-consumers)**
- [ ] DPA (Data Processing Agreement): signed with all processors
- [ ] Cookie consent: granular (analytics/functional/necessary categories)
- [ ] Data export: user can download their data (GDPR Article 20)
- [ ] Data deletion: fulfilled within 30 days (GDPR Article 17)
- [ ] Privacy policy: mentions lawful basis for each data type

**Payment lifecycle (gate: monetization: subscription+)**
- [ ] Subscription created: webhook received and processed
- [ ] Payment failed: user notified, grace period implemented
- [ ] Subscription cancelled: access revoked at period end, not immediately
- [ ] Refund flow: documented and tested
- [ ] Invoice: generated and emailed on successful charge

**SEO/discoverability (gate: intent: mvp+public or production-saas)**
- [ ] `<title>` and `<meta description>`: set on all key pages
- [ ] `robots.txt`: exists and correct
- [ ] `sitemap.xml`: exists and submitted to search console
- [ ] Open Graph tags: correct for social sharing

**Monitoring and incident response**
- [ ] Uptime alert: configured (pagerduty/SMS)
- [ ] On-call: someone has the alert → knows what to do
- [ ] Runbook: at minimum, "how to restart the service"
- [ ] Status page: exists (even a simple static page)
```

- [ ] **Step 2: Commit**

```bash
git add skills/launch-readiness/
git commit -m "feat: add /launch-readiness skill (Phase 16) — proactive pre-launch verification"
```

---

## Phase 17 — /sync-docs

### Task 23: Create /sync-docs skill

**Files:**
- Create: `skills/sync-docs/SKILL.md`

Per invocation-map: drift detection (implemented things not in spec; specced things not in diff), updates README + ARCHITECTURE + CHANGELOG, marks plan file SHIPPED.

- [ ] **Step 1: Create directory and SKILL.md**

```bash
mkdir -p skills/sync-docs
```

Create `skills/sync-docs/SKILL.md`:

```markdown
---
name: sync-docs
description: Syncs documentation with implementation at the end of /ship. Detects drift (implemented things not in spec; specced things not in diff), updates README/ARCHITECTURE/CONTRIBUTING/CHANGELOG, marks plan file SHIPPED, updates RTM status. Always runs as the last step of /ship.
---

# /sync-docs — documentation sync

Keeps documentation synchronized with implementation. Runs last in /ship.

## Drift detection (always runs)

**Forward drift (implemented but not specced):**
```bash
# Compare git diff of this feature branch vs spec artifacts
git diff main...HEAD --name-only | grep -v "docs/sdlc-engineer/"
# Find files changed that are not mentioned in any SRS story or AC
```
Finding: "File [X] was modified but is not covered by any AC in the SRS. Options: (1) add a new story to cover it, (2) remove the change if it's scope creep."

**Backward drift (specced but not implemented):**
```bash
# Check each AC in the SRS against git diff
# Any Gherkin scenario with no corresponding test → flag
```
Finding: "AC [US-003 scenario 2] has no test in the diff. Options: (1) add the test, (2) mark as deferred in the RTM."

**ADR drift:**
```bash
# Find decisions made in this feature that don't have an ADR
git log main...HEAD --oneline | grep -i "switch\|migrate\|replace\|use.*instead"
```
Finding: "Commit [hash] suggests an architectural decision was made without an ADR. Create one with /arch-adr."

## Document updates

**README.md:**
- Update features section with new capabilities from this feature
- Update installation/setup section if new dependencies added
- Update environment variables section if new vars required

**ARCHITECTURE.md (if exists):**
- Update component descriptions if components changed
- Add new components introduced in this feature
- Update data model section if schema changed

**CONTRIBUTING.md (if exists):**
- Add any new development commands introduced
- Update test instructions if test approach changed

**CHANGELOG.md:**
```markdown
## [Unreleased] — YYYY-MM-DD

### Added
- [feature description from plan goal]
  
### Changed  
- [any behavior changes]

### Fixed
- [any bugs fixed in this feature]
```

## Plan file update

Mark plan file as SHIPPED:
```markdown
<!-- At top of plan file, add: -->
**Status: SHIPPED — [YYYY-MM-DD]**
**Commit:** [git log -1 --oneline]
```

## RTM update

For each AC in the plan:
- Mark implementation status: IMPLEMENTED
- Link to commit hash
- Mark test status: PASSING (if suite is green)

```markdown
| AC ID | Story | Implementation | Test | Status |
|---|---|---|---|---|
| AC-001 | US-001 | src/api/users.ts:42 | tests/api/users.test.ts:15 | IMPLEMENTED ✓ |
```
```

- [ ] **Step 2: Commit**

```bash
git add skills/sync-docs/
git commit -m "feat: add /sync-docs skill (Phase 17) — drift detection + doc updates + plan marking"
```

---

## Phase 18 — /learn

### Task 24: Create /learn skill + define JSONL schema

**Files:**
- Create: `skills/learn/SKILL.md`

Per invocation-map + build-order note: JSONL schema must be defined now (Phase 1/tasks reads it). Schema already implied in Task 9 (/debug). Consolidate here and make authoritative.

- [ ] **Step 1: Create directory and SKILL.md**

```bash
mkdir -p skills/learn
```

Create `skills/learn/SKILL.md`:

```markdown
---
name: learn
description: Cross-session learning management. Reads and writes docs/sdlc-engineer/learnings.jsonl. Subcommands: /learn review, /learn prune, /learn export. Other skills (debug, retro, configure, tasks) write to learnings.jsonl automatically — this skill manages the entries. Use when user says "/learn review", "show learnings", "prune old learnings", "export learnings".
---

# /learn — cross-session learning management

Manages `docs/sdlc-engineer/learnings.jsonl` — the project's persistent knowledge base of patterns, failures, and calibrations.

## JSONL schema (authoritative)

Every entry in `learnings.jsonl` is a single JSON line:

```json
{
  "type": "anti-pattern|failed-approach|root-cause|config-correction|nfr-correction|research-gap",
  "date": "YYYY-MM-DD",
  "context": "brief description of where/when this occurred",
  "body": "the learning itself — what was observed",
  "relevant-skills": ["debug", "tasks"],
  "stale": false
}
```

### Type definitions

| Type | Written by | Read by | Description |
|---|---|---|---|
| `anti-pattern` | any skill | /tasks, /debug | A pattern observed that caused problems |
| `failed-approach` | /debug | /execute-subagent, /tasks | An approach that was tried and failed — do not retry |
| `root-cause` | /debug | /debug | A root cause diagnosis with its fix |
| `config-correction` | any skill | /configure | A config field that was wrong and was corrected mid-project |
| `nfr-correction` | /retro, /qa-headless | /req-nfr, /tasks | An NFR threshold that was inaccurate |
| `research-gap` | /retro | /research | A search that would have caught something that was missed |

## Subcommands

### /learn review

Display all learnings sorted by type, then date (newest first):

```
Anti-patterns (N):
  [YYYY-MM-DD] [context]: [body]

Failed approaches (N):
  ...

Config corrections (N):
  ...
```

### /learn prune

Mark specific learnings as stale (they no longer apply):
- Show each entry
- User confirms which to mark stale
- Update `"stale": true` — never delete (audit trail)

### /learn export

Export learnings to shareable format for team onboarding:
```markdown
# Learnings — [project name]
Exported: YYYY-MM-DD

## Anti-patterns
...

## Config corrections
...
```

## Per-skill reading behavior

Skills read ONLY the types relevant to them:

- `/tasks`: reads `anti-pattern`, `failed-approach` relevant to current stack
- `/debug`: reads `failed-approach`, `root-cause` for current symptom
- `/configure`: reads `config-correction` — surfaces before asking questions
- `/req-nfr`: reads `nfr-correction`
- `/research`: reads `research-gap`

Never dump the entire learnings file into context — filter by type and relevance first.

## Writing from any skill

Any skill encountering a noteworthy pattern writes to learnings.jsonl:

```bash
# Append a new learning
echo '{"type":"anti-pattern","date":"2026-05-16","context":"...","body":"...","relevant-skills":["tasks"],"stale":false}' >> docs/sdlc-engineer/learnings.jsonl
```
```

- [ ] **Step 2: Commit**

```bash
git add skills/learn/
git commit -m "feat: add /learn skill (Phase 18) — cross-session JSONL learning management + authoritative schema"
```

---

## Phase 20 — /retro

### Task 25: Create /retro skill

**Files:**
- Create: `skills/retro/SKILL.md`

Per invocation-map: reads all artifacts, analyzes plan accuracy + AC quality + NFR accuracy + debug patterns + anti-patterns + CI failures, produces retro markdown, writes calibration entries to learnings.jsonl.

- [ ] **Step 1: Create directory and SKILL.md**

```bash
mkdir -p skills/retro
```

Create `skills/retro/SKILL.md`:

```markdown
---
name: retro
description: Project retrospective. Reads all methodology artifacts (plan files, debug logs, learnings.jsonl, RTM, CI results, test coverage delta, research brief) and produces a structured retrospective. Writes calibration entries back to learnings.jsonl. Use when user says "/retro", "retrospective", "what did we learn", "post-mortem".
---

# /retro — project retrospective

Closes the methodology improvement loop. Reads artifacts, analyzes what worked and what didn't, writes calibration entries so the next project starts smarter.

## Input artifacts (read all that exist)

```bash
ls docs/sdlc-engineer/plans/*.md         # plan files (estimates vs actual)
ls docs/sdlc-engineer/sessions/*.md      # debug and session logs
cat docs/sdlc-engineer/learnings.jsonl   # existing learnings
ls docs/sdlc-engineer/retros/            # prior retros
# RTM: docs/sdlc-engineer/spec/rtm.md
# Research brief: docs/sdlc-engineer/research-brief-*.md
# CI results: via gh run list or gitlab CI history
# Test coverage: from most recent test run output
```

## Analysis checklist

### Plan accuracy
- Estimated task count vs actual task count
- Estimated complexity (XS/S/M/L/XL) vs actual time per task
- Tasks that were added mid-flight (scope creep? missed AC?)
- Tasks that were split or merged (incorrect granularity?)

### AC quality
- ACs that were ambiguous or required clarification during implementation
- ACs that were missing a scenario that only appeared during QA
- ACs that were too strict (caused over-engineering) or too loose (allowed under-engineering)

### NFR accuracy
- NFR thresholds that were too tight (prevented shipping) or too loose (shipped with performance issues)
- NFRs that were missing entirely (discovered during qa-headless or benchmark)

### Debug patterns
- Most common failure type (null checks? async ordering? wrong type?)
- Average time from failure to fix
- Failed approaches (that went into learnings.jsonl) — was the approach rational?

### Anti-patterns caught
- How many anti-patterns did guard/review-spec/review catch that would have shipped?
- Were any anti-patterns missed that appeared in production?

### CI failures
- What percentage of CI failures were caught by local test runs first?
- Infrastructure failures vs test failures vs environment failures

### Research accuracy
- Did the research brief correctly identify library risks?
- Were there CVEs or breaking changes not caught by research?
- Did market research inform any spec decisions?

### Config accuracy
- Were config-corrections written to learnings.jsonl?
- Would those corrections change the config for the next project of this type?

## Output

Write to `docs/sdlc-engineer/retros/YYYY-MM-DD-[feature].md`:

```markdown
# Retrospective — [feature name]
Date: YYYY-MM-DD
Plan file: [path]

## Summary
[2-3 sentences: what went well, what needs improvement]

## Plan accuracy
[findings]

## AC quality
[findings]

## NFR accuracy
[findings]

## Patterns
[debug patterns, anti-patterns caught/missed]

## What to calibrate next time
[specific changes to make]
```

## Write calibration entries to learnings.jsonl

After analysis, append entries:

```json
{"type":"nfr-correction","date":"YYYY-MM-DD","context":"[feature]","body":"PERF-001 threshold was 200ms but actual p95 was 45ms — next project: set to 100ms for this stack","relevant-skills":["req-nfr"],"stale":false}
{"type":"research-gap","date":"YYYY-MM-DD","context":"[feature]","body":"Library X had a breaking change in v3 that research brief missed — add 'breaking changes last 6 months' to research checklist","relevant-skills":["research"],"stale":false}
{"type":"config-correction","date":"YYYY-MM-DD","context":"[feature]","body":"security-tier was standard but PII was found in data model — escalate to hardened when user table has profile fields","relevant-skills":["configure"],"stale":false}
```

## Create retros directory

```bash
mkdir -p docs/sdlc-engineer/retros
```
```

- [ ] **Step 2: Create retros directory**

```bash
mkdir -p docs/sdlc-engineer/retros
echo "# Retrospectives" > docs/sdlc-engineer/retros/.gitkeep
```

- [ ] **Step 3: Commit**

```bash
git add skills/retro/ docs/sdlc-engineer/retros/
git commit -m "feat: add /retro skill (Phase 20) — retrospective + learnings.jsonl calibration entries"
```

---

## Cross-Cutting Updates

### Task 26: Wire learnings.jsonl path across all skills

**Files:**
- Modify: `skills/configure/SKILL.md`
- Modify: `skills/tasks/SKILL.md`
- Modify: `skills/debug/SKILL.md`

Verify each skill references the correct path `docs/sdlc-engineer/learnings.jsonl` and uses the correct JSONL schema from /learn.

- [ ] **Step 1: Verify paths in each skill**

```bash
grep -r "learnings.jsonl" skills/ --include="*.md"
```

Expected: configure, tasks, debug, learn, retro all reference `docs/sdlc-engineer/learnings.jsonl`

- [ ] **Step 2: Verify schema types match /learn SKILL.md**

Cross-check: any skill that writes `{"type": "..."}` uses one of the 6 defined types: `anti-pattern`, `failed-approach`, `root-cause`, `config-correction`, `nfr-correction`, `research-gap`

- [ ] **Step 3: Commit if any fixes needed**

```bash
git add skills/
git commit -m "fix: normalize learnings.jsonl path and schema types across all skills"
```

---

### Task 27: Update sdlc-foundation/invocation-map.md with hook details

**Files:**
- Modify: `skills/sdlc-foundation/invocation-map.md`

The invocation-map is the reference document. Verify it reflects the actual hooks.json implementation (SessionStart reads .sdlc/project.yml + ~/.sdlc/user.yml, PreToolUse intercepts specific patterns, Stop writes to docs/sdlc-engineer/sessions/).

- [ ] **Step 1: Read current invocation-map Layer 0 section**

```bash
head -40 skills/sdlc-foundation/invocation-map.md
```

- [ ] **Step 2: Verify accuracy against settings.json**

Compare Layer 0 in invocation-map against `.claude/settings.json`. If divergences found, update invocation-map to match implemented behavior.

- [ ] **Step 3: Commit if changed**

```bash
git add skills/sdlc-foundation/invocation-map.md
git commit -m "docs: sync invocation-map Layer 0 with implemented hooks"
```

---

### Task 28: Final audit — skill surface completeness check

**Files:**
- Read: all `skills/*/SKILL.md`

Verify every skill in the invocation-map has a corresponding SKILL.md.

- [ ] **Step 1: List all skills and compare against invocation-map**

```bash
ls skills/ | sort
```

Expected after all tasks complete:
```
analyze, arch-adr, arch-c4, arch-complexity, arch-components, arch-decompose,
arch-sequence, arch-use-cases, audit-security, benchmark, ci-verify, configure,
consult, debug, decide, deploy-cicd, deploy-observability, deploy-release-check,
deploy-rollback, deploy-secrets-audit, deploy-tier, design, elicit,
execute-inline, execute-parallel, execute-subagent, finish-branch, guard,
implement, launch-readiness, learn, monitor, qa-browser, qa-headless,
req-acceptance, req-nfr, req-rtm, req-srs, req-user-stories, research,
retro, review-spec, sdlc-foundation, session-restore, session-save, ship,
spec, sync-docs, tasks
```

- [ ] **Step 2: Verify every SKILL.md has valid frontmatter**

```bash
for f in skills/*/SKILL.md; do
  head -4 "$f" | grep -q "^name:" || echo "MISSING name: in $f"
  head -5 "$f" | grep -q "^description:" || echo "MISSING description: in $f"
done
```

Expected: no output (all files have valid frontmatter).

- [ ] **Step 3: Commit final state**

```bash
git add -A
git commit -m "feat: sdlc-engineer v1 — complete skill surface (20 skills + hooks + patches)"
```

---

## Self-Review

### Spec coverage check

Invocation-map skills required → plan coverage:

| Skill/Hook | Task | Status |
|---|---|---|
| SessionStart hook | Task 1 | ✓ |
| PreToolUse hook | Task 1 | ✓ |
| Stop hook | Task 1 | ✓ |
| /configure | Task 2 | ✓ |
| /research | Task 3 | ✓ |
| /tasks (rewrite) | Task 4 | ✓ |
| /implement (rewrite) | Task 5 | ✓ |
| /ship (new) | Task 5 | ✓ |
| /spec (patch) | Task 6 | ✓ |
| /design (patch) | Task 6 | ✓ |
| /consult (patch) | Task 7 | ✓ |
| /execute-inline | Task 8 | ✓ |
| /debug | Task 9 | ✓ |
| /review-spec | Task 10 | ✓ |
| /execute-subagent | Task 11 | ✓ |
| /session-save | Task 12 | ✓ |
| /session-restore | Task 12 | ✓ |
| /guard | Task 13 | ✓ |
| /ci-verify | Task 14 | ✓ |
| /execute-parallel | Task 15 | ✓ |
| /audit-security | Task 16 | ✓ |
| /qa-headless | Task 17 | ✓ |
| /qa-browser | Task 18 | ✓ |
| /monitor | Task 19 | ✓ |
| /benchmark | Task 20 | ✓ |
| /finish-branch | Task 21 | ✓ |
| /launch-readiness | Task 22 | ✓ |
| /sync-docs | Task 23 | ✓ |
| /learn | Task 24 | ✓ |
| /retro | Task 25 | ✓ |
| learnings.jsonl wiring | Task 26 | ✓ |
| invocation-map sync | Task 27 | ✓ |
| Final audit | Task 28 | ✓ |

Phase 19 (/coordinate): deferred to v2 per build-order-research.md recommendation. Config gate suppresses for solo. Document git worktree pattern in MULTI-DEV.md.

### 3 corrections from build-order-research.md

| Correction | Applied in |
|---|---|
| Correction 1: Config preamble → SessionStart hook (not per-skill bash read) | Task 1 + Task 2 |
| Correction 2: Guard → PreToolUse hook (not SKILL.md bootstrap) | Task 1 + Task 13 |
| Correction 3: QA Browser → @playwright/mcp (not raw Playwright) | Task 18 |

All 3 corrections applied.

---

**Plan complete and saved to `docs/sdlc-engineer/plans/2026-05-16-sdlc-engineer-v1.md`.**

**Two execution options:**

**1. Subagent-Driven (recommended)** — fresh subagent per task, review between tasks

**2. Inline Execution** — execute tasks in this session using executing-plans

**Which approach?**
