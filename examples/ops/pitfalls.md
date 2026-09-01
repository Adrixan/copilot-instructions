# Cross-Domain Ops Pitfalls

Anti-patterns that span Docker, Kubernetes, Terraform, and Ansible.
Domain-specific pitfalls live in each `ops-*.instructions.md` file.

1. ❌ Mutable production servers ("just patch it in place") → ✅ Immutable infrastructure: bake images, replace instances. Every change goes through Git + pipeline.
2. ❌ Secrets in Git, even "private" repos → ✅ Vault/Sealed Secrets/External Secrets Operator; `gitleaks` in pre-commit and CI.
3. ❌ `:latest` image tags in any environment → ✅ Version tags in dev, SHA digests in production.
4. ❌ Local/backend-less Terraform state shared by a team → ✅ Remote state with locking (S3+DynamoDB, TF Cloud); state per environment.
5. ❌ Hand-editing state files or running `terraform state rm` casually → ✅ `moved`/`removed` blocks and reviewed plans.
6. ❌ Broad `become: yes` / privileged containers "to make it work" → ✅ Least privilege; document every escalation; drop ALL capabilities.
7. ❌ Alerting only on "server down" → ✅ Alert on error rate >1%, P99 >500ms, saturation (USE/RED signals).
8. ❌ Dev/staging/prod drift → ✅ Environment parity: same topology, parameterized per environment.
9. ❌ Manual `kubectl apply` in production → ✅ GitOps (ArgoCD/Flux); all changes through PRs.
10. ❌ Applying without a dry run → ✅ `terraform plan`, `ansible-playbook --check --diff`, `kubectl --dry-run=server` before every production change.
