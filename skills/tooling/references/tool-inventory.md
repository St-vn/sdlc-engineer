# Tool Inventory — sdlc-engineer deterministic tooling

Every tool listed here has a deterministic output (exit code, JSON, structured data).
LLMs cannot fake these — they must be installed and working.

## Frontend Testing Tools

| Tool | Purpose | Deterministic check | Install (Windows) | Skill dependency |
|------|---------|-------------------|-------------------|-----------------|
| Playwright | E2E, visual regression, component testing | `npx playwright test --list` lists all tests | `npm i -g @playwright/test && npx playwright install chromium` | ui-design, test-engineer persona |
| axe-core CLI | Accessibility audit | `npx @axe-core/cli --help` | `npm i -g @axe-core/cli` | ui-design, qa-browser |
| Lighthouse CI | Performance, a11y, SEO audit | `npx lhci --version` | `npm i -g @lhci/cli` | ui-design, qa-browser |

## Security Tools

| Tool | Purpose | Deterministic check | Install (Windows) | Skill dependency |
|------|---------|-------------------|-------------------|-----------------|
| Semgrep | SAST pattern matching | `semgrep --version` | `npm i -g semgrep` | audit-code, security-auditor persona |
| Gitleaks | Git secret scanning | `gitleakes --version` | `winget install gitleaks.gitleaks` | audit-code, deploy-secrets-audit |
| Trivy | Container/FS/CVE scanner | `trivy --version` | `npm i -g trivy` | cloud, audit-code |

## Infrastructure Tools

| Tool | Purpose | Deterministic check | Install (Windows) | Skill dependency |
|------|---------|-------------------|-------------------|-----------------|
| Docker | Containerization, local dev parity | `docker --version` | `winget install Docker.DockerDesktop` | cloud |
| Terraform | IaC provisioning | `terraform version` | `winget install Hashicorp.Terraform` | cloud |
| Pulumi | IaC provisioning (programmable) | `pulumi version` | `winget install Pulumi.Pulumi` | cloud |

## MCP Servers (IDE Integration)

| Server | Enables | Deterministic via | Config location |
|--------|---------|-------------------|----------------|
| Chrome DevTools MCP | Browser console, network, screenshot, performance | `@anthropic/chrome-devtools-mcp` exposes tools with defined schemas | `./.claude/mcp.json` |
| Playwright MCP | E2E test execution, browser interaction | `@playwright/mcp` exposes Playwright as MCP tools | `./.claude/mcp.json` |

## Tool Categories by Determinism Level

```
Level 1 — Exit code only (0 = pass, non-zero = fail with stderr):
  semgrep, gitleaks, trivy, terraform validate, docker build

Level 2 — Exit code + structured output (JSON/XML/YAML):
  playwright test --reporter=json, lhci autorun, axe --format json

Level 3 — Streaming protocol with defined schemas:
  Chrome DevTools MCP (DOM, Console, Network, Performance tools)
  Playwright MCP (browser, page, locator tools)
```
