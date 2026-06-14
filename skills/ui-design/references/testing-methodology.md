# UI Testing — Quick Reference

## Test Pyramid (UI Focus)
```
E2E (10%):     Playwright — full user flows
Integration (20%): Testing Library — component interaction
Unit (70%):    Vitest/Jest — pure functions, state logic
Visual (cross-cutting): Playwright screenshot comparison
A11y (cross-cutting): axe-core automated + manual keyboard nav
```

## Playwright Patterns
```typescript
// Interaction test
test('user can submit form @interaction', async ({ page }) => {
  await page.goto('/contact');
  await page.fill('[name="email"]', 'test@example.com');
  await page.click('button[type="submit"]');
  await expect(page.locator('.success')).toBeVisible();
});

// Visual regression test
test('homepage renders correctly @visual', async ({ page }) => {
  await page.goto('/');
  await expect(page).toHaveScreenshot('homepage.png', {
    maxDiffPixels: 100,
  });
});

// Accessibility test
test('homepage has no a11y violations @a11y', async ({ page }) => {
  await page.goto('/');
  const results = await page.evaluate(() => axe.run());
  expect(results.violations).toHaveLength(0);
});
```

## Lighthouse CI Thresholds
```json
{
  "ci": {
    "assert": {
      "preset": "lighthouse:no-pwa",
      "assertions": {
        "categories:performance": ["warn", {"minScore": 0.8}],
        "categories:accessibility": ["error", {"minScore": 0.9}],
        "categories:best-practices": ["error", {"minScore": 0.9}],
        "categories:seo": ["error", {"minScore": 0.9}]
      }
    }
  }
}
```

## Tools and Install Commands
```bash
npm install -D @playwright/test @axe-core/cli @lhci/cli
npx playwright install
```
