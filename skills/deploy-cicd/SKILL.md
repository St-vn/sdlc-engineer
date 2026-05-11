---
name: deploy-cicd
description: Produces a CI/CD pipeline definition appropriate to the project's deployment tier. Use when the user asks for "CI/CD pipeline", "set up GitHub Actions", "automated deployment", "pipeline configuration", "continuous integration", "continuous delivery", or when /implement reaches this step. Produces tier-calibrated pipeline config (GitHub Actions YAML by default; adaptable to GitLab CI, CircleCI, etc.). Covers all six pipeline phases: source control → build → test → artifact archival → delivery → observability.
---

# /deploy-cicd — CI/CD pipeline definition

Produces a working CI/CD pipeline configuration calibrated to the deployment tier. References the six-phase pipeline shape from `sdlc-foundation/decision-frameworks.md`.

Read `sdlc-foundation/maturity-tier-detection.md` — tier drives all gating decisions.

## Six-phase pipeline shape

| Phase | Purpose | Hackathon | MVP | Scaling |
| :--- | :--- | :--- | :--- | :--- |
| Source control | Commit verification | Skip | Branch protection | Branch protection + signed commits + required reviews |
| Build | Compile + dependencies | Skip | `npm install` + lint | Build + dependency audit + license scan |
| Test | Quality gates | Skip | Unit tests; 60%+ coverage | Unit + integration + contract + SAST; 80%+ coverage |
| Artifact | Immutable package | Skip | Build artifact | Versioned artifact + checksum + vuln scan + registry push |
| Delivery | Rollout | Manual push | Auto-deploy to staging; manual to prod | Canary deploy; health check; traffic promotion |
| Observability | Runtime monitoring | Skip | Uptime check | Metrics/logs/traces; auto-rollback on SLO breach |

## Output: GitHub Actions YAML (default)

### MVP tier example

```yaml
name: CI/CD Pipeline

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
      - run: npm ci
      - run: npm run lint
      - run: npm test -- --coverage --coverageThreshold='{"global":{"lines":60}}'

  deploy-staging:
    needs: test
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Deploy to staging
        env:
          DEPLOY_TOKEN: ${{ secrets.DEPLOY_TOKEN }}
        run: |
          # Replace with your deployment command
          npm run deploy:staging

  deploy-production:
    needs: deploy-staging
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    environment:
      name: production
      url: https://your-app.com
    steps:
      - uses: actions/checkout@v4
      - name: Deploy to production
        env:
          DEPLOY_TOKEN: ${{ secrets.DEPLOY_TOKEN }}
        run: npm run deploy:production
```

### Scaling tier additions

```yaml
  security-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Dependency vulnerability scan
        run: npm audit --audit-level=high
      - name: SAST scan
        uses: github/codeql-action/analyze@v3

  artifact:
    needs: [test, security-scan]
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Build and push container
        run: |
          docker build -t $IMAGE_TAG .
          docker push $IMAGE_TAG
          echo "$IMAGE_TAG" | sha256sum > artifact.sha256
      - uses: actions/upload-artifact@v4
        with:
          name: deployment-artifact
          path: artifact.sha256

  canary-deploy:
    needs: artifact
    runs-on: ubuntu-latest
    steps:
      - name: Deploy canary (10% traffic)
        run: |
          # Route 10% traffic to new version
          # Monitor for 10 minutes
          # Auto-rollback if error rate > threshold
```

## Procedure

1. Ask (or infer from context): What is the CI platform? (GitHub Actions assumed; note alternatives)
2. Ask (or infer): What is the stack? (Node.js, Python, Go, etc. — affects build commands)
3. Ask (or infer): What is the deployment target? (Vercel, Fly.io, AWS, Kubernetes, etc.)
4. Produce the tier-appropriate pipeline YAML
5. Annotate secrets that need to be configured (e.g., `DEPLOY_TOKEN`, `DATABASE_URL`) — these are the items for `/deploy-secrets-audit`
6. Recommend next: `/deploy-observability` to define the monitoring layer.
