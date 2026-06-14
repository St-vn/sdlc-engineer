# UI Testing Methodology — Best Practices

Synthesized from Playwright (visual regression, accessibility, component testing, aria snapshots), Storybook (interaction, visual, accessibility, snapshot testing), and Jest-axe. Provides a step-by-step workflow for an AI coding agent to implement a comprehensive UI testing strategy across five dimensions.

## Design Principles (max 5)

1. **Test as a pyramid, not a trophy** — Multiple fast unit/component tests at the base, fewer slow E2E tests at the top. Each layer captures what the layer below cannot.

2. **Stories are test cases** — Every component state (loading, empty, error, edge case) is a story. Stories generate render tests automatically — no extra test code needed.

3. **Visual diffing for appearance, assertions for behavior** — Snapshots catch unintended visual changes; assertions verify logical correctness. One does not substitute for the other.

4. **Accessibility testing is not optional** — Automated a11y checks run on every component story and every critical page flow. Zero violations is the only acceptable threshold.

5. **Write tests that survive refactoring** — Test behavior and accessibility tree structure, not implementation details (CSS classes, internal state, DOM structure).

## When to Apply

- Before implementing any new feature (TDD: write test first, then implement)
- When adding new components (every component gets render + interaction + a11y tests)
- When modifying existing UI (visual regression tests catch unintended changes)
- Before every pull request or release
- When setting up CI/CD pipeline (tests must run automatically)
- When refactoring (tests prove behavior is preserved)

## Process

### Step 1 — Write stories as component test cases (Storybook)

Every component gets stories for each meaningful state:

```typescript
// Button.stories.ts
import type { Meta, StoryObj } from '@storybook/react'
import { Button } from './Button'

const meta = { component: Button } satisfies Meta<typeof Button>
export default meta
type Story = StoryObj<typeof meta>

export const Primary: Story = {
  args: { variant: 'primary', children: 'Submit' }
}

export const Disabled: Story = {
  args: { variant: 'primary', children: 'Submit', disabled: true }
}

export const Loading: Story = {
  args: { variant: 'primary', children: 'Saving...', loading: true }
}

export const WithIcon: Story = {
  args: { variant: 'secondary', children: 'Download', icon: 'download' }
}
```

**Minimum story coverage** per component:
- Default/primary state
- Disabled state (if applicable)
- Loading state (if applicable)
- Error/empty state (if applicable)
- Each variant/style
- Each size option
- Dark mode (using a global decorator)

**Verification**: `npx storybook build` succeeds with no errors. Every export has a matching story.

### Step 2 — Add interaction tests (play functions)

For stateful/interactive components, add a `play` function that simulates user behavior:

```typescript
// Dialog.stories.ts
export const Opens: Story = {
  play: async ({ canvas, userEvent, expect }) => {
    const button = canvas.getByRole('button', { name: 'Open Modal' })
    await userEvent.click(button)
    await expect(canvas.getByRole('dialog')).toBeInTheDocument()
    await expect(canvas.getByText('Modal content')).toBeVisible()
  }
}

// Form.stories.ts — with spies
export const Submits: Story = {
  args: {
    onSubmit: fn()
  },
  play: async ({ args, canvas, userEvent, expect }) => {
    await userEvent.type(canvas.getByLabelText('Email'), 'test@example.com')
    await userEvent.click(canvas.getByRole('button', { name: 'Submit' }))
    await expect(args.onSubmit).toHaveBeenCalledWith({ email: 'test@example.com' })
  }
}
```

**When to use play functions**:
- Form submissions (fill fields → submit → verify called with correct data)
- Dialog/modal open/close (click trigger → verify dialog → close → verify gone)
- Tab interactions (click each tab → verify panel content changes)
- Pagination (click next/prev → verify page number updates)
- Dropdown/select (open → select option → verify value)
- Error state (submit empty form → verify error messages appear)
- API-dependent flows (mock response → interact → verify loading → success → failure)

**Check**: Every play function starts by waiting for the element to be ready (auto-waiting handles this in Playwright/Storybook test). No sleep/timer-based waits.

### Step 3 — Add accessibility tests to every story

Run axe-core checks on every story:

**Via Storybook a11y addon** (automatic — no code needed):
```bash
npx storybook add @storybook/addon-a11y
```
Every story gets an accessibility panel showing violations, passes, and incomplete checks.

**Via Jest-axe for unit tests**:
```typescript
import { axe, toHaveNoViolations } from 'jest-axe'
expect.extend(toHaveNoViolations)

it('has no accessibility violations', async () => {
  const { container } = render(<Button>Submit</Button>)
  const results = await axe(container)
  expect(results).toHaveNoViolations()
})
```

**Via Playwright + @axe-core/playwright** for page-level:
```typescript
test('homepage passes WCAG A/AA', async ({ page, makeAxeBuilder }) => {
  await page.goto('/')
  const results = await makeAxeBuilder().analyze()
  expect(results.violations).toEqual([])
})
```

**Threshold**: Zero violations. If pre-existing violations exist, track them with violation fingerprint snapshots:
```typescript
// Create fingerprints (stable identifiers for known issues)
const fingerprints = results.violations.map(v => ({
  rule: v.id,
  targets: v.nodes.map(n => n.target)
}))
expect(JSON.stringify(fingerprints, null, 2)).toMatchSnapshot()
```

**Check**: `npx test-storybook --coverage` includes a11y checks. All violations are resolved or explicitly tracked.

### Step 4 — Add visual regression tests

Capture screenshots of every story and compare against baselines:

**Playwright visual comparisons** (per-page or per-component):
```typescript
test('login page matches snapshot', async ({ page }) => {
  await page.goto('/login')
  // Use stylePath to mask volatile elements (iframes, animated sections)
  await expect(page).toHaveScreenshot('login-page.png', {
    maxDiffPixels: 100,
    stylePath: path.join(__dirname, 'screenshot.css')
  })
})
```

**Storybook + Chromatic** (automatic per-story screenshots):
- Chromatic captures every story automatically
- Shows pixel-level diffs between baselines and new snapshots
- Groups changes by component for review
- Integrates with CI to block PRs on unexpected visual changes

**Handling dynamic content**:
- Use `stylePath` (Playwright) to hide or stabilize volatile elements (iframes, date displays, animated sections):
```css
/* screenshot.css */
iframe { visibility: hidden; }
.animated-banner { animation: none !important; }
.live-clock { visibility: hidden; }
```
- Mock API responses so data-driven components render deterministically
- Use fixed test data (not real/fixture data that changes) for screenshot tests

**When to update baselines**:
- After intentional design changes (run with `--update-snapshots`)
- After reviewing the diff and confirming the change is correct
- Never accept snapshot updates without reviewing the pixel diff

**Check**: `npx playwright test --update-snapshots` produces expected diffs. All diffs are reviewed before committing.

### Step 5 — Add E2E and integration tests (Playwright)

Test critical user flows across multiple pages:

```typescript
test('user can complete purchase flow', async ({ page }) => {
  await page.goto('/products')
  await page.getByText('Product A').click()
  await page.getByRole('button', { name: 'Add to Cart' }).click()
  await page.getByRole('link', { name: 'Checkout' }).click()
  await page.getByLabel('Email').fill('test@example.com')
  await page.getByLabel('Card Number').fill('4242424242424242')
  await page.getByRole('button', { name: 'Pay Now' }).click()
  await expect(page.getByText('Order confirmed')).toBeVisible()
})
```

**Aria snapshot testing** for structural assertions:
```typescript
test('navigation structure is correct', async ({ page }) => {
  await page.goto('/')
  await expect(page.getByRole('navigation')).toMatchAriaSnapshot(`
    - navigation "Main":
      - link "Home"
      - link "Products"
        - link "Category A"
        - link "Category B"
      - link "About"
      - link "Contact"
  `)
})
```

**Strategies for E2E tests**:
- Cover the 3-5 highest-value user flows (signup, purchase, search, settings)
- Use `page.getByRole()` and `page.getByLabel()` — never CSS selectors or XPath
- Mock external API calls at the network level (`page.route()`)
- Run tests in parallel with projects/shards
- Use authentication fixtures for logged-in flows

**Check**: All critical flows pass. E2E tests run in under 10 minutes in CI (parallel).

### Step 6 — Run tests in CI

Add a CI workflow that runs all test types:

```yaml
name: UI Tests
on: [push]
jobs:
  test:
    runs-on: ubuntu-latest
    container: mcr.microsoft.com/playwright:v1.58.2-noble
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: 22 }
      - run: npm ci
      - run: npx playwright install --with-deps
      - run: npm run test:unit          # jest-axe + vitest
      - run: npm run test:storybook     # interaction + a11y tests
      - run: npm run test:e2e           # Playwright E2E + visual
```

CI should:
- Run unit/component tests first (fastest feedback)
- Run Storybook tests next (covers most components)
- Run E2E + visual tests last (slowest, most comprehensive)
- Block the PR on any test failure
- Upload test artifacts (screenshots, trace files) for debugging

### Verification — Testing gate checklist

- [ ] Every component has stories for all meaningful states (default, disabled, loading, error, each variant)
- [ ] All interactive components have play-function tests that verify user interactions
- [ ] All stories/components have zero axe-core accessibility violations
- [ ] Visual regression snapshots exist for every story/page — all baselines reviewed
- [ ] Critical user flows covered by E2E tests (minimum 3 flows)
- [ ] ARIA snapshot tests exist for navigation and page structure
- [ ] All tests pass in CI with no flaky results
- [ ] Tests use accessible queries (`getByRole`, `getByLabel`) — no CSS-selector-based locators
- [ ] API calls are mocked in component tests and E2E tests (deterministic data)
- [ ] Test timeouts configured appropriately (expect: 5s, test: 30s)
- [ ] Failed tests produce artifacts (screenshots, traces, logs)
- [ ] Storybook builds successfully with all addons

## Anti-patterns

- **Testing implementation details** — Asserting on CSS classes, internal state, or DOM structure. Tests break on refactoring. Test behavior and accessibility tree instead.
- **Sleep-based waits** — `await page.waitForTimeout(1000)`. Always use auto-waiting, `waitForSelector`, or `waitForResponse`.
- **Skipping visual snapshots** — "It looks fine in my browser." Visual regression catches what humans miss during code review.
- **Disabling a11y rules permanently** — "This component doesn't need labels" is never true. Fix the component, not the test.
- **Mixing E2E and unit concerns** — Testing a single component's behavior in a full-page E2E test. Slow and fragile. Use Storybook + play functions instead.
- **Snapshotting the entire violations array** — Violations contain rendered HTML snippets. Snapshot fingerprints (rule ID + CSS selector) instead to avoid churn.
- **Running all tests sequentially** — Tests should run in parallel with proper isolation. CI time matters.
- **No test on CI** — If tests only pass locally, they don't exist. CI must run the same tests with the same configuration.
- **Catching errors in tests instead of fixing them** — `expect(errors).toHaveLength(0)` is better than `expect(errors.length).toBeLessThan(5)`.
- **Using `page.evaluate` to check state** — It bypasses the user-facing interface. Use accessible locators and assertion methods instead.

## Tools

**Installation**:
```bash
# Playwright (E2E, visual, aria snapshots)
npm init playwright@latest

# Storybook (component dev + interaction testing)
npx storybook@latest init

# Storybook a11y addon
npx storybook add @storybook/addon-a11y

# Storybook test runner (Vitest addon)
npx storybook add @storybook/addon-vitest

# Jest-axe (unit-level a11y)
npm install --save-dev jest-axe jest-environment-jsdom

# Playwright axe integration
npm install --save-dev @axe-core/playwright

# Chromatic (visual regression in CI)
npx chromatic --project-token=<token>
```

**Running tests**:
```bash
# All tests
npx playwright test
npx vitest --project=storybook

# Update snapshots
npx playwright test --update-snapshots
npx vitest --project=storybook --update

# Single file
npx playwright test tests/login.spec.ts

# With trace
npx playwright test --trace on

# Coverage
npx vitest --project=storybook --coverage
```

**Configuration files**:
- `playwright.config.ts` — Browser projects, timeouts, snapshot paths, reporters
- `.storybook/main.ts` — Addons, stories location, builder
- `chromatic.config.json` — Project token, build command, exit on error
