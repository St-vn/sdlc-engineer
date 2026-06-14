# Deployment Strategies — Quick Reference

## Strategy Selection Matrix
| | Recreate | Rolling | Blue-Green | Canary | Shadow |
|---|---|---|---|---|---|
| Zero downtime | ❌ | ✅ | ✅ | ✅ | ✅ |
| Quick rollback | ✅ | ❌ | ✅ | ✅ | ✅ |
| Production traffic test | ❌ | ❌ | ❌ | Partial | ✅ |
| Complexity | Low | Medium | Medium | High | Very High |
| Cost | Lowest | Low | 2x infra | 2x infra | 2x infra |

## When to Use
- **Recreate**: Dev deployments, staging, non-critical services
- **Rolling**: MVP production, low-traffic services
- **Blue-Green**: Production services, compliance-sensitive apps
- **Canary**: High-traffic production, ML model deployments
- **Shadow**: Experimental features, migration validation

## 12-Factor App Checklist
- [ ] Codebase: one codebase tracked in revision control
- [ ] Dependencies: explicitly declared and isolated
- [ ] Config: stored in environment variables
- [ ] Backing services: treated as attached resources
- [ ] Build, release, run: strictly separated stages
- [ ] Processes: stateless and share-nothing
- [ ] Port binding: export services via port binding
- [ ] Concurrency: scale out via process model
- [ ] Disposability: fast startup and graceful shutdown
- [ ] Dev/prod parity: keep dev, staging, prod as similar as possible
- [ ] Logs: treat logs as event streams
- [ ] Admin processes: run admin/maintenance tasks as one-off processes
