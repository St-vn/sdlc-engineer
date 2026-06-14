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