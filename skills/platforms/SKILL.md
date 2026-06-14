---
name: platforms
description: Platform derivation framework — maps abstract sdlc-engineer skills to concrete tools, stacks, and workflows for specific platforms (Roblox, WordPress, mobile, game dev, etc.). Triggers on "platform binding", "derive for [platform]", "create platform skill", or when the detected stack matches a known platform profile.
---

# /platforms — platform derivation framework

Abstract skills (`/ui-design`, `/cloud`, `/audit`, `/debug`) provide **methodology** — the what and why. Platform bindings provide **concrete tool mappings** — the how and with what.

## Why platform bindings?

Different platforms have fundamentally different tool chains:

| Platform | IDE | Language | Testing | Deploy | Tool interface |
|----------|-----|----------|---------|--------|---------------|
| **Web (React/Vue)** | VS Code | TS/JS | Playwright CLI | Vercel/AWS | CLI + MCP |
| **Roblox** | Roblox Studio | Luau | TestService | Roblox platform | MCP only |
| **WordPress** | VS Code | PHP | WP-CLI + PHPUnit | Apache/nginx | CLI |
| **Unity** | Unity Editor | C# | Unity Test Runner | Stores | CLI + API |
| **iOS** | Xcode | Swift | XCTest | App Store | CLI + API |

A platform binding maps every abstract methodology step to the platform's native tools.

## Creating a platform binding

1. Create `skills/platforms/<name>/SKILL.md`
2. For each abstract skill, define the concrete mapping:
   - **Tools**: Which CLIs/MCP servers replace the generic ones?
   - **Stack detection**: How to detect this platform (file patterns, config files)?
   - **Testing**: What replaces Playwright/axe-core/LHCI?
   - **Deployment**: Where does this platform deploy to?
   - **Verification**: How to verify tools are installed?

## Template: required sections per platform binding

```markdown
# /platforms/<name> — <Platform Name>

## Platform signature
- Language: <lang>
- Framework: <framework>
- IDE: <ide>
- Package manager: <pm>
- Deploy target: <target>

## Tool mappings
| Abstract tool | Platform tool | Install | Verify |
|---|---|---|---|
| Playwright CLI | <platform alternative> | <command> | <check> |
| axe-core | <platform alternative> | <command> | <check> |
| Docker | <platform alternative> | <command> | <check> |
| ... | ... | ... | ... |

## Stack detection
- File patterns: <glob patterns that identify this platform>
- Config files: <files to check>

## Derived skills
| Abstract skill | How it maps |
|---|---|
| /ui-design | <description of platform-specific UI workflow> |
| /cloud | <description of platform-specific deploy workflow> |
| /audit | <description of platform-specific security workflow> |
| /debug | <description of platform-specific debugging workflow> |
| /tooling | <description of platform-specific tools to install> |

## MCP servers
| Server | Purpose | Deterministic check |
|---|---|---|
| <MCP server> | <what it enables> | <tool that returns exit code or structured data> |

## Anti-rationalization table
| Common Excuse | Why It's Wrong | What to Do Instead |
|---|---|---|
</parameter>
