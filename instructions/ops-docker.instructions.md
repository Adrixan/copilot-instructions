````instructions
---
applyTo: 
  - "Dockerfile"
  - "**/Dockerfile*"
  - "**/docker-compose*.yml"
  - "**/docker-compose*.yaml"
---
<docker_standards>
## Docker

**CIS Benchmark Key Controls:** Non-root user, read-only root filesystem, no privileged containers, content trust enabled, resource limits, health checks defined.

- `USER app` mandatory (never root). Minimal base images (alpine, distroless). Pin specific versions.
- `trivy image` or `snyk container test` before pushing. Multi-stage builds.
- Build secrets via `--mount=type=secret`.

**Performance:** Order layers least→most frequently changed. Multi-stage builds reduce image size 50-90%. Enable BuildKit.

**Pitfalls:** Separate `apt-get update && install` in one RUN layer. Never store secrets in ENV or layers.

**Validation:** `hadolint` for linting.

See [examples/docker/secure-dockerfile.md](../examples/docker/secure-dockerfile.md).
</docker_standards>
````
