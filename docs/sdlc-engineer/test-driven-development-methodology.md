# Test-Driven Development — Best Practices Methodology

## Design Principles

1. **RED → GREEN → REFACTOR** — Write a failing test first, then minimal code to pass it, then clean up. Never write implementation before the test.
2. **The Beyoncé Rule** — "If you liked it, then you shoulda put a test on it." If a change breaks your code and you had no test for it, that's on you.
3. **Test State, Not Interactions** — Assert on outcomes, not internal method calls. Tests that verify implementation details break on refactor even when behavior is preserved.
4. **DAMP over DRY in Tests** — Descriptive And Meaningful Phrases. Each test should read like a specification. Duplication is acceptable for readability.
5. **Prefer Real Implementations Over Mocks** — Preference order: real > fake (in-memory DB) > stub (canned data) > mock (interaction verification). Mock only at boundaries where real deps are too slow or non-deterministic.

## When to Apply

- Implementing any new logic or behavior
- Fixing any bug (use the Prove-It Pattern)
- Modifying existing functionality
- Adding edge case handling
- Any change that could break existing behavior
- **NOT for:** Pure configuration, documentation, or static content with no behavioral impact

## Process

### The TDD Cycle

```
    RED                    GREEN                  REFACTOR
 ┌──────────┐       ┌──────────────────┐      ┌──────────────┐
 │ Write a  │  ──→  │ Write minimal    │ ──→  │ Clean up the │  ──→ repeat
 │ test that│       │ code to make     │      │ implement-   │
 │ fails    │       │ it pass          │      │ ation        │
 └──────────┘       └──────────────────┘      └──────────────┘
      │                      │                       │
      ▼                      ▼                       ▼
  Test FAILS             Test PASSES             Tests still PASS
```

### Step 1: RED — Write a Failing Test

```
Action: Write a test for the behavior you want before any implementation code.
Result: The test MUST fail. A test that passes immediately proves nothing.

Verification checklist:
  [ ] Test is written before any implementation code
  [ ] Test fails with a clear error message when run
  [ ] Test name is descriptive (reads like a specification)
  [ ] Test uses Arrange-Act-Assert structure
  [ ] Test asserts on behavior, not implementation details
```

```typescript
// RED: This test fails because createTask doesn't exist yet
describe('TaskService', () => {
  it('creates a task with title and default status', async () => {
    // Arrange
    const input = { title: 'Buy groceries' };

    // Act
    const task = await taskService.createTask(input);

    // Assert
    expect(task.id).toBeDefined();
    expect(task.title).toBe('Buy groceries');
    expect(task.status).toBe('pending');
    expect(task.createdAt).toBeInstanceOf(Date);
  });
});
```

### Step 2: GREEN — Make It Pass

```
Action: Write the minimum code to make the failing test pass.
Rule: Do NOT over-engineer. Do NOT add features the test doesn't require.
      If you're tempted to add "real" code the test doesn't cover, stop.
      The test drives what gets built.

Verification checklist:
  [ ] Code is minimal — only what's needed to pass the test
  [ ] No new functionality beyond what the test specifies
  [ ] Test now passes
  [ ] Run the test: npx vitest run --testNamePattern "creates a task"
```

```typescript
// GREEN: Minimal implementation — exactly enough to pass
export async function createTask(input: { title: string }): Promise<Task> {
  const task = {
    id: generateId(),
    title: input.title,
    status: 'pending' as const,
    createdAt: new Date(),
  };
  await db.tasks.insert(task);
  return task;
}
```

### Step 3: REFACTOR — Clean Up

```
Action: With tests green, improve the code without changing behavior.
Allowed: Extract shared logic, improve naming, remove duplication, optimize.
Forbidden: Adding new features, changing external behavior.

Verification checklist:
  [ ] All tests still pass after each refactoring step
  [ ] External behavior is unchanged
  [ ] Code is cleaner than before (lower complexity, better names)
  [ ] No "while we're here" scope creep
```

### The Prove-It Pattern (Bug Fixes)

```
Bug report arrives
       │
       ▼  Step 1: WRITE REPRODUCTION TEST
  Write a test that demonstrates the bug
       │
       ▼  Step 2: CONFIRM (RED)
  Test FAILS — confirms the bug exists
       │
       ▼  Step 3: FIX
  Implement the fix in source code
       │
       ▼  Step 4: CONFIRM (GREEN)
  Test PASSES — proves the fix works
       │
       ▼  Step 5: GUARD
  Run full test suite — no regressions
```

```typescript
// Bug: "Completing a task doesn't update the completedAt timestamp"

// Step 1: Write the reproduction test (it should FAIL)
it('sets completedAt when task is completed', async () => {
  const task = await taskService.createTask({ title: 'Test' });
  const completed = await taskService.completeTask(task.id);
  expect(completed.status).toBe('completed');
  expect(completed.completedAt).toBeInstanceOf(Date); // This fails → bug confirmed
});

// Step 2: Fix the bug
export async function completeTask(id: string): Promise<Task> {
  return db.tasks.update(id, {
    status: 'completed',
    completedAt: new Date(), // This was missing
  });
}

// Step 3: Test passes → bug fixed, regression guarded
```

## The Test Pyramid

```
          ╱╲
         ╱  ╲         E2E Tests (~5%)
        ╱    ╲        Full user flows, real browser
       ╱──────╲
      ╱        ╲      Integration Tests (~15%)
     ╱          ╲     Component interactions, API boundaries
    ╱────────────╲
   ╱              ╲   Unit Tests (~80%)
  ╱                ╲  Pure logic, isolated, milliseconds each
 ╱──────────────────╲
```

### Test Size Decision Guide

```
Is it pure logic with no side effects?
  → UNIT TEST (small) — milliseconds, single process, no I/O

Does it cross a boundary (API, database, file system)?
  → INTEGRATION TEST (medium) — seconds, localhost only

Is it a critical user flow that must work end-to-end?
  → E2E TEST (large) — minutes, external services OK
  → Limit these to critical paths only (login, checkout, core flow)
```

## Writing Good Tests

### Use the Arrange-Act-Assert Pattern

```typescript
it('marks overdue tasks when deadline has passed', () => {
  // Arrange: Set up the test scenario
  const task = createTask({
    title: 'Test',
    deadline: new Date('2025-01-01'),
  });

  // Act: Perform the action being tested
  const result = checkOverdue(task, new Date('2025-01-02'));

  // Assert: Verify the outcome
  expect(result.isOverdue).toBe(true);
});
```

### One Assertion Per Concept

```typescript
// Good: Each test verifies one behavior
it('rejects empty titles', () => { /* ... */ });
it('trims whitespace from titles', () => { /* ... */ });
it('enforces maximum title length', () => { /* ... */ });

// Bad: Everything in one test — first failure hides the rest
it('validates titles correctly', () => {
  expect(() => createTask({ title: '' })).toThrow();
  expect(createTask({ title: '  hello  ' }).title).toBe('hello');
  expect(() => createTask({ title: 'a'.repeat(256) })).toThrow();
});
```

### Name Tests Descriptively

```typescript
// Good: Reads like a specification
describe('TaskService.completeTask', () => {
  it('sets status to completed and records timestamp');
  it('throws NotFoundError for non-existent task');
  it('is idempotent — completing an already-completed task is a no-op');
  it('sends notification to task assignee when status changes');
});

// Bad: Vague names
describe('TaskService', () => {
  it('works');
  it('handles errors');
  it('test 3');
});
```

### DAMP Over DRY

```typescript
// DAMP: Each test is self-contained and readable
it('rejects tasks with empty titles', () => {
  const input = { title: '', assignee: 'user-1' };
  expect(() => createTask(input)).toThrow('Title is required');
});

it('trims whitespace from titles', () => {
  const input = { title: '  Buy groceries  ', assignee: 'user-1' };
  const task = createTask(input);
  expect(task.title).toBe('Buy groceries');
});

// Over-DRY: Shared setup obscures what each test verifies
// Don't do this just to avoid repeating the input shape
```

### Prefer Real Implementations Over Mocks

```
Preference order (most to least confidence):
1. Real implementation  → Highest confidence, catches real bugs
2. Fake                 → In-memory version (e.g., array-backed DB)
3. Stub                 → Returns canned data, no behavior logic
4. Mock (interaction)   → Verifies method calls — use sparingly

Use mocks ONLY when:
  → Real impl is too slow (external API latency)
  → Real impl is non-deterministic (random, clock-based)
  → Real impl has side effects you can't control (email, payments)
```

## Anti-patterns

| Anti-pattern | Problem | Fix |
|---|---|---|
| "I'll write tests after the code works" | You won't. Tests written post-hoc test implementation, not behavior. | Write the test first (RED). |
| "This is too simple to test" | Simple code gets complicated. The test documents expected behavior. | Test it. A 3-line test costs 10 seconds. |
| "Tests slow me down" | Tests slow you down now. They speed you up every time you change code later. | TDD pays for itself after 3 changes. |
| "I tested it manually" | Manual tests don't persist. Tomorrow's change breaks it silently. | Automate: one test, run forever. |
| "The code is self-explanatory" | Tests ARE the spec. They document what code SHOULD do, not what it DOES. | A test is executable documentation. |
| "It's just a prototype" | Prototypes become production. Test debt from day 1 compounds. | Write tests from the start. |
| Testing framework behavior | Tests framework code (React/Vue itself) | Only test YOUR application code. |
| Snapshot abuse | Large snapshots nobody reviews, break on any whitespace change | Small focused snapshots; review every change in PR. |
| No test isolation | Tests pass individually but fail together | Each test sets up and tears down its own state. |

## Tools with Install Commands

```bash
# Vitest — TDD test runner (default)
npm install -D vitest

# Run in watch mode for TDD loop
npx vitest

# Run once (for CI)
npx vitest run

# TypeScript testing
npm install -D vitest typescript

# Mocking library (built into Vitest)
# vi.mock(), vi.fn(), vi.spyOn() — no extra install needed

# Test coverage
npx vitest run --coverage
npm install -D @vitest/coverage-v8
```
