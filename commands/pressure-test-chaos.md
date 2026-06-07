---
description: Run local container and TCP connection disruptions using Pumba and Toxiproxy.
argument-hint: [optional target container or proxy name]
---

You are running the `/pressure-test-chaos` command from the sdlc-engineer plugin.

Use the `pressure-test-chaos` skill to handle this invocation. The skill is at `skills/pressure-test-chaos/SKILL.md` within the sdlc-engineer plugin directory.

User's arguments: $ARGUMENTS

Procedure:
1. Read `skills/pressure-test-chaos/SKILL.md` for Pumba SIGTERM/pause syntax and Toxiproxy latency/reset rest queries.
2. Inject packet latency, drop active connections, or freeze docker containers.
3. Validate circuit breakers and measure Recovery Time Objective (RTO).
