---
name: execute-subagent
description: Dispatches each task to a fresh Claude subagent with a clean context window. Each subagent gets only its task + file context — no accumulated session noise. Falls back to /execute-inline if Claude Code Task tool is unavailable. Use when /implement routes sequential subagent execution.
---

# /execute-subagent — fresh-context task execution

Dispatches tasks to fresh Claude subagents. Each task gets a 200K token context with no pollution from prior tasks.

## Why fresh context per task

"Context rot" is the #1 failure mode in long implementation sessions: accumulated decisions, failed approaches, and implementation details from previous tasks pollute the model's judgment. A fresh subagent starts clean.

Main conversation token load stays at 30-40% — it dispatches and reviews, does not implement.

## Dispatch protocol

For each task:

1. **Prepare subagent context:**
   ```
   You are implementing Task N: [name]
   
   AC reference: [Gherkin AC]
   NFRs in scope: [list]
   File set: [exact files to touch]
   
   Task:
   [full task block from plan file]
   
   Learnings to avoid (from learnings.jsonl):
   [relevant anti-patterns and failed approaches]
   ```

2. **Dispatch via Claude Code Task tool**

3. **Receive output:** commit hash + GREEN confirmation + any NFR warnings

4. **Route to review-spec:** pass AC + git diff

5. **On review-spec FAIL:** re-dispatch subagent with failure reason and instruction to fix

## Fallback

If Claude Code Task tool is not available in this session:
- Log: "Task tool unavailable — falling back to execute-inline"
- Route to /execute-inline for current-session sequential execution

## Context budget

Subagent context contains:
- Task block (~500 tokens)
- AC and NFRs (~200 tokens)
- Relevant files (variable)
- Learnings entries (~100 tokens)

Do NOT include: prior tasks, full codebase, session history.
