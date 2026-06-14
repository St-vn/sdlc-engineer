---
name: roblox
description: Roblox platform binding — maps abstract sdlc-engineer skills (ui-design, cloud, audit, debug, tooling) to Roblox Studio, Luau, Roblox MCP tools, and the Roblox platform. No npm, no Docker, no CLI — everything is MCP-driven.
---

# /platforms/roblox — Roblox development

Roblox is fundamentally different from web development:
- **IDE**: Roblox Studio (not VS Code)
- **Language**: Luau (not TypeScript/Python/Go)
- **Tooling**: MCP-based (Roblox Studio MCP plugin), not CLI-based
- **Testing**: Roblox TestService + playtest automation (no Jest/Playwright)
- **Deploy**: Roblox platform (no Vercel/AWS/Docker)
- **Packages**: RBXMV2 via Toolbox (no npm/pip/cargo)

This binding maps every abstract skill to Roblox-native workflows.

## Platform signature

- Language: Luau
- IDE: Roblox Studio
- Tool interface: Roblox Studio MCP plugin (MCP tools only — no CLI)
- Package management: Toolbox / rbxts-node for TypeScript users
- Deploy target: Roblox platform (game publish)

## Required tools

The Roblox development stack has almost NO traditional CLI tools. Everything is MCP:

```bash
# The only deterministic check is: can Roblox Studio respond?
# (MCP server connection test)
```

| Tool | Type | Install | Deterministic check |
|------|------|---------|-------------------|
| Roblox Studio | IDE | Download from create.roblox.com | MCP: `robloxstudio_get_place_info` returns place ID |
| Roblox Studio MCP | MCP | Claude Code plugin (pre-installed) | MCP: `robloxstudio_execute_luau("return 1+1")` returns 2 |

## Tool mappings

| Abstract tool (web) | Roblox equivalent | Deterministic check |
|---------------------|------------------|-------------------|
| Playwright CLI (E2E) | `robloxstudio_start_playtest` + `robloxstudio_capture_screenshot` | Screenshot PNG returned (non-empty = working) |
| Playwright assert | `robloxstudio_execute_luau("assert(...)")` | Luau returns or errors |
| axe-core (a11y) | Studio Accessibility properties | Manual check via `robloxstudio_get_instance_properties` |
| Lighthouse CI (perf) | Studio Performance Analyzer | `robloxstudio_execute_luau` to read memory/stats |
| Docker | N/A — Roblox is the platform | No containerization needed |
| Trivy (CVE) | N/A — Roblox sandboxes code | No OS-level vulnerabilities |
| Semgrep (SAST) | Luau lint via studio_lint | `robloxstudio_get_script_analysis` returns syntax errors |
| Gitleaks (secrets) | Manual review | Roblox Studio doesn't have git — no credentials in code |
| Terraform | Open Cloud API (asset upload) | HTTP API call (place update) |
| gh CLI (CI) | Roblox Open Cloud API | API returns publish status |

## Skill mappings

### /ui-design → Roblox UI

| Abstract phase | Roblox workflow |
|----------------|-----------------|
| Phase 1: Design System | Use `robloxstudio_search_materials` for available materials. Use `robloxstudio_create_object` for UI elements. Colors via BrickColor Enum. |
| Phase 2: Implementation | Luau in Script/LocalScript/ModuleScript. UI via ScreenGuis, SurfaceGuis, BillboardGuis. |
| Phase 3: Testing | `robloxstudio_start_playtest` (play mode) + `robloxstudio_capture_screenshot` for visual verification. `robloxstudio_execute_luau` for server-side assertions. |
| Phase 4: Review | Screenshots + Studio property checks. No cross-browser (single platform). |

### /cloud → Roblox deploy

| Abstract phase | Roblox workflow |
|----------------|-----------------|
| Architecture | Roblox server/client model. Server = Script, Client = LocalScript/ModuleScript. |
| IaC | No IaC — Roblox Studio is the single source of truth. For version control: use `rbxmk` or Rojo file syncing. |
| Containerization | N/A — Roblox runs code server-side. |
| CI/CD | Open Cloud API for game publish. GitHub Actions: use `roblox-js` for asset upload. |
| Deployment | `File → Publish to Roblox` (manual) or Open Cloud API (automated). |
| Observability | Studio Analytics dashboard. `robloxstudio_get_output_log` for real-time debugging. |

### /audit → Roblox security

| Abstract phase | Roblox workflow |
|----------------|-----------------|
| STRIDE threat model | Focus on: Filtering (exploits), RemoteEvent validation, DataStore security |
| Static analysis | `robloxstudio_get_script_analysis` for Luau syntax + `grep_scripts` for pattern search |
| Secrets | API keys in ServerScriptService (not LocalScript). Never in client. |
| Database (DataStore) | Verify DataStore key naming. Check for cached writes. Verify GetAsync/SetAsync error handling. |
| Compliance | COPPA (under-13), Roblox ToS, community guidelines |

### /debug → Roblox debugging

| Abstract phase | Roblox workflow |
|----------------|-----------------|
| Ground truth | `robloxstudio_get_output_log` for printed errors |
| Isolate | `robloxstudio_get_script_analysis` to check syntax. `robloxstudio_grep_scripts` to find related code |
| Hypothesize | Check Filtering, RemoteEvent fire order, DataStore rate limits |
| Verify | Fix → `robloxstudio_start_playtest` → run repro steps → check output |

### /tooling → Roblox tool setup

```powershell
# Roblox tool setup is minimal:
# 1. Install Roblox Studio (manual download)
# 2. Roblox Studio MCP comes with Claude Code plugin
# 3. Verify: run the MCP tool robloxstudio_get_place_info

# Optional TypeScript/Roblox-ts:
npm install -g @rbxts/compiler
```

## Anti-rationalization table
| Common Excuse | Why It's Wrong | What to Do Instead |
|---|---|---|
| "Roblox doesn't need testing, I can just playtest" | Manual playtesting misses edge cases and regression bugs. Use playtest automation (`start_playtest` + `execute_luau` assertions). | Write Luau assertions that run during playtest. Check output for failures. |
| "Roblox doesn't have CI/CD" | Roblox has Open Cloud API for programmatic publishing. You can automate publish from GitHub Actions. | Use `roblox-js` or Open Cloud REST API. Automate `Publish to Roblox`. |
| "Filtering is automatic, I don't need to audit it" | Filtering is NOT automatic. RemoteEvents/RemoteFunctions need manual validation on the server. | Check every RemoteEvent: does the server re-validate the client's input? |
| "Luau is like TypeScript, I can apply the same patterns" | Luau has no type runtime enforcement, no null safety built-in, different async patterns. | Use Luau-specific patterns: `type` annotations for lint, `pcall` for error handling, `task.spawn` for async. |
