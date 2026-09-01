# Secure Ansible Playbook Pattern

Idempotent native modules, Vault-encrypted secrets, documented `become`, dry-run friendly.

```yaml
- name: Deploy application service
  hosts: app_servers
  become: false # escalate per-task with justification, not wholesale

  vars:
    app_user: app
    app_dir: /opt/app

  tasks:
    - name: Install service dependencies
      ansible.builtin.apt:
        name:
          - nginx
          - curl
        state: present
        update_cache: true
      become: true # required: package installation needs root

    - name: Create application user
      ansible.builtin.user:
        name: "{{ app_user }}"
        system: true
        shell: /usr/sbin/nologin
        create_home: false
      become: true # required: user management needs root

    - name: Ensure application directory exists
      ansible.builtin.file:
        path: "{{ app_dir }}"
        state: directory
        owner: "{{ app_user }}"
        mode: "0750"
      become: true # required: /opt ownership change needs root

    - name: Deploy configuration template
      ansible.builtin.template:
        src: app.conf.j2
        dest: "{{ app_dir }}/app.conf"
        owner: "{{ app_user }}"
        mode: "0640"
      notify: restart app
      # Secret values inside the template come from Vault-encrypted vars:
      #   ansible-vault encrypt_string --name 'db_password'
      # Reference as {{ vault_db_password }} — never plaintext in vars files.

  handlers:
    - name: restart app
      ansible.builtin.service:
        name: app
        state: restarted
      become: true # required: service management needs root
```

## Run

```bash
# Always dry-run before production:
ansible-playbook playbook.yml --check --diff

# Lint first:
ansible-lint playbook.yml
```
