# Accessibility Methodology — Quick Reference

## WCAG 2.1 AA Checklist
- **1.1.1**: All non-text content has text alternative
- **1.4.3**: Contrast ≥ 4.5:1 (text) / 3:1 (large text)
- **1.4.11**: Non-text contrast ≥ 3:1 (icons, borders)
- **2.1.1**: All functionality via keyboard
- **2.4.7**: Focus visible
- **2.5.5**: Touch targets ≥ 44x44px
- **4.1.2**: Interactive elements have name, role, value
- **4.1.3**: Status messages announced via aria-live

## Testing Tools
- axe-core: `npx @axe-core/cli <url> --exit --threshold 0`
- Lighthouse a11y: `npx lhci autorun --collect.url=<url>`
- Playwright: `await page.evaluate(() => axe.run())`
- Color contrast: WebAIM contrast checker or browser devtools
- Screen reader: VoiceOver (macOS), NVDA (Windows), Orca (Linux)

## ARIA Rules
- Use semantic HTML first (button, nav, input, select)
- ARIA only when native semantics don't work
- Never override native semantics (role=button on a button — redundant)
- aria-label for icon-only buttons
- aria-expanded for toggleable content
- aria-live="polite" for dynamic updates
- aria-describedby linking error messages to inputs
