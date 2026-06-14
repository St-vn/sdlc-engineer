---
name: monitor
description: Produces a monitoring setup plan calibrated to intent tier. MVP: minimal health endpoint + error monitoring active. Production-saas: full uptime, latency, error rate, alert configuration. Gated on intent: mvp or production-saas. Invoked by /ship.
---

# /monitor — observability setup

Produces monitoring configuration at tier-appropriate depth.

## Gate

```
intent: hackathon → suppressed (no monitoring needed)
intent: mvp → minimal monitoring
intent: production-saas → full monitoring
```

## intent: mvp — minimal

Checklist:
- [ ] Health endpoint exists: `GET /health` returns `{"status": "ok"}` with HTTP 200
- [ ] Health endpoint checked: `curl http://[host]/health` returns 200
- [ ] Error monitoring active: Sentry (or equivalent) DSN configured, test error confirms delivery
- [ ] Deployment notification: Slack/email/webhook fires on successful deploy

Verify:
```bash
curl http://localhost:3000/health
# Expected: {"status":"ok"} with 200
```

## intent: production-saas — full

**Uptime monitoring:**
- External uptime monitor (Better Uptime, UptimeRobot, or platform-native) pinging health endpoint every 60 seconds
- Alert: SMS/PagerDuty on 3 consecutive failures
- Target: 99.9% uptime (43.8 min downtime/month)

**Latency monitoring:**
- p50, p95, p99 response time tracked per endpoint
- Alert: p95 > [PERF-001 threshold × 1.5]
- Dashboard: latency graph last 24h

**Error rate:**
- Error rate tracked (5xx / total requests)
- Alert: error rate > 1% over 5-minute window
- Sentry: error grouping, release tracking, performance monitoring

**Alert configuration matrix:**
| Signal | Threshold | Severity | Channel |
|---|---|---|---|
| Health check fail | 3 consecutive | P1 | PagerDuty |
| p95 latency > 2× SLO | 5 min sustained | P2 | Slack |
| Error rate > 1% | 5 min sustained | P2 | Slack |
| Error rate > 5% | 1 min sustained | P1 | PagerDuty |

## Output

Produces: `docs/sdlc-engineer/monitoring-plan.md` with configuration steps and verification commands.