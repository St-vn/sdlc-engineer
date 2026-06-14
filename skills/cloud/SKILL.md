---
name: cloud
description: Tier-calibrated cloud infrastructure, containerization, CI/CD, deployment, and observability. Not replacing terraform-skill/aws-skills — providing the orchestration layer. Triggers on "deploy", "infrastructure", "Docker", "CI/CD", "cloud", "production setup".
---

# /cloud — Cloud Infrastructure, Deployment & DevOps

Tier-aware infrastructure orchestration. Selects the right patterns and tools for your maturity level without over-engineering.

## Tier Detection

Determine tier automatically (or ask user if unclear):

| Tier | Signal | Infrastructure | Deploy |
|------|--------|---------------|--------|
| **Hackathon** | < 100 users, single developer, no SLA | Vercel/Railway/Fly.io, no containers | Manual or auto-deploy from git |
| **MVP** | 100-10K users, small team, some SLA | Docker + managed DB + CDN + CI/CD | Automated pipeline, staging env |
| **Scaling** | 10K+ users, multiple teams, production SLA | K8s/ECS, IaC, multi-region, observability | Blue-green/canary, rollback automation |

## Phase 1: Architecture Design

1. **Select cloud provider** based on team expertise and project needs:
   - AWS: broadest services, steepest learning curve
   - GCP: best for containers/K8s (GKE), data/ML
   - Azure: best for enterprise/Active Directory/.NET shops
2. **Select compute**:
   - Serverless (functions): good for APIs, event processing
   - Containers (ECS/EKS/GKE/ACR): good for services, batch jobs
   - VMs: only when you need full OS control
3. **Select data layer**:
   - Relational (RDS/Cloud SQL/Azure SQL): structured data, ACID
   - NoSQL (DynamoDB/Firestore/CosmosDB): high-throughput, flexible schema
   - Cache (ElastiCache/Redis/Memcached): read-heavy workloads
4. **Document architecture** with cost estimate before building

## Phase 2: Infrastructure as Code

Select tool based on team and provider:
- **Terraform/OpenTofu**: multi-provider, largest community
- **AWS CDK**: TypeScript-native, best for AWS-only
- **Pulumi**: general-purpose programming languages

**For every IaC project:**
1. Remote state backend (S3 + DynamoDB / GCS / Azure Storage)
2. State locking (DynamoDB / GCS object versioning)
3. Environment separation (dev/staging/prod via workspaces or directories)
4. Pin provider versions (no floating latest)
5. Run plan in CI before apply

Reference: `docs/sdlc-engineer/iac-best-practices.md`

## Phase 3: Containerization

**Dockerfile rules:**
1. Multi-stage builds (builder → runner, never ship build tools)
2. Distroless or scratch as final base image
3. Use specific tags, never `:latest`
4. Scan with Trivy before push: `trivy image <image>:<tag>`
5. SBOM generation: `docker sbom <image>`

**Docker Compose for dev:**
- Match production as closely as possible
- Use bind mounts for live reload
- Separate compose files: `docker-compose.yml` + `docker-compose.override.yml`

Reference: `docs/sdlc-engineer/docker-best-practices.md`

## Phase 4: CI/CD Pipeline

**Minimum pipeline (all tiers):**
1. Lint → 2. TypeCheck → 3. Test → 4. Build → 5. Run integration tests

**MVP addition:**
6. Docker build + push to registry
7. Deploy to staging
8. Smoke tests on staging
9. Manual approval gate → deploy to production

**Scaling addition:**
10. IaC validate + plan
11. Security scan (Trivy, Semgrep)
12. Canary deploy with metrics comparison
13. Rollback automation on failure

**GitHub Actions template (MVP tier):**
```yaml
name: CI/CD
on: [push]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
      - run: npm ci
      - run: npm run lint
      - run: npm run typecheck
      - run: npm test
  deploy:
    needs: test
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: npm run build
      - uses: docker/build-push-action@v5
        with: { push: true, tags: "${{ secrets.REGISTRY }}/app:latest" }
```

Reference: `docs/sdlc-engineer/cicd-patterns.md`

## Phase 5: Deployment

**Strategy selection:**
| Strategy | Downtime | Risk | When to use |
|---|---|---|---|
| Recreate | Yes | Low | Dev, staging |
| Rolling | No | Low | MVP production |
| Blue-Green | No | Medium | Scaling production |
| Canary | No | Low (gradual) | High-traffic production |
| Shadow | No | Very low | Experimental features |

**Deployment checklist:**
- [ ] Database migration plan (forward + rollback)
- [ ] DNS/TLS/CDN (CloudFront/Cloudflare)
- [ ] Secrets set in secrets manager (not env files)
- [ ] Health check endpoint configured
- [ ] Logging and metrics configured

Reference: `docs/sdlc-engineer/deployment-strategies.md`

## Phase 6: Observability

**Hackathon:**
- Uptime monitor (Better Uptime / Healthchecks.io)
- Basic error tracking (Sentry free tier)

**MVP:**
- Structured JSON logging (pino/bunyan/winston)
- Metrics: Grafana + Prometheus (or cloud native: CloudWatch/Stackdriver)
- Distributed tracing: OpenTelemetry auto-instrumentation

**Scaling:**
- SLO-based alerting
- Dashboards for each service
- Cost monitoring and budgets
- On-call rotation with escalation

## Anti-rationalization table
| Common Excuse | Why It's Wrong | What to Do Instead |
|---|---|---|
| "Kubernetes is always the answer" | K8s is the right answer for < 5% of projects. It adds massive operational complexity. | Use the simplest thing that works for your scale. Serverless or single Docker host. |
| "Docker in production is enough" | Docker gives you consistent builds, but not orchestration, service discovery, or auto-healing. | Add orchestration when you have > 1 server. Start with Docker Compose or ECS. |
| "I'll fix security later" | IaC security (network policies, IAM roles, encryption) is 10x cheaper to add at design time. | Validate IaC with Checkov/Trivy before apply. Security is not optional. |
| "Manual deploy is fine for early stage" | Manual deploys skip testing, have no audit trail, and create "works on my machine" problems. | Set up CI/CD before the first production deploy. Even a basic pipeline. |
| "We don't need monitoring until launch" | Launch without monitoring is blind. You only know something is wrong when users complain. | Add health check + uptime monitor before launch. Add metrics in week 1. |
