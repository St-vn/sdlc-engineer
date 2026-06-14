# UI/UX Design System Methodology — Best Practices

Synthesized from Material Design 3, Apple HIG, IBM Carbon, and the 91.5k-star UI-UX-Pro-Max design intelligence database. Provides a step-by-step workflow for an AI coding agent to produce professional, platform-appropriate UI.

## Design Principles (max 5)

1. **Clarity over cleverness** — Every interface element must be immediately understandable. Legible text, precise icons, unambiguous labels. If a user has to think about what something does, it fails.

2. **Content deference** — The interface defers to content. Controls support rather than compete with what users care about. Remove chrome, not features.

3. **Platform authenticity** — Use platform-native patterns (navigation, typography, gestures, motion) for each target. iOS gets Tab Bars + SF Pro + spring animations. Web gets responsive layouts + system fonts + hover states.

4. **Consistency through tokens** — Every visual decision (color, spacing, radius, shadow, type scale) is a named design token. No raw hex values, no arbitrary padding.

5. **Accessibility is not a layer** — Contrast 4.5:1, keyboard navigation, visible focus rings, and screen reader support are baked into every component from the start, not bolted on at the end.

## When to Apply

- Building new pages (landing, dashboard, admin, mobile app)
- Creating or refactoring UI components (buttons, modals, forms, tables, charts)
- Choosing color schemes, typography systems, spacing standards, or layout systems
- Reviewing UI code for UX quality or visual consistency
- Adding animations, navigation structures, or responsive behavior
- Making product-level design decisions (style, information hierarchy, brand expression)

## Process

### Step 1 — Analyze product requirements and choose style direction

Extract from the user request: product type (SaaS, e-commerce, portfolio, healthcare, etc.), target audience, style keywords (minimal, playful, dark mode, premium), target platform (web, iOS, Android, cross-platform), and framework (React + Tailwind, SwiftUI, Jetpack Compose, etc.).

Match product type to one of the 67 UI style categories:
- **Minimalism & Swiss Style** — Enterprise apps, dashboards, documentation
- **Glassmorphism** — Modern SaaS, financial dashboards
- **Soft UI Evolution** — Wellness, beauty, lifestyle brands
- **Bento Box Grid** — Dashboards, product pages, portfolios
- **Dark Mode (OLED)** — Night-mode apps, coding platforms
- **AI-Native UI** — AI products, chatbots, copilots
- **Neubrutalism** — Gen Z brands, startups, Figma-style tools
- **Liquid Glass** — Premium SaaS, high-end e-commerce (iOS 26+)

**Check**: Verify the chosen style is not an anti-pattern for the industry (e.g., avoid AI purple/pink gradients for banking; avoid bright neon for healthcare).

### Step 2 — Generate design system (Master + Overrides)

Create a complete design system with these dimensions:

**Color palette** (3-5 colors minimum):
- Primary + on-primary (brand color, high-emphasis actions)
- Secondary + on-secondary (supporting surfaces)
- Surface + on-surface (background and text)
- Muted + on-muted (subtle surfaces, descriptions)
- Destructive (error states)
- Dark mode variants for every token (desaturated/lighter tonal variants, not inverted)

**Typography** (type scale with 5-7 sizes):
- Base 16px body text (never below 16px on mobile — prevents iOS auto-zoom)
- Line-height 1.5-1.75 for body, 1.1-1.3 for headings
- Font pairing: one display/heading font + one body font with contrasting personality
- Semantic type scale: Display → Headline → Title → Body → Label → Caption
- Font weights: Bold (600-700) for headings, Regular (400) for body, Medium (500) for labels
- Tabular figures for data columns and prices

**Spacing scale** (4px / 8dp increments):
- 4, 8, 12, 16, 20, 24, 32, 40, 48, 64, 80, 96
- Maintain consistent rhythm across component, section, and page levels

**Elevation and shadow**:
- 3-5 elevation levels with consistent shadow values (e.g., Material elevation: 0dp, 1dp, 3dp, 6dp, 8dp)
- Shadows use `box-shadow` with multiple layers for depth realism

**Border radius scale**:
- Base radius token (`--radius`) with derived scale: sm (0.6x), md (0.8x), lg (1x), xl (1.4x), 2xl (1.8x)

**Key effects**:
- Animation durations: 150-300ms for micro-interactions, ≤400ms for complex transitions
- Easing: ease-out for entering, ease-in for exiting, spring/physics-based for natural feel
- Hover states with smooth transitions (150-300ms)
- Press feedback (ripple/opacity/elevation change)

**Verify**: Check the design system against the 10 anti-patterns for the product's industry (stored in the reasoning rules database).

### Step 3 — Implement components with the design system

Build UI components using the generated tokens. Follow platform conventions:

**Web (Tailwind/shadcn/ui)**:
- Use CSS variables for semantic tokens: `--color-primary`, `--color-background`, `--font-body`
- Dark mode via `.dark` selector overrides of the same tokens
- shadcn/ui pattern: open-code components with composable APIs, not wrapped library components
- Background/foreground token pairs: every surface has a matching text token

**iOS (SwiftUI)**:
- SF Pro font (Text ≤19pt) and SF Pro Display (≥20pt)
- Dynamic Type support with the 11 text styles (Large Title → Caption 2)
- Safe areas, notch, Dynamic Island awareness
- Bottom Tab Bar for top-level navigation (max 5 items)
- NavigationStack for push navigation with automatic back swipe

**Cross-platform**:
- Platform-adaptive: detect platform and switch navigation patterns
- Native controls preferred over custom for standard interactions
- Touch targets ≥44pt on iOS, ≥48dp on Android

**Check**: No emojis as icons (use SVG: Heroicons, Lucide). Hover states work. Focus states visible. Pressed states don't shift layout.

### Step 4 — Apply interaction and layout rules

**Interaction**:
- Touch targets: min 44x44pt (iOS) / 48x48dp (Android) with 8px minimum gap
- `cursor-pointer` on all clickable elements
- Loading buttons: disable during async, show spinner, then success/error state
- Form errors: inline below the field, not just a summary at top
- Input labels: always visible (not placeholder-only)
- Multi-step forms: show progress indicator, allow back navigation
- Auto-save drafts for long forms

**Responsive layout**:
- Mobile-first with breakpoints: 375px, 768px, 1024px, 1440px
- Readable line length: 35-60 chars on mobile, 60-75 on desktop
- No horizontal scroll on mobile
- Consistent max-width on desktop (max-w-6xl / 7xl)
- `min-h-dvh` instead of `100vh` on mobile (addresses browser chrome)
- 4px/8dp spacing rhythm maintained
- Fixed navbar/bottom bar reserve safe padding for underlying content
- Z-index scale: 0, 10, 20, 40, 100, 1000

### Step 5 — Apply motion and animation rules

- Duration 150-300ms for micro-interactions, exit faster than enter (60-70% of enter)
- Use `transform` and `opacity` only — never animate `width`/`height`/`top`/`left`
- Stagger list/grid items by 30-50ms per item
- Shared element / hero transitions for spatial continuity between screens
- Parallax must respect `prefers-reduced-motion`
- Motion must convey meaning (cause-effect relationship), never be purely decorative
- Animations must be interruptible (user tap cancels in-progress animation)
- Enter from below = deeper, exit upward = back (hierarchy motion)

### Verification — Pre-delivery checklist

- [ ] No emojis used as icons (SVG: Heroicons, Lucide, platform icon sets)
- [ ] All icons from a consistent icon family with uniform stroke width
- [ ] Semantic theme tokens used consistently (no ad-hoc hardcoded hex values)
- [ ] `cursor-pointer` on all clickable elements
- [ ] Hover states with smooth transitions (150-300ms)
- [ ] Focus states visible for keyboard navigation (2-4px ring)
- [ ] Pressed-state visuals don't shift layout bounds
- [ ] Text contrast ≥4.5:1 (AA) — test in both light and dark mode
- [ ] Touch targets ≥44x44pt, 8px minimum gap
- [ ] Form fields have visible labels, inline errors, and helper text
- [ ] `prefers-reduced-motion` respected
- [ ] Responsive at 375px, 768px, 1024px, 1440px — no horizontal scroll
- [ ] Safe areas respected for fixed headers/tab bars
- [ ] Light/dark mode both tested, contrast verified independently
- [ ] Modal/drawer scrim opacity strong enough (40-60% black)
- [ ] Tab order matches visual order; full keyboard support
- [ ] Disabled states visually clear and non-interactive (opacity 0.38-0.5)
- [ ] Build with `design-system/MASTER.md` for persistence across sessions

## Anti-patterns

- **Emoji as structural icons** — Emojis are font-dependent, inconsistent across platforms, and cannot be controlled via design tokens. Use SVG.
- **Color-only information** — Never convey meaning by color alone. Add icons, text, or patterns.
- **Premature dark mode** — Design light and dark variants together. Don't infer dark mode from light values.
- **Mixing UI styles** — Don't combine flat and skeuomorphic or glass and brutalism in the same product.
- **Icon-only navigation without labels** — Destroys discoverability. Always pair icon + text.
- **Nested scroll regions** — Avoid nested scroll that interferes with main scroll.
- **Decorative-only animation** — Every animation must have a purpose and cause-effect relationship.
- **Fixed pixel container widths** — Use relative units, max-width, and min-height.
- **Disabling zoom** — Never set `user-scalable=no`. Always use `width=device-width, initial-scale=1`.
- **Purple/pink gradients as default** — Avoid the "AI startup" cliché unless the product genuinely calls for it.
- **Slow animations (>500ms)** — Users perceive the app as sluggish.
- **Placeholder-only labels** — Disappearing context hurts accessibility and usability.

## Tools

- **UI-UX-Pro-Max** (design system generation): `python3 skills/ui-ux-pro-max/scripts/search.py "<product> <keywords>" --design-system -p "Project Name"`
- **Domain-specific search**: `python3 skills/ui-ux-pro-max/scripts/search.py "<query>" --domain <domain>` where domain = `product`, `style`, `color`, `typography`, `landing`, `chart`, `ux`
- **Stack-specific search**: `python3 skills/ui-ux-pro-max/scripts/search.py "<query>" --stack <stack>` where stack = `html-tailwind`, `react`, `nextjs`, `react-native`, `swiftui`, `flutter`, `shadcn`, `jetpack-compose`
- **Color contrast**: Chrome DevTools Accessibility tab, axe-core, or `@axe-core/playwright`
- **Responsive testing**: Browser DevTools device emulation at 375px, 768px, 1024px, 1440px
- **Animation timing**: Chrome DevTools Performance tab, `performance.now()` measurements
