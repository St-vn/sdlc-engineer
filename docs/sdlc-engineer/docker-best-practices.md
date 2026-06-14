# Docker & Containerization — Best Practices Methodology

## Design Principles

1. **Ephemeral containers** — Containers must be stop-and-destroy safe, rebuildable with zero setup. Stateless by default; state goes in volumes or backing services.
2. **Single concern** — One container, one responsibility. Decouple your app into web, worker, cache, and database containers.
3. **Minimal attack surface** — Smallest possible base image, no unnecessary packages, non-root user, read-only filesystem where possible.
4. **Immutable image tags** — Pin base image versions (preferably by digest) in production. Rebuild and redeploy — never patch a running container.
5. **Shift security left** — Scan images in CI/CD before they reach a registry or production environment.

## When to Apply

- Any application that needs consistent behavior across dev/staging/prod
- Microservices or service-oriented architectures
- CI/CD pipeline artifacts and deployment units
- Any tech stack where dependency management differs between environments

## Process

### 1. Base Image Selection

```
Priority order:
  1. Docker Official Images (most trusted, regularly patched)
  2. Verified Publisher images
  3. Docker-Sponsored Open Source images
  4. Custom minimal images (distroless, scratch)

Size recommendation: Alpine (~6 MB) for minimal, distroless for production Go/Java/Node
```

Use two base images: one for build (full toolchain) and one for production (slim, no build tools).

### 2. Dockerfile Construction

**Multi-stage builds (always):**
```dockerfile
# syntax=docker/dockerfile:1
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
RUN npm run build

FROM node:20-alpine
RUN addgroup -g 1001 app && adduser -u 1001 -G app -s /bin/sh -D app
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
USER app
EXPOSE 3000
CMD ["node", "dist/index.js"]
```

**Key instructions checklists:**

| Instruction | Rule |
|-------------|------|
| `FROM` | Use official images, pin tag+digest: `alpine:3.21@sha256:abc...` |
| `RUN` | Combine `apt-get update` with `install` in same RUN, clean cache (`rm -rf /var/lib/apt/lists/*`) |
| `COPY` | Prefer over `ADD` unless downloading remote artifacts with checksum verification |
| `ADD` | Only for remote URLs + archive extraction with `--checksum` |
| `CMD` | Use exec form: `CMD ["executable", "param1"]` |
| `ENTRYPOINT` | Set main command, use `CMD` as default flags |
| `USER` | Always switch to non-root before `CMD` |
| `WORKDIR` | Use absolute paths |
| `EXPOSE` | Document the port, document the protocol |
| `LABEL` | Add version, maintainer, and licensing metadata |

**Sort multi-line arguments** alphanumerically:
```dockerfile
RUN apt-get update && apt-get install -y --no-install-recommends \
  bzr \
  cvs \
  git \
  mercurial \
  subversion \
  && rm -rf /var/lib/apt/lists/*
```

### 3. .dockerignore

```gitignore
**/.git
**/node_modules
**/.env
**/Dockerfile
**/README.md
**/.dockerignore
.dist/
*.md
coverage/
tests/
.git/
```

### 4. Build Pipeline

```bash
# CI build commands
docker build --pull --no-cache -t myapp:${CI_COMMIT_SHA} .
docker scout quickview myapp:${CI_COMMIT_SHA}
docker scout cves myapp:${CI_COMMIT_SHA} --only-severity critical,high
trivy image myapp:${CI_COMMIT_SHA}

# Only push if scans pass
docker tag myapp:${CI_COMMIT_SHA} myapp:latest
docker push myapp:${CI_COMMIT_SHA}
```

### 5. Container Security (OWASP Rules)

| # | Rule | Enforcement |
|---|------|-------------|
| 0 | Keep host and Docker up to date | Schedule regular updates, monitor CVEs |
| 1 | Do NOT expose `/var/run/docker.sock` | Audit all volume mounts in CI |
| 2 | Set a non-root user | `USER app` in Dockerfile |
| 3 | Drop all capabilities, add only needed | `docker run --cap-drop all --cap-add CHOWN` |
| 4 | Prevent privilege escalation | `--security-opt=no-new-privileges` |
| 5 | Limit inter-container connectivity | Use custom networks, not default `docker0` bridge |
| 6 | Use seccomp/AppArmor/SELinux | Start with Docker's default profile, customize per workload |
| 7 | Limit resources | `--memory`, `--cpus`, `--ulimit nofile`, `--restart=on-failure:N` |
| 8 | Set filesystem to read-only | `--read-only --tmpfs /tmp` |
| 9 | Scan in CI/CD | Trivy, Grype, Docker Scout, Snyk |
| 10 | Keep daemon logging at `info` level | Not `debug` unless troubleshooting |
| 11 | Run Docker in rootless mode | `dockerd-rootless-setuptool.sh install` |
| 12 | Use Docker Secrets | `docker secret create` for production |
| 13 | Supply chain security | SBOM, image signing, trusted registry, SLSA provenance |

### 6. Runtime Configuration

```bash
# Minimal secure run command
docker run -d \
  --name myapp \
  --read-only \
  --tmpfs /tmp:noexec,nosuid,size=64M \
  --tmpfs /var/run:noexec,nosuid \
  --cap-drop ALL \
  --cap-add NET_BIND_SERVICE \
  --security-opt=no-new-privileges \
  --memory=256M \
  --cpus=0.5 \
  --pids-limit=100 \
  --restart=on-failure:5 \
  --network=myapp-net \
  myapp:latest
```

### 7. Cache Optimization

```
Order Dockerfile instructions from least-changing to most-changing:
  1. RUN apt-get / package manager updates (pinned versions)
  2. COPY package*.json + RUN npm ci (or pip install)
  3. COPY application code
  4. RUN build step
  5. COPY --from=builder (final stage)
  6. USER, EXPOSE, CMD

Use --mount=type=cache for package managers:
  RUN --mount=type=cache,target=/root/.npm npm ci
```

### 8. CI/CD Integration

```yaml
# GitHub Actions example
jobs:
  build-and-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Build image
        run: docker build --pull -t myapp:${{ github.sha }} .
      - name: Scan with Trivy
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: myapp:${{ github.sha }}
          severity: CRITICAL,HIGH
      - name: Scan with Docker Scout
        run: |
          docker scout cves myapp:${{ github.sha }} \
            --only-severity critical,high \
            --exit-code \
            --ignore-base
```

## Anti-patterns

- **Running as root in container** — if compromised, the attacker has root on the container. Use `USER` directive.
- **Installing unnecessary packages** — each package is an attack surface. No text editors in DB images.
- **Using `latest` tag** — non-reproducible. Always pin to digest or semantic version.
- **Separate `RUN apt-get update` and `RUN apt-get install`** — Docker caches the update layer, resulting in stale package lists.
- **Storing secrets in environment variables at build time** — leaked in image history. Use build args only for non-secret build-time values.
- **Single-stage builds with build tools in production image** — bloated images, CVEs from compiler toolchain.
- **Exposing Docker socket for "management"** — gives root-level host access. Use Docker API with TLS auth if needed.
- **`--privileged` flag** — disables all security isolation. Never use in production.

## Tools with install commands

```bash
# Docker Engine
choco install docker-desktop   # Windows
# or: winget install Docker.DockerDesktop

# Trivy (vulnerability scanner)
choco install trivy

# Grype (vulnerability scanner)
winget install anchore.grype

# Hadolint (Dockerfile linter)
choco install hadolint

# Docker Scout (integrated in Docker Desktop)
# Already included; also: docker scout install

# Dive (image layer inspector)
choco install dive

# Container Structure Test
choco install container-structure-test

# Cosign (image signing)
choco install cosign

# Syft (SBOM generation)
choco install syft

# Docker Bench Security
git clone https://github.com/docker/docker-bench-security.git
cd docker-bench-security && sudo sh docker-bench-security.sh
```

**References:**
- [Dockerfile Best Practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
- [Docker Security (OWASP)](https://cheatsheetseries.owasp.org/cheatsheets/Docker_Security_Cheat_Sheet.html)
- [Docker Security Best Practices](https://docs.docker.com/develop/security-best-practices/)
- [Docker Build Cache](https://docs.docker.com/build/cache/)
