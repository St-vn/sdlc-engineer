---
name: tooling
description: Deterministic tooling management — install, verify, and configure all CLI tools and MCP servers required by sdlc-engineer skills. Triggers on "install tools", "verify tools", "check dependencies", "tool setup", "mcp", or when a skill's pre-flight check fails.
---

# /tooling — Deterministic tool & MCP management

LLMs are probabilistic. Skills must use deterministic tools (CLIs, MCP servers, APIs) to produce verifiable results. This skill ensures all required tools are installed, configured, and working.

## Determinism principle

Every tool in the inventory produces a deterministic output:
- **Level 1**: Exit code (0 = pass, non-zero = fail)
- **Level 2**: Structured JSON/XML output
- **Level 3**: MCP protocol with defined tool schemas

A test that runs `npx playwright test` is deterministic (it exits 0 or non-zero).
A test that says "verify the UI looks correct" is probabilistic (LLM judges its own output).
The goal is to maximize Level 1-3 tools and minimize LLM-as-judge.

## Stack-to-tools mapping

Every tech stack maps to a specific set of deterministic tools.
Choose your stack → get the exact tools you need. No bloat.

Reference: `skills/tooling/references/stack-tool-matrix.md`

The matrix covers:
- **Frontend**: Playwright (CLI) + Chrome DevTools MCP (agent) per framework (React, Vue, Svelte, vanilla)
- **Backend**: test runners + linters + type checkers per language (TS, Python, Rust, Go)
- **Databases**: query verification + linting per DB (PostgreSQL, SQLite, MongoDB, Redis)
- **Containers**: Docker CLI, Trivy, Docker Compose, K8s tools per tier
- **Cloud**: provider-specific CLIs + IaC tools per provider (AWS, GCP, Azure, multi-cloud)
- **CI/CD**: platform-specific CLIs per pipeline (GitHub Actions, GitLab CI, Vercel)
- **Security**: universal tools needed by every stack (Semgrep, Gitleaks, Trivy)
- **MCP servers**: IDE-level deterministic tools per platform

### Agent browser vs Playwright CLI

Both are deterministic, but serve different purposes:

| | Agent Browser (Chrome DevTools MCP) | Playwright CLI |
|---|---|---|
| Mode | Interactive debugging | Automated CI testing |
| Determinism | Medium (MCP-defined schemas) | High (exit code 0/1) |
| When | Inspecting DOM, console, network during dev | Running regression suites in CI |
| Skill | debug, ui-design review | ui-design testing, qa-browser, ship |

See `stack-tool-matrix.md` for the full decision table.

## Available commands

### /tooling install

Installs all deterministic tools. Platform-aware (winget/choco/npm/pip).

```powershell
# Install everything
.\skills\tooling\scripts\install-tools.ps1

# Or by category
.\skills\tooling\scripts\install-tools.ps1 -Categories @("frontend")
.\skills\tooling\scripts\install-tools.ps1 -Categories @("security")
.\skills\tooling\scripts\install-tools.ps1 -Categories @("infra")
.\skills\tooling\scripts\install-tools.ps1 -Categories @("mcp")
```

### /tooling verify

Checks every tool is installed and produces a report.

```powershell
.\skills\tooling\scripts\verify-tools.ps1
# Or JSON output for programmatic use:
.\skills\tooling\scripts\verify-tools.ps1 -Json
```

### /tooling mcp

Report on MCP server configuration:
- Checks `.claude/mcp.json` exists
- Lists configured servers and their status
- Verifies servers are startable

### /tooling profile

Reads `.sdlc/project.yml` and installs only the tools needed for the detected stack.

```powershell
.\skills\tooling\scripts\install-tools.ps1 -Profile .sdlc/project.yml
```

This maps:
- `stack.framework` → frontend tools (Playwright, axe-core, LHCI, Chrome DevTools MCP)
- `stack.language` → backend tools (test runner, linter, type checker)
- `stack.database` → database tools (pgTAP, psql, etc.)
- `stack.ci` → CI tools (gh CLI, etc.)
- `deployment-target: cloud` → cloud tools (Docker, Trivy, Terraform)
- `security-tier: hardened` → security tools (Semgrep, Gitleaks, OWASP ZAP)

### /tooling inventory

Lists all tools, their deterministic check command, and which skill depends on them.

Reference: `skills/tooling/references/tool-inventory.md`

## Pre-flight protocol (for other skills to use)

Every skill that uses deterministic tools MUST check they exist before running:

```markdown
### Required tools
<tool-name>: <deterministic check command>
```

If a pre-flight check fails, the skill should:
1. Report which tool is missing
2. Offer to run `/tooling install` (or relevant category)
3. NOT proceed without the tool

## Anti-rationalization table
| Common Excuse | Why It's Wrong | What to Do Instead |
|---|---|---|
| "I don't need to install it, I'll just describe what would happen" | LLM-generated test results are imaginary. Real tests require real tools. | Run the tool. Check the exit code. Report the actual output. |
| "npm install takes too long" | 2 minutes of install saves 20 minutes of debugging imaginary problems. | Run install-tools.ps1. It handles everything. |
| "The tool is probably already installed" | "Probably" is not a verification. Check explicitly. | Run verify-tools.ps1. It tells you exactly what's missing. |
| "I can fake the output" | Fake output is worse than no output — it creates false confidence. | Never fake tool output. Either run the tool or report it as unavailable. |
