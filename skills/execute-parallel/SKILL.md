---
name: execute-parallel
description: Executes multiple tasks simultaneously using git worktrees — one worktree per task. Tasks must have disjoint file sets. Uses wave-based topological sort from the dependency graph. Requires Claude Code Task tool. Activated when task count > 8 or team-size is small-2-5+.
---

# /execute-parallel — wave-based parallel task execution

Executes tasks in parallel using git worktrees for isolation. Each task runs in its own worktree with a fresh Claude subagent.

## Prerequisites

- Git ≥ 2.5 (worktrees available)
- Claude Code Task tool available
- Tasks have disjoint file sets (verified before dispatch)

## Wave algorithm

```
Input: task list with dependency graph

Wave 0: tasks with no dependencies
Wave 1: tasks whose dependencies are all in Wave 0
Wave N: tasks whose dependencies are all in Waves 0 through N-1

Execute all tasks in Wave N in parallel.
Wait for Wave N to complete before starting Wave N+1.
Run integration tests between waves.
```

## Worktree setup per task

```bash
# Create isolated worktree for each task in the wave
git worktree add ../[project]-task-[N] [current-branch]
```

Each worktree:
- Starts from the same commit as the current branch
- Has its own working directory (no file conflicts)
- Gets its own fresh Claude subagent via Task tool

## Dispatch protocol

For each task in the current wave:
```
Task tool input:
  Working directory: ../[project]-task-[N]
  Context: task block + AC + file set + learnings
  Instruction: execute-inline procedure (write test → RED → implement → GREEN → commit)
```

## Merge protocol

After all tasks in a wave complete:

```bash
# For each worktree, in dependency order:
git checkout [current-branch]
git merge ../[project]-task-[N]/[branch] --no-ff -m "merge: Task N — [name]"
git worktree remove ../[project]-task-[N]
```

Conflict resolution: if merge conflict arises (file sets should be disjoint, so this indicates a planning error), halt and report: "File conflict during merge of Task N and Task M — their file sets were not truly disjoint. Resolve manually."

## File set validation

Before dispatching any wave, verify disjointness:

```python
# Pseudocode — run before dispatch
for task_a, task_b in combinations(wave_tasks, 2):
    overlap = set(task_a.file_set) & set(task_b.file_set)
    if overlap:
        error(f"Tasks {task_a.id} and {task_b.id} share files: {overlap}")
        error("Assign one to next wave. Do not dispatch.")
```

## Config gate

Activated when ANY of:
- Total task count > 8
- `team-size: small-2-5` or `team-6+`
- `intent: production-saas` AND wave has > 1 task

Solo + short task list → execute-subagent (sequential). Don't force parallelism where it doesn't help.
