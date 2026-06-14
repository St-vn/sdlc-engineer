# Design Tokens & Tailwind CSS Methodology — Best Practices

Synthesized from Tailwind CSS v4 theme variables, shadcn/ui theming system, Material Design 3 token architecture, and IBM Carbon design token patterns. Provides a step-by-step workflow for an AI coding agent to design, implement, and maintain a token-based design system.

## Design Principles (max 5)

1. **Tokens are the single source of truth** — Every visual property (color, spacing, typography, radius, shadow, animation) is a named token. No raw hex, no arbitrary values, no magic numbers.

2. **Three-layer token architecture** — Reference tokens (raw values: `#1a1a1a`) → System tokens (semantic: `--color-primary`) → Component tokens (specific: `--button-bg`). Each layer adds meaning, not duplication.

3. **Semantic naming over descriptive** — Name tokens by what they do (`--color-primary`, `--color-surface`), not what they look like (`--color-blue`, `--color-gray-800`). This enables theme switching without renaming.

4. **Background/foreground pairs** — Every surface token has a matching `-foreground` variant. `--primary` controls the surface; `--primary-foreground` controls the text on it.

5. **Dark mode is token override, not separate CSS** — Dark mode redefines the same semantic tokens inside `.dark`. No new classes, no conditional styles, no `dark:` prefix everywhere.

## When to Apply

- Starting a new project with any framework
- Introducing a design system to an existing project
- Implementing dark mode or multi-theme support
- Sharing styles across multiple projects or platforms
- Making a design decision about colors, spacing, or typography
- Refactoring hardcoded values into a maintainable system
- Building a component library intended for reuse

## Process

### Step 1 — Define the token architecture

Choose one of two approaches:

**CSS variables approach (recommended)** — Define tokens in `:root` and `.dark`, expose to Tailwind via `@theme inline`:
```css
:root {
  --primary: oklch(0.205 0 0);
  --primary-foreground: oklch(0.985 0 0);
  --background: oklch(1 0 0);
  --foreground: oklch(0.145 0 0);
}
.dark {
  --primary: oklch(0.922 0 0);
  --primary-foreground: oklch(0.205 0 0);
  --background: oklch(0.145 0 0);
  --foreground: oklch(0.985 0 0);
}
@theme inline {
  --color-primary: var(--primary);
  --color-primary-foreground: var(--primary-foreground);
  --color-background: var(--background);
  --color-foreground: var(--foreground);
}
```

**Tailwind-only approach** — Override `@theme` directly without CSS variables (simpler, no runtime switching):
```css
@import "tailwindcss";
@theme {
  --color-primary: oklch(0.205 0 0);
  --color-primary-foreground: oklch(0.985 0 0);
}
```

**Decision**: Use CSS variables if you need dark mode, dynamic theming, or the ability to change tokens at runtime. Use Tailwind-only if the design is static.

### Step 2 — Define the core token namespaces

Map out every namespace in the Tailwind theme based on the design decisions:

| Namespace | Purpose | Example tokens |
|-----------|---------|---------------|
| `--color-*` | All color tokens | `--color-primary`, `--color-muted`, `--color-border` |
| `--font-*` | Font families | `--font-sans`, `--font-mono`, `--font-display` |
| `--text-*` | Font sizes with line-height | `--text-sm`, `--text-base`, `--text-lg` |
| `--font-weight-*` | Font weights | `--font-weight-normal`, `--font-weight-bold` |
| `--tracking-*` | Letter spacing | `--tracking-tight`, `--tracking-wide` |
| `--leading-*` | Line heights | `--leading-normal`, `--leading-relaxed` |
| `--spacing-*` | All spacing and sizing | `--spacing-4` (= 4px), `--spacing-8` (= 8px) |
| `--radius-*` | Border radius | `--radius-sm`, `--radius-lg`, `--radius-xl` |
| `--shadow-*` | Box shadows | `--shadow-sm`, `--shadow-md`, `--shadow-xl` |
| `--ease-*` | Transition timing | `--ease-in`, `--ease-out`, `--ease-in-out` |
| `--animate-*` | Animation keyframes | `--animate-spin`, `--animate-fade-in` |
| `--breakpoint-*` | Responsive breakpoints | `--breakpoint-sm`, `--breakpoint-lg` |
| `--container-*` | Container query widths | `--container-sm`, `--container-lg` |

**Check**: Every token namespace that the project uses has at least one value defined. No gaps in the type scale or color palette.

### Step 3 — Define semantic color tokens (shadcn/ui convention)

Use the shadcn/ui token schema as the recommended baseline. These tokens follow a strict background/foreground convention:

```css
:root {
  --background / --foreground       /* Page shell, default text */
  --card / --card-foreground        /* Elevated surfaces */
  --popover / --popover-foreground  /* Floating overlays */
  --primary / --primary-foreground  /* Brand, high-emphasis actions */
  --secondary / --secondary-foreground /* Supporting surfaces */
  --muted / --muted-foreground      /* Subtle, descriptions, placeholders */
  --accent / --accent-foreground    /* Hover/focus states, selected items */
  --destructive                     /* Error states, destructive buttons */
  --border                          /* Default borders, separators */
  --input                           /* Form control borders */
  --ring                            /* Focus rings */
  --chart-1 through --chart-5       /* Chart data series */
  --sidebar / ...                   /* Sidebar surfaces (optional) */
}
```

Color values use OKLCH color space for perceptual uniformity:

| Token | Light | Dark |
|-------|-------|------|
| `--background` | `oklch(1 0 0)` (white) | `oklch(0.145 0 0)` (near-black) |
| `--foreground` | `oklch(0.145 0 0)` | `oklch(0.985 0 0)` (near-white) |
| `--primary` | `oklch(0.205 0 0)` | `oklch(0.922 0 0)` |
| `--primary-foreground` | `oklch(0.985 0 0)` | `oklch(0.205 0 0)` |
| `--muted` | `oklch(0.97 0 0)` | `oklch(0.269 0 0)` |
| `--border` | `oklch(0.922 0 0)` | `oklch(1 0 0 / 10%)` |

**Check**: All foreground tokens have ≥4.5:1 contrast against their paired background token. Test in both light and dark mode.

### Step 4 — Define the radius scale from a base token

Derive all radius values from a single `--radius` base token:

```css
:root {
  --radius: 0.625rem;  /* base */
}
@theme inline {
  --radius-sm: calc(var(--radius) * 0.6);   /* 0.375rem */
  --radius-md: calc(var(--radius) * 0.8);   /* 0.5rem */
  --radius-lg: var(--radius);                /* 0.625rem */
  --radius-xl: calc(var(--radius) * 1.4);    /* 0.875rem */
  --radius-2xl: calc(var(--radius) * 1.8);   /* 1.125rem */
  --radius-3xl: calc(var(--radius) * 2.2);   /* 1.375rem */
  --radius-4xl: calc(var(--radius) * 2.6);   /* 1.625rem */
}
```

This ensures: changing `--radius` updates every corner radius in the entire system. Components use derived tokens (`rounded-lg`, `rounded-xl`), not hardcoded values.

### Step 5 — Implement dark mode as token overrides

Dark mode redefines the same CSS variable tokens inside a `.dark` selector:

```css
@custom-variant dark (&:is(.dark *));

.dark {
  --background: oklch(0.145 0 0);
  --foreground: oklch(0.985 0 0);
  --primary: oklch(0.922 0 0);
  --primary-foreground: oklch(0.205 0 0);
  --muted: oklch(0.269 0 0);
  --muted-foreground: oklch(0.708 0 0);
  --border: oklch(1 0 0 / 10%);
  --input: oklch(1 0 0 / 15%);
  --ring: oklch(0.556 0 0);
}
```

Rules:
- Never use `filter: invert()` for dark mode — it inverts images and produces muddy colors
- Dark mode desaturates foreground colors (lighter on dark backgrounds)
- Muted/surface tokens get darker backgrounds with lighter but desaturated text
- Border tokens use semi-transparent white (`oklch(1 0 0 / 10%)`) instead of opaque colors
- Test contrast independently for dark mode — light mode values don't transfer

### Step 6 — Share tokens across projects

Put shared theme variables into their own CSS file and import it:

```css
/* packages/brand/theme.css */
@theme {
  --*: initial;  /* clear default theme */
  --spacing: 4px;
  --font-body: Inter, sans-serif;
  --color-primary: oklch(0.62 0.21 259.8);
  --color-surface: oklch(0.98 0 0);
  /* ... full token set ... */
}
```

```css
/* apps/admin/app.css */
@import "tailwindcss";
@import "@company/brand/theme.css";
```

Use `@theme static` to always emit all CSS variables (even unused ones) for library/distribution packages:
```css
@theme static {
  --color-primary: var(--color-blue-500);
  --color-secondary: var(--color-green-500);
}
```

### Step 7 — Extend with custom tokens

To add a new semantic token (e.g., `warning`), follow the pattern:

```css
:root {
  --warning: oklch(0.84 0.16 84);
  --warning-foreground: oklch(0.28 0.07 46);
}
.dark {
  --warning: oklch(0.41 0.11 46);
  --warning-foreground: oklch(0.99 0.02 95);
}
@theme inline {
  --color-warning: var(--warning);
  --color-warning-foreground: var(--warning-foreground);
}
```

Now `bg-warning` and `text-warning-foreground` work everywhere.

### Verification — Token system checklist

- [ ] Every hardcoded color, spacing, radius, shadow, and font-size in the codebase has been replaced with a token reference
- [ ] All tokens follow background/foreground pair convention
- [ ] `@theme inline` exposes all CSS variable tokens to Tailwind
- [ ] Dark mode overrides exist for every color token (tested independently for contrast)
- [ ] Base radius token (`--radius`) controls all derived radius values
- [ ] OKLCH color space used for all new color values
- [ ] No CSS variables defined in `:root` that should be tokens (and vice versa)
- [ ] Token names are semantic (what they do), not descriptive (what they look like)
- [ ] All text tokens meet 4.5:1 contrast ratio in both light and dark mode
- [ ] `components.json` has `tailwind.cssVariables: true` if using shadcn/ui with CSS variables

## Anti-patterns

- **Raw hex in components** — `bg-[#1a1a1a]` in multiple files means changing the color requires searching every file. Always use a token.
- **Descriptive token names** — `--color-blue-500` instead of `--color-primary`. When the brand color changes to green, every component breaks.
- **Missing foreground pairs** — Defining `--color-primary` but not `--color-primary-foreground` means you can't place text on primary surfaces.
- **Per-screen token overrides** — Overriding `--primary` on one page and expecting it not to leak. Tokens are global.
- **Inverting for dark mode** — `filter: invert(1)` produces muddy, unreadable UI. Use proper token overrides.
- **Hardcoded border radius** — `rounded-[8px]` instead of `rounded-lg`. Every radius should come from the scale.
- **Shadow values without tokens** — `shadow-[0_2px_8px_rgba(0,0,0,0.1)]` should be `--shadow-md`.
- **Nesting `@theme` inside selectors** — `@theme` must be top-level. Use `:root` and `.dark` for CSS variables, then reference them in `@theme`.
- **Mixing token approaches** — Don't use both CSS variables and Tailwind-only tokens in the same project. Pick one.
- **Forgetting `@theme inline`** — CSS variables in `:root` do NOT automatically create Tailwind utilities. You must expose them with `@theme inline`.

## Tools

**Setup commands**:
```bash
# Tailwind CSS v4 with the design system
npm install tailwindcss @tailwindcss/cli

# shadcn/ui with CSS variables
npx shadcn@latest init --css-variables

# shadcn/ui without CSS variables
npx shadcn@latest init --no-css-variables

# Visual theme builder
npx shadcn@latest create
# → browse at https://ui.shadcn.com/create
```

**Shadcn/ui token reference** — Default neutral theme scaffold (the 40+ CSS variables in `:root` + `.dark` from shadcn/ui theming docs) serves as the canonical starting point. Copy into `app/globals.css` and adjust token values.

**Design token export** — Material Design 3 tokens for reference:
- `npm` package: `@material-design/design-tokens` (or download from m3.material.io)
- Tokens Studio format: `tokens-studio/material3-designkit-tokens` (GitHub)
