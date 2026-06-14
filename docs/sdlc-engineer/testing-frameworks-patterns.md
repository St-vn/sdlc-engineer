# Testing Frameworks & Patterns — Best Practices Methodology

## Design Principles

1. **User-centric testing** — "The more your tests resemble the way your software is used, the more confidence they can give you." (Testing Library)
2. **Test behavior, not implementation** — Assert on outcomes (state/output), not internal method calls. Tests that verify implementation break on refactor even when behavior is unchanged.
3. **Test isolation** — Every test gets a fresh environment (browser context, DB, state). No shared mutable state between tests.
4. **Auto-waiting over manual waits** — Let the framework wait for actionability. Manual `setTimeout`/`sleep` calls are the #1 cause of flakiness.
5. **DAMP over DRY in tests** — Descriptive And Meaningful Phrases. Each test should read as a self-contained specification. Duplication is acceptable for readability.

## When to Apply

- Adding new logic or behavior → unit tests (Vitest/Jest + Testing Library)
- Adding UI components → component tests (Playwright CT or Storybook + interaction tests)
- Modifying rendering or CSS → visual regression tests (Playwright `toHaveScreenshot`)
- Fixing bugs → reproduction test first (Prove-It pattern)
- Adding critical user flows → E2E tests (Playwright)
- Ensuring accessibility → axe-core scans via Playwright
- Validating API contracts → Playwright API testing or Vitest integration tests

## Process

### A. Unit/Integration Testing (Vitest + Testing Library)

```
Step 1 — ARRANGE: Set up the test scenario
  ├── Create test data (inputs, mock store state)
  ├── Render the component or call the function
  └── Verify: test environment is clean (no leftovers from previous tests)

Step 2 — ACT: Perform the action being tested
  ├── Simulate user interaction (click, type, submit)
  ├── Or call the function under test with inputs
  └── Verify: the action completed without throwing

Step 3 — ASSERT: Verify the outcome
  ├── Assert on rendered output: getByRole, getByText, getByLabelText
  ├── Assert on function return value or state change
  ├── Use async matchers for DOM assertions (waitFor, findByRole)
  └── Verify: assertion passes on first attempt (no retries needed)

Step 4 — CLEANUP: Tear down
  ├── Unmount components
  ├── Clear mocks and database state
  └── Verify: no side effects leaked to next test
```

### B. E2E Testing (Playwright)

```
Step 1 — NAVIGATE: Go to the starting URL
  ├── Use page.goto() — Playwright auto-waits for load state
  └── Verify: page loaded, expected URL is active

Step 2 — LOCATE: Find elements using role-based locators
  ├── Use getByRole(), getByLabelText(), getByPlaceholder()
  ├── Avoid: XPath, CSS selectors tied to DOM structure
  └── Verify: locator resolves to exactly one actionable element

Step 3 — INTERACT: Perform user actions
  ├── Click, fill, selectOption, check/uncheck
  ├── Playwright auto-waits for actionability (visible, enabled, stable)
  └── Verify: no error thrown during interaction

Step 4 — ASSERT: Verify expected state
  ├── Use async matchers: toBeVisible(), toHaveText(), toHaveURL()
  ├── Use generic matchers for non-DOM values: toEqual(), toContain()
  └── Verify: assertion passes within the timeout window

Step 5 — ISOLATE: Each test gets a fresh BrowserContext
  ├── Built-in: Playwright creates a new context per test
  └── Verify: no cookies/localStorage leak between tests
```

### C. Visual Regression Testing (Playwright Snapshots)

```
Step 1 — GENERATE BASELINE: First run creates golden screenshots
  ├── Command: npx playwright test (first run)
  ├── Screenshots stored in `test-file.spec.ts-snapshots/` directory
  └── Verify: baseline screenshots exist in the snapshots directory

Step 2 — COMPARE: Subsequent runs compare against baseline
  ├── Uses pixelmatch for pixel-by-pixel comparison
  ├── Configurable threshold: maxDiffPixels, maxDiffPixelRatio
  └── Verify: diff count is below threshold (0 by default)

Step 3 — UPDATE: When intentional visual changes occur
  ├── Command: npx playwright test --update-snapshots
  ├── Review all changed screenshots in version control
  └── Verify: only intentional changes were updated (no drift)

Step 4 — STABILIZE: Control volatile elements
  ├── Use stylePath to hide dynamic content (iframes, animations)
  ├── Use maxDiffPixels for anti-aliasing tolerance
  └── Verify: screenshots are deterministic across runs
```

### D. Component Testing (Playwright CT)

```
Step 1 — INSTALL: Add Playwright CT to project
  ├── Command: npm init playwright@latest -- --ct
  ├── Creates playwright/index.html and playwright/index.ts
  └── Verify: mount fixture is available in tests

Step 2 — MOUNT: Render component in real browser
  ├── Use mount() fixture — component renders in a real Chromium browser
  ├── Pass props, children, and callbacks as JSX/HTML
  └── Verify: component mounted without console errors

Step 3 — INTERACT & ASSERT: Same as Playwright E2E
  ├── Use Playwright locators and assertions on the mounted component
  └── Verify: interactions work in real browser (not JSDOM)

Step 4 — HANDLE LIMITATIONS: Bridge Node ↔ Browser boundary
  ├── Create wrapper components ("stories") that convert complex objects
  ├── Module mocks (vi.mock) don't cross the boundary — use beforeMount hooks
  └── Verify: only serializable data flows between test and component
```

### E. Accessibility Testing (Playwright + axe-core)

```
Step 1 — INSTALL: Add @axe-core/playwright
  └── npm install -D @axe-core/playwright

Step 2 — SCAN: Run axe against the page or a sub-element
  ├── Full page: new AxeBuilder({ page }).analyze()
  ├── Sub-element: .include('#nav-menu').analyze()
  └── Verify: analysis completes without timeout

Step 3 — FILTER: Target specific WCAG levels if needed
  ├── .withTags(['wcag2a', 'wcag2aa', 'wcag21a', 'wcag21aa'])
  └── Verify: tags match the compliance target

Step 4 — ASSERT: Expect zero violations
  └── expect(scanResults.violations).toEqual([])

Step 5 — HANDLE KNOWN ISSUES (choose one strategy):
  ├── Exclude: .exclude('#known-issue-element')
  ├── Disable rule: .disableRules(['duplicate-id'])
  ├── Snapshot fingerprint: snapshot a simplified violation signature
  └── Verify: known issues are tracked (not silently ignored)
```

### F. Storybook for UI Component Testing

```
Step 1 — DEFINE STORIES: Create CSF files alongside components
  ├── Default export: metadata about the component
  ├── Named exports: each story is a component state/variant
  └── Verify: stories render in Storybook UI without errors

Step 2 — ADD PLAY FUNCTION: Simulate user interaction
  ├── Use canvas.findByRole(), userEvent.type(), userEvent.click()
  ├── Assert with expect() from storybook/test
  └── Verify: play function runs without timeout

Step 3 — REUSE ARGS: Compose stories for composite components
  ├── Import args from child component stories
  ├── Spread into parent component stories
  └── Verify: child changes propagate to parent stories automatically

Step 4 — INTEGRATE WITH TESTS: Run stories as interaction tests
  ├── Use @storybook/test-runner or @storybook/experimental-playwright
  ├── Run in CI to catch regressions
  └── Verify: all stories pass as tests in CI
```

## Anti-patterns

| Anti-pattern | Problem | Fix |
|---|---|---|
| Testing implementation details | Tests break on refactor with same behavior | Test inputs and outputs, not internal structure |
| Snapshot abuse (large/untracked) | Nobody reviews them, break on any change | Small focused snapshots; review every change |
| Mocking everything | Tests pass, production breaks | Prefer real > fake > stub > mock |
| Flaky tests (timing/order-dependent) | Erode trust in the suite | Deterministic assertions, isolate state |
| `getByTestId` as default locator | Brittle; ties tests to non-semantic attributes | Use `getByRole` first, then `getByLabelText`, then `getByTestId` as last resort |
| Shared mutable fixtures | Tests pass alone, fail together | Each test creates its own data |
| Sleeping/timing in tests | Flaky; fails on slow CI | Use auto-waiting; `waitFor`/`toHaveText`/`toBeVisible` |
| Module mocks in component tests | Don't cross Node/browser boundary | Use `beforeMount` hooks with `hooksConfig` |

## Tools with Install Commands

```bash
# Vitest — Unit/integration testing
npm install -D vitest

# Testing Library — User-centric DOM queries
npm install -D @testing-library/react @testing-library/jest-dom

# Playwright — E2E, component, visual, accessibility testing
npm init playwright@latest
npm install -D @playwright/test @axe-core/playwright

# Playwright CT — Component testing (React example)
npm init playwright@latest -- --ct
npm install -D @playwright/experimental-ct-react

# Storybook — UI component development & testing
npx storybook@latest init
npm install -D @storybook/test-runner

# MSW — API mocking for integration tests
npm install -D msw @playwright/experimental-ct-react
```
