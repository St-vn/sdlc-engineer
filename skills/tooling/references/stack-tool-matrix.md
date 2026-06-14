# Stack-to-Tools Dependency Matrix

Complete mapping from technology stack choices to the deterministic tools required.
Reference for `/tooling` install/verify, `/configure` stack selection, and every skill's pre-flight checks.

## How to use

1. Find your stack in each category below
2. The "Required tools" column lists every deterministic tool you need
3. The "Install command" column tells you how to get it
4. The "Skill dependency" column tells you which skills use it
5. Run `verify-tools.ps1` to confirm everything is installed

---

## Frontend Frameworks

### React / Next.js
| Tool | Type | Purpose | Install | Used by | Agent vs CLI |
|------|------|---------|---------|---------|-------------|
| Playwright | CLI | E2E, visual regression, component testing | `npm i -g @playwright/test && npx playwright install chromium` | ui-design, qa-browser, test-engineer | **CLI** for CI/automation |
| Chrome DevTools MCP | MCP | Browser debugging, console, network, screenshot | `npx -y @anthropic/chrome-devtools-mcp` | ui-design, debug, performance-engineer | **Agent** for interactive debug |
| axe-core | CLI | Automated accessibility audit | `npm i -g @axe-core/cli` | ui-design, ux-designer, qa-browser | CLI |
| Lighthouse CI | CLI | Performance, a11y, SEO audit | `npm i -g @lhci/cli` | ui-design, performance-engineer, qa-browser | CLI |
| Storybook | CLI | Visual regression + interaction testing | `npm i -g storybook` | ui-design | CLI |

### Vue / Nuxt
| Tool | Type | Purpose | Install | Used by |
|------|------|---------|---------|---------|
| Playwright | CLI | E2E + component testing | `npm i -g @playwright/test && npx playwright install chromium` | ui-design, qa-browser |
| Chrome DevTools MCP | MCP | Browser debugging | `npx -y @anthropic/chrome-devtools-mcp` | debug |
| axe-core | CLI | Accessibility audit | `npm i -g @axe-core/cli` | ui-design |
| Lighthouse CI | CLI | Performance audit | `npm i -g @lhci/cli` | ui-design |

### Svelte / SvelteKit
| Tool | Type | Purpose | Install | Used by |
|------|------|---------|---------|---------|
| Playwright | CLI | E2E (built-in SvelteKit support) | `npm i -g @playwright/test && npx playwright install chromium` | ui-design |
| Chrome DevTools MCP | MCP | Browser debugging | `npx -y @anthropic/chrome-devtools-mcp` | debug |
| axe-core | CLI | Accessibility audit | `npm i -g @axe-core/cli` | ui-design |

### Vanilla HTML/CSS/JS
| Tool | Type | Purpose | Install | Used by |
|------|------|---------|---------|---------|
| Playwright | CLI | E2E testing | `npm i -g @playwright/test && npx playwright install chromium` | ui-design |
| Chrome DevTools MCP | MCP | Browser debugging | `npx -y @anthropic/chrome-devtools-mcp` | debug |
| axe-core | CLI | Accessibility audit | `npm i -g @axe-core/cli` | ui-design |

---

## Backend Languages

### TypeScript / Node.js
| Tool | Type | Purpose | Install | Used by |
|------|------|---------|---------|---------|
| Vitest | CLI | Unit + integration testing | `npm i -g vitest` | implement, test-engineer |
| ESLint | CLI | Static analysis / linting | `npm i -g eslint` | ci-verify |
| TypeScript | CLI | Type checking | `npm i -g typescript` | ci-verify |
| Semgrep | CLI | SAST pattern matching | `npm i -g semgrep` | audit-code, security-auditor |

### Python
| Tool | Type | Purpose | Install | Used by |
|------|------|---------|---------|---------|
| pytest | CLI | Unit + integration testing | `pip install pytest` | implement, test-engineer |
| ruff | CLI | Linting + formatting | `pip install ruff` | ci-verify |
| mypy | CLI | Type checking | `pip install mypy` | ci-verify |
| Semgrep | CLI | SAST pattern matching | `pip install semgrep` | audit-code |

### Rust
| Tool | Type | Purpose | Install | Used by |
|------|------|---------|---------|---------|
| cargo test | CLI | Unit + integration testing | (bundled with Rust) | implement |
| clippy | CLI | Linting | `rustup component add clippy` | ci-verify |
| cargo audit | CLI | CVE scanning | `cargo install cargo-audit` | audit-code |

### Go
| Tool | Type | Purpose | Install | Used by |
|------|------|---------|---------|---------|
| go test | CLI | Unit + integration testing | (bundled with Go) | implement |
| staticcheck | CLI | Linting | `go install honnef.co/go/tools/cmd/staticcheck@latest` | ci-verify |
| govulncheck | CLI | CVE scanning | `go install golang.org/x/vuln/cmd/govulncheck@latest` | audit-code |

---

## Databases

### PostgreSQL
| Tool | Type | Purpose | Install | Used by |
|------|------|---------|---------|---------|
| pgTAP | CLI | Unit testing for DB functions/RLS | `npm i -g pgtap` | audit-code |
| pgLint | CLI | Schema linting | `npm i -g pglint` | ci-verify, audit-code |
| psql | CLI | Direct query verification | (bundled with PostgreSQL) | audit-code, database-security |
| Supabase CLI | CLI | RLS policy verification | `npm i -g supabase` | audit-code, deploy |

### SQLite
| Tool | Type | Purpose | Install | Used by |
|------|------|---------|---------|---------|
| sqlite3 | CLI | Direct query verification | (bundled with SQLite) | audit-code |

### MongoDB
| Tool | Type | Purpose | Install | Used by |
|------|------|---------|---------|---------|
| mongosh | CLI | Direct query + schema verification | (bundled with MongoDB) | audit-code |

### Redis
| Tool | Type | Purpose | Install | Used by |
|------|------|---------|---------|---------|
| redis-cli | CLI | Direct query + cache verification | (bundled with Redis) | audit-code |

---

## Containerization / Docker

### Docker (all stacks using containers)
| Tool | Type | Purpose | Install | Used by |
|------|------|---------|---------|---------|
| Docker CLI | CLI | Build, run, compose containers | `winget install Docker.DockerDesktop` | cloud, debug |
| Docker Compose | CLI | Multi-container local dev | (bundled with Docker Desktop) | cloud |
| Trivy | CLI | Container + filesystem CVE scanning | `npm i -g trivy` | cloud, audit-code, security-auditor |
| Docker BuildKit | CLI | Multi-stage, SBOM generation | (bundled with Docker Desktop) | cloud |

### Kubernetes (scaling tier only)
| Tool | Type | Purpose | Install | Used by |
|------|------|---------|---------|---------|
| kubectl | CLI | K8s cluster management | `winget install Kubernetes.kubectl` | cloud |
| kustomize | CLI | K8s config management | `winget install kustomize` | cloud |
| helm | CLI | K8s package management | `winget install Helm.Helm` | cloud |

---

## Cloud Providers

### AWS
| Tool | Type | Purpose | Install | Used by |
|------|------|---------|---------|---------|
| AWS CLI | CLI | AWS service management | `winget install Amazon.AWSCLI` | cloud |
| AWS CDK | CLI | TypeScript-native IaC | `npm i -g aws-cdk` | cloud |
| Terraform | CLI | Multi-provider IaC | `winget install Hashicorp.Terraform` | cloud |
| cdk-nag | CLI | CDK security compliance | `npm i -g cdk-nag` | cloud, audit-code |

### GCP
| Tool | Type | Purpose | Install | Used by |
|------|------|---------|---------|---------|
| gcloud CLI | CLI | GCP service management | `winget install Google.GoogleCloudSDK` | cloud |
| Pulumi | CLI | Multi-provider IaC (GCP-native) | `winget install Pulumi.Pulumi` | cloud |

### Azure
| Tool | Type | Purpose | Install | Used by |
|------|------|---------|---------|---------|
| az CLI | CLI | Azure service management | `winget install Microsoft.AzureCLI` | cloud |
| Bicep | CLI | Azure-native IaC | `winget install Microsoft.Bicep` | cloud |
| Terraform | CLI | Multi-provider IaC | `winget install Hashicorp.Terraform` | cloud |

### Multi-Cloud
| Tool | Type | Purpose | Install | Used by |
|------|------|---------|---------|---------|
| Terraform/OpenTofu | CLI | Universal IaC | `winget install Hashicorp.Terraform` | cloud |
| Pulumi | CLI | Universal IaC (programmable) | `winget install Pulumi.Pulumi` | cloud |
| Checkov | CLI | IaC security scanning | `pip install checkov` | cloud, audit-code |

---

## CI/CD

### GitHub Actions
| Tool | Type | Purpose | Install | Used by |
|------|------|---------|---------|---------|
| gh CLI | CLI | PR management, workflow triggers | `winget install GitHub.cli` | ci-verify, ship |
| act | CLI | Run GitHub Actions locally | `winget install act.act` | ci-verify, debug |

### GitLab CI
| Tool | Type | Purpose | Install | Used by |
|------|------|---------|---------|---------|
| glab CLI | CLI | MR management, pipeline triggers | `winget install glab.cli` | ci-verify |

### Vercel
| Tool | Type | Purpose | Install | Used by |
|------|------|---------|---------|---------|
| Vercel CLI | CLI | Deploy, preview, env management | `npm i -g vercel` | cloud, deploy |

---

## Security (Universal — needed by every stack)

| Tool | Type | Purpose | Install | Used by |
|------|------|---------|---------|---------|
| Semgrep | CLI | SAST pattern matching (all languages) | `npm i -g semgrep` | audit-code, security-auditor |
| Gitleaks | CLI | Git secret scanning | `winget install gitleaks.gitleaks` | audit-code, deploy-secrets-audit |
| Trivy | CLI | CVE scanning (containers + fs) | `npm i -g trivy` | cloud, audit-code |
| OWASP ZAP | CLI | DAST web app scanning | `winget install ZAP.ZAP` | audit-code, qa-browser |

---

## MCP Servers (IDE-level deterministic tools)

A tool is "MCP" when it's a server that exposes tools with defined JSON schemas — the LLM calls them like functions with type-checked arguments. This is more structured than CLI parsing.

| Server | What it exposes | Stack | For |
|--------|----------------|-------|-----|
| Chrome DevTools MCP | `browser_navigate`, `browser_screenshot`, `console_get`, `network_list` | Any web stack | Interactive debugging, state inspection, real-time console/network |
| Playwright MCP | `browser_goto`, `page_click`, `locator_fill`, `screenshot` | Any web stack | Automated E2E test execution from IDE |
| Sentry MCP | `issue_list`, `event_get`, `release_track` | All stacks | Error monitoring, release verification |
| Supabase MCP | `query_run`, `migration_list`, `rls_check` | Supabase stacks | Database + RLS verification |
| Vercel MCP | `deploy_list`, `env_get`, `log_stream` | Vercel-deployed apps | Deployment management |

---

## Agent Browser vs Playwright CLI — When to Use What

| Dimension | Agent Browser (Chrome DevTools MCP) | Playwright CLI |
|-----------|-------------------------------------|----------------|
| **Mode** | Interactive/exploratory | Automated/scripted |
| **Determinism** | Medium (MCP has defined schemas, but human steers) | High (exit code 0/1, repeatable) |
| **Best for** | Debugging a specific runtime issue, inspecting DOM state, checking console errors | CI pipelines, regression suites, visual diff testing |
| **Output** | Screenshots, console logs, network waterfall | JUnit XML, JSON report, screenshot diffs |
| **Human needed?** | Yes — inspects and decides what to look at | No — runs, passes or fails, reports |
| **Stack needed** | Any web stack (browser required) | Any web stack (headless or headed) |
| **CI-compatible?** | No (interactive) | Yes (headless+exit code) |
| **Skill integration** | debug, ui-design (Phase 4 review) | ui-design (Phase 3 testing), qa-browser, ship |

**Rule of thumb:**
- Development/debugging → Agent browser (Chrome DevTools MCP)
- CI/verification/release → Playwright CLI
- UI review → Both (agent for spot-check, CLI for regression suite)

---

## Cross-Category Tool Dependencies

Some tools appear in multiple categories. These are the universal ones:

```
Tool              → Categories
─────────────────────────────────────────────────────
Playwright        → frontend (all frameworks), E2E testing
Chrome DevTools   → frontend (all frameworks), debugging
Semgrep           → security, backend (all languages)
Trivy             → security, containers, IaC
Terraform         → cloud (AWS, Azure, multi-cloud)
Pulumi            → cloud (GCP, multi-cloud)
Docker CLI        → containers, cloud, local dev (every stack)
```

## Install Commands by Package Manager (Windows)

```powershell
# npm global tools (frontend + security + infra)
npm install -g @playwright/test @axe-core/cli @lhci/cli semgrep trivy vercel supabase aws-cdk

# winget tools (infrastructure + desktop tools)
winget install Docker.DockerDesktop Hashicorp.Terraform Pulumi.Pulumi
winget install Amazon.AWSCLI Google.GoogleCloudSDK Microsoft.AzureCLI
winget install GitHub.cli Kubernetes.kubectl Helm.Helm
winget install gitleaks.gitleaks ZAP.ZAP

# pip tools (Python-specific)
pip install checkov

# Playwright browsers (after npm install)
npx playwright install chromium
```
