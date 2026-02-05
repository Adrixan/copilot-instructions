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
Examples: See examples/docker/, examples/terraform/, examples/kubernetes/, examples/ansible/
</agent_profile>

<quick_reference>
**Critical Rules (TL;DR):**
- **No Root:** Docker USER must not be root
- **Pin Versions:** Never use `:latest` tags or unpinned dependencies
- **Remote State:** Terraform MUST use remote state with locking
- **Secrets:** Never commit secrets; use Vault/environment variables
- **Read-Only:** K8s containers should have read-only root filesystem
- **Test First:** Validate/lint before apply (TDD for infrastructure)
- **Resource Limits:** Always define CPU/memory limits for containers
</quick_reference>

<security_standards>
**MANDATORY SECURITY GATES:**

1. **Docker:**
   - **Non-Root User:** `USER app` is mandatory (never run as root).
   - **Base Image Security:** 
     - Pin specific versions (e.g., `python:3.11.7-slim`, NOT `:latest`).
     - Use minimal base images (alpine, distroless) when possible.
     - Update base images monthly for security patches.
   - **Scanning:** Run `trivy image` or `snyk container test` before pushing.
   - **Multi-Stage Builds:** Separate build and runtime dependencies.
   - **Secrets:** Use build secrets (`--mount=type=secret`) for build-time credentials.
   - **Examples:** See examples/docker/secure-dockerfile.md

2. **Kubernetes:**
   - **Security Context:**
     - `readOnlyRootFilesystem: true` (use emptyDir volumes for temp files).
     - `allowPrivilegeEscalation: false`
     - `runAsNonRoot: true`
     - `capabilities.drop: ["ALL"]`
   - **Resource Management:** Always define `requests` and `limits` for CPU and memory.
   - **Network Policies:** Define explicit ingress/egress rules (deny-by-default).
   - **RBAC:** Use least-privilege service accounts; avoid `cluster-admin`.
   - **Secrets:** Use Sealed Secrets, External Secrets Operator, or native K8s secrets (never in Git).
   - **Examples:** See examples/kubernetes/secure-deployment.md

3. **Ansible:**
   - **Idempotency:** Every playbook must be safely re-runnable without side effects.
   - **Secrets Management:** 
     - Use Ansible Vault for sensitive variables: `ansible-vault encrypt_string`.
     - Never commit unencrypted credentials.
   - **Privilege Escalation:** Use `become: yes` explicitly; document why sudo is needed.
   - **Validation:** Use `--check` and `--diff` flags before production runs.
   - **Examples:** See examples/ansible/secure-playbook.md

4. **Terraform:**
   - **State Security:**
     - ALWAYS configure remote state (S3+DynamoDB, Azure Blob, Terraform Cloud).
     - Enable state locking to prevent concurrent modifications.
     - Encrypt state at rest (S3: `server_side_encryption_configuration`).
   - **Secrets Management:**
     - NEVER commit `.tfvars` containing secrets.
     - Use environment variables (`TF_VAR_name`) or HashiCorp Vault.
     - Mark sensitive outputs: `sensitive = true`.
   - **Scanning:** Run `checkov`, `tfsec`, or `terrascan` before committing.
   - **Examples:** See examples/terraform/secure-config.md
</security_standards>

<terraform_standards>
**Terraform-Specific Best Practices:**

1. **State Management:**
   - **Remote State:** Configure backend with locking (S3+DynamoDB, Azure Blob, TF Cloud).
   - **State Isolation:** Separate state files per environment (dev/stage/prod).
   - **State Import:** Document how to import existing resources.
   - **Rationale:** Local state files cause conflicts, lack auditing, and risk data loss.

2. **Modularity:**
   - **Standard Module Structure:** Use `main.tf`, `variables.tf`, `outputs.tf`, `versions.tf`.
   - **Refactoring Threshold:** If a module exceeds 200 lines, split into child modules.
   - **Module Versioning:** Pin module sources to specific versions/tags.
   - **Examples:** See examples/terraform/module-structure/

3. **Versioning & Dependencies:**
   - **Pin Everything:** 
     ```hcl
     terraform {
       required_version = ">= 1.5.0, < 2.0.0"
       required_providers {
         aws = {
           source  = "hashicorp/aws"
           version = "~> 5.0"
         }
       }
     }
     ```
   - **Why:** Prevents breaking changes from upstream provider updates.

4. **Resource Lifecycle:**
   - **Protect Stateful Resources:**
     ```hcl
     lifecycle {
       prevent_destroy = true
     }
     ```
     Apply to databases, storage buckets, KMS keys.
   - **Ignore Changes:** Use `ignore_changes` for externally managed attributes.

5. **Naming & Organization:**
   - **Convention:** Use `snake_case` for all resource names.
   - **Outputs:** Export all useful values (IPs, DNS names, ARNs) in `outputs.tf`.
   - **Locals:** Use `locals {}` to simplify complex expressions and avoid repetition.

6. **Documentation:**
   - **README:** Every module must have a README with usage examples.
   - **Variable Descriptions:** All `variable` blocks must have meaningful descriptions.
   - **Comments:** Document non-obvious design decisions.
</terraform_standards>

<testing_protocol>
**TDD for Infrastructure (MANDATORY):**

1. **Phase 1: Lint (Red)**
   - **Terraform:** `terraform fmt -check && terraform validate`
   - **Docker:** `hadolint Dockerfile`
   - **Kubernetes:** `kubeval` or `kubectl --dry-run=server`
   - **Ansible:** `ansible-lint playbook.yml`

2. **Phase 2: Plan/Dry-Run (Green)**
   - **Terraform:** `terraform plan -out=tfplan` → Review manually or with policy-as-code (OPA/Sentinel).
   - **Ansible:** `ansible-playbook --check --diff playbook.yml`
   - **Kubernetes:** `kubectl apply --dry-run=server -f manifest.yaml`

3. **Phase 3: Automated Testing (Refactor)**
   - **Terraform:** Use **Terratest** (Go) or **kitchen-terraform** for integration tests.
   - **Example:** Verify that provisioned infrastructure is reachable and configured correctly.
   - **Docker:** Test container startup, exposed ports, and health checks.
   - **Coverage Goal:** Critical paths (networking, security groups, IAM) must have integration tests.

4. **Continuous Testing:**
   - **Pre-commit Hooks:** Run linters automatically (`pre-commit` framework).
   - **CI Pipeline:** Lint → Plan → Test → Scan → Manual Approval → Apply.
   - **Examples:** See examples/ci/terraform-pipeline.yml
</testing_protocol>

<performance_guidelines>
**Optimization & Efficiency:**

1. **Docker:**
   - **Layer Caching:** Order Dockerfile commands from least to most frequently changed.
   - **Multi-Stage Builds:** Reduce final image size by 50-90%.
   - **Example:** Build artifacts in stage 1, copy only runtime files to stage 2.
   - **BuildKit:** Enable `DOCKER_BUILDKIT=1` for parallel builds and advanced caching.

2. **Kubernetes:**
   - **Resource Requests:** Set requests based on actual usage (use metrics/VPA).
   - **Autoscaling:** Implement HPA (Horizontal Pod Autoscaler) for variable workloads.
   - **Pod Disruption Budgets:** Ensure availability during node maintenance.
   - **Image Pull Policy:** Use `IfNotPresent` to avoid redundant registry pulls.

3. **Terraform:**
   - **Parallelism:** Use `-parallelism=N` flag for large infrastructures (default: 10).
   - **Target Specific Resources:** Use `-target` during development to speed up iterations.
   - **State Management:** Use smaller, focused state files (per service/module).
   - **Remote State Caching:** Terraform Cloud/Enterprise provides state caching.

4. **Ansible:**
   - **Fact Gathering:** Disable when not needed: `gather_facts: no`.
   - **Pipelining:** Enable SSH pipelining in `ansible.cfg` for 2-5x speedup.
   - **Parallelism:** Tune `forks` parameter (default: 5) based on target capacity.
   - **Change Detection:** Use `changed_when` to avoid unnecessary handler triggers.
</performance_guidelines>

<common_pitfalls>
**Frequent Mistakes & How to Avoid Them:**

1. **Docker:**
   - ❌ **Mistake:** `RUN apt-get update && apt-get install -y package` in separate layers.
   - ✅ **Fix:** Chain commands in one RUN to avoid cache invalidation issues.
   - ❌ **Mistake:** Storing secrets in ENV variables or layers.
   - ✅ **Fix:** Use Docker secrets or multi-stage builds to exclude secrets from final image.

2. **Terraform:**
   - ❌ **Mistake:** Modifying stateful resources (databases) without `lifecycle { prevent_destroy = true }`.
   - ✅ **Fix:** Always protect critical infrastructure with lifecycle policies.
   - ❌ **Mistake:** Using `count` when `for_each` is more appropriate.
   - ✅ **Fix:** Prefer `for_each` for resource collections (allows removal without re-indexing).
   - ❌ **Mistake:** Hardcoding values instead of using `data` sources or variables.
   - ✅ **Fix:** Fetch dynamic values (AMI IDs, availability zones) via data sources.

3. **Kubernetes:**
   - ❌ **Mistake:** No resource limits → OOMKilled or node exhaustion.
   - ✅ **Fix:** Always define `resources.limits` and `resources.requests`.
   - ❌ **Mistake:** Using `latest` tag in production.
   - ✅ **Fix:** Use specific image tags or SHA256 digests.
   - ❌ **Mistake:** Secrets stored in ConfigMaps (unencrypted).
   - ✅ **Fix:** Use Secrets (base64, but better than plain ConfigMap) or external secret management.

4. **Ansible:**
   - ❌ **Mistake:** Non-idempotent tasks (e.g., `shell` without `creates` or `changed_when`).
   - ✅ **Fix:** Use native modules (e.g., `apt`, `yum`, `copy`) which are idempotent by default.
   - ❌ **Mistake:** Commands with sudo without explicit documentation.
   - ✅ **Fix:** Use `become: yes` with a comment explaining why privilege escalation is needed.

**Examples:** See examples/ops/pitfalls.md for detailed code examples.
</common_pitfalls>

<architecture_principles>
**Foundational Design Decisions:**

1. **Immutable Infrastructure:**
   - Never modify infrastructure in place; replace it.
   - Use versioned container images and AMI baking (Packer).

2. **Infrastructure as Code Repository:**
   - Separate IaC from application code (different repos).
   - **Rationale:** Different deployment cadences, access controls, and review processes.

3. **Environment Parity:**
   - Dev, staging, and production should be identical in topology.
   - Use variables/tfvars to parameterize environment differences.

4. **Declarative Over Imperative:**
   - Prefer Terraform/Kubernetes manifests over shell scripts.
   - **Why:** Declarative configs are idempotent, self-documenting, and easier to test.

5. **Gitops Workflow:**
   - Infrastructure changes MUST go through Git (pull requests, reviews).
   - Use tools like ArgoCD or Flux for continuous deployment.
</architecture_principles>

