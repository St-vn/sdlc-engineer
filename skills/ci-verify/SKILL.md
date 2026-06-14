---
name: ci-verify
description: Pushes the current branch, polls CI for completion, and surfaces specific failure steps. Detects GitHub Actions (gh CLI) or GitLab CI (glab CLI). Graceful fallback if no CLI available. Invoked by /implement after all tasks complete.
---

# /ci-verify — CI integration verification

Ensures CI passes before finish-branch runs.

## Pre-flight

1. Check if branch has been pushed:
   ```bash
   git status -sb | head -1
   ```
   If not tracking remote: push first.

2. Detect CI platform:
   ```bash
   ls .github/workflows/ 2>/dev/null && echo "github"
   ls .gitlab-ci.yml 2>/dev/null && echo "gitlab"
   ls Jenkinsfile 2>/dev/null && echo "jenkins"
   ls .circleci/ 2>/dev/null && echo "circleci"
   ```

3. Check CLI availability:
   ```bash
   which gh 2>/dev/null && echo "gh available"
   which glab 2>/dev/null && echo "glab available"
   ```

## GitHub Actions flow (gh CLI available)

```bash
# Push if needed
git push -u origin HEAD

# Wait for CI (10 min timeout)
gh run watch --exit-status

# If fails, get the specific step
gh run view --log-failed
```

## GitLab CI flow (glab CLI available)

```bash
git push -u origin HEAD
glab ci status --wait
glab ci view  # on failure
```

## No CLI available (fallback)

```
CI CLI not available (gh/glab not installed).
CI verification skipped.

Branch URL: [git remote get-url origin + branch path]
Check CI status manually before merging.
```

Do NOT block execution — log warning and continue to finish-branch.

## Failure handling

On CI failure:
- Surface the specific step that failed (not just "CI failed")
- Categorize failure:
  - **Test failure** → actionable: "Test X failed in step Y. Return to debug."
  - **Build failure** → actionable: "Build failed: [error]. Fix the compilation error."
  - **Infrastructure failure** → retry recommended: "Runner out of resources. Retry the workflow."
  - **Timeout** → "CI timed out. Check for infinite loops or slow tests."

## Timeout

Poll for max 10 minutes. If still running after 10 min:
```
CI still running after 10 minutes.
Branch URL: [url]
Continue polling manually or check the CI dashboard.
```

## Anti-rationalization table
| Common Excuse | Why It's Wrong | What to Do Instead |
|---|---|---|
| "CI is flaky, I'll merge anyway" | "Flaky" CI is unreliable CI. Unreliable CI is worse than no CI — it gives false confidence. | Investigate flakiness. Fix the tests. Then merge. |
| "My change is small, it won't break anything" | Small changes are statistically the most likely to break something unexpected. | Wait for CI. If it's clean, merge. 5 minutes. |
| "I already ran tests locally" | Local != CI. Different environment, different dependencies, different state. CI is the source of truth. | Push and wait for CI green. Don't merge on local-only tests. |
