# CI/CD Patterns — Best Practices Methodology

## Design Principles

1. **Build once, deploy many** — The artifact that passes tests in CI is the same artifact promoted through every environment. Never rebuild for production.
2. **Shift security left** — Static analysis, dependency scanning, secrets detection, and IaC scanning run on every PR — before merge, not after.
3. **Environment gating** — Each environment has a promotion gate: dev auto-deploys, staging requires approval, production requires reviewed artifact + approval.
4. **Fast feedback cycles** — CI should complete in < 10 minutes. If it takes longer, parallelize or split into focused workflows.
5. **Deterministic, reproducible pipelines** — Pipeline behavior depends only on code, not on environment state. Pin tool versions and base images.

## When to Apply

- Any codebase with more than one contributor
- Any service deployed to production
- Any infrastructure managed as code
- Any project requiring audit trail of changes

## Process

### 1. Pipeline Stage Architecture

```
┌──────────────────────────────────────────────────────┐
│                    TRIGGER                            │
│   push (feature/*) | pull_request | tag (v*) | cron   │
└──────────────────────┬───────────────────────────────┘
                       ▼
┌──────────────────────────────────────────────────────┐
│  STAGE 1: SOURCE & QUALITY (Fast, < 2 min)           │
│   ├── Checkout + LFS pull                             │
│   ├── Lint (eslint, ruff, tflint, hadolint)           │
│   ├── Format (prettier, rustfmt, terraform fmt)       │
│   ├── Secrets scan (gitleaks, trufflehog)             │
│   └── Dependency audit (npm audit, pip-audit)         │
└───────────────────────────────────┬───────────────────┘
                                    ▼
┌──────────────────────────────────────────────────────┐
│  STAGE 2: BUILD & TEST (Medium, < 8 min)             │
│   ├── Compile / Build artifact                        │
│   ├── Unit tests (parallel)                           │
│   ├── Container build (--pull, digest pin)             │
│   ├── Container scan (trivy, grype, docker scout)     │
│   └── SBOM generation (syft)                          │
└───────────────────────────────────┬───────────────────┘
                                    ▼
┌──────────────────────────────────────────────────────┐
│  STAGE 3: IaC & INFRASTRUCTURE (When IaC changes)    │
│   ├── terraform fmt -check / tofu fmt -check          │
│   ├── terraform validate / tofu validate               │
│   ├── tflint / checkov / trivy config                  │
│   ├── Infracost (cost estimation)                      │
│   └── Plan (review artifact)                           │
└───────────────────────────────────┬───────────────────┘
                                    ▼
┌──────────────────────────────────────────────────────┐
│  STAGE 4: STAGING DEPLOY (Auto on main merge)        │
│   ├── Deploy to staging environment                    │
│   ├── Integration tests                                │
│   ├── Smoke tests (health + critical paths)            │
│   └── E2E tests (if applicable)                        │
└───────────────────────────────────┬───────────────────┘
                                    ▼
┌──────────────────────────────────────────────────────┐
│  STAGE 5: PRODUCTION PROMOTION (Gated + Approved)    │
│   ├── Manual approval step (via GitHub Environments)   │
│   ├── Apply reviewed plan artifact (Terraform)         │
│   ├── Canary deploy (5% → 25% → 100%)                 │
│   ├── Post-deploy monitoring (error budget check)      │
│   └── Rollback on metric degradation                   │
└──────────────────────────────────────────────────────┘
```

### 2. GitHub Actions Workflow Templates

**PR Validation (Fast checks on every PR):**
```yaml
name: PR Validate
on:
  pull_request:
    branches: [main]
    types: [opened, synchronize]

permissions:
  contents: read
  id-token: write
  pull-requests: write

jobs:
  quality:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Lint
        run: npm run lint
      - name: Format check
        run: npx prettier --check .
      - name: Secrets scan
        uses: gitleaks/gitleaks-action@v2
      - name: Dependency audit
        run: npm audit --audit-level=high

  test:
    needs: quality
    runs-on: ubuntu-latest
    strategy:
      matrix:
        node-version: [20, 22]
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: ${{ matrix.node-version }}
          cache: npm
      - run: npm ci
      - run: npm test -- --coverage

  build-and-scan:
    needs: quality
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Build image
        run: docker build --pull -t app:${{ github.sha }} .
      - name: Scan image
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: app:${{ github.sha }}
          severity: CRITICAL,HIGH
      - name: Generate SBOM
        uses: anchore/sbom-action@v0
        with:
          image: app:${{ github.sha }}
```

**Terraform CI/CD with OIDC:**
```yaml
name: Terraform
on:
  pull_request:
    paths: ['terraform/**']
  push:
    branches: [main]
    paths: ['terraform/**']

permissions:
  contents: read
  id-token: write   # For OIDC auth to cloud

jobs:
  validate:
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: terraform
    steps:
      - uses: actions/checkout@v4
      - uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: 1.10.0

      - name: Format & Validate
        run: |
          terraform fmt -check
          terraform validate

      - name: Lint & Security
        run: |
          tflint --format compact
          trivy config .
          checkov -d .

  plan:
    needs: validate
    runs-on: ubuntu-latest
    if: github.event_name == 'pull_request'
    environment: ${{ matrix.env }}
    strategy:
      matrix:
        env: [dev, staging]
    steps:
      - uses: actions/checkout@v4
      - uses: hashicorp/setup-terraform@v3
      - uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: arn:aws:iam::123456789:role/github-oidc-${{ matrix.env }}
          aws-region: us-east-1

      - name: Terraform Plan
        run: |
          terraform init -backend-config=backends/${{ matrix.env }}.hcl
          terraform plan -out=tfplan -var-file=env/${{ matrix.env }}.tfvars

      - name: Upload Plan
        uses: actions/upload-artifact@v4
        with:
          name: tfplan-${{ matrix.env }}
          path: terraform/tfplan

  apply:
    needs: plan
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main' && github.event_name == 'push'
    environment:
      name: ${{ matrix.env }}
      url: ${{ steps.deploy-url.outputs.url }}
    strategy:
      matrix:
        env: [dev]
    steps:
      - uses: actions/checkout@v4
      - uses: hashicorp/setup-terraform@v3
      - uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: arn:aws:iam::123456789:role/github-oidc-${{ matrix.env }}

      - name: Apply
        run: |
          terraform init -backend-config=backends/${{ matrix.env }}.hcl
          terraform apply tfplan  # Apply the REVIEWED plan artifact
```

**Reusable workflow for deployments:**
```yaml
# .github/workflows/deploy-reusable.yml
name: Deploy Reusable
on:
  workflow_call:
    inputs:
      environment:
        required: true
        type: string
      image-tag:
        required: true
        type: string
    secrets:
      cloud-role-arn:
        required: true

jobs:
  deploy:
    runs-on: ubuntu-latest
    environment: ${{ inputs.environment }}
    steps:
      - uses: actions/checkout@v4
      - uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: ${{ secrets.cloud-role-arn }}
          aws-region: us-east-1
      - name: Deploy
        run: |
          echo "Deploying ${{ inputs.image-tag }} to ${{ inputs.environment }}"
          # Your deploy script here
```

### 3. GitLab CI Patterns

```yaml
# .gitlab-ci.yml
stages:
  - quality
  - build
  - test
  - security
  - deploy

variables:
  DOCKER_IMAGE: $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
  TF_ROOT: ${CI_PROJECT_DIR}/terraform

include:
  - template: Security/SAST.gitlab-ci.yml
  - template: Security/Secret-Detection.gitlab-ci.yml

quality:
  stage: quality
  image: node:20
  script:
    - npm ci
    - npm run lint
    - npx prettier --check .
  cache:
    key: $CI_COMMIT_REF_SLUG
    paths:
      - node_modules/

build:
  stage: build
  image: docker:24
  services:
    - docker:24-dind
  script:
    - docker build --pull -t $DOCKER_IMAGE .
    - docker push $DOCKER_IMAGE

deploy-canary:
  stage: deploy
  image: alpine/k8s:1.28
  script:
    - kubectl set image deployment/myapp myapp=$DOCKER_IMAGE
    - kubectl rollout status deployment/myapp
  environment:
    name: production
    url: https://myapp.example.com
  rules:
    - if: $CI_COMMIT_BRANCH == "main"
      when: manual
```

### 4. CI/CD Maturity Evaluation (DORA Metrics)

| Metric | Elite | High | Medium | Low |
|--------|-------|------|--------|-----|
| Deployment frequency | On-demand (multiple/day) | Between once per day and once per week | Between once per week and once per month | Between once per month and once every 6 months |
| Lead time for changes | < 1 hour | < 1 day | < 1 week | < 6 months |
| Time to restore service | < 1 hour | < 1 day | < 1 week | < 6 months |
| Change failure rate | 0-5% | 6-10% | 11-15% | > 16% |
| Rework rate | < 10% | 10-20% | 21-30% | > 30% |

Use these as team reflection metrics, not individual performance targets. Track during retrospectives.

### 5. Security Gates Checklist

Every pipeline must verify before proceeding to deploy stage:

```
☐ Static code analysis (SAST) - no critical/high findings
☐ Dependency scan (SCA) - no known critical CVEs
☐ Secrets detection - no hard-coded credentials
☐ Container scan - no critical CVEs in final image
☐ IaC scan (terraform/cloudformation) - no high-severity misconfigurations
☐ License compliance - all dependencies have approved licenses
☐ SBOM generated and attached to release
☐ Image signed with cosign (for production artifacts)
```

### 6. Production Promotion Workflow

```
Pull Request → Merge → Auto-deploy Dev → [Manual] → Staging → [Manual] → Canary Prod

PR:
  - Automatic checks: lint, test, build, scan
  - Required reviews: 1 for dev, 2 for production changes
  - Blocking: any critical/high security finding

Merge to main:
  - Auto-deploy dev environment
  - Create git tag (semantic release)

Staging promotion:
  - "Deploy to Staging" button
  - Runs integration + smoke tests
  - Generates release notes

Production promotion:
  - "Deploy to Production" button
  - Canary rollout: 5% → 25% → 100%
  - Auto-rollback if error budget exceeded
  - Post-deploy: monitor for 30 min
```

## Anti-patterns

- **Deploying from local machines** — No credentials on laptops. CI/CD is the only path to production.
- **Long-lived feature branches** — Branches older than 2 days indicate WIP overflow. Merge to main daily with feature flags.
- **Skipping the plan review** (Terraform) — Running `terraform apply` from CI without reviewing the plan artifact is guesswork. Apply the reviewed plan only.
- **Rebuilding artifacts per environment** — If you `npm build` for dev and again for prod, you're testing one binary and shipping another.
- **CI that takes > 20 minutes** — Developers will find ways around it. Parallelize, cache, or split into focused pipelines.
- **Pipeline as an un-reviewable blob** — If the CI YAML can't be reviewed in a PR, it's too complex. Use reusable workflows or composite actions.
- **Hard-coded credentials in CI variables** — Use OIDC/openID Connect. GitHub Action secrets are better than plaintext but still need rotation.
- **`latest` tag for deploy** — Unpinned tags cause non-reproducible deploys. Use commit SHA or semantic version tags.

## Tools with install commands

```bash
# GitHub CLI
choco install gh

# GitLab Runner
choco install gitlab-runner

# Trivy (IaC + container scan)
choco install trivy

# Gitleaks (secrets detection)
choco install gitleaks

# Cosign (image signing)
choco install cosign

# Syft (SBOM generation)
choco install syft

# Infracost (Terraform cost estimation)
choco install infracost

# semantic-release (automated versioning)
npm install -g semantic-release

# pre-commit (local quality gates)
pip install pre-commit

# Renovate (automated dependency updates)
# GitHub App: install from https://github.com/apps/renovate
```

**References:**
- [GitHub Actions Workflow Syntax](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions)
- [GitLab CI Documentation](https://docs.gitlab.com/ee/ci/)
- [ThoughtWorks Technology Radar — CI/CD Patterns](https://www.thoughtworks.com/radar/techniques)
- [DORA Metrics Guide](https://www.devops-research.com/)
- [Zero Trust CI/CD — ThoughtWorks](https://www.thoughtworks.com/radar/techniques/zero-trust-security-for-ci-cd)
