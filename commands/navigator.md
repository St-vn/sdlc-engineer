---
description: Open the master SDLC blueprint and behavioral guide. Demystifies the workflow pipeline and boots agent discipline.
argument-hint: [optional stage name, e.g. spec, implement]
---

You are running the `/navigator` command from the sdlc-engineer plugin.

Use the `navigator` skill to handle this invocation. The skill is at `skills/navigator/SKILL.md` within the sdlc-engineer plugin directory; consult it for the full behavior contract and navigation guidelines.

User's arguments: $ARGUMENTS

Procedure:
1. Read `skills/navigator/SKILL.md` for the behavioral rules and lifecycle mapping.
2. If arguments are provided (e.g. spec, implement, ship), pull out that specific stage's details and present a focused walkthrough of that stage, including its inputs, outputs, commands, and background workflows (like worktrees, context-isolated reviews, or debugging).
3. If no arguments are provided, present the main overview table, agent behavioral rules, and a summary of the quick-start feature tutorial.
4. Conclude with a clear recommendation for the user's next logical command (e.g., "Run `/configure` if this is a new project, or `/consult` to assess your situation").
