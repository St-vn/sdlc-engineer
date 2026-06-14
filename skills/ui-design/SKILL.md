---
name: ui-design
description: Full-stack UI/UX workflow — design system generation, component implementation with accessibility, automated testing (visual regression, a11y audit, performance), and cross-browser review. Triggers on "design UI", "build frontend", "create component", "design system", or frontend implementation requests.
---

# /ui-design — Design → Build → Test → Review

A four-phase workflow for production-grade UI development. Every phase includes automated verification gates. Outputs: design tokens, components, test reports.

## Trigger phrases (auto-invoke from chat)
- "design the UI for X"
- "build a frontend for X"
- "create a component for X"
- "design system for X"
- Invoked by /implement for frontend tasks

## Phase 1: Design System Generation

1. **Detect tech stack**: React/Vue/Svelte/Solid/vanilla — check package.json, ask user, or assume React
2. **Determine UI style** — ask user or infer from project domain:
   - Landing page: modern, bold, gradient-heavy
   - Dashboard: clean, data-dense, muted
   - E-commerce: product-first, trust-signaling
3. **Generate design tokens in CSS custom properties**:
   ```css
   :root {
     /* Colors — ensure WCAG AA 4.5:1 contrast */
     --color-primary: oklch(45% 0.15 260);
     --color-surface: oklch(98% 0 0);
     --color-text: oklch(20% 0 0);
     /* Spacing — 4px grid */
     --space-xs: 0.25rem;
     --space-sm: 0.5rem;
     --space-md: 1rem;
     --space-lg: 1.5rem;
     --space-xl: 2rem;
     /* Typography — system fonts or Google Fonts pairings */
     --font-body: system-ui, sans-serif;
     --font-heading: 'Inter', system-ui, sans-serif;
     /* Shadows, radii, transitions */
     --shadow-sm: 0 1px 2px oklch(0% 0 0 / 10%);
     --radius-sm: 4px;
     --radius-md: 8px;
   }
   ```
4. **Define component architecture**: atomic design (atoms → molecules → organisms → templates)
5. Reference files for expanded guidance (consult if needed):
   - `docs/sdlc-engineer/ui-ux-design-system-methodology.md`
   - `docs/sdlc-engineer/ui-ux-design-tokens-methodology.md`

**Gate:** Design tokens pass contrast check (all text/background pairs ≥ WCAG AA 4.5:1)

## Phase 2: Implementation

Build components following these rules:

1. **Accessibility (WCAG 2.1 AA)**:
   - All interactive elements: keyboard navigable, focus visible, role/purpose announced
   - Color is never the sole differentiator — use icons, text, patterns
   - Touch targets: minimum 44x44px
   - Form inputs: label associated, error messages linked via aria-describedby
2. **States** (every interactive component must handle all of):
   - Default, Hover, Focus, Active, Disabled, Loading, Error, Empty
3. **Responsive**: mobile-first, breakpoints at 640/768/1024/1280px
4. **Performance**: lazy-load below-fold images, code-split route-level, minimize layout shifts
5. Reference files:
   - `docs/sdlc-engineer/ui-ux-accessibility-methodology.md`

**Gate:** Manual a11y checklist (keyboard nav through all interactive elements, screen reader test on critical flows)

## Phase 3: Automated Testing

Run in this order (stop on failure):

1. **Interaction tests** (Playwright/Testing Library):
   - User flows: click, type, navigate, submit
   - Assert: correct render, correct behavior, no console errors
   ```bash
   npx playwright test --grep "@interaction"
   ```

2. **Accessibility audit** (axe-core):
   ```bash
   npx @axe-core/cli http://localhost:3000 --exit --threshold 0
   ```
   - Fail on: any violation (threshold=0)
   - Review: best-practice recommendations (informational, not blocking)

3. **Visual regression** (Playwright screenshot comparison):
   ```bash
   npx playwright test --grep "@visual"
   ```
   - Diff threshold: 0.1% max per component
   - On diff: update screenshots with `--update-snapshots` after manual review

4. **Performance audit** (Lighthouse CI):
   ```bash
   npx lhci autorun --collect.url=http://localhost:3000
   ```
   - Thresholds: Performance ≥ 80, Accessibility ≥ 90, Best Practices ≥ 90, SEO ≥ 90

Reference files:
- `docs/sdlc-engineer/ui-ux-testing-methodology.md`
- `docs/sdlc-engineer/browser-testing-devtools.md`

**Gate:** All 4 testing steps pass. If any fails, fix before proceeding.

## Phase 4: Review

Generate review report covering:

1. **Design consistency**: tokens used correctly? spacing grid followed? component variants complete?
2. **Accessibility report**: axe-core violations, keyboard nav gaps, contrast failures
3. **Performance report**: Lighthouse scores, Largest Contentful Paint, Cumulative Layout Shift
4. **Cross-browser**: test in Chrome + Firefox + Safari (or note "tested in Chrome only" if not)

Output report:
```markdown
## UI/UX Review
### Accessibility: PASS/FAIL (N violations)
### Performance: XX/100
### Visual Regression: PASS/FAIL (N diffs)
### Cross-Browser: PASS/LIMITED
### Open Issues:
- [ ] Issue 1
- [ ] Issue 2
```

**Gate:** Review report is generated. Open issues are either fixed or documented with rationale.

## Anti-rationalization table
| Common Excuse | Why It's Wrong | What to Do Instead |
|---|---|---|
| "I'll add accessibility later" | Retrofitting a11y costs 5x more than building it in. Users with disabilities are users too. | Build with a11y from the start. Use semantic HTML. Test with axe-core. |
| "Visual regression tests are overkill" | CSS changes break layouts silently. Visual regression catches what unit tests miss. | Add Playwright screenshot tests for every component. Low effort, high value. |
| "I don't need a design system for this" | Even a 5-file project benefits from consistent spacing, color, and typography. Inconsistent UI looks unprofessional. | Generate design tokens. 20 lines of CSS. Every project deserves it. |
| "Mobile can come later" | Mobile-first is cheaper and prevents desktop-only assumptions. 60%+ of users are mobile. | Start mobile-first. Expand to desktop. Less code, better UX. |
