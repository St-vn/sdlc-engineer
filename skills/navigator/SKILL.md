---
name: navigator
description: Master bootstrap and navigation skill for the sdlc-engineer plugin. Establishes the behavioral contract for all skills and guides users/agents through the SDLC pipeline.
---

# /navigator — SDLC Navigator & Behavioral Blueprint

This skill is the **meta-behavioral bootstrap** for `sdlc-engineer`. It establishes how the agent must discover, run, and enforce the methodology, and serves as an interactive guide for the user to navigate the entire Software Development Lifecycle (SDLC).

---

## 1. Agent Behavioral Contract

To maintain engineering discipline and prevent "vibe coding" (making assumptions, bypassing quality checks, or writing code without plans), the agent must adhere to the following rules:

### A. The 1% Rule of Engagement
Before responding to any request, prompt, or command, the agent must check if any skill in the `sdlc-engineer` skill set applies. 
* **If there is even a 1% chance a skill applies, the agent is REQUIRED to invoke it.**
* The agent must NOT bypass, minimize, or explain away the need for a skill.

### B. Announce Invocation
Before running any skill, the agent must announce to the user:
```
[sdlc-engineer] Using [skill-name] to [briefly state the purpose of the skill].
```
This ensures absolute transparency so the user knows the agent is following the methodology.

### C. Rule Precedence
1. Explicit user constraints/override files (e.g., `CLAUDE.md`, `.sdlc/project.yml`, `.gitignore`) always take precedence.
2. `sdlc-engineer` skill instructions take second precedence.
3. Default AI/agent system prompts have the lowest priority.

---

## 2. Core SDLC Lifecycle Pipeline

The methodology is organized into sequential phases. Each stage produces an artifact that gates downstream execution.

| Stage | Command | Purpose | Input Required | Output Produced |
| :--- | :--- | :--- | :--- | :--- |
| **0. Configure** | `/configure` | Initialize project parameters & gates | User answers | `.sdlc/project.yml` |
| **1. Consult** | `/consult` | Assess current situation and suggest next command | Idea / Situation | Recommendation |
| **2. Decide** | `/decide` | Structural / architectural decisions | Tech stack choice | ADR draft / `/design` update |
| **3. Elicit** | `/elicit` | Gather domain constraints & user stories | Project intent | Stakeholder inputs, INVEST stories |
| **4. Analyze** | `/analyze` | Tradeoff analysis & feasibility mapping | Elicit output | Complexity/dependency maps |
| **5. Research** | `/research` | **Orchestrator.** Dispatches `/research-market`, `/research-tech`, `/research-compliance`. | Chosen libraries | Compacted `research-brief.md` |
| **6. Spec** | `/spec` | Write formal software requirements | Elicited info | Gherkin ACs, metric NFRs, SRS, RTM |
| **7. Design** | `/design` | Component, sequence, and system architecture | SRS + RTM | C4 diagrams, components, sequence |
| **8. Tasks** | `/tasks` | TDD task list breakdown | Spec + Design | `docs/sdlc-engineer/task.md` |
| **9. Implement** | `/implement` | TDD implementation (Red-Green-Refactor) | Task list | Working code, passing test suite |
| **10. Audit** | `/audit` | **Adversarial Audit.** Orchestrates `/audit-spec` and `/audit-code`. | Code PR + Specs | Vulnerability / logic scorecard |
| **11. Pressure-Test**| `/pressure-test`| **Reliability Test.** Runs `/pressure-test-load` and `/pressure-test-chaos`. | Deployed app port| Load and RTO recovery metrics |
| **12. Ship** | `/ship` | Pre-flight security, QA, CI/CD, and deploy | Main branch state | Verified deployments, updated docs |
| **13. Retro** | `/retro` | Calibrate estimates, metrics, and learnings | Completed work | `learnings.jsonl` updates |

---

## 3. Automated Background & Adversarial Workflows

The agent operates several automated guardrails and security audits behind the scenes:

### Git Worktree Isolation
* **When triggered**: During `/implement` when waves of tasks have disjoint (non-overlapping) file sets and the task count is large.
* **What it does**: Spawns independent subagents to work on different tasks concurrently, checking out each task to a dedicated git worktree (`git worktree add ../[project]-task-[N]`).

### Context-Isolated Code Reviews
* **When triggered**: Right after any task implementation completes during the `/implement` loop.
* **What it does**: Spawns a `review-spec` subagent with *only* the task's Acceptance Criteria and the git diff (zero general codebase context). Next, the `quality reviewer` subagent checks the diff against Architectural Decision Records (ADRs) and style guides.

### Methodical 4-Phase Debugging
* **When triggered**: Automatically when a test suite or verification step fails.
* **What it does**: Restricts the agent from blindly rewriting code. It forces a methodical debug loop:
  1. *Phase 0: Reproduce* (confirm failure is stable).
  2. *Phase 1: Isolate* (locate failing boundary: commit, input, or layer).
  3. *Phase 2: Hypothesize* (rank root causes by likelihood).
  4. *Phase 3: Verify fix* (run RED to GREEN verification).
  5. *Log*: Saves approaches/fixes to `learnings.jsonl`.

### Adversarial Requirements Review (DIR Protocol)
* **When triggered**: During `/audit-spec` or `/audit`.
* **What it does**: Employs Direct-Indirect Reasoning (DIR) using proof by contradiction to systematically verify design specifications and requirements logic. It negates claims to expose unhandled edge cases, platform gate violations, and logical deadlocks.

### Custom Security Linting (Semgrep Red-Teaming)
* **When triggered**: During `/audit-code` or `/audit`.
* **What it does**: Runs targeted Semgrep scans using custom syntax match patterns (such as cryptographic bypass checks for the `jwt-simple` library). If vulnerabilities are flagged, it verifies their reachability path.

### Chaos Engineering & Network Degradation
* **When triggered**: During `/pressure-test-chaos` or `/pressure-test`.
* **What it does**: Uses **Pumba** to simulate OOM events or pause API containers, and **Toxiproxy** to inject downstream TCP latency or sever connections mid-transaction. It gates the app on Recovery Time Objective (RTO $\le 30\text{s}$).

---

## 4. Quick-Start Workflow Tutorial

Here is how you drive the agent to build a feature (e.g., adding user roles) from scratch:

### Step 1: Project Configuration
Run `/configure` first. You will answer up to 8 questions to configure your target tier (hackathon, MVP, scaling), authentication, monetization, and compliance requirements.
```bash
/configure
```

### Step 2: Live Modular Research
Run `/research` (or run `/research-tech`, `/research-market`, or `/research-compliance` separately) to scan dependencies for CVEs, verify license compliance, check regulations, and discover competitors:
```bash
/research
```

### Step 3: Capture Requirements & Specifications
Run `/spec` to define your user stories, Given-When-Then Gherkin acceptance criteria, and Non-Functional Requirements (NFRs):
```bash
/spec "As an admin, I want to assign roles to users so that I can control access"
```

### Step 4: Map Architecture
Run `/design` to generate component models, sequence diagrams, and formal ADRs:
```bash
/design
```

### Step 5: TDD Task Breakdown
Run `/tasks` to outline your red-green implementation steps:
```bash
/tasks
```

### Step 6: Structured Implementation
Run `/implement` to start coding. The agent will write failing tests, code to make them pass, and review the code:
```bash
/implement
```

### Step 7: Run Adversarial Auditing
Run `/audit` to verify spec consistency and scan code commits for vulnerabilities before merging:
```bash
/audit
```

### Step 8: Run Local Reliability & Stress Testing
Run `/pressure-test` to stress-test your system using k6 load generators under Pumba and Toxiproxy container/network failures:
```bash
/pressure-test
```

### Step 9: Ship to Production
Run `/ship` to trigger security scans, browser Playwright audits, and push the release:
```bash
/ship
```
