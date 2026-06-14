# Common Debugging Patterns and Diagnostic Steps

This reference guides diagnostic analysis across common failure patterns.

## 1. Test Failures
When a test fails, run the following diagnostics:
- **Check Assertions:** Inspect the exact difference between expected and actual values. Do not assume the assertion is incorrect.
- **Verify Test Isolation:** Run the test by itself to rule out state pollution, database contamination, or side effects from preceding tests.
- **Check Test Data:** Verify if the database, mock stores, or environment variables are prepopulated with the correct fixtures.
- **Audit Mocks and Stubs:** Ensure mock definitions match the current API signature and that timers/promises are flushed.

## 2. Build Failures
When a compilation, type check, or bundling step fails:
- **Parse Error Output:** Focus on the first error line. Later errors are often cascades from the first failure.
- **Verify Imports:** Check relative file paths, case sensitivity (crucial on Linux containers vs. macOS/Windows), and named vs. default exports.
- **Dependency and Version Audit:** Inspect `package.json` vs. lock files. Run clean installation if dependencies were modified.

## 3. Runtime Errors
When code executes but throws exceptions:
- **Stack Trace Analysis:** Map the trace to specific lines of source code. Identify the topmost non-library call.
- **Null and Undefined Checks:** Check variables at external boundaries (API payloads, user inputs, database queries) before accessing properties.
- **Async Ordering and Race Conditions:** Check if state transitions depend on the response order of concurrent asynchronous promises.

## 4. Regressions
When a feature that previously worked is now broken:
- **Git Bisect Workflow:**
  ```bash
  git bisect start
  git bisect bad
  git bisect good <last-known-good-sha>
  ```
- **Dependency Change Detection:** Check locks to see if transitively upgraded packages introduced breaking behavior.
