# sdlc-engineer v2 — One-Shot Execution Plan

> **For:** Antigravity IDE or any autonomous agent executor
> **Instructions:** Execute all tasks in order. Each task is fully self-contained — do NOT reference external files for content. Use RED→GREEN verification per task. If GREEN fails, STOP and flag.

---

## Session 1: Core Skills — ALREADY DONE (skip)

Tasks completed by previous Antigravity run:
- `skills/debug/SKILL.md` ✅ — enhanced
- `skills/debug/references/common-patterns.md` ✅ — created
- `skills/modify/SKILL.md` ✅ — created
- `skills/doubt/SKILL.md` ✅ — created

---

## Sessions 2-3: Anti-Rationalization Tables on 27 Existing Skills

For each of the 27 files below:
1. Read the existing SKILL.md
2. Append this section before the last line of the file (before the closing `---` or end):
3. (The content is fully specified below for each skill)

### Task 2.1 — skills/implement/SKILL.md

Append:
```
## Anti-rationalization table
| Common Excuse | Why It's Wrong | What to Do Instead |
|---|---|---|
| "I'll write tests later" | Later never happens. Tests written after code confirm the implementation, not the requirements. | Write the failing test first (RED), then implement. |
| "This is too simple to break down into tasks" | Every non-trivial change has hidden edge cases. Task breakdown reveals them. | Run /tasks first. If it produces 1 task, fine — but verify. |
| "The task plan is too rigid, I'll improvise" | Improvisation skips the RED step, removing the only objective success criterion. | Follow the task plan. If it's wrong, fix the plan, not the execution. |
| "I don't need pre-flight checks" | Missing project config or stale research causes silent correctness failures. | Run /implement's pre-flight. It takes 30 seconds. |
```

### Task 2.2 — skills/spec/SKILL.md

Append:
```
## Anti-rationalization table
| Common Excuse | Why It's Wrong | What to Do Instead |
|---|---|---|
| "I already know what to build" | Writing it down reveals hidden assumptions and missing stakeholders. | Write user stories. INVEST-check them. Then start coding. |
| "Requirements will change anyway, why document?" | Changing documented requirements is traceable. Changing undocumented assumptions is chaos. | Document current understanding. Update when things change. |
| "This is obvious, it doesn't need acceptance criteria" | "Obvious" means different things to different people. ACs are the definition of done. | Write Given-When-Then for every story. |
```

### Task 2.3 — skills/design/SKILL.md

Append:
```
## Anti-rationalization table
| Common Excuse | Why It's Wrong | What to Do Instead |
|---|---|---|
| "It's a simple feature, we don't need architecture" | Complexity compounds. The 10th "simple feature" creates an unmaintainable mess. | Draw a component diagram anyway. 5 minutes saves 5 hours. |
| "We'll refactor later" | Refactoring without architectural context is shuffling deck chairs. | Document the architecture intent now. Refactor against it later. |
| "Microservices will solve this" | Microservices before monolith is premature distribution. You don't know the boundaries yet. | Start modular monolith. Extract only when boundaries are proven. |
```

### Task 2.4 — skills/elicit/SKILL.md

Append:
```
## Anti-rationalization table
| Common Excuse | Why It's Wrong | What to Do Instead |
|---|---|---|
| "I know what the user needs" | You are not the user. Assumptions are the #1 source of rework. | Ask structured questions. Document answers. Validate with stakeholders. |
| "The requirements are in the ticket" | Tickets are summaries, not specifications. They hide context and tradeoffs. | Elicit: who, what, why, when, edge cases, failure modes. |
| "We already discussed this" | Verbal agreements are not requirements. Memory is unreliable. | Write down every decision. Share with stakeholders. Confirm in writing. |
```

### Task 2.5 — skills/analyze/SKILL.md

Append:
```
## Anti-rationalization table
| Common Excuse | Why It's Wrong | What to Do Instead |
|---|---|---|
| "We don't have time for analysis" | Unanalysed projects fail 3x more often. Analysis is time invested, not spent. | Run a lightweight feasibility check. 30 minutes saves days. |
| "Analysis is just speculation" | Structured analysis maps dependencies, risks, and tradeoffs. Speculation is guessing without structure. | Use the dependency map and risk register templates. Tangible output. |
| "We already know the tradeoffs" | Known tradeoffs are rarely documented, so they're forgotten under pressure. | Write tradeoff analysis. Refer back during implementation. |
```

### Task 2.6 — skills/decide/SKILL.md

Append:
```
## Anti-rationalization table
| Common Excuse | Why It's Wrong | What to Do Instead |
|---|---|---|
| "We'll decide later" | Deferred decisions block implementation and accumulate as technical debt. | Make the smallest irreversible decision now. Document explicitly. |
| "Either option works fine" | If both options work, you haven't identified the discriminators. Find the constraint that breaks one. | Map decision criteria. Weight them. Score options. |
| "Let's ask everyone first" | Consensus-seeking without a proposal leads to endless bikeshedding. | Propose a recommendation first. Then solicit disagreement. |
```

### Task 2.7 — skills/tasks/SKILL.md

Append:
```
## Anti-rationalization table
| Common Excuse | Why It's Wrong | What to Do Instead |
|---|---|---|
| "I'll figure out the steps as I go" | Planning as you go misses dependencies, duplicates work, and forgets edge cases. | Break into tasks first. Each task has one clear RED test. |
| "My tasks are small enough" | "Small enough" is subjective. If a task touches 3+ files, it's too large. | Split until each task touches 1-2 files and has a single behavioral change. |
| "Task breakdown is overhead" | A 10-minute task plan is 1% overhead for a 2-day feature. It eliminates 50% of integration bugs. | Run /tasks. Read the output. Adjust if needed. Don't skip. |
```

### Task 2.8 — skills/review-spec/SKILL.md

Append:
```
## Anti-rationalization table
| Common Excuse | Why It's Wrong | What to Do Instead |
|---|---|---|
| "The tests pass, so the spec is satisfied" | Tests can be wrong, incomplete, or test the wrong thing. | Verify each AC against the implementation independently. |
| "I reviewed it in my head" | Mental review misses 60% of defects. Written review catches them. | Use the review-spec subagent. It sees only the ACs + diff. |
| "This is a minor change, it doesn't need review" | Minor changes have caused major incidents (Heartbleed, Knight Capital). | Review every change. 5 minutes. Non-negotiable. |
```

### Task 2.9 — skills/configure/SKILL.md

Append:
```
## Anti-rationalization table
| Common Excuse | Why It's Wrong | What to Do Instead |
|---|---|---|
| "Defaults are fine for now" | Defaults don't know your security tier, compliance needs, or deployment target. | Answer the configure questions. It takes 2 minutes. |
| "I'll configure later when I need it" | Later-configuring a project meant for production is re-engineering, not setup. | Configure before writing code. The config gates all downstream skills. |
| "I know what my maturity tier is" | Then the configure questions will take 10 seconds. Skipping config means no skill gates work. | Run /configure. Confirm the tier. Move on. |
```

### Task 2.10 — skills/consult/SKILL.md

Append:
```
## Anti-rationalization table
| Common Excuse | Why It's Wrong | What to Do Instead |
|---|---|---|
| "I already know what to do" | If you already know, you don't need consult. But consult checks for hidden complexity. | Let consult assess your maturity. If you're right, it's fast. If wrong, it saves you. |
| "Just tell me the answer" | The answer depends on context (tier, team, constraints). Consult extracts that context. | Answer the questions. Get a calibrated recommendation. |
| "I'll figure out the lifecycle stage myself" | SDLC stage determines everything: depth of spec, design rigor, testing scope. Get it wrong = wrong output. | Let Consult determine the stage. It's what it's for. |
```

### Task 2.11 — skills/audit/SKILL.md

Append:
```
## Anti-rationalization table
| Common Excuse | Why It's Wrong | What to Do Instead |
|---|---|---|
| "I already reviewed the code" | Self-review has blind spots. Audit runs systematic spec contradiction analysis + static analysis. | Run /audit. It catches what you missed. |
| "No vulnerabilities? Must be clean" | Absence of evidence is not evidence of absence. Audit checks what you didn't think to check. | Review the audit report. Pay attention to what was NOT tested. |
| "We'll audit before release" | Post-hoc auditing finds issues that require rewrites. Pre-audit finds issues that are easy to fix. | Audit incrementally. Each task, not just the release. |
```

### Task 2.12 — skills/audit-spec/SKILL.md

Append:
```
## Anti-rationalization table
| Common Excuse | Why It's Wrong | What to Do Instead |
|---|---|---|
| "The requirements make sense to me" | Making sense individually doesn't mean they're consistent collectively. | Run contradiction analysis across all requirements. |
| "This edge case doesn't need a requirement" | Undocumented edge cases are unimplemented edge cases. They will fail in production. | If it's a real state, it needs a defined behavior. Document it. |
| "The spec is complete enough" | "Enough" is a rationalization for skipping rigor. Every missing state is a potential incident. | Check every state transition. If unhandled, add a requirement. |
```

### Task 2.13 — skills/audit-code/SKILL.md

Append:
```
## Anti-rationalization table
| Common Excuse | Why It's Wrong | What to Do Instead |
|---|---|---|
| "No Semgrep findings means no bugs" | Static analysis finds patterns, not logic errors. No findings ≠ correct code. | Review the logic, not just the tool output. |
| "I'll fix the critical findings and ignore the rest" | Warnings are warnings for a reason. They accumulate into technical debt. | Triage every finding. Document why ignored findings are safe. |
| "The code passes review, it's fine" | Code review catches style and obvious bugs. Static analysis catches subtle injection paths. | Run audit-code even after human review. Different coverage. |
```

### Task 2.14 — skills/retro/SKILL.md

Append:
```
## Anti-rationalization table
| Common Excuse | Why It's Wrong | What to Do Instead |
|---|---|---|
| "We don't have time for a retro" | Not retroing guarantees repeating the same mistakes. The time cost is exponential. | Run a 15-min retro. Focus on 1 thing to improve. |
| "Nothing went wrong, no need to retro" | If nothing went wrong, you missed something. Every project has learning opportunities. | Run a "what went well" retro. Document positive patterns too. |
| "Retros are just blame sessions" | Bad retros are blame sessions. Good retros are system improvement. | Focus on process, not people. "What in our system allowed this?" |
```

### Task 2.15 — skills/learn/SKILL.md

Append:
```
## Anti-rationalization table
| Common Excuse | Why It's Wrong | What to Do Instead |
|---|---|---|
| "I'll remember this for next time" | You won't. Human memory is unreliable, especially under pressure. | Write it to learnings.jsonl. 30 seconds. Permanent record. |
| "This failure is a one-off, it won't happen again" | One-off failures are the most dangerous — they hide systemic issues. | Log it. If it happens twice, it's a pattern. |
| "Learnings are for juniors" | Senior engineers learn from failures faster because they document and share them. | Lead by example. Write the learning. Your team will follow. |
```

### Task 2.16 — skills/arch-adr/SKILL.md

Append:
```
## Anti-rationalization table
| Common Excuse | Why It's Wrong | What to Do Instead |
|---|---|---|
| "This decision is obvious, no need for an ADR" | "Obvious" decisions are the most dangerous — they're never questioned. | Write a one-paragraph ADR. If it's obvious, it takes 2 minutes. |
| "We'll write ADRs later" | Later means never. The context is lost, the decision-maker has moved on. | Write the ADR when the decision is made. Fresh context. |
| "ADRs are bureaucratic overhead" | ADRs are insurance against the question "why did we do this?" that every team asks 6 months later. | One ADR per decision. Template: Context → Options → Decision → Consequences. |
```

### Task 2.17 — skills/arch-c4/SKILL.md

Append:
```
## Anti-rationalization table
| Common Excuse | Why It's Wrong | What to Do Instead |
|---|---|---|
| "Diagrams get outdated immediately" | Outdated diagrams are still better than no diagrams. The structure rarely changes as fast as the code. | Keep the level 1-2 diagrams current. Update them when architecture changes. |
| "I don't need a diagram, I understand the system" | Understanding in your head doesn't scale to the team. Diagrams communicate structure. | Draw the C4 level 1. If the team can't agree on it, the architecture is unclear. |
| "C4 is overkill for this project" | C4 level 1 is one box with actors. It's never overkill. Level 2-3 is tier-dependent. | Draw the tier-appropriate depth. Hackathon = level 1 only. |
```

### Task 2.18 — skills/arch-components/SKILL.md

Append:
```
## Anti-rationalization table
| Common Excuse | Why It's Wrong | What to Do Instead |
|---|---|---|
| "We'll figure out the components as we build" | Emergent architecture without guardrails produces Big Ball of Mud. | Define component boundaries first. They can change, but they must be explicit. |
| "Microservices will give us clean boundaries" | Microservices enforce network boundaries, not logical boundaries. You get Distributed Monolith instead. | Start modular monolith. Prove component boundaries before splitting. |
| "Our components are already clean" | If interfaces aren't documented, they aren't clean. Undocumented interfaces drift into spaghetti. | Document every component's interface. If it has >5 dependencies, refactor. |
```

### Task 2.19 — skills/arch-sequence/SKILL.md

Append:
```
## Anti-rationalization table
| Common Excuse | Why It's Wrong | What to Do Instead |
|---|---|---|
| "The happy path is all that matters" | The happy path never happens in production. Error paths and edge cases cause incidents. | Draw 3 sequence diagrams: happy path, error path, edge case. |
| "Sequence diagrams are too detailed for early design" | Sequence diagrams force you to think about ordering, which is where most bugs live. | Focus on the 2-3 most architecturally risky flows. Not every flow. |
| "I can visualize the flow without drawing it" | Visualization in your head has no shared language. The team can't discuss it. | Draw it in Mermaid. 10 minutes. Everyone can see and critique. |
```

### Task 2.20 — skills/arch-use-cases/SKILL.md

Append:
```
## Anti-rationalization table
| Common Excuse | Why It's Wrong | What to Do Instead |
|---|---|---|
| "We know who our users are" | Known users are rarely all users. Missing actors cause missing features. | List every actor explicitly. Include systems, admins, background jobs. |
| "Use cases are just documentation" | Use cases define the system boundary. Without a boundary, scope creeps infinitely. | Draw the system boundary. Everything outside is not your problem. |
| "Actors are obvious from the domain" | Obvious actors are still worth documenting. The intern needs to see them too. | Write actor descriptions. Stakeholder → goal → interaction. |
```

### Task 2.21 — skills/deploy-cicd/SKILL.md

Append:
```
## Anti-rationalization table
| Common Excuse | Why It's Wrong | What to Do Instead |
|---|---|---|
| "I'll set up CI/CD later" | Without CI/CD, every deploy is manual and every manual deploy is an incident waiting to happen. | Set up CI/CD before the first production deploy. Even a basic pipeline. |
| "Manual deploy to production is fine for now" | Manual deploys have no audit trail, no rollback automation, and no consistency. | Use GitHub Actions or equivalent. Push-button deploys only. |
| "My project is too small for CI" | Small projects have the most to gain — CI catches the bugs that testing alone misses. | Add a 5-step CI pipeline: lint → typecheck → test → build → notify. |
```

### Task 2.22 — skills/deploy-observability/SKILL.md

Append:
```
## Anti-rationalization table
| Common Excuse | Why It's Wrong | What to Do Instead |
|---|---|---|
| "We'll add monitoring after launch" | Launch without monitoring is blind. You won't know something is broken until users tell you. | Add health checks + basic metrics before launch. Expand after. |
| "Logs are enough for debugging" | Logs tell you what happened. Metrics tell you when it started trending wrong. Traces tell you where. | Set up the 3 pillars: logs + metrics + traces. Start with logs and uptime. |
| "We can't afford observability tools" | Free tiers of Grafana/Loki/Prometheus handle most projects. The cost of downtime is higher. | Start with free tier. Upgrade when scaling demands it. |
```

### Task 2.23 — skills/deploy-rollback/SKILL.md

Append:
```
## Anti-rationalization table
| Common Excuse | Why It's Wrong | What to Do Instead |
|---|---|---|
| "We'll figure out rollback if we need it" | During an incident is the worst time to figure out rollback. Stress, time pressure, incomplete docs. | Document rollback procedure before first deploy. Test it in staging. |
| "Our deploy is reversible by re-deploying the old version" | That assumes the old version is available, the DB schema is compatible, and the rollback doesn't cause data loss. | Write a rollback plan that covers: code, DB, config, data, DNS. |
| "Nothing has gone wrong before" | Past success does not predict future failure. Every deploy is a risk. | Have a rollback plan regardless of confidence. 1 page. 30 minutes. |
```

### Task 2.24 — skills/deploy-secrets-audit/SKILL.md

Append:
```
## Anti-rationalization table
| Common Excuse | Why It's Wrong | What to Do Instead |
|---|---|---|
| "I don't have secrets in my code" | Everyone says this. Secrets end up in code: hardcoded keys, .env files committed, config in git. | Run secrets audit. You'll be surprised. |
| "The repo is private, it's fine" | Private repos get compromised too. CI logs, dependency caches, and collaborator accounts leak secrets. | Use environment variables. Never commit secrets. Rotate if compromised. |
| "I'll remove the secret later" | Once in git history, it's there forever — even after removal. | Use git history scanning (gitleaks, truffleHog). Rotate immediately. |
```

### Task 2.25 — skills/deploy-release-check/SKILL.md

Append:
```
## Anti-rationalization table
| Common Excuse | Why It's Wrong | What to Do Instead |
|---|---|---|
| "We'll check everything during the deploy" | During-deploy checking is rushed, incomplete, and stressful. You'll miss things. | Run the checklist before the deploy window. Fix issues before Go time. |
| "The checklist is too long" | A long checklist means too many things can go wrong. Shorten it by automating checks. | Move automated checks to CI. Keep the checklist for things only humans can verify. |
| "We deployed last time without issues" | Last time's success doesn't tell you about this time's changes. Different code, different risks. | Run the full checklist every time. No exceptions. |
```

### Task 2.26 — skills/ship/SKILL.md

Append:
```
## Anti-rationalization table
| Common Excuse | Why It's Wrong | What to Do Instead |
|---|---|---|
| "Let's ship fast and fix later" | "Fix later" becomes "fix in production under pressure." Quality is not optional. | Run the full ship pipeline. If it finds issues, fix them before shipping. |
| "Security audit is overkill for this release" | Minor releases can introduce major vulnerabilities. Every release is a security boundary. | Run security audit. It's automated, it's fast, it's non-negotiable. |
| "QA already tested this" | QA tests correctness. Ship runs additional gates: security, monitoring, benchmark, launch readiness. | Let ship run. If QA already covered something, the gate will pass fast. |
```

### Task 2.27 — skills/ci-verify/SKILL.md

Append:
```
## Anti-rationalization table
| Common Excuse | Why It's Wrong | What to Do Instead |
|---|---|---|
| "CI is flaky, I'll merge anyway" | "Flaky" CI is unreliable CI. Unreliable CI is worse than no CI — it gives false confidence. | Investigate flakiness. Fix the tests. Then merge. |
| "My change is small, it won't break anything" | Small changes are statistically the most likely to break something unexpected. | Wait for CI. If it's clean, merge. 5 minutes. |
| "I already ran tests locally" | Local != CI. Different environment, different dependencies, different state. CI is the source of truth. | Push and wait for CI green. Don't merge on local-only tests. |
```

---

## Session 4: UI/UX Design Skill

### Task 4.1 — Create /ui-design SKILL.md

Create file: `skills/ui-design/SKILL.md`

Content:
```yaml
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
```

### Task 4.2 — Create UI Design Reference Files (4 files)

Create `skills/ui-design/references/design-system-methodology.md`:
```markdown
# Design System Methodology — Quick Reference

## Atomic Design Levels
- **Atoms**: buttons, inputs, labels, icons, colors, typography
- **Molecules**: search bars, form groups, nav items
- **Organisms**: headers, footers, sidebars, cards, modals
- **Templates**: page layouts, grid systems
- **Pages**: specific instances of templates with real content

## Style Categories
- General (49 styles): Minimal, Modern, Corporate, Playful, Luxury, Dark, Light, Neon, Retro, Vintage, Brutalist, Glassmorphism, Neumorphism, Cyberpunk, Material, Flat, Skeuomorphic, Gradient, Monochrome, Nature, Ocean, Sunset, Midnight, Pastel, Bold, Elegant, Industrial, Scandinavian, Japanese, Bohemian, Tribal, Futuristic, Steampunk, Art Deco, Bauhaus, Memphis, Swiss, Grunge, Pop Art, Cosmic, Ethereal, Tech, Organic, Abstract, Geometric, Asymmetric, Symmetric, Layered, Minimalist
- Landing Page (8): Hero-centric, Feature-grid, Storytelling, Product-showcase, SaaS, Launch-countdown, Waitlist, Single-scroll
- Dashboard (10): Analytics, Monitoring, CRM, Finance, Project management, Social media, E-commerce, Healthcare, Real-time, Kanban

## Component Library Selection
- shadcn/ui (React): Best for dashboards, internal tools, SaaS
- Radix UI (React): Unstyled primitives, full control
- Headless UI (React/Vue): Accessible, minimal
- Tailwind CSS: Utility-first, pairs with all above
```

Create `skills/ui-design/references/accessibility-methodology.md`:
```markdown
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
```

Create `skills/ui-design/references/design-tokens-methodology.md`:
```markdown
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
```

Create `skills/ui-design/references/testing-methodology.md`:
```markdown
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
```

### Task 4.3 — Create Testing Scripts (2 files)

Create `skills/ui-design/scripts/visual-regression.ps1`:
```powershell
param(
    [Parameter(Mandatory)] [string]$Url,
    [Parameter()] [string]$OutputDir = "./__screenshots__",
    [Parameter()] [float]$Threshold = 0.001
)

$ErrorActionPreference = "Stop"

if (-not (Get-Command "npx" -ErrorAction SilentlyContinue)) {
    Write-Error "npx is required but not found. Install Node.js."
    exit 1
}

# Run Playwright visual regression tests
Write-Host "Running visual regression tests against $Url"
Write-Host "Threshold: $($Threshold * 100)% max diff per component"

npx playwright test --grep "@visual" --reporter=line 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "FAIL: Visual regression detected differences."
    Write-Host "Review screenshots in $OutputDir"
    Write-Host "To update: npx playwright test --grep '@visual' --update-snapshots"
    exit 1
}

Write-Host "PASS: No visual regression detected"
```

Create `skills/ui-design/scripts/a11y-audit.ps1`:
```powershell
param(
    [Parameter(Mandatory)] [string]$Url,
    [Parameter()] [int]$Threshold = 0
)

$ErrorActionPreference = "Stop"

if (-not (Get-Command "npx" -ErrorAction SilentlyContinue)) {
    Write-Error "npx is required but not found. Install Node.js."
    exit 1
}

Write-Host "Running axe-core a11y audit against $Url"
Write-Host "Threshold: $Threshold violations (0 = zero tolerance)"

$result = npx @axe-core/cli $Url --exit --threshold $Threshold 2>&1
$exitCode = $LASTEXITCODE

if ($exitCode -eq 0) {
    Write-Host "PASS: No accessibility violations found"
} else {
    Write-Host "FAIL: $exitCode accessibility violation(s) found"
    Write-Host $result
    exit 1
}
```

---

## Session 5: Cloud / Infrastructure Skill

### Task 5.1 — Create /cloud SKILL.md

Create file: `skills/cloud/SKILL.md`

Content:
```yaml
---
name: cloud
description: Tier-calibrated cloud infrastructure, containerization, CI/CD, deployment, and observability. Not replacing terraform-skill/aws-skills — providing the orchestration layer. Triggers on "deploy", "infrastructure", "Docker", "CI/CD", "cloud", "production setup".
---

# /cloud — Cloud Infrastructure, Deployment & DevOps

Tier-aware infrastructure orchestration. Selects the right patterns and tools for your maturity level without over-engineering.

## Tier Detection

Determine tier automatically (or ask user if unclear):

| Tier | Signal | Infrastructure | Deploy |
|------|--------|---------------|--------|
| **Hackathon** | < 100 users, single developer, no SLA | Vercel/Railway/Fly.io, no containers | Manual or auto-deploy from git |
| **MVP** | 100-10K users, small team, some SLA | Docker + managed DB + CDN + CI/CD | Automated pipeline, staging env |
| **Scaling** | 10K+ users, multiple teams, production SLA | K8s/ECS, IaC, multi-region, observability | Blue-green/canary, rollback automation |

## Phase 1: Architecture Design

1. **Select cloud provider** based on team expertise and project needs:
   - AWS: broadest services, steepest learning curve
   - GCP: best for containers/K8s (GKE), data/ML
   - Azure: best for enterprise/Active Directory/.NET shops
2. **Select compute**:
   - Serverless (functions): good for APIs, event processing
   - Containers (ECS/EKS/GKE/ACR): good for services, batch jobs
   - VMs: only when you need full OS control
3. **Select data layer**:
   - Relational (RDS/Cloud SQL/Azure SQL): structured data, ACID
   - NoSQL (DynamoDB/Firestore/CosmosDB): high-throughput, flexible schema
   - Cache (ElastiCache/Redis/Memcached): read-heavy workloads
4. **Document architecture** with cost estimate before building

## Phase 2: Infrastructure as Code

Select tool based on team and provider:
- **Terraform/OpenTofu**: multi-provider, largest community
- **AWS CDK**: TypeScript-native, best for AWS-only
- **Pulumi**: general-purpose programming languages

**For every IaC project:**
1. Remote state backend (S3 + DynamoDB / GCS / Azure Storage)
2. State locking (DynamoDB / GCS object versioning)
3. Environment separation (dev/staging/prod via workspaces or directories)
4. Pin provider versions (no floating latest)
5. Run plan in CI before apply

Reference: `docs/sdlc-engineer/iac-best-practices.md`

## Phase 3: Containerization

**Dockerfile rules:**
1. Multi-stage builds (builder → runner, never ship build tools)
2. Distroless or scratch as final base image
3. Use specific tags, never `:latest`
4. Scan with Trivy before push: `trivy image <image>:<tag>`
5. SBOM generation: `docker sbom <image>`

**Docker Compose for dev:**
- Match production as closely as possible
- Use bind mounts for live reload
- Separate compose files: `docker-compose.yml` + `docker-compose.override.yml`

Reference: `docs/sdlc-engineer/docker-best-practices.md`

## Phase 4: CI/CD Pipeline

**Minimum pipeline (all tiers):**
1. Lint → 2. TypeCheck → 3. Test → 4. Build → 5. Run integration tests

**MVP addition:**
6. Docker build + push to registry
7. Deploy to staging
8. Smoke tests on staging
9. Manual approval gate → deploy to production

**Scaling addition:**
10. IaC validate + plan
11. Security scan (Trivy, Semgrep)
12. Canary deploy with metrics comparison
13. Rollback automation on failure

**GitHub Actions template (MVP tier):**
```yaml
name: CI/CD
on: [push]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
      - run: npm ci
      - run: npm run lint
      - run: npm run typecheck
      - run: npm test
  deploy:
    needs: test
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: npm run build
      - uses: docker/build-push-action@v5
        with: { push: true, tags: "${{ secrets.REGISTRY }}/app:latest" }
```

Reference: `docs/sdlc-engineer/cicd-patterns.md`

## Phase 5: Deployment

**Strategy selection:**
| Strategy | Downtime | Risk | When to use |
|---|---|---|---|
| Recreate | Yes | Low | Dev, staging |
| Rolling | No | Low | MVP production |
| Blue-Green | No | Medium | Scaling production |
| Canary | No | Low (gradual) | High-traffic production |
| Shadow | No | Very low | Experimental features |

**Deployment checklist:**
- [ ] Database migration plan (forward + rollback)
- [ ] DNS/TLS/CDN (CloudFront/Cloudflare)
- [ ] Secrets set in secrets manager (not env files)
- [ ] Health check endpoint configured
- [ ] Logging and metrics configured

Reference: `docs/sdlc-engineer/deployment-strategies.md`

## Phase 6: Observability

**Hackathon:**
- Uptime monitor (Better Uptime / Healthchecks.io)
- Basic error tracking (Sentry free tier)

**MVP:**
- Structured JSON logging (pino/bunyan/winston)
- Metrics: Grafana + Prometheus (or cloud native: CloudWatch/Stackdriver)
- Distributed tracing: OpenTelemetry auto-instrumentation

**Scaling:**
- SLO-based alerting
- Dashboards for each service
- Cost monitoring and budgets
- On-call rotation with escalation

## Anti-rationalization table
| Common Excuse | Why It's Wrong | What to Do Instead |
|---|---|---|
| "Kubernetes is always the answer" | K8s is the right answer for < 5% of projects. It adds massive operational complexity. | Use the simplest thing that works for your scale. Serverless or single Docker host. |
| "Docker in production is enough" | Docker gives you consistent builds, but not orchestration, service discovery, or auto-healing. | Add orchestration when you have > 1 server. Start with Docker Compose or ECS. |
| "I'll fix security later" | IaC security (network policies, IAM roles, encryption) is 10x cheaper to add at design time. | Validate IaC with Checkov/Trivy before apply. Security is not optional. |
| "Manual deploy is fine for early stage" | Manual deploys skip testing, have no audit trail, and create "works on my machine" problems. | Set up CI/CD before the first production deploy. Even a basic pipeline. |
| "We don't need monitoring until launch" | Launch without monitoring is blind. You only know something is wrong when users complain. | Add health check + uptime monitor before launch. Add metrics in week 1. |
```

### Task 5.2 — Create Cloud Reference Files (3 files)

Create `skills/cloud/references/iac-patterns.md`:
```markdown
# IaC Patterns — Quick Reference

## Tool Selection
| Tool | Best For | State | Language |
|------|----------|-------|----------|
| Terraform/OpenTofu | Multi-cloud, any provider | Remote (S3/DynamoDB) | HCL |
| AWS CDK | AWS-only, TypeScript teams | S3 + DynamoDB | TypeScript/Python/C# |
| Pulumi | Multi-cloud, general-purpose teams | S3/GCS/Azure Storage | TypeScript/Python/Go |

## Terraform Module Structure
```
modules/
  networking/    (VPC, subnets, security groups)
  database/      (RDS, replica, backups)
  compute/       (ECS/Fargate, auto-scaling)
  ci-cd/         (CodePipeline, GitHub Actions OIDC)
```

## Testing Matrix
| Test type | Terraform | CDK | Pulumi |
|-----------|-----------|-----|--------|
| Syntax | terraform validate | cdk synth | pulumi preview |
| Policy | Checkov, Sentinel | cdk-nag | Policy as Code |
| Integration | Terratest | integ-runner | pulumi up --dry-run |
| Security | Trivy, tfsec | cdk-nag | Trivy |

## State Management
1. Enable state locking (DynamoDB for Terraform)
2. Never store state locally
3. Encrypt state at rest
4. Restrict state access via IAM policies
5. Workspaces for environment separation
```

Create `skills/cloud/references/docker-patterns.md`:
```markdown
# Docker Patterns — Quick Reference

## Multi-Stage Build Template
```dockerfile
# Stage 1: Build
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
RUN npm run build

# Stage 2: Runtime (distroless)
FROM gcr.io/distroless/nodejs20-debian12
COPY --from=builder /app/dist /app
COPY --from=builder /app/node_modules /app/node_modules
USER nonroot
CMD ["/app/main.js"]
```

## OWASP Docker Security Rules (Top 5)
1. Use specific base image tags, not `:latest`
2. Run as non-root user (add `USER` directive)
3. Don't store secrets in images (use build args + secrets mounts)
4. Scan images: `trivy image <image> --exit-code 1 --severity CRITICAL`
5. Keep layers minimal (combine RUN commands, use `.dockerignore`)

## Docker Compose Dev Pattern
```yaml
version: '3.8'
services:
  app:
    build: .
    ports: ["3000:3000"]
    volumes: [".:/app"]  # hot reload
    environment:
      - NODE_ENV=development
      - DATABASE_URL=postgres://user:pass@db:5432/app
  db:
    image: postgres:16-alpine
    volumes: ["pgdata:/var/lib/postgresql/data"]

volumes:
  pgdata:
```
```

Create `skills/cloud/references/deployment-strategies.md`:
```markdown
# Deployment Strategies — Quick Reference

## Strategy Selection Matrix
| | Recreate | Rolling | Blue-Green | Canary | Shadow |
|---|---|---|---|---|---|
| Zero downtime | ❌ | ✅ | ✅ | ✅ | ✅ |
| Quick rollback | ✅ | ❌ | ✅ | ✅ | ✅ |
| Production traffic test | ❌ | ❌ | ❌ | Partial | ✅ |
| Complexity | Low | Medium | Medium | High | Very High |
| Cost | Lowest | Low | 2x infra | 2x infra | 2x infra |

## When to Use
- **Recreate**: Dev deployments, staging, non-critical services
- **Rolling**: MVP production, low-traffic services
- **Blue-Green**: Production services, compliance-sensitive apps
- **Canary**: High-traffic production, ML model deployments
- **Shadow**: Experimental features, migration validation

## 12-Factor App Checklist
- [ ] Codebase: one codebase tracked in revision control
- [ ] Dependencies: explicitly declared and isolated
- [ ] Config: stored in environment variables
- [ ] Backing services: treated as attached resources
- [ ] Build, release, run: strictly separated stages
- [ ] Processes: stateless and share-nothing
- [ ] Port binding: export services via port binding
- [ ] Concurrency: scale out via process model
- [ ] Disposability: fast startup and graceful shutdown
- [ ] Dev/prod parity: keep dev, staging, prod as similar as possible
- [ ] Logs: treat logs as event streams
- [ ] Admin processes: run admin/maintenance tasks as one-off processes
```

---

## Session 6: Agent Personas

### Task 6.1 — Create /personas SKILL.md

Create file: `skills/personas/SKILL.md`

Content:
```yaml
---
name: personas
description: Pre-defined specialist agent personas for focused code review, testing, security audit, design, and performance analysis. Triggers on "review this code", "audit this", "run persona", or inline persona activation.
---

# /personas — specialist agent personas

Activate pre-defined personas for focused analysis. Each persona constrains the agent to a specific role with targeted focus areas, constraints, and anti-rationalization rules.

## Usage

```
/personas <persona-name> <context>
```

Example: `/personas code-reviewer "Review the auth module in src/auth/"`

## Available Personas

| Persona | When to Use |
|---------|-------------|
| code-reviewer | Before merging any PR |
| test-engineer | Before writing or reviewing tests |
| security-auditor | For any auth, payments, or data-handling code |
| ux-designer | Before or after UI implementation |
| performance-engineer | For any performance-sensitive code |

## Persona Activation

Each persona loads constraints from `skills/personas/references/<name>.yaml`. The agent adopts the role, focus areas, and constraints specified in the yaml file.

## Chaining Personas

Multiple personas can be run in sequence on the same code:
```
/personas security-auditor "src/api/" → fix findings → /personas code-reviewer "src/api/"
```

## Anti-rationalization table
| Common Excuse | Why It's Wrong | What to Do Instead |
|---|---|---|
| "I can review my own code" | Self-review misses blind spots. A code-reviewer persona catches assumptions you didn't question. | Run /personas code-reviewer. Fresh perspective. |
| "Testing is just writing test files" | Test-engineer persona checks test quality, not just presence. A bad test is worse than no test. | Run /personas test-engineer. It checks what your tests actually prove. |
| "Security auditors are for production" | Security findings found early cost 10x less to fix. Run security-auditor on every auth/data change. | Run /personas security-auditor pre-merge, not pre-release. |
```

### Task 6.2 — Create Persona Reference Files (5 files)

Create `skills/personas/references/code-reviewer.yaml`:
```yaml
role: Code Reviewer
focus:
  - correctness
  - security
  - performance
  - maintainability
  - test coverage
  - edge cases
constraints:
  - Do NOT suggest implementation — only review
  - Flag every bug, not just the first N
  - Distinguish: "must fix" vs "should fix" vs "nice to have"
  - Verify tests actually test what they claim
  - Do not approve code with untested error paths
anti-rationalization:
  - "Mostly correct" → "Mostly correct" means partially wrong
  - "Edge cases are unlikely" → Unlikely ≠ impossible
  - "This is standard practice" → Standard practice can still be wrong
  - "Tests pass" → Tests only cover what you thought to test
```

Create `skills/personas/references/test-engineer.yaml`:
```yaml
role: Test Engineer
focus:
  - test correctness (no false positives/negatives)
  - test coverage (not just lines — behaviors)
  - test isolation (no shared state between tests)
  - edge case coverage (null, empty, boundary, error)
  - test readability (next developer must understand intent)
constraints:
  - Run the tests first. Confirm RED for new tests.
  - Flag tests that test implementation instead of behavior
  - Check for missing unhappy-path tests
  - Verify async tests actually wait for completion
anti-rationalization:
  - "100% coverage is enough" → Coverage != correctness. Check what's tested, not how much.
  - "This test is too simple to fail" → Simple tests catch complex regressions.
  - "Integration tests cover this" → Integration tests miss unit-level edge cases.
```

Create `skills/personas/references/security-auditor.yaml`:
```yaml
role: Security Auditor
focus:
  - input validation (injection, XSS, path traversal)
  - authentication (session management, token handling)
  - authorization (IDOR, privilege escalation)
  - data protection (encryption, secrets handling)
  - dependency vulnerabilities (known CVEs)
constraints:
  - Assume attacker has read access to source code
  - Check every external boundary (API, file, network, user input)
  - Verify authentication is not bypassable
  - Check that error messages don't leak sensitive info
  - Flag hardcoded secrets, tokens, or keys immediately
anti-rationalization:
  - "This endpoint requires auth" → Check every branch. Auth check might be bypassable.
  - "Input is sanitized" → Prove it. Show me the sanitization path.
  - "It's an internal tool" → Internal tools get compromised too.
```

Create `skills/personas/references/ux-designer.yaml`:
```yaml
role: UX Designer
focus:
  - visual consistency (design tokens, spacing grid)
  - accessibility (WCAG 2.1 AA compliance)
  - interaction design (states: loading, empty, error, edge)
  - responsive design (mobile-first breakpoints)
  - user flows (task completion paths)
constraints:
  - Check every interactive element has all states (hover, focus, active, disabled)
  - Verify touch targets ≥ 44x44px
  - Check color is never the only differentiator
  - Verify keyboard navigation through all interactive elements
  - Check that error messages are helpful, not technical
anti-rationalization:
  - "The design system handles accessibility" → Components are only as accessible as how they're used.
  - "Users won't notice this inconsistency" → Inconsistency erodes trust.
  - "Mobile is a separate concern" → Mobile-first or mobile-last, but be intentional.
```

Create `skills/personas/references/performance-engineer.yaml`:
```yaml
role: Performance Engineer
focus:
  - runtime complexity (algorithm efficiency)
  - bundle size (tree-shaking, code splitting)
  - rendering performance (re-renders, layout shifts)
  - network performance (request count, payload size, caching)
  - database performance (N+1 queries, indexing)
constraints:
  - Profile before optimizing. Never optimize blind.
  - Every optimization must come with a before/after measurement
  - Distinguish: "optimization" vs "micro-optimization"
  - Check for common performance anti-patterns by framework
  - Verify caching strategy (browser, CDN, server, database)
anti-rationalization:
  - "This is fast enough" → What's your evidence? Measure it.
  - "Premature optimization is the root of all evil" → Not measuring is the root of all performance problems.
  - "The database will handle it" → Every query costs something. Check for N+1.
```

---

## Session 7: Integration & Pipeline Enhancements

### Task 7.1 — Auto-Debug in /implement

Modify `skills/implement/SKILL.md`:

Locate the line `### Task execution loop` section. After the `On GREEN confirmation` failure handling paragraphs, add the following block:

```markdown
### Failure handling

On any failure during task execution:

1. **Test failure** → Capture the exact error output → Auto-invoke /debug
   - Do NOT re-implement without diagnosis
   - The /debug skill performs isolate → hypothesize → verify
2. **Build failure** → Parse the first error line → Check `debug/references/common-patterns.md`
   - If pattern matches: apply known fix → re-run
   - If no pattern matches: invoke /debug
3. **Runtime error** → Capture stack trace + relevant logs → Invoke /debug
4. **After ANY fix**: Write root cause to `docs/sdlc-engineer/learnings.jsonl`

```json
{"type": "root-cause", "date": "YYYY-MM-DD", "symptom": "...", "root-cause": "...", "fix": "...", "relevant-skills": ["implement"]}
```

**Gate:** Never attempt a second implementation without diagnosis. First failure → debug. Second failure → escalate to user.
```

### Task 7.2 — Security Pipeline Enhancement

Modify `skills/audit/SKILL.md`:

Find the phases section of the audit process. Add after the existing phases:

```markdown
### Phase 5: Threat Modeling (STRIDE)

Run STRIDE threat modeling on the system's data flow:

1. **Draw the DFD**: identify external entities, processes, data stores, data flows
2. **Apply STRIDE per element**:
   - Spoofing: who can impersonate?
   - Tampering: who can modify data in transit/at rest?
   - Repudiation: can actions be denied?
   - Information Disclosure: who can read data?
   - Denial of Service: what happens under load?
   - Elevation of Privilege: can auth be bypassed?
3. **Assess risk**: Likelihood × Impact per threat
4. **Mitigate**: For each valid threat, add a mitigation (input validation, encryption, audit logging, rate limiting, WAF)

Reference: `docs/sdlc-engineer/threat-modeling-methodology.md`

### Phase 6: Static Analysis + Secrets

```bash
# Semgrep (pattern-based SAST)
semgrep --config=auto --error .

# Secret scanning
gitleaks detect --verbose

# Dependency audit
npm audit --audit-level=high
# or for other ecosystems:
# pip-audit / cargo audit / go list -m -json all | nancy sleuth
```

Reference: `docs/sdlc-engineer/owasp-standards-reference.md`
Reference: `docs/sdlc-engineer/secrets-management-methodology.md`

### Phase 7: Database Security

- [ ] Verify RLS policies on multi-tenant tables
- [ ] Check for SQL injection in raw queries
- [ ] Verify least-privilege database credentials
- [ ] Check that migrations don't expose sensitive data

Reference: `docs/sdlc-engineer/database-security-rls-methodology.md`

### Phase 8: Compliance Verification

- [ ] GDPR: data deletion flow, consent recording, data inventory
- [ ] SOC2: audit logging, access control, change management
- [ ] HIPAA: PHI encryption, access logs, BAA verification
- [ ] PCI-DSS: card data tokenization, network segmentation

Reference: `docs/sdlc-engineer/compliance-frameworks-reference.md`
```

### Task 7.3 — Human Gates Integration

Modify each of these files: `skills/audit/SKILL.md`, `skills/audit-code/SKILL.md`, `skills/audit-spec/SKILL.md`, `skills/deploy-secrets-audit/SKILL.md`

For each file, append before the Anti-rationalization table (or at end of file):

```markdown
## Human Gate

Operations in this skill auto-detect risk level:

- **Low risk** (informational findings, warnings, non-blocking recommendations):
  → Proceed without gate. Report findings on completion.

- **Medium risk** (moderate vulnerabilities, misconfigurations, policy violations):
  → Proceed with gate. Present findings to user. User can approve, deny, or modify scope.
  → Timeout: 5 minutes. On timeout: proceed with documented exceptions.

- **High risk** (critical vulnerabilities, credential exposure, compliance violations):
  → STOP. Present findings with severity, impact, and recommended fix.
  → User must explicitly approve or provide override rationale.
  → Timeout: 10 minutes. On timeout: ABORT. Safe default is to not proceed.
```

---

## Execution Order Summary

| Session | Tasks | Dependency |
|---------|-------|------------|
| 1 | Core skills (debug, modify, doubt) | Done ✅ |
| 2 | Anti-rationalization tables 1-14 | None |
| 3 | Anti-rationalization tables 15-27 | None |
| 4 | UI/UX design skill (4 tasks) | None |
| 5 | Cloud/infra skill (4 tasks) | None |
| 6 | Personas (6 tasks) | None |
| 7 | Integration (3 tasks) | None |

Sessions 2-7 can run in any order since they touch different file sets. Session 4 and 5 have internal sequential dependencies (create directory before writing child files), but are independent of each other.

## Context Management

If running in a context-constrained environment (e.g., Antigravity with limited tokens per agent):
- Spawn separate agents for Sessions 2-3 (one per group of 7 skills)
- Spawn separate agents for Sessions 4, 5, 6, 7
- Each agent works independently — file sets are disjoint
- Commit after each session: `feat(skill): Phase N — <description>`
