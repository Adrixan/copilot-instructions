````instructions
---
applyTo: 
  - "**/*.tf"
  - "**/*.tfvars"
  - "**/*.hcl"
---
<terraform_standards>
## Terraform

**Cloud CIS Controls:** IAM least privilege, MFA on root/admin, encryption at rest and in transit, VPC/network segmentation, logging to central SIEM, no public S3/storage buckets by default.

- Remote state (S3+DynamoDB, Azure Blob, TF Cloud) with locking and encryption.
- Never commit `.tfvars` with secrets — use `TF_VAR_*` env vars or Vault. Mark sensitive outputs.
- Run `checkov`, `tfsec`, or `terrascan` before committing.

**Module Structure:** `main.tf`, `variables.tf`, `outputs.tf`, `versions.tf`. Split at >200 lines.
- **State Isolation:** Separate state files per environment (dev/stage/prod).
- **Pin Everything:** `required_version` and `required_providers` with version constraints.
- **Protect Stateful Resources:** `lifecycle { prevent_destroy = true }` on databases, storage, KMS keys.
- **Prefer `for_each`** over `count` for resource collections (stable on removal).
- **Use `locals {}`** to simplify complex expressions. Export useful values in `outputs.tf`.

**Performance:** `-parallelism=N` for large infra. `-target` during dev. Smaller, focused state files.

**Pitfalls:** Always `prevent_destroy` on stateful resources. Prefer `for_each` over `count`. Use `data` sources for dynamic values (AMI IDs, AZs).

**Validation:** `terraform fmt -check && terraform validate`, `tflint`.
**CI Pipeline:** Lint → Plan → Test → Scan → Manual Approval → Apply. See [examples/ci/terraform-pipeline.yml](../examples/ci/terraform-pipeline.yml).
**Integration Testing:** Terratest or kitchen-terraform for critical paths (networking, security groups, IAM).

See [examples/terraform/secure-config.md](../examples/terraform/secure-config.md).
</terraform_standards>
````
