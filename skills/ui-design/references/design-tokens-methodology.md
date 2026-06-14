# Design Tokens — Quick Reference

## Token Categories
```
Color:    --color-primary, --color-surface, --color-text, --color-border
Spacing:  --space-{xs,sm,md,lg,xl,2xl}  (4px grid)
Typography: --font-body, --font-heading, --font-mono
Size:     --text-{sm,md,lg,xl,2xl,3xl}
Radius:   --radius-{none,sm,md,lg,full}
Shadow:   --shadow-{sm,md,lg}
Transition: --transition-fast, --transition-normal
Z-index:  --z-dropdown, --z-modal, --z-toast
```

## Color Token Strategy
```css
:root {
  /* Primary palette */
  --color-primary: oklch(45% 0.15 260);
  --color-primary-hover: oklch(40% 0.15 260);
  --color-primary-soft: oklch(90% 0.05 260);
  
  /* Neutral palette */
  --color-surface: oklch(98% 0 0);
  --color-surface-alt: oklch(95% 0 0);
  --color-border: oklch(85% 0 0);
  --color-text: oklch(20% 0 0);
  --color-text-soft: oklch(50% 0 0);
  
  /* Semantic palette */
  --color-success: oklch(55% 0.15 150);
  --color-warning: oklch(65% 0.15 80);
  --color-error: oklch(50% 0.2 30);
  --color-info: oklch(55% 0.1 230);
}
```

## OKLCH Color Space — Why
- Perceptually uniform: same numerical difference = same visual difference
- Good hue interpolation: no gray dead zone like HSL
- Wide gamut: covers Display P3, not just sRGB
- Tools: `oklch.com`, Culori, Chroma.js
