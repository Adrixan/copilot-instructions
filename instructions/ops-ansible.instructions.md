````instructions
---
applyTo: 
  - "**/ansible/**"
  - "**/playbooks/**"
---
<ansible_standards>
## Ansible

- All playbooks must be idempotent. Ansible Vault for sensitive variables. `become: yes` with documented justification.
- `--check --diff` before production runs.

**Performance:** `gather_facts: no` when unneeded. SSH pipelining for 2-5x speedup. Tune `forks`.

**Pitfalls:** Use native modules (apt, copy) for idempotency — avoid `shell` without `creates`/`changed_when`. Document `become: yes`.

**Validation:** `ansible-lint`, `ansible-playbook --check --diff`.

See [examples/ansible/secure-playbook.md](../examples/ansible/secure-playbook.md).
</ansible_standards>
````
