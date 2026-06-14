# Secrets Management Methodology — Best Practices

## Design Principles

1. **Never hardcode secrets** — No API keys, passwords, tokens, or certificates in source code, config files committed to git, or environment variables in documentation.
2. **Centralize and standardize** — All secrets in a single secrets management solution per environment (Vault, AWS Secrets Manager, GCP Secret Manager, Azure Key Vault). No ad hoc storage.
3. **Least privilege access** — Every user and service gets only the secrets they need, for only as long as they need them. No blanket access.
4. **Dynamic over static** — Prefer dynamic (short-lived, generated-on-demand) secrets over static (long-lived) secrets wherever possible.
5. **Automate lifecycle** — Secret creation, rotation, revocation, and expiration should all be automated. Manual secret management is a security risk.

## When to Apply

- During initial project scaffolding (before writing any code)
- When configuring CI/CD pipelines
- When setting up database connections, API integrations, or third-party services
- When reviewing code for compliance (SOC 2, PCI-DSS, HIPAA all require secrets management)
- When onboarding new team members
- During incident response (secret rotation after compromise)

## Process

### Phase 1: Secret Inventory

Identify every secret in the system:

| Secret Type | Where It's Used | Current Storage | Risk |
|-------------|-----------------|-----------------|------|
| Database passwords | App → DB connection | [env vars / config file / vault] | HIGH |
| API keys | App → external service | [source code / .env / vault] | HIGH |
| JWT signing keys | Auth service | [code constant / file / vault] | CRITICAL |
| SSL/TLS private keys | Web server, API gateway | [file system / cert manager] | CRITICAL |
| SSH keys | Deployment, server access | [agent / file / vault] | HIGH |
| OAuth client secrets | OAuth flows | [env vars / vault] | MEDIUM |
| Encryption keys | Data at rest encryption | [env vars / HSM / vault] | CRITICAL |
| Service account tokens | Service-to-service auth | [file / env vars] | HIGH |

**Scan for hardcoded secrets:**
```bash
# Scan current codebase
gitleaks detect -v

# Scan git history
gitleaks detect --no-git -v
trufflehog3 --rules trufflehog3-rules.yaml .

# Search for common patterns
grep -rn "password\s*=\|secret\s*=\|api_key\s*=\|token\s*=" \
  --include="*.py" --include="*.js" --include="*.ts" \
  --include="*.go" --include="*.rs" --include="*.java" \
  --include="*.yaml" --include="*.yml" --include="*.env*" | \
  grep -vi "example\|placeholder\|changeme\|your-"
```

### Phase 2: Choose a Secrets Store

Select the appropriate secrets store for the environment:

| Solution | Best For | Commands |
|----------|----------|----------|
| **HashiCorp Vault** | Multi-cloud, self-hosted, advanced policies | `winget install vault` |
| **AWS Secrets Manager** | AWS-native, automatic rotation | Use AWS Console/CLI/SDK |
| **GCP Secret Manager** | GCP-native, automatic rotation | Use GCP Console/gcloud/SDK |
| **Azure Key Vault** | Azure-native, HSM-backed | Use Azure Portal/CLI/SDK |
| **1Password/LastPass** | Team access to shared credentials | Use browser extension |
| **Bitwarden** | Open-source password manager | Use Bitwarden CLI |

**For an AI coding agent:** Default to cloud-native secret manager matching the deployment environment. For local development, use `.env` files (gitignored) or a local Vault dev server.

### Phase 3: Secret Storage Implementation

**Step 3a: Store secrets properly:**

```bash
# HashiCorp Vault
vault kv put secret/myapp/database username=dbuser password=$(openssl rand -base64 32)
vault kv get secret/myapp/database

# AWS Secrets Manager
aws secretsmanager create-secret \
  --name myapp/database \
  --secret-string '{"username":"dbuser","password":"xxx"}'

# GCP Secret Manager
gcloud secrets create myapp-database --replication-policy="automatic"
echo -n "dbpassword" | gcloud secrets versions add myapp-database --data-file=-

# Azure Key Vault
az keyvault secret set --vault-name myvault --name "database-password" --value "xxx"
```

**Step 3b: Retrieve secrets at runtime (never at build time):**

```python
# CORRECT: Retrieve at runtime from secrets manager
import boto3
def get_db_password():
    client = boto3.client('secretsmanager')
    response = client.get_secret_value(SecretId='myapp/database')
    return json.loads(response['SecretString'])['password']

# CORRECT: Use Vault sidecar pattern (Kubernetes)
# Sidecar container fetches secrets, mounts to shared volume
# Application reads from /mnt/secrets/db_password

# WRONG: Environment variables at build time
# DON'T: ENV DATABASE_PASSWORD=xxx in Dockerfile
# DON'T: secrets in CI/CD pipeline variables that are persisted
```

**Step 3c: CI/CD secrets injection:**

```yaml
# GitHub Actions — CORRECT pattern
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Configure AWS credentials (OIDC)
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: arn:aws:iam::123456:role/github-actions
          aws-region: us-east-1
      - name: Fetch secrets from secrets manager
        run: |
          DB_PASSWORD=$(aws secretsmanager get-secret-value \
            --secret-id myapp/database \
            --query SecretString --output text | jq -r '.password')
          echo "DB_PASSWORD=$DB_PASSWORD" >> $GITHUB_ENV
```

### Phase 4: OIDC for Keyless Authentication

Replace long-lived credentials with OIDC-based keyless auth:

**How OIDC works for workload authentication:**
1. CI/CD or workload requests a token from its identity provider (GitHub, AWS, GCP, Azure)
2. The provider issues a signed JWT containing claims about the caller (repo, environment, branch)
3. The workload uses this token to authenticate to the target service (cloud provider, Vault)
4. No long-lived secrets to store or rotate

**GitHub Actions → AWS (OIDC):**
```yaml
# Step 1: Configure AWS as OIDC provider in GitHub (one-time setup)
# Step 2: Create IAM role with trust policy for GitHub
# Step 3: Use in workflow:
jobs:
  deploy:
    permissions:
      id-token: write  # Required for OIDC
      contents: read
    steps:
      - uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: arn:aws:iam::123456:role/github-actions
          aws-region: us-east-1
      # Now using temporary AWS credentials — no secrets needed
      - run: aws sts get-caller-identity
```

**GitHub Actions → Vault (OIDC):**
```yaml
# Step 1: Configure Vault JWT/OIDC auth with GitHub's OIDC provider
# Step 2: Create Vault role mapping GitHub org/repo to Vault policies
# Step 3: Use in workflow:
jobs:
  deploy:
    permissions:
      id-token: write
      contents: read
    steps:
      - uses: hashicorp/vault-action@v3
        with:
          url: https://vault.example.com
          role: myapp-ci
          method: jwt
          secrets: |
            secret/data/myapp/database db_password | DB_PASSWORD
```

### Phase 5: Secret Lifecycle Automation

**Automatic rotation patterns:**

```python
# AWS Secrets Manager rotation (Lambda function)
def rotate_secret(secret_name, token, step):
    """Automatically rotate database credentials."""
    client = boto3.client('secretsmanager')
    if step == 'createSecret':
        new_password = secrets.token_urlsafe(32)
        client.put_secret_value(
            SecretId=secret_name,
            ClientRequestToken=token,
            SecretString=json.dumps({
                'username': 'dbuser',
                'password': new_password
            }),
            VersionStages=['AWSPENDING']
        )
    elif step == 'setSecret':
        # Update database with new password
        update_db_password(new_password)
    elif step == 'testSecret':
        # Test the new password works
        test_db_connection(new_password)
    elif step == 'finishSecret':
        client.update_secret_version_stage(
            SecretId=secret_name,
            VersionStage='AWSCURRENT',
            RemoveFromVersionId=old_version
        )
```

**Rotation schedule:**
| Secret Type | Recommended Rotation |
|-------------|---------------------|
| Database passwords | 90 days (or dynamic per-session) |
| API keys | 90 days |
| JWT signing keys | 180 days |
| TLS certificates | 90 days (automated via ACME) |
| SSH keys | 180 days |
| Root/Admin keys | 30 days |
| OAuth secrets | As needed or 90 days |

### Phase 6: Detection and Incident Response

**Detect leaked secrets:**
```bash
# Pre-commit hook to prevent secrets in git
# Install: https://pre-commit.com/
# .pre-commit-config.yaml:
#   - repo: https://github.com/gitleaks/gitleaks
#     rev: v8.16.0
#     hooks:
#     - id: gitleaks

# CI/CD scanning
# In GitHub Actions:
#   - uses: gitleaks/gitleaks-action@v2

# Periodic scanning of git history
gitleaks detect --source . -v

# Monitor for exposed secrets on GitHub
# Use: GitHub secret scanning (enabled by default for public repos)
```

**Incident response for leaked secrets:**
1. **Immediate** — Revoke the compromised secret
2. **Investigate** — Check audit logs for unauthorized access using the secret
3. **Rotate** — Generate a new secret and update all consumers
4. **Analyze** — Determine how the leak happened
5. **Prevent** — Implement control to prevent recurrence (pre-commit hooks, scanning, policy)
6. **Document** — Incident report for compliance evidence

## Anti-patterns

- **Secrets in environment variables** — `env` output is visible to all processes, logged in CI/CD outputs, and leaked in crash reports. Use a secrets manager.
- **One secret for multiple services** — A shared secret between services means a compromise of one service compromises all. Use service-specific secrets.
- **Long-lived secrets without rotation** — The longer a secret lives, the more likely it is to leak. Rotate on a schedule.
- **Checking in .env files** — Add `.env` to `.gitignore`. Use `.env.example` with placeholder values for documentation.
- **Secrets in Docker images** — Secrets baked into images persist in layers and registries. Inject at runtime.
- **Build-time secret injection** — Secrets fetched during CI/CD build persist in build artifacts. Fetch at runtime.
- **Logging secrets** — Ensure logging frameworks redact sensitive fields. Test with regex-based scanners.
- **Hardcoded fallback secrets** — Code like `password = os.getenv('DB_PASSWORD', 'default_password')` creates a fallback path that bypasses the secrets manager.

## Tools with Install Commands

```bash
# GitLeaks — secrets scanning in git
winget install gitleaks
gitleaks detect -v

# TruffleHog — deep git history scanning
pip install truffleHog
trufflehog --regex --entropy=False https://github.com/org/repo.git

# HashiCorp Vault
winget install vault
vault server -dev  # local dev only

# AWS CLI (for Secrets Manager)
winget install awscli
aws secretsmanager list-secrets

# pre-commit hooks (secrets prevention)
pip install pre-commit
pre-commit install

# detect-secrets (Yelp)
pip install detect-secrets
detect-secrets scan > .secrets.baseline

# OWASP Secrets Management Cheat Sheet
# https://cheatsheetseries.owasp.org/cheatsheets/Secrets_Management_Cheat_Sheet.html
```
