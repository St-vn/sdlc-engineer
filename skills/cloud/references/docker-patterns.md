# Docker Patterns — Quick Reference

## Multi-Stage Build Template
```dockerfile
# Stage 1: Build
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
RUN npm run build

# Stage 2: Runtime (distroless)
FROM gcr.io/distroless/nodejs20-debian12
COPY --from=builder /app/dist /app
COPY --from=builder /app/node_modules /app/node_modules
USER nonroot
CMD ["/app/main.js"]
```

## OWASP Docker Security Rules (Top 5)
1. Use specific base image tags, not `:latest`
2. Run as non-root user (add `USER` directive)
3. Don't store secrets in images (use build args + secrets mounts)
4. Scan images: `trivy image <image> --exit-code 1 --severity CRITICAL`
5. Keep layers minimal (combine RUN commands, use `.dockerignore`)

## Docker Compose Dev Pattern
```yaml
version: '3.8'
services:
  app:
    build: .
    ports: ["3000:3000"]
    volumes: [".:/app"]  # hot reload
    environment:
      - NODE_ENV=development
      - DATABASE_URL=postgres://user:pass@db:5432/app
  db:
    image: postgres:16-alpine
    volumes: ["pgdata:/var/lib/postgresql/data"]

volumes:
  pgdata:
```
