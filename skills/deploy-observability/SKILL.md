---
name: deploy-observability
description: Produces an observability plan covering the three telemetry signals (metrics, logs, traces) using the LGTM stack (Loki, Grafana, Tempo, Mimir) and OpenTelemetry as the collection layer. Use when the user asks for "observability setup", "monitoring plan", "how do I know when things break", "set up logging and metrics", "distributed tracing", "LGTM stack", or when /implement reaches this step. Tier-aware: hackathon gets a single uptime monitor; MVP gets metrics + structured logs; scaling gets all three signals with correlation IDs and automated alerting.
---

# /deploy-observability — observability plan

Defines the three-signal observability strategy. Observability is how you know a system is healthy; without it, you find out about problems from user complaints. Setup happens before the first production deploy, not after the first production incident.

Read `sdlc-foundation/decision-frameworks.md` — three telemetry signals, LGTM stack, W3C Trace Context.
Read `sdlc-foundation/maturity-tier-detection.md` for tier depth.

## The three signals

| Signal | What it is | Primary use |
| :--- | :--- | :--- |
| **Metrics** | Numeric time-series (CPU, error rate, latency p99, throughput) | Dashboards, alerting, capacity planning |
| **Logs** | Structured event records with fields | Incident investigation, audit trail, debugging |
| **Traces** | End-to-end request paths across services with timing | Latency analysis, chatty service detection, distributed debugging |

A correlation ID (W3C `traceparent` header) flowing through all three signals lets you pivot: metric spike → relevant traces → underlying logs.

## LGTM stack

- **L**oki — log aggregation (drop-in Elasticsearch alternative, cost-efficient)
- **G**rafana — unified visualization across all three signals
- **T**empo — distributed tracing backend
- **M**imir — metrics storage at scale (Prometheus-compatible)

**OpenTelemetry** is the vendor-neutral collection layer. Instrument with OTel once; swap backends later without re-instrumenting.

## Tier-appropriate setup

### Hackathon

One uptime monitor (UptimeRobot, BetterUptime — free tier). That's it. No other observability setup is worth the time.

### MVP

- **Metrics**: platform-native metrics (Vercel Analytics, Fly.io metrics, Railway metrics) OR Prometheus + Grafana Cloud free tier
- **Logs**: structured JSON logs shipped to Grafana Cloud Loki or Logtail (free tier)
- **Traces**: skip unless you have multiple services; add when you hit your first mysterious latency issue
- **Alerting**: one alert — error rate > 5% or uptime < 99% → PagerDuty/Opsgenie free tier or email

### Scaling

Full LGTM stack self-hosted (Kubernetes) or managed (Grafana Cloud):
- OpenTelemetry SDK instrumented in all services
- W3C `traceparent` propagated through all HTTP headers and queue messages
- Structured logging with correlation ID on every log line
- Dashboards: per-service SLO dashboard + golden signals dashboard (latency, traffic, errors, saturation)
- Alerting: SLO-based alerts (error budget burn rate) not threshold-based; PagerDuty with escalation policy
- Runbook for every alert

## Output format

```markdown
## Observability Plan — [Project Name]

**Tier: [Hackathon / MVP / Scaling]**

### Signal coverage

| Signal | Tool | Scope |
| :--- | :--- | :--- |
| Metrics | [Tool] | [What's measured] |
| Logs | [Tool] | [What's logged] |
| Traces | [Tool / Skip] | [Scope] |

### Instrumentation requirements

- [ ] OTel SDK installed in [services]
- [ ] Correlation ID propagated via W3C traceparent header
- [ ] Structured logging format (JSON) enforced
- [ ] Health check endpoint: GET /health returns 200 when healthy

### Key dashboards

1. [Dashboard name] — [What it shows]

### Alerting rules

| Alert | Condition | Severity | Response |
| :--- | :--- | :--- | :--- |
| Error rate spike | error_rate > 5% for 5min | Critical | Page on-call |
| SLO budget burn | Burn rate > 5× for 1h | Warning | Ticket |

### Correlation ID flow
[Diagram or description of how traceparent flows through the system]
```

After plan: recommend `/deploy-release-check` for pre-release gate verification, and note that the observability infrastructure should be live and emitting before the first production deploy.

## Anti-rationalization table
| Common Excuse | Why It's Wrong | What to Do Instead |
|---|---|---|
| "We'll add monitoring after launch" | Launch without monitoring is blind. You won't know something is broken until users tell you. | Add health checks + basic metrics before launch. Expand after. |
| "Logs are enough for debugging" | Logs tell you what happened. Metrics tell you when it started trending wrong. Traces tell you where. | Set up the 3 pillars: logs + metrics + traces. Start with logs and uptime. |
| "We can't afford observability tools" | Free tiers of Grafana/Loki/Prometheus handle most projects. The cost of downtime is higher. | Start with free tier. Upgrade when scaling demands it. |
