---
name: finish-branch
description: Human-in-the-loop gate for completing a development branch. Presents 4 options: merge to main, open PR, keep branch, or discard. Pre-flight: all tasks complete + suite green + CI green + spec compliance PASS + no quality BLOCKs. Invoked by /implement after ci-verify.
---

# /finish-branch — development branch completion

The last gate before a branch is merged or published. Human decides — the skill presents options and executes the choice.

## Pre-flight (hard gates — do not proceed if any fail)

- [ ] All tasks in plan file marked complete
- [ ] Full test suite: green
- [ ] CI: green (or skipped with documented reason)
- [ ] review-spec: all tasks PASS
- [ ] Quality review: no BLOCK verdicts outstanding

If any pre-flight fails: "Pre-flight failed: [reason]. Fix before finishing branch."

## 4 options

Present these options to the user:

---

**Option 1: Merge to main**
- Squash WIP commits into one clean commit per task (or one per feature)
- Merge to main
- Delete branch and any associated worktrees
- Trigger session-save (checkpoint this branch as complete)

```bash
git checkout main
git merge --squash [branch]
git commit -m "[feature summary from plan]"
git branch -d [branch]
```

---

**Option 2: Open PR**
- Auto-populate PR description from methodology artifacts:
  - Title: from plan file feature name
  - Body: AC coverage, NFRs verified, test coverage delta, security audit verdict, benchmark comparison
  - Labels: from intent tier and security tier

```bash
git push -u origin [branch]
gh pr create \
  --title "[feature name]" \
  --body "[auto-generated from artifacts]" \
  --label "[intent-tier]"
```

---

**Option 3: Keep branch**
- Trigger session-save: write checkpoint with current state
- Commit checkpoint to branch
- Branch remains open for continuation in next session

---

**Option 4: Discard**
- Confirm explicitly: "Type 'discard' to confirm deletion of branch [name] and all worktrees"
- On confirm:
```bash
git worktree list | grep [branch] | awk '{print $1}' | xargs -I{} git worktree remove {}
git checkout main
git branch -D [branch]
```

## PR description template

```markdown
## What this PR does
[1-3 sentences from plan goal]

## AC coverage
[table: story ID → Gherkin AC → implemented: yes/no]

## NFRs verified
[table: NFR ID → target → actual → status]

## Test coverage
Lines: [before]% → [after]%

## Security audit
Tier: [minimal/standard/hardened]
Verdict: [PASS/PASS-WITH-WARNINGS]
Findings: [count] ([severity breakdown])

## Benchmark
[before/after comparison if production-saas]
```