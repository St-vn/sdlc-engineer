# Accessibility Testing Methodology — Best Practices

Synthesized from WCAG 2.1 AA, WAI-ARIA Authoring Practices Guide, web.dev Learn Accessibility, axe-core, Playwright accessibility testing, and Apple HIG accessibility guidelines. Provides a step-by-step workflow for an AI coding agent to integrate accessibility into every stage of development.

## Design Principles (max 5)

1. **Automated checks catch ~30% of barriers** — Tools find common issues but cannot guarantee accessibility. Always combine automated + manual + assistive technology testing.

2. **Semantic HTML first, ARIA second** — Use native HTML elements before ARIA roles. The first rule of ARIA is: don't use ARIA if a native HTML element already provides the semantics.

3. **Keyboard everything** — Every interactive element must be reachable and operable via keyboard alone. Tab order must match visual order.

4. **Color is never the only channel** — Never convey information, state, or distinction through color alone. Always pair with text, icon, or pattern.

5. **Respect user preferences** — Support `prefers-reduced-motion`, `prefers-color-scheme`, Dynamic Type / text scaling, and forced colors mode.

## When to Apply

- When building any new component, page, or feature
- Before every release or pull request merge
- When adding interactive elements (forms, modals, nav, drag-and-drop)
- When choosing color palettes or implementing dark mode
- When adding animations, transitions, or parallax effects
- When integrating third-party widgets or embeds

## Process

### Step 1 — Semantic structure and landmarks

Ensure the page has a correct document structure before adding any visual styling:

- Use `<header>`, `<nav>`, `<main>`, `<aside>`, `<footer>` landmark elements
- One `<h1>` per page, sequential heading hierarchy (h1→h2→h3, no skipping levels)
- `<main>` element wraps primary content, exactly one per page
- Skip-to-content link as the first focusable element
- `<table>` elements have `<caption>`, `<th>` with `scope`, and appropriate `<thead>`/`<tbody>` structure
- Lists use `<ul>`/`<ol>`/`<li>` with correct nesting, not styled `<div>` sequences

**Check**: Run `document.querySelectorAll('h1, h2, h3, h4, h5, h6')` — verify no level skips and exactly one h1.

### Step 2 — Color and contrast verification

Verify all text and UI element contrast using WCAG 2.1 AA thresholds:

- Normal text (<18pt or <14pt bold): contrast ratio ≥4.5:1
- Large text (≥18pt or ≥14pt bold): contrast ratio ≥3:1
- UI components and graphical objects: contrast ratio ≥3:1 against adjacent colors
- Focus indicators: 2-4px solid outline or ring with ≥3:1 contrast against the background
- Error states: use semantic danger color that still meets contrast requirements; pair with icon/text

**Verification** — Automated check:
```javascript
// Run in browser DevTools or test framework
// Manual: use Chrome DevTools → Inspect → Accessibility — check "Contrast ratio"
// Automated: use axe-core or @axe-core/playwright
```

### Step 3 — Keyboard navigation audit

Walk through every interactive element using only Tab, Shift+Tab, Enter, Space, and arrow keys:

- All interactive elements reachable via Tab in logical order (matches visual reading order)
- Visible focus indicator on every focusable element (never `outline: none` without replacement)
- No focus traps — modals trap focus but close with Escape; tooltips dismiss with Escape
- Custom widgets implement expected keyboard patterns from ARIA APG:
  - Radio groups: arrow keys to navigate, Tab to enter/exit group
  - Tabs: arrow keys to switch tabs, Tab to move into tab panel
  - Combobox: arrow keys to navigate options, Enter to select
  - Dialog: focus first focusable element on open, return focus on close
  - Menu/Menubar: arrow keys, Enter/Space to activate, Escape to close

**Verification**: Tab through the entire page. Every element should have a visible focus ring. No element should be unreachable.

### Step 4 — ARIA roles, states, and properties

Add ARIA attributes only where native HTML does not provide the semantics:

Mandatory checks:
- `aria-label` on icon-only buttons and links (screen reader needs text)
- `aria-expanded` and `aria-controls` on expandable elements (accordions, menus)
- `aria-current="page"` on active navigation items
- `aria-live="polite"` on dynamic content regions (toasts, notifications, loading spinners)
- `aria-live="assertive"` only for time-critical messages (errors that block progress)
- `aria-describedby` for input descriptions (connects helper text to input)
- `aria-required`, `aria-invalid`, `aria-errormessage` on form fields
- `role="alert"` on error messages (not on static warnings)
- `role="dialog"` or `role="alertdialog"` for modals (with `aria-modal="true"`)
- `role="progressbar"` with `aria-valuenow`, `aria-valuemin`, `aria-valuemax` for progress indicators
- `aria-hidden="true"` on decorative icons and non-interactive visual elements
- `role="status"` for status messages that should announce without interrupting
- `role="tablist"`, `role="tab"`, `role="tabpanel"` for tab interfaces
- `aria-selected` on tab elements

Anti-patterns:
- Do not add `role="button"` to a `<div>` when `<button>` works
- Do not override native semantics (e.g., `role="heading"` on an `<h2>`)
- Do not nest interactive elements (e.g., button inside a link)
- Do not use `aria-live="assertive"` for routine updates
- Do not use `tabindex` > 0 (use source order instead)
- Do not remove focus indicators globally

**Check**: Run `axe-core` or `@axe-core/playwright` — verify zero violations for `aria-*` rules.

### Step 5 — Automated accessibility testing (axe-core)

Run axe-core automated scans at multiple levels:

**Unit/component level** (jest-axe):
```javascript
import { axe, toHaveNoViolations } from 'jest-axe'
expect.extend(toHaveNoViolations)

it('component has no accessibility violations', async () => {
  const { container } = render(<MyComponent />)
  const results = await axe(container)
  expect(results).toHaveNoViolations()
})
```

**Page/integration level** (Playwright + `@axe-core/playwright`):
```javascript
import AxeBuilder from '@axe-core/playwright'

test('page has no detectable WCAG A/AA violations', async ({ page }) => {
  await page.goto('https://site.com/page')
  const results = await new AxeBuilder({ page })
    .withTags(['wcag2a', 'wcag2aa', 'wcag21a', 'wcag21aa'])
    .analyze()
  expect(results.violations).toEqual([])
})
```

**Configuration for isolated components** (disable landmark rules):
```javascript
const axe = configureAxe({
  rules: { 'region': { enabled: false } }
})
```

**Fixture pattern for shared config**:
```javascript
import { test as base } from '@playwright/test'
import AxeBuilder from '@axe-core/playwright'

const test = base.extend({
  makeAxeBuilder: async ({ page }, use) => {
    const makeAxeBuilder = () => new AxeBuilder({ page })
      .withTags(['wcag2a', 'wcag2aa', 'wcag21a', 'wcag21aa'])
      .exclude('#known-issue-element')
    await use(makeAxeBuilder)
  }
})
```

**Handling known issues**:
- Use `AxeBuilder.exclude(selector)` to exclude specific elements with known issues
- Use `AxeBuilder.disableRules(['rule-id'])` to disable specific rules temporarily
- Use violation fingerprint snapshots to track known issues without freezing full violation objects
- Never permanently disable rules — re-enable after fixing the underlying issue

**Verification**: `npx playwright test` passes with zero violations. If pre-existing violations exist, they are tracked with `toMatchSnapshot` of violation fingerprints.

### Step 6 — Manual accessibility testing

Automated tools miss ~70% of barriers. Perform these manual checks:

**Screen reader test** (VoiceOver on macOS/iOS, NVDA on Windows, TalkBack on Android):
- Navigate page from top to bottom using only screen reader navigation commands
- Verify: all content is announced, reading order is logical, interactive elements have correct labels and states
- Test: form submission with errors, dynamic content updates, modal open/close

**Dynamic Type / text scaling**:
- On iOS: Settings → Accessibility → Display & Text Size → Larger Text — set to largest
- On web: Ctrl/Cmd + Plus to zoom to 200%, also use browser zoom to 400%
- Verify: no text truncation, no overlapping elements, no content loss, all functionality still accessible

**Reduced motion**:
- Enable `prefers-reduced-motion` in OS accessibility settings or browser DevTools (Rendering → Emulate CSS media feature)
- Verify: all animations are disabled or reduced, no content is hidden by disabled animation, parallax effects fall back to static

**Forced colors / high contrast mode**:
- On Windows: Settings → Accessibility → High contrast (or Windows High Contrast theme)
- On web: Chrome DevTools → Rendering → Emulate CSS media feature `forced-colors: active`
- Verify: all information conveyed by color is still conveyed, focus indicators remain visible, custom buttons/inputs are distinguishable

**Keyboard-only flow**:
- Complete a critical user flow (sign up, checkout, search) using only Tab, Enter, Space, arrow keys
- Verify: no mouse required at any step, all tooltips/popovers open and close via keyboard, skip link works on first Tab press

### Verification — Accessibility gate checklist

- [ ] `axe-core` / `jest-axe` — zero violations (component and page level)
- [ ] Color contrast ≥4.5:1 for normal text, ≥3:1 for large text (verified with tool)
- [ ] All form fields have visible `<label>` with `for` attribute
- [ ] All icon-only buttons/links have `aria-label`
- [ ] All images with meaning have `alt` text; decorative images have `alt=""` or `aria-hidden="true"`
- [ ] Heading hierarchy: h1→h2→h3, no skips, exactly one h1 per page
- [ ] Landmarks present: `<header>`, `<nav>`, `<main>`, `<footer>` (at minimum)
- [ ] Tab order matches visual order, no positive `tabindex` values
- [ ] Focus indicators visible on all interactive elements (never `outline: none` alone)
- [ ] Modals: focus trap + close on Escape + return focus on close
- [ ] `prefers-reduced-motion` respected — no motion when disabled
- [ ] Skip-to-content link present as first focusable element
- [ ] Screen reader navigation works top-to-bottom, all content announced
- [ ] Dynamic Type / 200% zoom — no truncation, no overlap
- [ ] Color is never the only indicator of state (add icon or text)
- [ ] Error messages have `aria-live="polite"` or `role="alert"`
- [ ] Disabled states: visible, non-interactive, with `disabled` attribute (opacity 0.38-0.5)
- [ ] ARIA landmarks have unique `aria-label` when multiple same-role landmarks exist
- [ ] Role, state, and property changes in custom widgets follow ARIA APG patterns

## Anti-patterns

- **Relying solely on automated tools** — Automated checks miss ~70% of barriers. Always combine with manual testing.
- **Removing focus outlines** — Never `outline: none` without providing a replacement. Leads to keyboard-unfriendly UI.
- **Placeholder as label** — Placeholder text disappears on input, losing context. Always use a persistent `<label>`.
- **Color-only indicators** — Error states, active states, required fields — always pair color with icon/text.
- **Icon-only controls without labels** — An icon of a trash can needs `aria-label="Delete"`.
- **Disabling zoom** — `user-scalable=no` violates WCAG Success Criterion 1.4.4 Resize text.
- **Invisible skip link** — Must be visible on focus, not just in the DOM.
- **Nested interactive elements** — Button inside a link, clickable div inside a button — breaks screen reader navigation.
- **Live regions for static content** — Don't add `aria-live` to elements that don't change dynamically.
- **Custom controls without ARIA** — Building a custom select without `role="listbox"`, `role="option"`, `aria-selected` — screen readers see nothing.
- **Focus traps without escape** — Any focus-trapping element (modal, menu) must close with Escape.

## Tools

**Installation**:
```bash
# axe-core for unit tests (jest)
npm install --save-dev jest-axe jest jest-environment-jsdom

# axe-core for Playwright
npm install --save-dev @axe-core/playwright

# Storybook accessibility addon
npx storybook add @storybook/addon-a11y

# Manual testing assistants
# Chrome: Accessibility Insights for Web (free, Microsoft)
# macOS: VoiceOver (built-in) — Cmd+F5 to enable
# Windows: NVDA (free, nvaccess.org)
```

**Verification commands**:
```bash
# Run all accessibility tests
npx jest --testPathPattern="accessibility"
npx playwright test

# Interactive axe scan in browser DevTools
axe DevTools extension (Chrome)

# Color contrast checker
Chrome DevTools → Elements → Styles → Color picker (contrast ratio badge)
```
