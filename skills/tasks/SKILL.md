---
name: tasks
description: Produces a work breakdown structure from a completed spec and architecture. Converts user stories and design components into implementable engineering tasks with clear acceptance, dependencies, and effort estimates. Use when the user asks "break this into tasks", "what do I implement first?", "create a sprint plan", "give me the implementation checklist", "what's the order of work?", or has a complete (or partial) spec+design and wants to start building. Tier-aware: hackathon tasks are a simple ordered checklist; MVP tasks are a groomed sprint backlog; scaling tasks include story-point estimates, dependencies, and team assignments.
---

# /tasks — work breakdown structure

Converts requirements and architecture into implementable engineering tasks. The output is an ordered, dependency-aware task list the team can pick up and execute.

## Tier-appropriate output

| Tier | Output |
|:---|:---|
| Hackathon | Ordered checklist: "1. Scaffold project. 2. Build X. 3. Wire Y. 4. Deploy." Timebox estimates in hours. |
| MVP | Sprint backlog: tasks grouped by sprint, each with a 1-3 line description, rough effort (S/M/L), and dependency note |
| Scaling | Full WBS: tasks grouped by domain, numbered IDs (TASK-001), story-point estimates, blocked-by links, suggested owner role |

## Procedure

### Step 1 — Collect inputs
User stories (from `/spec`), architecture components (from `/design`). Work with whatever exists; if design hasn't run, use the user stories alone and flag that architectural tasks will be discovered during implementation.

### Step 2 — Identify the mandatory foundation tasks
Every system has a set of tasks that must come first because everything else depends on them. Common ones:
- Project scaffolding / repo setup
- CI pipeline (even a minimal one at hackathon tier)
- Auth / identity (most features gate on this)
- Core data model / migrations
- API skeleton / routing layer

Surface these explicitly as Phase 0.

### Step 3 — Map stories to implementation tasks
For each user story, break down into implementation-level tasks:
- Data layer: schema changes, migrations, repository methods
- Business logic: service layer functions, validation rules
- API: endpoint definitions, request/response contracts
- UI: components, state management, API calls
- Tests: unit tests for business logic, integration tests for API, E2E for critical flows

Not every story needs all layers — calibrate to the system's actual architecture.

### Step 4 — Sequence by dependencies
Order tasks so that each one can be completed without waiting for another:
- Mark explicit blockers: "TASK-004 blocked by TASK-001 (auth must exist)"
- Identify parallelizable work: "TASK-010 and TASK-011 can be done simultaneously by two devs"
- Surface the critical path: what's the sequence of tasks that determines the minimum possible completion time?

### Step 5 — MoSCoW cut (MVP tier)
Verify that only Must-have user stories have tasks in Sprint 1. Should-haves in Sprint 2. Could-haves parked. Flag any task drift.

### Step 6 — Output
Tasks in tier-appropriate format. End with: the critical path (what must complete for anything else to proceed), the first task to start (typically scaffolding + CI), and recommended next step: `/implement` for deployment planning.

## Anti-patterns flagged
- **"Build the perfect architecture first"** — flag as analysis paralysis; recommend delivering a thin vertical slice end-to-end before polishing each layer
- **Tasks with no acceptance** — every task should have a one-line definition of done
- **No testing tasks** — if no test tasks exist, add them; tests are not optional extras

## Audience adaptation
- Novice: explain what a sprint is, why the foundation comes first, what story points mean; use the S/M/L estimate scale rather than story points
- Senior: numbered task list with explicit deps and rough sizing; skip explanations
