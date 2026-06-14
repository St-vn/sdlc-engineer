# IaC Patterns — Quick Reference

## Tool Selection
| Tool | Best For | State | Language |
|------|----------|-------|----------|
| Terraform/OpenTofu | Multi-cloud, any provider | Remote (S3/DynamoDB) | HCL |
| AWS CDK | AWS-only, TypeScript teams | S3 + DynamoDB | TypeScript/Python/C# |
| Pulumi | Multi-cloud, general-purpose teams | S3/GCS/Azure Storage | TypeScript/Python/Go |

## Terraform Module Structure
```
modules/
  networking/    (VPC, subnets, security groups)
  database/      (RDS, replica, backups)
  compute/       (ECS/Fargate, auto-scaling)
  ci-cd/         (CodePipeline, GitHub Actions OIDC)
```

## Testing Matrix
| Test type | Terraform | CDK | Pulumi |
|-----------|-----------|-----|--------|
| Syntax | terraform validate | cdk synth | pulumi preview |
| Policy | Checkov, Sentinel | cdk-nag | Policy as Code |
| Integration | Terratest | integ-runner | pulumi up --dry-run |
| Security | Trivy, tfsec | cdk-nag | Trivy |

## State Management
1. Enable state locking (DynamoDB for Terraform)
2. Never store state locally
3. Encrypt state at rest
4. Restrict state access via IAM policies
5. Workspaces for environment separation
