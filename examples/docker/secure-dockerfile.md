# Secure Dockerfile Pattern

CIS Docker Benchmark aligned: non-root, minimal base, pinned by digest in production,
multi-stage, build secrets via `--mount=type=secret`, health check, `.dockerignore` in place.

```dockerfile
# syntax=docker/dockerfile:1

# ---------- Build stage ----------
FROM node:22-bookworm-slim AS build

WORKDIR /app

# Dependencies cached in their own layer (least→most frequently changed).
COPY package.json package-lock.json ./
RUN --mount=type=cache,target=/root/.npm \
    npm ci --ignore-scripts

COPY . .
RUN npm run build

# ---------- Runtime stage ----------
# Pin by digest in production: node:22-bookworm-slim@sha256:<digest>
FROM node:22-bookworm-slim AS runtime

ENV NODE_ENV=production

# Non-root user with fixed UID — never run as root.
RUN groupadd --gid 1001 app && useradd --uid 1001 --gid app --shell /usr/sbin/nologin app

WORKDIR /app
COPY --from=build /app/dist ./dist
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/package.json ./

USER app

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=3s --start-period=10s \
  CMD node -e "fetch('http://localhost:8080/healthz').then(r => process.exit(r.ok ? 0 : 1)).catch(() => process.exit(1))"

CMD ["node", "dist/server.js"]
```

## Build

```bash
# Build-time secrets never land in layers:
docker build --secret id=NPM_TOKEN,src=$HOME/.npmrc -t app:dev .

# Production: pin digest, scan, generate SBOM
trivy image --severity HIGH,CRITICAL app:dev
syft app:dev -o spdx-json > app.sbom.json
```

## Checklist

- [ ] `USER` is non-root
- [ ] No secrets in `ENV`, `ARG`, or layers (`--mount=type=secret` only)
- [ ] Multi-stage; runtime image minimal
- [ ] `HEALTHCHECK` defined
- [ ] `.dockerignore` excludes `.git`, `.env`, tests
- [ ] `hadolint Dockerfile` clean
