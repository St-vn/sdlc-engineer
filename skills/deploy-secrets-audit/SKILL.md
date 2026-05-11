---
name: deploy-secrets-audit
description: Scans for exposed credentials in source code, config files, and git history, and produces an extraction plan. Use when the user asks about "secrets management", "credential security", "are my secrets safe", "API keys in code", "environment variables setup", or when /implement reaches this step. The output is a scan report (what was found) and an extraction plan (how to fix it). Note: actual git history scanning requires running tools (gitleaks, truffleHog, git-secrets) on the repository — this skill produces the plan and commands, not the scan itself.
---

# /deploy-secrets-audit — credential exposure scan

Identifies exposed credentials and produces an extraction plan. Credential exposure is the most common and most costly deployment security failure — easier to prevent than to recover from (leaked credentials require rotation, not just deletion).

## What counts as a secret

- API keys and tokens (third-party services, cloud providers)
- Database connection strings with passwords
- OAuth client secrets
- Private keys (RSA, EC, SSH)
- JWT signing secrets
- Encryption keys
- Webhook secrets
- SMTP credentials
- Any value with a pattern like `sk-`, `pk-`, `ghp_`, `AKIA`, `Bearer `, `password=`, `secret=`

## Scan procedure

### Manual review checklist (immediate, no tools required)

Go through these locations and flag any secrets found:

```
Files to check:
  .env, .env.local, .env.production, .env.development
  config/*.json, config/*.yaml, config/*.toml
  docker-compose.yml, docker-compose.prod.yml
  *.tf, *.tfvars (Terraform)
  k8s/*.yaml, helm/values*.yaml
  CI/CD config (.github/workflows/*.yml, .gitlab-ci.yml)
  README.md, CHANGELOG.md (sometimes contain example keys that are real)
  Source code: any hardcoded strings matching secret patterns

Git history to check:
  Run: git log --all --full-history -- .env
  Run: gitleaks detect --source . --verbose
  Run: truffleHog git file://.
```

### Automated scan tools (recommend the user run these)

```bash
# gitleaks (recommended — finds secrets in history too)
brew install gitleaks
gitleaks detect --source . --verbose --report-path gitleaks-report.json

# truffleHog (deep git history scan)
pip install truffleHog
trufflehog git file://.

# git-secrets (pre-commit hook approach)
brew install git-secrets
git secrets --install
git secrets --scan-history
```

## Extraction plan

For each secret found:

### Immediate steps
1. **Rotate the credential** — before removing from code. The credential is compromised the moment it touched a repo, even if pushed and immediately reverted. Assume it was scraped.
2. **Remove from current code** — move to environment variable
3. **Purge from git history** — `git filter-repo` or BFG Repo-Cleaner

### Git history purge

```bash
# Using BFG Repo-Cleaner (simpler)
java -jar bfg.jar --replace-text secrets-to-remove.txt my-repo.git
cd my-repo.git && git reflog expire --expire=now --all && git gc --prune=now --aggressive
git push --force

# Force-push required; all team members must re-clone
```

### Secret management by tier

| Tier | Secret management approach |
| :--- | :--- |
| Hackathon | `.env` file on the server (not in git); `.env.example` with placeholder values in git |
| MVP | Platform secrets (Vercel env vars, Railway env, Fly.io secrets, Render env groups) |
| Scaling | Dedicated secret manager: AWS Secrets Manager, HashiCorp Vault, or Doppler; RBAC on who can read each secret; audit log of secret access |

## Output format

```markdown
## Secrets Audit Report

### Scan coverage
- [ ] Source code reviewed
- [ ] Config files reviewed
- [ ] CI/CD config reviewed
- [ ] Git history scanned (tool: [gitleaks / truffleHog / pending])

### Findings

| Location | Secret type | Status | Action required |
| :--- | :--- | :--- | :--- |
| [file/commit] | [type] | 🔴 Exposed / ✅ Clean | [Rotate + purge / None] |

### Extraction plan
[Per-secret: rotate → remove → purge history → verify]

### Prevention: .gitignore additions
\`\`\`
.env
.env.*
!.env.example
*.pem
*.key
*.p12
\`\`\`

### Prevention: pre-commit hook
[gitleaks pre-commit hook setup instructions]
```

After audit: recommend `/deploy-cicd` if pipeline wasn't already set up, to add secrets scanning as a CI gate.
