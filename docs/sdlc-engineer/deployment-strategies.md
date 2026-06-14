# Deployment Strategies — Best Practices Methodology

## Design Principles

1. **Zero-downtime by default** — Production deploys must never take the system offline. Use strategies that route traffic around the deployment process.
2. **Fast, safe rollback** — Every deploy must have a one-step rollback path (re-route traffic, re-deploy previous image, revert DB migration).
3. **Progressive exposure** — New versions meet production traffic gradually, not all at once. Measure before full rollout.
4. **Immutable artifacts** — The build artifact that passed tests is the same binary that runs in production. Build once, deploy many times (from 12 Factor: Build/Release/Run separation).
5. **Observability-gated promotion** — Each phase of a rollout requires metric validation (error rate, latency, throughput) before proceeding to the next.

## When to Apply

| Strategy | When to Use |
|----------|-------------|
| Recreate | Dev-only, zero-cost environments, batch jobs |
| Rolling/Ramped | Stateful services, cautious gradual rollouts, no additional infra cost |
| Blue-Green | Critical production services, instant rollback requirement |
| Canary | Low confidence in new release, missing test coverage, new features |
| A/B Testing | Business decisions (conversion, UX experiments) |
| Shadow | Performance testing with production traffic, migration validation |

## Process

### 1. Twelve-Factor App Foundation (Pre-requisite)

Before implementing any deployment strategy, the app must satisfy 12 Factor:

| Factor | Rule | Verification |
|--------|------|-------------|
| I. Codebase | One codebase tracked in revision control, many deploys | `git remote -v` shows single origin |
| II. Dependencies | Explicitly declare and isolate dependencies | Package.lock / requirements.txt committed |
| III. Config | Store config in environment variables | No hard-coded secrets in source |
| IV. Backing services | Treat backing services as attached resources | Swap DB via config change, not code change |
| V. Build, release, run | Strictly separate build, release, run stages | CI builds artifact, CD creates release, run deploys it |
| VI. Processes | Execute as stateless processes | No local disk state needed; use backing service |
| VII. Port binding | Export services via port binding | App is self-contained, not injected into server |
| VIII. Concurrency | Scale out via process model | Horizontal scale via process count, not threads only |
| IX. Disposability | Fast startup + graceful shutdown | `SIGTERM` handler drains connections in < 30s |
| X. Dev/prod parity | Keep dev, staging, prod as similar as possible | Same backing service types, same versions |
| XI. Logs | Treat logs as event streams | App writes to stdout/stderr, environment routes |
| XII. Admin processes | Run admin tasks as one-off processes | Migrations, DB consoles in same runtime environment |

### 2. Deployment Strategy Selection Matrix

| Criteria | Recreate | Rolling | Blue-Green | Canary | Shadow |
|----------|----------|---------|------------|--------|--------|
| Downtime | Full | None | None | None | None |
| Rollback speed | Slow (re-deploy) | Slow (sequential) | Instant (switch) | Fast (re-route) | N/A |
| Resource cost | 1x | 1x + surge | 2x | 1x + fraction | 2x |
| Traffic control | None | Per-instance | Router-level | Weighted | Mirrored |
| State handling | Simple | Requires compatibility | Requires compatibility | Requires compatibility | Requires mocking |
| Test confidence | Low | Low | High (full test on green) | Moderate | High (real traffic) |
| Setup complexity | Minimal | Low | Medium | Medium | High |

### 3. Recreate Strategy (Dev Only)

```
1. Scale down version A to 0
2. Wait for all connections to drain (SIGTERM + grace period)
3. Deploy version B
4. Scale up version B
5. Verify health

Risk: Full downtime. Use only for dev environments or batch jobs.
```

### 4. Rolling/Ramped Strategy

```
1. Set max surge (instances added beyond current): 25-50%
2. Set max unavailable: 0-25%
3. Deploy one instance of B, wait for healthy
4. Remove one instance of A
5. Repeat until all A is replaced
6. Monitor error rate and latency continuously

Kubernetes: `kubectl set image deployment/app app=app:v2 --record`
Docker Swarm: `docker service update --image app:v2 app`

Verification per step:
  - Error rate < baseline + 1%
  - P99 latency < baseline + 10%
  - Health check passes on new instances
```

### 5. Blue-Green Deployment

```
1. Maintain two identical environments: Blue (live) and Green (staging)
2. Deploy version B to Green environment
3. Run full test suite against Green (integration, smoke, load)
4. Switch router from Blue to Green (DNS change / load balancer update)
5. Monitor Green for smoke period (15-60 min)
6. If rollback needed: switch router back to Blue (instant)
7. Once confident: decommission Blue or use as next staging

Load balancer switch example:
  # AWS ALB - swap target groups
  aws elbv2 modify-listener --listener-arn $LISTENER \
    --default-actions Type=forward,TargetGroupArn=$GREEN_TG

Database consideration:
  1. Apply schema changes BEFORE the app deploy (support both versions)
  2. Use ParallelChange: old schema + compatibility layer
  3. After deployment, remove old schema support

Verification gates:
  - All integration tests pass in Green
  - Synthetic monitoring passes in Green
  - Error rate after switch is within baseline
  - No increase in support tickets
```

### 6. Canary Release

```
1. Deploy version B alongside A (B receives 0% initially)
2. Route 1-5% of users to B (internal/employee users first)
3. Monitor for N minutes (5-30 min depending on traffic)
4. Increase to 10-25%, monitor again
5. Increase to 50%, monitor
6. Increase to 100% (full rollout)
7. If regression detected at any step: route 100% back to A

Traffic splitting methods:
  - Service mesh (Istio, Linkerd): weighted subsets
  - Load balancer: weighted target groups
  - Feature flags: user/group-based routing
  - Region-based: deploy to one region at a time

Istio example:
  apiVersion: networking.istio.io/v1beta1
  kind: VirtualService
  spec:
    hosts:
    - myapp
    http:
    - route:
      - destination:
          host: myapp
          subset: v1
        weight: 95
      - destination:
          host: myapp
          subset: v2
        weight: 5

Rollback trigger conditions (Cluster Immune System):
  - 5xx rate increases by >2x baseline
  - P99 latency exceeds SLO by >20%
  - Error budget consumption rate > 2x normal
```

### 7. Shadow Deployment

```
1. Deploy version B alongside A
2. Mirror production traffic (requests) to B without returning B's responses
3. Compare B's responses to A's responses for correctness
4. Measure B's performance under real production load
5. If B meets performance and correctness criteria, proceed to full rollout
6. If issues found, fix and re-deploy B, repeat shadow cycle

WARNING: Shadow deployments with side effects (write operations) require
mocking response paths or idempotency guarantees. A payment service shadow
would charge customers twice without proper isolation.
```

### 8. Database Migration During Deployments

```
1. Phase 1 (before deploy): Apply backward-compatible schema changes
   - Add new columns (nullable or with defaults)
   - Add new tables
   - Create compatibility views
2. Deploy application (supports old + new schema)
3. Phase 2 (after deploy): Data migration
   - Backfill new columns
   - Migrate data to new tables
4. Phase 3 (after stable): Remove old schema support
   - Drop old columns/tables
   - Remove compatibility layer
```

## Twelve-Factor Cloud Qualifications

For an app to use modern deployment strategies, verify these cloud-readiness criteria:

```
1. Health check endpoint: GET /health returns 200
2. Readiness check endpoint: GET /ready returns 200 when accepting traffic
3. Graceful shutdown: SIGTERM → stop accepting connections → drain in-flight → exit
4. Startup time: < 30 seconds (under 5s preferred for orchestration)
5. Stateless: Any instance can serve any request
6. Logging: Structured JSON to stdout, no file-based logs
7. Configuration: All config via environment variables, no config files
```

## Anti-patterns

- **Big-bang deploy** — Stopping all old instances before new ones are healthy. Always roll, never recreate in production.
- **Deploying on Friday afternoon** — The "no deploys on Friday" heuristic is real. Do your first canary on Tuesday-Thursday.
- **Skipping health checks** — Deploying to a load balancer that doesn't verify health means routing traffic to dead instances.
- **Database changes in the same deploy as app changes** — Schema migrations should be backward-compatible and deployed separately.
- **Ignoring rollback plan** — If your deployment script doesn't have a documented rollback, you don't have a deploy, you have an experiment.
- **Over-relying on A/B testing for deployment** — A/B testing measures business metrics (needs days); canary measures operational metrics (needs minutes). Don't conflate.
- **Manual cutover** — Any deployment strategy requiring SSH access or manual load balancer editing is not a real deployment strategy.

## Tools with install commands

```bash
# Kubernetes (for rolling, blue-green, canary)
choco install kubernetes-cli

# Istio (advanced canary routing)
choco install istio

# Flagger (automated canary with metric analysis)
curl -sL https://flagger.app/install | bash

# Argo Rollouts (blue-green + canary for Kubernetes)
kubectl create namespace argo-rollouts
kubectl apply -n argo-rollouts -f https://github.com/argoproj/argo-rollouts/releases/latest/download/install.yaml

# Spinnaker (multi-cloud deployment pipelines)
# (requires Halyard or Operator installation)

# Feature flags for canary
npm install -g unleash-server  # OpenFeature-compliant
```

**References:**
- [Blue-Green Deployment (Martin Fowler)](https://martinfowler.com/bliki/BlueGreenDeployment.html)
- [Canary Release (Martin Fowler)](https://martinfowler.com/bliki/CanaryRelease.html)
- [The Twelve-Factor App](https://12factor.net/)
- [Six Strategies for Application Deployment (The New Stack)](https://thenewstack.io/deployment-strategies/)
- [Continuous Delivery (Jez Humble, Dave Farley)](https://continuousdelivery.com/)
