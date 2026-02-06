````instructions
---
applyTo: 
  - "Dockerfile"
  - "**/*.yaml"
  - "**/*.yml"
  - "**/ansible/**"
  - "**/*.tf"
  - "**/*.tfvars"
  - "**/*.hcl"
---
<agent_profile>
Role: DevOps Engineer & SRE
Skills: Ansible, Docker, Kubernetes, Linux, Terraform
Focus: Immutable Infrastructure, Security, State Management
</agent_profile>

<quick_reference>
**Critical Rules (TL;DR):**
- **No Root:** Docker `USER` must not be root
- **Pin Versions:** Never use `:latest` tags or unpinned dependencies
- **Remote State:** Terraform MUST use remote state with locking
- **Secrets:** Never commit secrets; use Vault/environment variables
- **Read-Only:** K8s containers: read-only root filesystem
- **Validate First:** Lint before apply (hadolint, tflint, kubeval, ansible-lint)
- **Resource Limits:** Always define CPU/memory limits for containers
</quick_reference>

<security_standards>
**Governing Standards:** CIS Benchmarks (Docker, Kubernetes, AWS/Azure/GCP), NIST SP 800-190 (Container Security), NIST SP 800-204 (Microservices Security). All infrastructure code MUST be reviewed against the applicable benchmark.

**CIS Benchmark Key Controls:**
- **Docker CIS:** Non-root user, read-only root filesystem, no privileged containers, content trust enabled, resource limits, health checks defined.
- **Kubernetes CIS:** Pod security standards (restricted), RBAC least privilege, network policies deny-by-default, etcd encryption, audit logging enabled, admission controllers (OPA/Kyverno).
- **Cloud CIS (AWS/Azure/GCP):** IAM least privilege, MFA on root/admin, encryption at rest and in transit, VPC/network segmentation, logging to central SIEM, no public S3/storage buckets by default.

**Supply Chain Security:**
- Sign container images (cosign/Notary). Verify signatures before deployment.
- Pin base images by SHA digest in production Dockerfiles.
- Use SBOM generation (syft/trivy) for all container images.
- Scan IaC with `checkov`, `tfsec`, or `terrascan` before committing.

1. **Docker:**
   - `USER app` mandatory (never root). Minimal base images (alpine, distroless). Pin specific versions.
   - `trivy image` or `snyk container test` before pushing. Multi-stage builds.
   - Build secrets via `--mount=type=secret`. See [examples/docker/secure-dockerfile.md](../examples/docker/secure-dockerfile.md).

2. **Kubernetes:**
   - Security context: `readOnlyRootFilesystem: true`, `allowPrivilegeEscalation: false`, `runAsNonRoot: true`, `capabilities.drop: ["ALL"]`.
   - Always define `requests` and `limits`. Network policies with deny-by-default. Least-privilege RBAC.
   - Secrets: Sealed Secrets, External Secrets Operator, or native K8s secrets — never in Git.
   - See [examples/kubernetes/secure-deployment.md](../examples/kubernetes/secure-deployment.md).

3. **Ansible:**
   - All playbooks must be idempotent. Ansible Vault for sensitive variables. `become: yes` with documented justification.
   - `--check --diff` before production runs. See [examples/ansible/secure-playbook.md](../examples/ansible/secure-playbook.md).

4. **Terraform:**
   - Remote state (S3+DynamoDB, Azure Blob, TF Cloud) with locking and encryption.
   - Never commit `.tfvars` with secrets — use `TF_VAR_*` env vars or Vault. Mark sensitive outputs.
   - Run `checkov`, `tfsec`, or `terrascan` before committing. See [examples/terraform/secure-config.md](../examples/terraform/secure-config.md).

</security_standards>

<terraform_standards>
- **State Isolation:** Separate state files per environment (dev/stage/prod).
- **Module Structure:** `main.tf`, `variables.tf`, `outputs.tf`, `versions.tf`. Split at >200 lines.
- **Pin Everything:** `required_version` and `required_providers` with version constraints.
- **Protect Stateful Resources:** `lifecycle { prevent_destroy = true }` on databases, storage, KMS keys.
- **Prefer `for_each`** over `count` for resource collections (stable on removal).
- **Use `locals {}`** to simplify complex expressions. Export useful values in `outputs.tf`.
</terraform_standards>

<testing_protocol>
1. **Lint:** `terraform fmt -check && terraform validate`, `hadolint`, `kubeval`/`kubectl --dry-run=server`, `ansible-lint`
2. **Plan/Dry-Run:** `terraform plan -out=tfplan`, `ansible-playbook --check --diff`, `kubectl apply --dry-run=server`
3. **Integration:** Terratest or kitchen-terraform for critical paths (networking, security groups, IAM)
4. **CI Pipeline:** Lint → Plan → Test → Scan → Manual Approval → Apply. See [examples/ci/terraform-pipeline.yml](../examples/ci/terraform-pipeline.yml).
</testing_protocol>

<performance_guidelines>
- **Docker:** Order layers least→most frequently changed. Multi-stage builds reduce image size 50-90%. Enable BuildKit.
- **Kubernetes:** Set requests from actual metrics (VPA). HPA for variable workloads. Pod Disruption Budgets. `imagePullPolicy: IfNotPresent`.
- **Terraform:** `-parallelism=N` for large infra. `-target` during dev. Smaller, focused state files.
- **Ansible:** `gather_facts: no` when unneeded. SSH pipelining for 2-5x speedup. Tune `forks`.
</performance_guidelines>

<common_pitfalls>
1. **Docker:** Separate `apt-get update && install` in one RUN layer. Never store secrets in ENV or layers.
2. **Terraform:** Always `prevent_destroy` on stateful resources. Prefer `for_each` over `count`. Use `data` sources for dynamic values (AMI IDs, AZs).
3. **Kubernetes:** Always set resource limits. Never use `:latest` in production (use SHA digests). Never store secrets in ConfigMaps.
4. **Ansible:** Use native modules (apt, copy) for idempotency — avoid `shell` without `creates`/`changed_when`. Document `become: yes`.

See [examples/ops/pitfalls.md](../examples/ops/pitfalls.md) for detailed examples.
</common_pitfalls>

<architecture_principles>
- **Immutable Infrastructure:** Replace, don't modify. Versioned images, AMI baking (Packer).
- **IaC in Separate Repo:** Different deployment cadence and access controls from app code.
- **Environment Parity:** Dev/staging/production identical in topology, parameterized by variables.
- **Declarative Over Imperative:** Prefer Terraform/K8s manifests over shell scripts.
- **GitOps:** All infra changes through Git PRs. ArgoCD or Flux for continuous deployment.
</architecture_principles>
````
