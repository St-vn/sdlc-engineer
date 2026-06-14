# Infrastructure as Code — Best Practices Methodology

## Design Principles

1. **Declarative over imperative** — Describe desired state, not step-by-step commands. IaC tools (Terraform, CDK, Pulumi) reconcile state automatically.
2. **Immutable infrastructure** — Never modify servers in-place. Destroy and recreate; this prevents configuration drift and enables reproducible deploys.
3. **Environment parity** — Dev, staging, and prod run identical IaC with different configuration. Environment-specific values come from variables/ESC, not hard-coded branches.
4. **Least-privilege identity** — Cloud credentials via OIDC/workload identity federation, never static keys. Human users authenticate individually; CI/CD pipelines get short-lived tokens.
5. **Progressive disclosure** — The AI agent follows a diagnose-first workflow: capture execution context, identify failure mode, load only matching reference depth, propose fix with risk controls, validate, emit response contract.

## When to Apply

- Any cloud resource created manually more than once
- Teams larger than 2 people sharing infrastructure
- Any deployment requiring audit trails or compliance
- Resources that span multiple environments (dev/staging/prod)
- Any service with a change management process

## Process

### 1. Capture Execution Context
```
Runtime+version (terraform 1.10+ / tofu 1.6+)
Provider(s) with version constraints
State backend type and location
Execution path (local / CI / Cloud / Atlantis)
Environment criticality (dev/staging/prod)
```

### 2. Choose IaC Tool by Maturity

| Situation | Tool | Rationale |
|-----------|------|-----------|
| Declarative, multi-cloud, large state | Terraform/OpenTofu | Mature ecosystem, native tests (1.6+), `write_only` (1.11+) |
| TypeScript/Python teams, need real programming | CDK (AWS) or Pulumi | Full programming language, construct reuse, unit-testable |
| Azure-native workloads | Pulumi with azure-native provider | First-class Azure support, latest API versions |
| Cross-cloud standardization | Terraform with composition pattern | Same HCL across AWS/Azure/GCP |

### 3. Module Development (Terraform/OpenTofu)

**Directory layout:**
```
environments/   # prod/ staging/ dev/  — per-env configurations
modules/        # networking/ compute/ data/ — reusable modules
examples/       # minimal/ complete/ — docs + integration fixtures
tests/          # *._test.tf for native tests (1.6+)
```

**Module structure:**
```
my-module/
├── main.tf         # Primary resources
├── variables.tf    # Typed inputs with descriptions
├── outputs.tf      # Output values
├── versions.tf     # required_version + required_providers
├── examples/
│   ├── minimal/
│   └── complete/
└── tests/
    └── module_test.tftest.hcl
```

**Variable contracts:**
- Always `description`, always explicit `type`
- Use `validation` for complex constraints
- Use `sensitive = true` for secrets
- Prefer `optional()` with typed defaults (1.3+) over untyped `map(any)`

**Block ordering:**
- Resource: `count`/`for_each` → arguments → `tags` → `depends_on` → `lifecycle`
- Variable: `description` → `type` → `default` → `validation` → `nullable` → `sensitive`

### 4. State Management

**Never use local state in teams or production.** Remote backends provide locking, encryption, versioning, audit logging.

| Pattern | When | Example Path |
|---------|------|--------------|
| Per environment | Different teams per env | `prod/terraform.tfstate`, `staging/...` |
| Per component | Independent lifecycles | `prod/vpc/`, `prod/eks/`, `prod/rds/` |
| Hybrid (recommended) | Both benefits | `prod/networking/`, `prod/compute/` |

**Split state when:** different teams, different update cadences, or >500 resources.
**Combine when:** tightly coupled resources, <100 resources, same lifecycle.

**S3 backend example (Terraform 1.10+):**
```hcl
terraform {
  backend "s3" {
    bucket       = "my-terraform-state"
    key          = "prod/vpc/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true   # Native S3 locking, 1.10+. Pre-1.10: dynamodb_table
  }
}
```

### 5. Testing Strategy

| Situation | Approach | Tools |
|-----------|----------|-------|
| Quick syntax check | Static analysis | `validate`, `fmt` |
| Pre-commit validation | Static + lint | `validate`, `tflint`, `trivy`, `checkov` |
| Terraform 1.6+, simple logic | Native test framework | `terraform test` |
| Pre-1.6, or Go expertise | Integration testing | Terratest |
| Security/compliance focus | Policy as code | OPA, Sentinel |
| Cost-sensitive workflow | Mock providers (1.7+) | Native tests + mocks |

**Native test rules (1.6+):**
- `command = plan` — fast, for input-derived values only
- `command = apply` — required for computed values (ARNs, generated names)
- Set-type blocks cannot be indexed with `[0]` — use `for` expressions or `command = apply`

### 6. CDK Development (AWS)

**Core rule:** Do NOT explicitly specify resource names when optional in CDK constructs.

```
// ❌ BAD
new lambda.Function(this, 'MyFunction', { functionName: 'my-lambda' });

// ✅ GOOD
new lambda.Function(this, 'MyFunction', { /* no functionName */ });
```

**Lambda functions:**
- TypeScript/JavaScript: `NodejsFunction` from `aws-cdk-lib/aws-lambda-nodejs`
- Python: `PythonFunction` from `@aws-cdk/aws-lambda-python-alpha`

**Pre-deployment validation:**
```bash
npm run build && npm test && npm run lint && cdk synth
./scripts/validate-stack.sh
```

**cdk-nag for compliance:** Install `cdk-nag`, add `Aspects.of(app).add(new AwsSolutionsChecks())`.

### 7. Pulumi Development (TypeScript)

**ESC Integration (instead of pulumi config set):**
```bash
pulumi env init myorg/myproject-dev
pulumi config env add myorg/myproject-dev
```

**ESC environment with OIDC:**
```yaml
values:
  pulumiConfig:
    aws:region: us-west-2
  aws:
    login:
      fn::open::aws-login:
        oidc:
          roleArn: arn:aws:iam::123456789:role/pulumi-oidc
          sessionName: pulumi-deploy
```

**Component resources for reusability:**
```typescript
class WebService extends pulumi.ComponentResource {
    constructor(name: string, args: WebServiceArgs, opts?: pulumi.ComponentResourceOptions) {
        super("custom:app:WebService", name, {}, opts);
        // Create child resources with { parent: this }
        new aws.lb.LoadBalancer(`${name}-lb`, { ... }, { parent: this });
        this.registerOutputs({ url: this.url });
    }
}
```

**Multi-language components:** Use `PulumiPlugin.yaml` with `runtime: nodejs`. All Args must use `pulumi.Input<T>`.

**Safe deployment workflow:**
```bash
pulumi preview          # Step 1: Preview
pulumi stack output     # Step 2: Validate
pulumi up               # Step 3: Deploy
pulumi stack output     # Step 4: Verify outputs
```

### 8. Version Management

| Component | Strategy | Example |
|-----------|----------|---------|
| Terraform runtime | Pin minor | `required_version = "~> 1.9"` |
| Providers | Pin major | `version = "~> 5.0"` |
| Modules (prod) | Pin exact | `version = "5.1.2"` |
| Modules (dev) | Allow patch | `version = "~> 5.1"` |

Commit `.terraform.lock.hcl` intentionally. Keep provider/runtime upgrades in a separate PR from functional changes.

### 9. Security & Compliance

```bash
trivy config .
checkov -d .
```

**Don't:** Store secrets in variables or `.tfvars`, use default VPC, skip encryption, open security groups to `0.0.0.0/0`, use inline `ingress`/`egress` in `aws_security_group`.

**Do:** Source secrets from cloud secret manager or `write_only` arguments (1.11+), create dedicated VPCs, enforce encryption at rest and TLS, least-privilege SGs, use separate `aws_vpc_security_group_{ingress,egress}_rule` resources.

### 10. Validation Plan (Response Contract)

Every IaC change must include before finalizing:
1. `fmt -check` — formatting compliance
2. `validate` — syntax and internal consistency
3. `plan -out=<file>` — reviewable change artifact (not for destroy)
4. Policy check — `trivy config .`, `checkov -d .`
5. For destroy: `plan -destroy` first, show every resource, get explicit confirmation

## Anti-patterns

- **Mounting the Docker socket in containers** (`/var/run/docker.sock`) — equivalent to root access to host. Never do this in any IaC runner container.
- **Explicit resource naming** in CDK constructs — prevents parallel deployments and reuse.
- **Single prod+non-prod state file** — one bad apply destroys everything. Split by environment.
- **Secrets in variables/state** — `sensitive = true` only masks display. Use `write_only` (1.11+) or runtime secret lookups.
- **Using `count` for list iteration** — removing middle element reshuffles every address. Use `for_each = toset(list)`.
- **Running `terraform destroy` without plan-destroy review first** — always plan, show, confirm.
- **`null_resource` + `local-exec` for bootstrap** — provisioners leak secrets in CI logs and are not tracked in state.

## Tools with install commands

```bash
# Terraform/OpenTofu
choco install terraform           # Windows
scoop install terraform
# or: choco install opentofu / scoop install opentofu

# TFLint (Terraform linter)
choco install tflint

# Trivy (IaC security scanner)
choco install trivy

# Checkov (policy-as-code scanner)
pip install checkov

# pre-commit-terraform
pip install pre-commit
# then: pre-commit install

# terraform-docs
choco install terraform-docs

# CDK (AWS)
npm install -g aws-cdk
npm install --save-dev cdk-nag

# Pulumi
choco install pulumi

# Pulumi ESC
pulumi plugin install resource esc
```

**References:**
- [Terraform Best Practices](https://terraform-best-practices.com)
- [terraform-aws-modules](https://github.com/terraform-aws-modules)
- [AWS CDK Patterns](https://github.com/cdklabs/cdk-patterns)
- [Pulumi ESC Documentation](https://www.pulumi.com/docs/esc/)
