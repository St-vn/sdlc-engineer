---
name: personas
description: Pre-defined specialist agent personas for focused code review, testing, security audit, design, and performance analysis. Triggers on "review this code", "audit this", "run persona", or inline persona activation.
---

# /personas — specialist agent personas

Activate pre-defined personas for focused analysis. Each persona constrains the agent to a specific role with targeted focus areas, constraints, and anti-rationalization rules.

## Required tools by persona

| Persona | Required tools | Verify command |
|---------|---------------|---------------|
| code-reviewer | git | `git --version` |
| test-engineer | Playwright | `npx @playwright/test --version` |
| security-auditor | Semgrep, Gitleaks, Trivy | `.\skills\tooling\scripts\verify-tools.ps1` |
| ux-designer | axe-core, Lighthouse CI | `npx @axe-core/cli --version && npx lhci --version` |
| performance-engineer | Lighthouse CI | `npx lhci --version` |

Before activating any persona, verify its required tools exist. If missing, run:
```powershell
.\skills\tooling\scripts\install-tools.ps1
```

## Usage

```
/personas <persona-name> <context>
```

Example: `/personas code-reviewer "Review the auth module in src/auth/"`

## Available Personas

| Persona | When to Use |
|---------|-------------|
| code-reviewer | Before merging any PR |
| test-engineer | Before writing or reviewing tests |
| security-auditor | For any auth, payments, or data-handling code |
| ux-designer | Before or after UI implementation |
| performance-engineer | For any performance-sensitive code |

## Persona Activation

Each persona loads constraints from `skills/personas/references/<name>.yaml`. The agent adopts the role, focus areas, and constraints specified in the yaml file.

## Chaining Personas

Multiple personas can be run in sequence on the same code:
```
/personas security-auditor "src/api/" → fix findings → /personas code-reviewer "src/api/"
```

## Anti-rationalization table
| Common Excuse | Why It's Wrong | What to Do Instead |
|---|---|---|
| "I can review my own code" | Self-review misses blind spots. A code-reviewer persona catches assumptions you didn't question. | Run /personas code-reviewer. Fresh perspective. |
| "Testing is just writing test files" | Test-engineer persona checks test quality, not just presence. A bad test is worse than no test. | Run /personas test-engineer. It checks what your tests actually prove. |
| "Security auditors are for production" | Security findings found early cost 10x less to fix. Run security-auditor on every auth/data change. | Run /personas security-auditor pre-merge, not pre-release. |
