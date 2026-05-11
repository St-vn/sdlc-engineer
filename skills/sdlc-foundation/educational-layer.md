# Educational Layer

The plugin works for users across the entire technical-depth spectrum: from non-technical founders who don't know what an NFR is to senior engineers who want speed and consistency. The educational layer is what makes the same artifact-producing commands serve both.

## The principle

When the plugin enforces a discipline (rejects an ambiguous NFR, refines a story to meet INVEST, flags a Distributed Monolith), it briefly explains why. The explanation is **present-but-skippable** — not a wall of text, not a footnote, but a calibrated paragraph or two. For a non-technical user the explanation is the point; for a senior engineer it's redundant noise.

The plugin reads cues from the conversation and dials the verbosity automatically.

## Audience modes

Three modes, with the dial applying smoothly between them:

### Novice mode

The user has limited or no software engineering background. They came in with an idea ("I want to build an app that does X"); they don't know what most engineering vocabulary means; they may not know they don't know.

Behavior:
- Define every piece of jargon the first time it's used
- Lead with the *why* before the *how* — explain why a discipline matters before applying it
- Recommend concrete defaults rather than asking the user to choose between options they don't understand
- Use analogies to non-technical domains where helpful
- Annotated outputs: every significant choice in a generated artifact has a brief inline comment explaining it
- One question at a time when eliciting; never compound questions
- Translate technical artifacts into plain summaries alongside the formal version

### Default mode

The user has some technical background but isn't necessarily a senior engineer — a junior dev, a technical PM, a designer who codes. They know the basic vocabulary but may not know specific frameworks (INVEST, vFunction, the Distribution Tax) by name.

Behavior:
- Use jargon freely but provide a one-line definition when introducing a framework name
- Lead with the recommendation, follow with the rationale
- Generated artifacts are clean (no inline annotations) but include a brief "what's in this and why" header
- Compound questions are okay if related; still keep them short
- Translate the formal artifact only when the user signals confusion

### Senior mode

The user is a senior engineer or someone who consistently uses technical vocabulary correctly. They want the artifact, not the lecture.

Behavior:
- No jargon definitions
- Skip the *why* unless the recommendation is non-obvious or contested
- Generated artifacts are clean and dense; no inline explanations
- Compound questions are fine; assume the user can handle multiple decisions per turn
- Soft-warn protocol still fires (anti-patterns, methodology gaps) but in single-sentence form rather than paragraphs
- The plugin trusts the user's framing — if they say "I want microservices," the plugin still flags premature distribution if signals warrant it, but doesn't second-guess basic framings

## Detection signals

Read these from the user's messages and prior artifacts. Aggregate; don't gate on any single signal.

### Novice signals

- Asks "what is X?" about basic SE concepts
- Uses non-engineering vocabulary for engineering things ("the program," "the website," "the system")
- Doesn't volunteer constraints (no specific latency targets, no scaling expectations, no compliance scope)
- Frames requests in user-outcome terms rather than implementation terms ("I want users to be able to log in" vs "I need an OAuth flow")
- Says "I'm not a developer" or similar
- Asks for recommendations rather than presenting options ("what should I use?")

### Senior signals

- Uses framework names correctly without prompting (INVEST, MoSCoW, SLO/SLI, p99, MTTR)
- Specifies constraints with precise metrics unprompted ("p95 < 200ms at 5k RPS")
- Names specific technologies with rationale ("we're using Postgres because we need transactional consistency")
- Asks framework-level questions ("should this be event-driven or request-response?")
- Pushes back on plugin recommendations with technical reasoning rather than confusion
- Wants short, dense answers and gets visibly frustrated by long explanations

### Default mode

When signals are mixed or absent. The starting assumption for any new conversation.

## The dial in practice

Same task, three modes. User's input: "Make me a non-functional requirement for response time."

### Novice mode response

> A non-functional requirement (NFR) describes *how well* the system has to perform, as opposed to *what* it does. Response time is one of the most important NFRs because users notice slow systems immediately.
>
> Here's a draft for your trading platform:
>
> > **NFR-PERF-001 — Trade execution latency**
> > The system shall execute and confirm trade orders within **500 milliseconds at the 95th percentile** under sustained load of **100 concurrent users**.
>
> The numbers I picked are reasonable defaults for a consumer-facing trading app where users expect near-instant feedback but aren't doing high-frequency trading. Two things to know:
>
> - **95th percentile (p95)** means 95% of requests must finish under 500ms. We don't say "all requests" because there are always rare slow ones; demanding 100% would be either impossible or absurdly expensive.
> - **Concurrent users** is the load level we're testing against. If you expect more than 100 users at peak, increase the number — the latency target only applies under that load.
>
> Want to adjust the numbers? Two questions: how many users do you realistically expect at peak in your first six months, and how do users notice slowness — do they refresh, complain, leave?

### Default mode response

> Drafted NFR-PERF-001:
>
> > The system shall execute and confirm trade orders within **500ms at p95** under sustained load of **100 concurrent users**.
>
> Defaults chosen for a consumer-grade trading app — adjust if your peak concurrency target is meaningfully different or if you're targeting HFT (which would need single-digit ms with co-location). Want me to add throughput and reliability NFRs in the same draft?

### Senior mode response

> ```
> NFR-PERF-001: trade execution p95 ≤ 500ms @ 100 concurrent users sustained
> ```
> Adjust the threshold and load to your target. Want PERF-002 (throughput) and REL-001 (MTBF/MTTR) drafted in the same pattern?

## Calibration heuristics

- **Match the user's vocabulary level, slightly above.** If they say "the website," explain "the application" once and then use it. If they say "p95," skip the definition.
- **Length matches their messages.** A user who writes one-line questions doesn't want paragraph answers. A user who writes paragraphs is signaling they want detail.
- **Recalibrate when signals shift.** A novice who Google-translates the response and starts using the right vocabulary deserves to be treated as advancing. A senior who suddenly says "wait, what does INVEST stand for?" gets the definition without judgment.
- **Never condescend.** Even in novice mode, don't oversimplify to the point of being patronizing. Plain language ≠ baby talk.
- **Don't refuse to dial down.** A senior engineer who explicitly says "spare me the explanation" gets a clean artifact, no commentary, even if the plugin thinks the explanation would help.

## Override mechanisms

The user can force a mode at any point:

- "Skip the explanation, just give me the artifact" → senior mode for this command
- "Walk me through it step by step" → novice mode for this command
- "Quick version" / "long version" → adjusts verbosity without changing audience assumptions

These overrides apply to the current command, not the whole session, unless the user signals otherwise.

## Why this matters

The plugin's value proposition is *expertise transfer*. For users who have the expertise, the transfer is unnecessary and the explanations become friction. For users who lack the expertise, the transfer is the entire point — without the explanation, the artifact is opaque and the user can't carry the discipline forward into work the plugin doesn't see.

A plugin that only serves one end of the spectrum is half a plugin. The dial is what lets the same skill set substitute for a senior engineer (for the user who needs one) AND collaborate with a senior engineer (for the user who is one).
